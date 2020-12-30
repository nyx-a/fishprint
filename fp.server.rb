
require 'openssl'
require 'curb'
require 'mongo'
require_relative 'b.structure.rb'
require_relative 'b.dhms.rb'
require_relative 'fp.rb'

Mongo::Logger.logger.level = Logger::ERROR



# "Hexadecimal" -> BSON::Binary(Hexadecimal)
def encode_digest s
  BSON::Binary.new s.scan(/../).map{ _1.to_i(16).chr }.join
end

# "data" -> BSON::Binary(SHA256)
def calc_digest b
  encode_digest Digest::SHA256.hexdigest b
end

# BSON::Binary(Hexadecimal) -> "Hexadecimal"
def decode_digest b
  b.data.bytes.map{ '%02x' % _1 }.join
end



class FishPrint

  def initialize(
    agent:nil,
    connect_timeout:,
    timeout:,
    max_redirects:,
    cookiejar:,
    retry_plan:,
    server:,
    db:,
    user:nil,
    password:nil,
    auth:nil
  )
    @agent           = agent
    @connect_timeout = connect_timeout
    @timeout         = timeout
    @max_redirects   = max_redirects
    @cookiejar       = cookiejar
    @retry_plan      = retry_plan

    @client = Mongo::Client.new(
      [server],
      database:    db,
      user:        user,
      password:    password,
      auth_source: auth,
    )

    @urls    = @client['urls']
    @digests = @client['digests']
    @moments = @client['moments']
    @errors  = @client['errors']
    @bucket  = Mongo::Grid::FSBucket.new @client
  end

  def get1 uri, count:, referer:nil, agent:nil
    # r is Curl::Easy
    r = Curl.get uri do |x|
      x.timeout            = @timeout
      x.connect_timeout    = @connect_timeout
      x.follow_location    = true
      x.max_redirects      = @max_redirects
      x.fetch_file_time    = true
      x.useragent          = agent || @agent || nil
      x.headers['Referer'] = referer if referer
      x.enable_cookies     = true
      x.cookiefile         = @cookiejar
      x.cookiejar          = @cookiejar
    end
    new_url = is_unknown_url? uri
    # fpr is Fishprint::Result
    fpr = save_data uri, r.body, {
      response_code:       r.response_code,
      primary_ip:          r.primary_ip,
      file_time:           (r.file_time==-1 ? nil : Time.at(r.file_time)),
      last_effective_url:  get_urlid(r.last_effective_url),
      redirect_count:      r.redirect_count,
      redirect_time:       r.redirect_time,
      name_lookup_time:    r.name_lookup_time,
      connect_time:        r.connect_time,
      app_connect_time:    r.app_connect_time,
      pre_transfer_time:   r.pre_transfer_time,
      start_transfer_time: r.start_transfer_time,
      total_time:          r.total_time,
      download_speed:      r.download_speed,
      count:               count,
      head:                r.head,
    }
    return Result.new(
      date:               fpr.date,
      body:               r.body,
      url:                uri,
      last_effective_url: r.last_effective_url,
      response_code:      r.response_code,
      new_url:            new_url,
      new_body:           fpr.new_body,
    )
  end

  def get uri, referer:nil, agent:nil
    @retry_plan.each_with_index do |wait,cnt|
      cnt += 1 # should be 1 origin
      begin
        tstart = Time.now
        result = get1 uri, count:cnt, referer:referer, agent:agent
        if result.response_code == 200
          return result # <- Fishprint::Result
        end
      rescue Exception => err
        save_error uri, err.class.name, cnt, tstart
      end
      sleep wait
    end
    return nil
  end

  def save_error src, ex, cnt, start_time, end_time=Time.now
    @errors.insert_one(
      url:             get_urlid(src),
      date:            end_time,
      total_time:      (end_time - start_time),
      exception:       ex,
      count:           cnt,
      retry_plan:      @retry_plan,
      agent:           @agent,
      connect_timeout: @connect_timeout,
      timeout:         @timeout,
      max_redirects:   @max_redirects,
    )
  end

  def save_data src, blob, metadata={ }
    isnew  = false
    sha256 = calc_digest blob # BSON::Binary
    date   = Time.now
    @moments.insert_one(
      {
        url:    get_urlid(src),
        sha256: sha256,
        date:   date,
      }.merge(metadata)
    )
    if first_digest sha256
      isnew = true
      @bucket.upload_from_stream(
        decode_digest(sha256),
        blob,
        sha256:sha256
      )
    end
    return Result.new(
      date:     date,
      new_body: isnew,
    )
  end

  # returns true <- if it is first insert <- before is nil
  def first_digest digest
    not @digests.find_one_and_update(
      { _id: digest }, # insert digest as ID
      { },             # update nothing
      {
        upsert: true,
        return_document: :before,
      }
    )
  end

  def get_urlid url
    after = @urls.find_one_and_update(
      { url:url },
      { '$setOnInsert': { url:url } },
      {
        upsert: true,
        return_document: :after,
      }
    )
    after['_id'] # BSON::ObjectId
  end

  def download sha256
    obj = @bucket.find(filename:sha256).first
    if obj
      s = String.new
      @bucket.download_to_stream obj[:_id], s
      s
    end
  end

  # url may be Regexp or String
  def is_unknown_url? url
    @urls.count_documents(url:url) == 0
  end

  def url_id2s id
    @urls.find('_id':id).to_a.last['url']
  end

  def find_urls q=nil
    @urls.find q
  end

  def find_buckets q=nil
    @bucket.find q
  end

  def find_moments q=nil
    @moments.find q
  end

  def find_digests q=nil
    @digests.find q
  end

  class Result < B::Structure
    attr_accessor :date
    attr_accessor :body
    attr_accessor :url
    attr_accessor :last_effective_url
    attr_accessor :response_code
    attr_accessor :new_url
    attr_accessor :new_body
  end
end

