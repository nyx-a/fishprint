
require 'addressable'
require 'nokogiri'
require 'mime-types'
require_relative '../b.structure.rb'
require_relative '../fp.query.rb'
require_relative '../fp.inquiry.rb'


# -> Array[ Addressable::URI ]
def extract result, tag:'a', attr:'href', grep:nil
  base = Addressable::URI.parse result.last_effective_url
  doc = Nokogiri::HTML result.body
  relstr = doc.css(tag).map{ _1&.attr(attr) }.compact.uniq
  if grep
    relstr = relstr.grep Regexp.new grep
  end
  links = relstr.map{ base + _1.strip rescue nil }.compact
  links.delete base
  links.select{ _1.scheme =~ /https?/i }
end

# -> Array[ Addressable::URI ]
def filter_binaries links
  mimehtml = [
    MIME::Type.new('text/html'),
    MIME::Type.new('application/x-httpd-php'),
  ]
  links.select do
    (MIME::Types.of(_1.to_s) - mimehtml).any? &:binary?
  end
end


class Skimmer < B::Structure
  attr_accessor :host
  attr_accessor :port
  attr_accessor :verbose
  attr_accessor :force

  def initialize host:, port:, **other
    super
    @inquiry = Inquiry.new host:@host, port:@port
  end

  def is_unknown_uri? o
    @inquiry.is_unknown_uri? o
  end

  def is_unknown_digest? o
    @inquiry.is_unknown_digest? o
  end

  # -> Result / nil
  def get target, **option
    q = Query.new(target:target, **option)
    print q.target, ' ' if @verbose
    r = q.post host:@host, port:@port
    @verbose ? p(r) : r
  end

  # -> Result / nil
  def skim target, **option
    r = get(target, **option)
    a = [ ]
    a.concat extract r, tag:'img', attr:'src'
    a.concat extract r, tag:'img', attr:'data-src'
    a.concat filter_binaries extract r
    a.each do
      if @force or !@inquiry.uri?(_1)
        get _1, referer:target
      end
    end
    return r
  end
end

