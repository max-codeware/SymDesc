module SymDesc::Base
    
    SUM_ID = "+"
    SUB_ID = "-"
    MUL_ID = "*"
    DIV_ID = "/"
    POW_ID = "**"
    SPACE  = " "


    def is_symbolic?
        return true
    end

    def =~(b)
   	    false 
   	end

    for name in %w|+ - * / ** opt_sum opt_sub opt_prod opt_div opt_pow ==|
        eval "
            def #{name}(b)
                raise NotImplementedError, \"Method `#{name}' for \#\{self.class\} not implemented yiet\"
            end"
    end

protected
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
    
end