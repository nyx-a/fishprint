#! /usr/bin/env ruby

require_relative 'fp.client.rb'

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
  result = FP.request( i, host:option['host'], port:option['port'] )
  p result.class
  p result
end

