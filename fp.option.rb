
require_relative 'b.option.rb'
require_relative 'b.path.rb'
require_relative 'b.dhms.rb'

Option_fishprint = [
  B::Option::Property.new(
    long:        'toml',
    description: 'TOML filename (find it from XDG config)',
    normalizer: -> s { B::Path.find_first_config s },
    default:     'fishprint.toml',
  ),
  B::Option::Property.new(
    long:        'daemonize',
    boolean:     true,
    description: 'Run as a daemon process',
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
    default:     '1sec,5sec,1min,5min',
  ),
  B::Option::Property.new(
    long:        'curl.connect_timeout',
    description: 'Curl connect_timeout',
    normalizer: -> s { B::dhms2sec s },
    default:     '1min',
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
    default:     10,
  ),
  B::Option::Property.new(
    long:        'curl.cookiejar',
    description: 'Curl Cookiejar file path',
    normalizer: -> s { B::Path.new s },
    default:     'cookies.fishprint.txt',
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

