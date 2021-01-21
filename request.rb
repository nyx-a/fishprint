#! /usr/bin/env ruby

require_relative 'b.option.rb'
require_relative 'fp.query.rb'

begin
  option = B::Option.new(
    host:   'fishprint host',
    port:   'fishprint port',
    latest: 'latest entity in DB',
  )
  option.short(
    host:   'h',
    port:   'p',
    latest: 'l',
  )
  option.essential :host, :port
  option.boolean :latest
  option.make!
rescue => e
  STDERR.puts e.message
  STDERR.puts
  exit 1
end

for i in option.bare
  result = Query.request i, host:option['host'], port:option['port']
  p result
end

