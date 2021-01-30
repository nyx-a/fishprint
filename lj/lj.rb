#! /usr/bin/env ruby

$LOAD_PATH.push '.', '..'

require 'addressable'
require 'nokogiri'
require 'filemagic/ext'
require 'mime-types'
require 'colorize'
require 'b.option.rb'
require 'fp.query.rb'
require 'fp.inquiry.rb'
require 'item.rb'

#
#* tuple like class
#

class FishPrintServer
  attr_accessor :host
  attr_accessor :port

  FM = FileMagic.new FileMagic::MAGIC_MIME_TYPE

  def initialize slh # something like a hash
    @host = slh['host']
    @port = slh['port']
    @inquiry = Inquiry.new host:@host, port:@port
  end

  def to_hash
    { host:@host, port:@port }
  end

  # -> Result or nil
  def request target, **option
    print "#{target} ... "
    sleep 1 ####
    r = Query.new(target:target, **option).post(**self)
    if r
      img = extract r, 'img', 'src'
      bin = link_binaries r
      for lnk in img + bin
        unless @inquiry.uri? lnk
          print lnk.to_s.colorize(:yellow), ' '
          p Query.new(target:lnk, **option).post(**self)
          sleep 1
        end
      end
    end
    return r
  end

end



# -> Array[ Addressable::URI ]
def extract result, tag='a', attr='href'
  base = Addressable::URI.parse result.url
  doc = Nokogiri::HTML result.body
  doc.css(tag).map{
    a = _1&.attr(attr)
    a ? (base + a) : nil
  }.compact.uniq - [base]
end

# -> Array[ Addressable::URI ]
def link_binaries result
  links = extract(result).select{ _1.scheme =~ /https?/i }
  texthtml = MIME::Type.new('text/html')
  links.select do
    (MIME::Types.of(_1.to_s) - [texthtml]).any? &:binary?
  end
end

def follow item, server, previous=nil
  if item.line == nil or item.line.chr == '*'
    item.children&.each{ follow _1, server, previous }
  elsif previous.nil?
    current = server.request item.line
    if current&.body&.content_type == 'text/html'
      item.children&.each{ follow _1, server, current }
    end
  else
    anchor = extract(previous).select{ _1.scheme =~ /https?/i }
    for l in anchor.grep Regexp.new item.line
      current = server.request l, referer:previous.url
      if current&.body&.content_type == 'text/html'
        item.children&.each{ follow _1, server, current }
      end
    end
  end
end

#
#* main
#

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

fps = FishPrintServer.new option

if option[:irb]
  binding.irb
else
  for f in option.bare
    root = Item.new.parse open(f).read
    p root
    follow root, fps
  end
end

