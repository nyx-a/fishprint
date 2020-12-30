
require 'curb'
require_relative 'fp.rb'
require_relative 'b.structure.rb'

module FP
  class Result < B::Structure
    attr_accessor :head
    attr_accessor :body
    attr_accessor :meta
    def inspect
      "head:#{@head.size} body:#{@body.size} meta:#{@meta.inspect}"
    end
  end

  def self.fetch target, host:, port:, referer:nil, agent:nil
    f = [ ]
    f.push Curl::PostField.content(FP::Q_TARGET, target)
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

