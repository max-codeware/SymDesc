
require_relative "Base.rb"

module SymDesc

	#  _   _            
    # | \ | | ___  __ _ 
    # |  \| |/ _ \/ _` |
    # | |\  |  __/ (_| |
    # |_| \_|\___|\__, |
    #             |___/ 

    class Neg

    	include Base

    	attr_reader :argument

    	class <<self
    		alias   :__new :new 
    		private :__new

    		def new(arg)
    			arg = arg.symdescfy
    			if arg.is_a? Neg
    				return arg.argument
    			end
    			return __new(arg)
    		end
    	end

    	def initialize(argument)
    		@argument = argument
    	end


    	def +(b)
    		return case b
    		    when Neg
    		    	return argument - b.argument 
    		    else
    		    	b - argument
    		end
    	end

    	def opt_sum(b) # :nodoc:
    		if argument.is_a? Neg
    			tmp   = argument.opt_sum b.argument
                tmp &&= -tmp
    		else
    			tmp = b.opt_sub argument
    		end
    		tmp 
    	end

    	def -(b)
    		return case b
    		    when Neg
    		    	 b.argument - argument
    		    else
    		    	-(argument + b)
    		end
    	end

    	def opt_sub(b) # :nodoc:
    		if argument.is_a? Neg
    			tmp   = b.argument.opt_sub argument
    		else
    			tmp   = b.opt_sum argument
    			tmp &&= -tmp
    		end
    		tmp 
    	end

    	def -@
    		argument 
    	end

    	def ==(obj)
            obj = obj.symdescfy
    		return true if obj.is_a?(Neg) && obj.argument == argument
    		false
    	end

    	def to_s(io = nil)
            _io = io || StringIO.new
            case argument
                when Sum, Sub 
                    __io_append(io,SUB_ID,"(",@argument,")")
                else
                    __io_append(io,SUB_ID,@argument)
            end
            if !io
            	io.close
            	return io.string 
            end
            return io
    	end

    	alias :inspect :to_s
    	
    	
    end
end