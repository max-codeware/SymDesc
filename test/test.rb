
require "test/unit"

%w| ../lib/SymDesc.rb
    test-Ratio.rb 
  |.each do |file|
  	    require_relative file 
  	end