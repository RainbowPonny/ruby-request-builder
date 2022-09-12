lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'lib/request/builder/version'

Gem::Specification.new do |spec|
  spec.name          = "request-builder"
  spec.version       = Request::Builder::VERSION
  spec.authors       = ["Anton Kostyuk"]
  spec.email         = ["anton.kostuk.2012@gmail.com"]

  spec.summary       = %q{Request DSL}
  spec.description   = %q{Request DSL}
  spec.homepage      = "https://github.com/RainbowPonny/request-builder"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/RainbowPonny/request-builder"

  spec.files         = Dir["CHANGELOG.md", "LICENSE", "README.md", "request-builder.gemspec", "lib/**/*"]
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 1.7.1"
  spec.add_dependency "dry-schema", "~> 1.9"
  spec.add_dependency "dry-initializer", "~> 3.0"

  spec.add_runtime_dependency 'activesupport', '~> 5.0'
end
