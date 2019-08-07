# MIT License
# 
# Copyright (c) 2019 Massimiliano Dal Mas
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#  ____                 
# | __ )  __ _ ___  ___ 
# |  _ \ / _` / __|/ _ \
# | |_) | (_| \__ \  __/
# |____/ \__,_|___/\___|

##
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

    class Bug < StandardError; end


    ##
    # Returns always true. Every object that includes
    # this module or class that extends SymDesc::Base is
    # automatically considered as symbolic
    def is_symbolic?
        return true
    end

    def =~(b) # :nodoc:
   	    false 
   	end

    %w|+ - * / ** 
       opt_sum opt_sub opt_prod opt_div opt_pow 
       ==
       get_size to_s
       diff diff!
       sub sub!|.each do |name|
        abstract_method name
    end

protected

    ##
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

    ##
    # Optimized string buffer for mruby engine
    def __new_io(size)
        return StringIO.new String.buffer(size)
    end

else

    ##
    # Optimized string buffer for ruby engine
    def __new_io(size)
        return StringIO.new String.new(capacity: size)
    end

end
    
end