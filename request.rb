#! /usr/bin/env ruby

require 'time'
require_relative 'b.option.rb'
require_relative 'fp.query.rb'

begin
  option = B::Option.new(
    host:          'fishprint host',
    port:          'fishprint port',
    referer:       '',
    agent:         '',
    date_start:    '',
    date_end:      '',
    include_start: '',
    include_end:   '',
    edge:          'oldest or latest',
  )
  option.short(
    host: 'h',
    port: 'p',
    edge: 'e',
  )
  option.default(
    host: '192.168.0.100',
    port: 33333,
  )
  option.normalizer(
    edge:       -> { Query::Edge.new _1.to_sym },
    date_start: -> { Time.parse _1 },
    date_end:   -> { Time.parse _1 },
  )
  option.boolean :include_start, :include_end
  option.make!
rescue => e
  STDERR.puts e.message
  STDERR.puts
  exit 1
end

query = Query.new(**option.except(:host, :port, :toml, :help))

for i in option.bare
  query.target = i
  p query.post host:option['host'], port:option['port']
end

