lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spiketime/version'

Gem::Specification.new do |s|
  s.name          = 'spiketime'
  s.version       = Spiketime::VERSION
  s.authors       = ['UCM Agency']
  s.email         = ['info@ucastme.de']
  s.summary       = 'Simple wrapper around spiketime API, which provides german holidays'
  s.description   = 'Simple wrapper around spiketime API, which provides german holidays'
  s.homepage      = ''
  s.license       = 'MIT'

  s.files         = Dir['lib/**/*.rb', 'spec/**/*']
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'oj', '~> 3.7', '>= 3.7.9'
  s.add_dependency 'redis', '~> 4.1'

  s.add_development_dependency 'bundler', '~> 1.17.2'
  s.add_development_dependency 'mock_redis', '~> 0.19.0'
  s.add_development_dependency 'rake', '~> 12.3', '>= 12.3.2'
  s.add_development_dependency 'rspec', '~> 3.8'
  s.add_development_dependency 'rubocop', '~> 0.65.0'
end
