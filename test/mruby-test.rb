class Float
	alias :to_r :to_f
end
class Integer
	alias :to_r :to_f
end

Test = MTest
include SymDesc
%w| ./test-Int.rb
    ./test-Neg.rb
    ./test-Sum.rb|.each { |f| require_relative f }
MTest::Unit.new.run