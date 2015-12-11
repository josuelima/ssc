lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ssc/version'

Gem::Specification.new do |spec|
  spec.name          = "ssc"
  spec.version       = SSC::VERSION
  spec.authors       = ['Josue Lima']
  spec.email         = ['josuedsi@gmail.com']

  spec.summary       = %q{Simple CLI tool to schedule EC2/ECS instances start and stop}
  spec.homepage      = 'https://github.com/josuelima/ssc'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk', '~> 2'
  spec.add_dependency 'colorize', '0.7.7'
  spec.add_dependency 'ruby-progressbar', '1.7.5'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end

