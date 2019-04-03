
require_relative "Base.rb"

module SymDesc

	#  _   _            
    # | \ | | ___  __ _ 
    # |  \| |/ _ \/ _` |
    # | |\  |  __/ (_| |
    # |_| \_|\___|\__, |
    #             |___/ 

    # This class represents the unary negation of a symbolic
    # object. It simply wraps a symbolic expression and manipulates
    # it accurding to unary negation.
    class Neg

    	include Base

    	attr_reader :argument

    	class <<self
    		alias   :__new :new 
    		private :__new

            # Creates a new negated expression with automatic
            # simplification if necessary.
            # If the passed object is not a symbolic one,
            # a conversion is attempted.
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

        # :call-seq:
        #   neg + obj -> new_obj
        #
        # It sums `obj` to `neg` returning a new object
        # as result of the operation.
        #
        # Automatic simplifications are:
        # ```
        # (-a) + b    -> b - a
        # (-a) + (-b) -> -(a + b)
        # ```
        #
        # If `obj` is not symbolic, a conversion is attempted 
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

        # :call-seq:
        #   neg  obj -> new_obj
        #
        # It subtracts `obj` to `neg` returning a new object
        # as result of the operation.
        #
        # Automatic simplifications are:
        # ```
        # (-a) - b    -> -(a + b)
        # (-a) - (-b) -> b - a
        # ```
        #
        # If `obj` is not symbolic, a conversion is attempted 
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

        # :call-seq:
        #   -neg -> argument
        #
        # It performs the unary negation of `neg`.
        # Since simplification is automatic it returns the
        # argument of `neg`
    	def -@
    		argument 
    	end

        # :call-seq:
        #   `neg` == `obj`
        #
        # It compares `obj` with `neg`, returning true if `obj`
        # is a Neg and has the same argument.
    	def ==(obj)
            obj = obj.symdescfy
    		return true if obj.is_a?(Neg) && obj.argument == argument
    		false
    	end

        # :call-seq:
        #   to_s -> string
        #   to_s(str_io) -> str_io
        #
        # If no argument is provided, it returns a string representation
        # of the unary negation. If a StringIO object is passed, the string
        # representation is appended to the buffer and this last is returned.
    	def to_s(io = nil)
            _io = io || StringIO.new
            case argument
                when Sum, Sub 
                    __io_append(io,SUB_ID,"(",@argument,")")
                else
                    __io_append(io,SUB_ID,@argument)
            end
            if !io
            	_io.close
            	return _io.string 
            end
            return io
    	end

    	alias :inspect :to_s
    	
    	
    end
end