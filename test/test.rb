if RUBY_ENGINE == "ruby"
require "simplecov"

SimpleCov.start
require "test/unit"
require_relative "../lib/SymDesc.rb"

include SymDesc
end