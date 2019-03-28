module SymDesc
	
	class RecursionError < SystemStackError; end
	class SymDescError   < StandardError   ; end

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
end