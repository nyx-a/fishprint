
require 'curb'
require_relative 'b.structure.rb'
require_relative 'fp.literal.rb'
require_relative 'fp.option.rb'

module FP
  class Result < B::Structure
    attr_accessor :head
    attr_accessor :body
    attr_accessor :meta
    def inspect
      "Head:#{@head.size} Body:#{@body.size} Meta:#{@meta.inspect}"
    end
  end

  def self.parse_header str
    leftend = Regexp.new('^' + Regexp.escape(A_PREFIX))
    str.lines(chomp:true).grep(leftend).to_h do |l|
      l =~ /:/
      k = $~.pre_match.delete_prefix(A_PREFIX).strip
      v = $~.post_match.strip.downcase
      [k, v]
    end
  end

  def self.request url, host:, port:, referer:nil, agent:nil
    f = [ ]
    f.push Curl::PostField.content(FP::Q_TARGET, url)
    f.push Curl::PostField.content(FP::Q_REFERER, referer) if referer
    f.push Curl::PostField.content(FP::Q_AGENT, agent) if agent
    r = Curl::Easy.http_post("#{host}:#{port}/fetch", *f)
    Result.new(
      head: r.head,
      body: r.body,
      meta: FP.parse_header(r.head),
    )
  end
end

