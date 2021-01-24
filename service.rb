#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative 'fp.option.rb'
require_relative 'fp.fishprint.rb'
require_relative 'fp.query.rb'
require_relative 'fp.result.rb'
require_relative 'b.log.rb'

option = B::Option.new
option.register Option_fishprint
option.register Option_mongo
option.register Option_curl
option.register Option_sinatra
option.make!

fishprint = FishPrint.new(
  agent:           option['curl.agent'],
  connect_timeout: option['curl.connect_timeout'],
  timeout:         option['curl.timeout'],
  max_redirects:   option['curl.max_redirects'],
  cookiejar:       option['curl.cookiejar'],
  retry_plan:      option['curl.retry_plan'],
  server:          option['mongo.host'],
  db:              option['mongo.db'],
  user:            option['mongo.user'],
  password:        option['mongo.pw'],
  auth:            option['mongo.auth']
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

lp = B::Path.xdgvisit('log.fishprint.log', :cache)
log = B::Log.new file:lp

Process.daemon true if option[:daemonize]
log.i "Process started. PID=#{$$}"
at_exit do
  log.i "Process terminated. PID=#{$$}"
  log.gap
end

require 'sinatra'

set :bind, option['sinatra.bind']
set :port, option['sinatra.port']

post '/fetch' do
  begin
    q = Query.new(**request.params)
    log.i "#{q.inspect}"
    unless q.target.is_a? String
      log.f "URL isn't String"
      body ""
      next
    end
    result = if q.ranged?
               q.reproduce fishprint
             else
               q.get fishprint
             end

    if result.nil?
      log.i "> (empty)"
      body ''
    else
      log.i "> #{result.inspect}"
      for k,v in result.compose_header
        headers[k] = v
      end
      body result.body
    end
  rescue ArgumentError => ex
    log.e ex.message
  rescue Exception => ex
    log.f ex.message
  end
end

get '/u/?' do
  fishprint.find_urls.map do |i|
    "#{i['_id']} - #{i['url']}<br>\n"
  end.join
end

get '/m/?' do
  fishprint.find_moments.map do |i|
    "#{i['date'].localtime} - #{fishprint.url_id2s i['url']} - #{fishprint.url_id2s i['last_effective_url']} ( #{i['response_code']} ) #{decode_digest i['sha256']}<br>"
  end.join
end

get '/u/:oid' do |oid|
  fishprint.find_moments(url:BSON::ObjectId.from_string(oid)).map do |i|
    "#{i[:date]} #{decode_digest i[:sha256]}<br>"
  end.join
end

get '/d/:hex' do |hex|
  fishprint.download(hex)
end

