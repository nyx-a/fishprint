#! /usr/bin/env ruby

require 'addressable'
require 'nokogiri'
require 'filemagic/ext'
require 'colorize'
require_relative '../b.option.rb'
require_relative '../fp.query.rb'
require_relative '../fp.inquiry.rb'
require_relative 'item.rb'
require_relative 'skimmer.rb'


def follow item, skimmer, previous=nil
  if item.line == nil or item.line.chr == '*'
    item.children&.each{ follow _1, skimmer, previous }
  elsif previous.nil?
    current = skimmer.skim item.line
    if current&.body&.content_type == 'text/html'
      item.children&.each{ follow _1, skimmer, current }
    end
  else
    anchor = extract(previous).select{ _1.scheme =~ /https?/i }
    for l in anchor.grep Regexp.new item.line
      current = skimmer.skim l, referer:previous.url
      if current&.body&.content_type == 'text/html'
        item.children&.each{ follow _1, skimmer, current }
      end
    end
  end
end

option = B::Option.new(
  host: 'fishprint host',
  port: 'fishprint port',
  irb:  'REPL',
)
option.short(
  host: 'h',
  port: 'p',
  irb:  'i',
)
option.boolean :irb
option.default(
  host: '192.168.0.100',
  port: '33333',
)
option.make!

fps = Skimmer.new(**option.slice(:host,:port))

if option[:irb]
  binding.irb
else
  for f in option.bare
    root = Item.new.parse open(f).read
    p root
    follow root, fps
  end
end

