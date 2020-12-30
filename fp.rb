
module FP
  # Request / POST Field
  Q_REFERER     = 'referer'         # URL
  Q_TARGET      = 'target'          # URL
  Q_AGENT       = 'agent'           # User Agent
  Q_DATE_S      = 'date_start'      # Float unix time
  Q_DATE_E      = 'date_end'        # Float unix time
  Q_INCLUDE_S   = 'include_start'   # bool true:<= false:<
  Q_INCLUDE_E   = 'include_end'     # bool true:>= false:>
  Q_ALLOW_FETCH = 'allow_fetch'     # bool allow new fetch when N/A

  # Answer / HTTP Header
  A_PREFIX             = 'Fishprint-'
  A_DATE               = "#{A_PREFIX}Date" # Float unix time
  A_URL                = "#{A_PREFIX}Url"
  A_LAST_EFFECTIVE_URL = "#{A_PREFIX}Last-Effective-Url"
  A_RESPONSE_CODE      = "#{A_PREFIX}Response-Code"
  A_NEW_URL            = "#{A_PREFIX}New-Url"
  A_NEW_BODY           = "#{A_PREFIX}New-Body"

  def self.parse_header str
    leftend = Regexp.new('^' + Regexp.escape(A_PREFIX))
    str.lines(chomp:true).grep(leftend).to_h do |l|
      l =~ /:/
      k = $~.pre_match.delete_prefix(A_PREFIX).strip
      v = $~.post_match.strip.downcase
      [k, v]
    end
  end
end

