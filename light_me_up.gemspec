# frozen_string_literal: true

require_relative "lib/light_me_up/version"

Gem::Specification.new do |spec|
  spec.name = "light_me_up"
  spec.version = LightMeUp::VERSION
  spec.authors = ["Peter McCracken"]
  spec.email = ["peter@petermccracken.com"]

  spec.summary = "Command line control for a brand name key light."
  spec.description = "Provides the ability to turn on and off, and adjust brightness and temperature, on a key light."
  spec.homepage = "https://github.com/peterjm/light_me_up"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/peterjm/light_me_up"
  spec.metadata["changelog_uri"] = "https://github.com/peterjm/light_me_up/CHANGELOG.md"

  spec.files = [
    "lib/light_me_up/version.rb",
    "lib/light_me_up.rb",
  ]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
end
