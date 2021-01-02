
require_relative 'b.option.rb'
require_relative 'b.path.rb'
require_relative 'b.dhms.rb'


Option_fishprint = [
  B::Option::Property.new(
    long:        'toml',
    description: 'TOML filename (find from XDG config)',
    normalizer: -> s { B::Path.xdgfind :config, s },
    default:     'fishprint.toml',
  ),
  B::Option::Property.new(
    long:        'daemonize',
    short:       'd',
    boolean:     true,
    description: 'Run as a daemon process',
  ),
  B::Option::Property.new(
    long:        'log',
    normalizer: -> s { B::Path.xdgvisit :cache, s },
    description: 'log filename (write to XDG cache)',
    default:     'fishprint.log',
  ),
]

Option_mongo = [
  B::Option::Property.new(
    long:        'mongo.host',
    description: 'MongoDB Host',
    default:     '127.0.0.1',
  ),
  B::Option::Property.new(
    long:        'mongo.port',
    description: 'MongoDB Port',
    default:     27017,
  ),
  B::Option::Property.new(
    long:        'mongo.db',
    description: 'MongoDB Database',
    default:     'fishprint',
  ),
  B::Option::Property.new(
    long:        'mongo.user',
    description: 'MongoDB User',
  ),
  B::Option::Property.new(
    long:        'mongo.pw',
    description: 'MongoDB Password',
  ),
  B::Option::Property.new(
    long:        'mongo.auth',
    description: 'MongoDB Authorization Source',
  ),
]

Option_curl = [
  B::Option::Property.new(
    long:        'curl.agent',
    description: 'Curl User-Agent',
  ),
  B::Option::Property.new(
    long:        'curl.retry_plan',
    description: 'Curl Retry delay(s)',
    normalizer: -> s { s.split(',').map{ B::dhms2sec _1 } },
    default:     '1sec,3sec',
  ),
  B::Option::Property.new(
    long:        'curl.connect_timeout',
    description: 'Curl connect_timeout',
    normalizer: -> s { B::dhms2sec s },
    default:     '90sec',
  ),
  B::Option::Property.new(
    long:        'curl.timeout',
    description: 'Curl timeout',
    normalizer: -> s { B::dhms2sec s },
    default:     '5min',
  ),
  B::Option::Property.new(
    long:        'curl.max_redirects',
    description: 'Curl max_redirects',
    normalizer:  :to_integer,
    default:     20,
  ),
  B::Option::Property.new(
    long:        'curl.cookiejar',
    description: 'Curl Cookiejar filename (write to XDG cache)',
    normalizer: -> s { B::Path.xdgvisit :cache, s },
    default:     'fishprint.cookies.txt',
  ),
]

Option_sinatra = [
  B::Option::Property.new(
    long:        'sinatra.bind',
    description: 'Sinatra Bind ',
    default:     '0.0.0.0',
  ),
  B::Option::Property.new(
    long:        'sinatra.port',
    description: 'Sinatra Port',
    default:     33333,
  ),
]

