#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative 'fp.option.rb'
require_relative 'fp.fishprint.rb'
require_relative 'fp.query.rb'
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

binding.irb

