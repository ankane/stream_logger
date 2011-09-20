# -*- encoding: utf-8 -*-
require File.expand_path("../lib/stream_logger/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Kane"]
  gem.email         = ["andrew@getformidable.com"]
  gem.description   = %q{Logs are streams, not files}
  gem.summary       = %q{StreamLogger is a super-lightweight logging library that logs to `stdout`.}
  gem.homepage      = "https://github.com/ankane/stream_logger"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "stream_logger"
  gem.require_paths = ["lib"]
  gem.version       = StreamLogger::VERSION
end
