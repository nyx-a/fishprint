
require_relative 'b.structure.rb'


# Query Result
# sent/received embedded in the http header

class Result < B::Structure

  HeaderPrefix = 'Fishprint-'.freeze

  def self.parse_header str
    leftend = Regexp.new('^' + Regexp.escape(HeaderPrefix))
    str.lines(chomp:true).grep(leftend).to_h do |l|
      l =~ /:/
      k = $~.pre_match.delete_prefix(HeaderPrefix).downcase.strip
      v = $~.post_match.strip
      [k, v]
    end
  end

  attr_accessor :date
  attr_accessor :body
  attr_accessor :url
  attr_accessor :last_effective_url
  attr_accessor :response_code
  attr_accessor :new_url
  attr_accessor :new_body

  # -> Hash
  def compose_header
    self.except(
      :body,
      k:->{ "#{HeaderPrefix}#{_1.capitalize}" },
      v:'to_s'
    )
  end

  def read_header! header
    set!(**self.class.parse_header(header))
  end

  def inspect
    [
      "Status:#{@response_code}",
      "BodySize:#{@body&.size}",
      "NewURL:#{@new_url.inspect}",
      "NewBody:#{@new_body.inspect}",
    ].join(' ')
  end
end

