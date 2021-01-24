
require 'curb'
require_relative 'b.structure.rb'
require_relative 'b.enum.rb'
require_relative 'fp.result.rb'


# Query ( POST Field )
class Query < B::Structure

  Edge = B::Enum.new :oldest, :latest

  KEYS = [
    :target,
    :referer,
    :agent,
    :date_start,    # Float unix time
    :date_end,      # Float unix time
    :include_start, # bool true:<= false:<
    :include_end,   # bool true:>= false:>
    :edge,          # Edge
  ].freeze
  KEYS.each{ attr_accessor _1 }

  def edge= o
    @edge = o ? Edge.new(o.to_sym) : nil
  end

  def ranged?
    @date_start or @date_end or @edge
  end

  # local (old)
  def reproduce fp
    fp.reproduce(
      @target,
      s:     @date_start,
      is:    @include_start,
      e:     @date_end,
      ie:    @include_end,
      desc:  (@edge==:oldest ? false : true ),
    )
  end

  # local (new)
  def get fp
    fp.get @target, referer:@referer, agent:@agent
  end

  def inspect
    compact
      .sort_by{ |k,v| KEYS.index k }
      .map{ |k,v| "#{k}:#{v}" }
      .join("\n")
  end

  def post host:, port:
    f = self.compact.map do |k,v|
      Curl::PostField.content k, v.to_s
    end
    r = Curl::Easy.http_post("#{host}:#{port}/fetch", *f)
    result = Result.new body:r.body
    result.read_header! r.head
    return result
  end

end

