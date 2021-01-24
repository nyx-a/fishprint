
require 'time'
require_relative 'b.structure.rb'


# Query Result
# received embedded in the http header

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

  attr_reader   :date
  attr_accessor :body
  attr_accessor :url
  attr_accessor :last_effective_url
  attr_accessor :response_code
  attr_reader   :new_url
  attr_reader   :new_body

  def date= o
    @date = Time.parse o
  end

  def new_url= o
    @new_url = case o
               when /true/i  then true
               when /false/i then false
               else
                 raise
               end
  end

  def new_body= o
    @new_body = case o
                when /true/i  then true
                when /false/i then false
                else
                  raise
                end
  end

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
      (@new_url ? '<<NewURL>>' : nil),
      (@new_body ? '<<NewBODY>>' : nil),
    ].compact.join(' ')
  end
end

