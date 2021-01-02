#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative 'fp.option.rb'
require_relative 'fp.fishprint.rb'
require_relative 'fp.literal.rb'
require_relative 'b.log.rb'

begin
  option = B::Option.new
  option.register Option_fishprint
  option.register Option_mongo
  option.register Option_curl
  option.register Option_sinatra
  option.make!
rescue => e
  STDERR.puts e.message
  STDERR.puts
  exit 1
end

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

log = B::Log.new file:option[:log]
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
  rurl = request.params[FP::Q_TARGET]
  rref = request.params[FP::Q_REFERER]
  ragt = request.params[FP::Q_AGENT]
  log.i "<< #{rurl} (r:#{rref}) (a:#{ragt})"
  result = fishprint.get rurl, referer:rref, agent:ragt
  if result.nil?
    log.i ">> (empty)"
    body ''
  else
    log.i ">> status:#{result.response_code} body:#{result.body.size}"
    headers[FP::A_DATE]               = result.date.to_f.to_s
    headers[FP::A_URL]                = result.url
    headers[FP::A_LAST_EFFECTIVE_URL] = result.last_effective_url
    headers[FP::A_RESPONSE_CODE]      = result.response_code.to_s
    headers[FP::A_NEW_URL]            = result.new_url.to_s
    headers[FP::A_NEW_BODY]           = result.new_body.to_s
    body result.body
  end
end

get '/form' do
  [
    '<form method="post" action="/fetch">',
    %Q(  <input type="text" name="#{FP::Q_TARGET}">),
    %Q(  <input type="text" name="#{FP::Q_AGENT}">),
    '<input type="submit" value="魚拓">',
    '</form>',
  ].join
end

get '/u/?' do
  fishprint.find_urls.map do |i|
    "#{i['_id']} - #{i['url']}<br>\n"
  end.join
end

get '/m/?' do
  fishprint.find_moments.map do |i|
    "#{i['date'].localtime} - #{fishprint.url_id2s i['url']} - #{fishprint.url_id2s i['last_effective_url']} - #{decode_digest i['sha256']}<br>"
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

