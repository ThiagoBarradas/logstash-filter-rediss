Gem::Specification.new do |s|
  s.name            = 'logstash-filter-rediss'
  s.version         = '1.0.3'
  s.licenses        = ['MIT']
  s.summary         = "Redis (with SSL) Filter for Logstash"
  s.description     = "A Logstash filter plugin for storing and retrieving data from redis cache. This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gem_name. This gem is not a stand-alone program."
  s.authors         = ["Thiago Barradas", "Bruno Sales", "David Robakowski"]
  s.email           = 'th.barradas@gmail.com'
  s.homepage        = "https://github.com/thiagobarradas/logstash-filter-rediss"
  s.require_paths   = ["lib"]
  s.platform        = Gem::Platform::JAVA if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE']
   
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency 'redis', '~> 3.3', '>= 3.3.3'
  s.add_runtime_dependency 'redlock', '~> 0.2', '>= 0.2.0'
  s.add_development_dependency 'logstash-devutils', '~> 0'
end
