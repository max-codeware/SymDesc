module SymDesc::Base
    
    SUM_ID = "+"
    SUB_ID = "-"
    MUL_ID = "*"
    DIV_ID = "/"
    POW_ID = "**"


    def is_symbolic?
        return true
    end

    module_function :is_symbolic?

    def =~(b)
   	    false 
   	end

   	module_function :=~

protected
    def __io_append(io,*args)
        raise ArgumentError, 
            "Expected StringIO (#{io.class found})" unless io.is_a? StringIO
        args.each do |a|
        	begin
                if a.is_symbolic?
                	a.to_s(io)
                end
            rescue SystemStackError => e
            	raise RecursionError,"\
                    Recursive call to :__io_append detected\n\
                    #{e.backtrace}\
            	"
            end
            io << a
        end
    end
    module_function :__io_append
end