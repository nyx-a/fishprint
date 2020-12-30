
require_relative 'b.option.rb'
require_relative 'b.dhms.rb'

OPT = B::Option.new(
  # mongo
  server:          String,
  db:              String,
  user:            String,
  password:        String,
  auth:            String,

  # curl
  agent:           String,
  retry_plan:      String,
  connect_timeout: Numeric,
  timeout:         Numeric,
  max_redirects:   Integer,
  cookiejar:       String,
  config:          String,

  # sinatra
  s_host:          String,
  s_port:          Integer,
)
OPT.normalizer retry_plan: -> str do
  str.split(',').map(&:strip).map{ B::dhms2sec _1 }
end
OPT.default(
  server:          '127.0.0.1',
  db:              'fishprint',
  retry_plan:      '10sec,1min,15min',
  connect_timeout: 60,
  timeout:         3600,
  max_redirects:   10,
  cookiejar:       'cookies.fishprint.txt',
  config:          'fishprint.yml',
  s_host:          'localhost',
  s_port:          33333,
)
OPT.short(
  config:          'c',
  retry_plan:      'r',
)
OPT.description(
  server:          'Mongo Server',
  db:              'Mongo Database',
  user:            'Mongo User',
  password:        'Mongo Password',
  auth:            'Mongo Authorization Source',
  agent:           'Curl  User-Agent',
  connect_timeout: 'Curl  Timeout for connection',
  timeout:         'Curl  Timeout',
  max_redirects:   'Curl  Redirect limit',
  retry_plan:      'Retry plan in dhms strings',
  cookiejar:       'Cookie jar',
  config:          'Load YML file from XDG config dir (if exists)',
  s_host:          'sinatra host',
  s_port:          'sinatra listen port',
)

