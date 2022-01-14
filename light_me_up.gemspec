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
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.executables = ["light-me-up"]
  spec.test_files = spec.files.grep(%r{\Atest/})
  spec.require_paths = ["lib"]

  spec.add_dependency "optimist", "~> 3.0"
end
