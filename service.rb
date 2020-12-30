#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative 'fp.option.rb'
require_relative 'fp.server.rb'

begin
  OPT.parse ARGV
  cfg = B::Path::find_first_config OPT[:config]
  if cfg
    OPT.yaml_underlay cfg
  end
rescue => e
  STDERR.puts e.message
  STDERR.puts
  exit 1
end

fp = FishPrint.new(
  **OPT.slice(
    :agent,
    :connect_timeout,
    :timeout,
    :max_redirects,
    :cookiejar,
    :retry_plan,
    :server,
    :db,
    :user,
    :password,
    :auth
  )
)

ARGV.clear

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

require 'sinatra'
require 'sinatra/reloader'

set :bind, OPT[:s_host]
set :port, OPT[:s_port]

post '/fetch' do
  result = fp.get(
    request.params[FP::Q_TARGET],
    referer: request.params[FP::Q_REFERER],
    agent:   request.params[FP::Q_AGENT],
  )
  if result.nil?
    body ''
  else
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
  fp.find_urls.map do |i|
    "#{i['_id']} - #{i['url']}<br>\n"
  end.join
end

get '/m/?' do
  fp.find_moments.map do |i|
    "#{i['date'].localtime} - #{fp.url_id2s i['url']} - #{fp.url_id2s i['last_effective_url']} - #{decode_digest i['sha256']}<br>"
  end.join
end

get '/u/:oid' do |oid|
  fp.find_moments(url:BSON::ObjectId.from_string(oid)).map do |i|
    "#{i[:date]} #{decode_digest i[:sha256]}<br>"
  end.join
end

get '/d/:hex' do |hex|
  fp.download(hex)
end
