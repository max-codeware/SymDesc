#  ____                 
# | __ )  __ _ ___  ___ 
# |  _ \ / _` / __|/ _ \
# | |_) | (_| \__ \  __/
# |____/ \__,_|___/\___|

# SymDesc::Base is the basic module included or extedned by
# all the symbolic objects. It includes some basic methods,
# constants and virtual methods that should be common 
# to all the objects or classes.
module SymDesc::Base
    
    SUM_ID = "+"
    SUB_ID = "-"
    MUL_ID = "*"
    DIV_ID = "/"
    POW_ID = "**"
    SPACE  = " "
    LPAR   = "("
    RPAR   = ")"


    # Returns always true. Every object that includes
    # this module or class that extends SymDesc::Base is
    # automatically considered as symbolic
    def is_symbolic?
        return true
    end

    def =~(b) # :nodoc:
   	    false 
   	end

    for name in %w|+ - * / ** opt_sum opt_sub opt_prod opt_div opt_pow ==|
        eval "
            def #{name}(b)
                raise NotImplementedError, \"Method `#{name}' for \#\{self.class\} not implemented yiet\"
            end"
    end

    for name in %w||
    end

protected

    # Method used as helper routine to append the string representation
    # of symbolic objects to the buffer. This helps improving performances
    # avoiding many allocations of little strings.
    def __io_append(io,*args)
        raise ArgumentError, 
            "Expected StringIO (#{io.class}) found" unless io.is_a? StringIO
        args.each do |a|
        	begin
                if a.is_symbolic?
                	a.to_s(io)
                else
                    io << a
                end
            rescue SystemStackError => e
            	raise RecursionError,"\
                    Recursive call to :__io_append detected\n\
                    #{e.backtrace}"
            end
        end
    end

if ENGINE.mruby?

    # Optimized string buffer for mruby engine
    def __new_io(size)
        return StringIO.new String.buffer(size)
    end

else

    # Optimized string buffer for ruby engine
    def __new_io(size)
        return StringIO.new String.new(capacity: size)
    end

end
    
end