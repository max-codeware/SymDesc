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

module SymDesc
    
    #  ____                  
    # / ___| _   _ _ __ ___  
    # \___ \| | | | '_ ` _ \ 
    #  ___) | |_| | | | | | |
    # |____/ \__,_|_| |_| |_|

    ##
    # This class represents a sum between two symbolic objects.
    class Sum < BinaryOp

        include Addition
        OP = :+

    	class <<self

    		##
            # Creates a new SymDesc::Sum given left and right value
    		# that ase expected to be symbolic objects. Some simplification
    		# is performed.
            def new(left,right)
            	return left if right == 0
            	return right if left == 0
            	tmp = nil
            	if left.is_a?(Neg) && right.is_a?(Neg)
            		tmp = Neg.new super(left.argument,right.argument)
                elsif left.is_a? Neg
                	tmp = Sub.new(right,left.argument)
                elsif right.is_a? Neg
                	tmp = Sub.new(left,right.argument)
                end
                return tmp || super(left,right)
            end		
    	end

        ##
        # :call-seq:
        #   to_s -> string
        #   to_s(str_io) -> str_io
        #
        # If no argument is provided, it returns a string representation
        # of the symbolic sum. If a StringIO object is passed, the string
        # representation is appended to the buffer and the buffer is returned. 
    	def to_s(io = nil)
    		_io = io || __new_io(get_size)
    		__io_append(_io,@left,SPACE,SUM_ID,SPACE,@right)
    		if !io 
    			_io.close
    			return _io.string
    		end
    		io 
    	end

    	alias :inspect :to_s

    private 

        def __sum_else(b)
        	if (tmp = @left.opt_sum(b))
            	tmp + @right
            elsif (tmp = @right.opt_sum(b))
                @left + tmp
            else
            	Sum.new(self,b)
            end
        end

        def __sub_else(b)
        	if (tmp = @left.opt_sub(b))
            	tmp + @right
            elsif (tmp = @right.opt_sub(b))
                @left + tmp
            else
            	Sub.new(self,b)
            end
        end
    end
end