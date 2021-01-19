
require_relative 'b.structure.rb'


# Request / POST Field
class Query < B::Structure
  KEYS = [
    :target,
    :referer,
    :agent,
    :date_start,    # Float unix time
    :date_end,      # Float unix time
    :include_start, # bool true:<= false:<
    :include_end,   # bool true:>= false:>
    :edge,          # "oldest" or "latest"
  ].freeze
  KEYS.each{ attr_accessor _1 }

  def get fp
    fp.get @target, referer:@referer, agent:@agent
  end

  def ranged?
    @date_start or @date_end or @edge
  end

  def inspect
    to_h.compact
      .sort_by{ |k,v| KEYS.index k }
      .map{ |k,v| "#{k}:#{v}" }
      .join(' ')
  end
end









# Answer / HTTP Header
A_PREFIX             = 'Fishprint-'
A_DATE               = "#{A_PREFIX}Date" # Float unix time
A_URL                = "#{A_PREFIX}Url"
A_LAST_EFFECTIVE_URL = "#{A_PREFIX}Last-Effective-Url"
A_RESPONSE_CODE      = "#{A_PREFIX}Response-Code"
A_NEW_URL            = "#{A_PREFIX}New-Url"
A_NEW_BODY           = "#{A_PREFIX}New-Body"
