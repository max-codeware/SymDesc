module SymDesc
	
	class RecursionError < SystemStackError; end
	class SymDescError   < StandardError   ; end

	SYM_CONFIG = {
        :ratio_precision => 1e-16
	}

	%w|
	       SymDesc/Base.rb 
	       SymDesc/Variable.rb 
	       SymDesc/Overload/Numeric.rb 
	       SymDesc/Overload/Object.rb 
	       SymDesc/Overload/Symbol.rb 
	       SymDesc/Number/Number.rb 
	       SymDesc/Number/Int.rb 
	       SymDesc/Number/Ratio.rb
	  |.each do |file|
		  require_relative file
	  end

	ZERO = Int.new 0
	ONE  = Int.new 1
	TWO  = Int.new 2
end