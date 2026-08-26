#!/usr/bin/env bash
set -euo pipefail

ruby <<'RUBY'
module UI
  def self.user_error!(message)
    raise message
  end
end

def platform(*)
  yield
end

def desc(*); end
def lane(*); end

load "ios/fastlane/Fastfile"

Dir.chdir("ios/fastlane") do
  ENV["{{ENV_PREFIX}}_XCODE_PROJECT"] = "ios/{{PROJECT_NAME_PASCAL}}.xcodeproj"
  resolved = xcode_container_path("{{ENV_PREFIX}}_XCODE_PROJECT")
  expected = File.expand_path("../../ios/{{PROJECT_NAME_PASCAL}}.xcodeproj")

  raise "expected #{expected}, got #{resolved}" unless resolved == expected
end
RUBY

echo "Fastlane Xcode path resolution tests passed."
