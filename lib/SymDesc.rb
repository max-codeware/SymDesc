module ENGINE
	class <<self

	    def ruby?
	    	RUBY_ENGINE == "ruby"
	    end

	    def mruby?
	    	RUBY_ENGINE == "mruby"
	    end
	end
	freeze
end

module SymDesc
	
	class RecursionError < SystemStackError; end
	class SymDescError   < StandardError   ; end

	if ENGINE.mruby?
		engine = :mruby
	    if !Kernel.respond_to? :require 
	    	raise SymDescError, "mrbgem-require not found for mruby. Please install it"
	    end
	    require File.expand_path("./SymDesc/Extra/mruby.rb",File.dirname(__FILE__))
	elsif ENGINE.mruby?
		engine = :ruby
		require_relative "SymDesc/Extra/ruby.rb"
	else
		raise SymDescError,"Ruby engine #{RUBY_ENGINE} not supported yet"
	end

	SYM_CONFIG = {
        :ratio_precision => 1e-16,
        :symdesc_engine  => engine,
        :var_scope       => :global
	}

	%w|
	       SymDesc/Extra/Engine_conf.rb
	       SymDesc/Base.rb 
	       SymDesc/Variable.rb 
	       SymDesc/Neg.rb
	       SymDesc/Overload/Numeric.rb 
	       SymDesc/Overload/Object.rb 
	       SymDesc/Overload/Symbol.rb
	       SymDesc/Overload/Kernel.rb 
	       SymDesc/Number/Number.rb 
	       SymDesc/Number/Int.rb 
	       SymDesc/Number/Ratio.rb
	       SymDesc/BinaryOp/BinaryOp.rb
	       SymDesc/BinaryOp/Sum.rb
	       SymDesc/BinaryOp/Sub.rb
	  |.each do |file|
		  require_relative file
	  end

	ZERO = Int.new 0
	ONE  = Int.new 1
	TWO  = Int.new 2
end