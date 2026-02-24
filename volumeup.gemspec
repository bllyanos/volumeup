lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'volumeup/version'

Gem::Specification.new do |spec|
  spec.name          = 'volumeup'
  spec.version       = VolumeUp::VERSION
  spec.authors       = ['Your Name']
  spec.email         = ['your.email@example.com']

  spec.summary       = 'Docker volume backup manager'
  spec.description   = 'A CLI tool for backing up and restoring Docker volumes'
  spec.homepage      = 'https://github.com/yourusername/volumeup'
  spec.license       = 'MIT'

  spec.files         = Dir.glob('{bin,lib}/**/*') + %w[README.md Gemfile volumeup.gemspec]
  spec.bindir        = 'bin'
  spec.executables   = ['volumeup']
  spec.require_paths = ['lib']

  spec.add_dependency 'base64', '~> 0.1'
  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'docker-api', '~> 2.0'
  spec.add_dependency 'thor', '~> 1.5'
  spec.add_dependency 'tty-progressbar', '~> 0.18'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0.14'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
end
