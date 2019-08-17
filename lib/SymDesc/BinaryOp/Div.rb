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

	class Div < BinaryOp
        class <<self
        end

        def +(b)
        	return self if b == 0
        	b = b.symdescfy
        	return case b
        	when Neg
        		return self - b.argument
        	when Div
        		__sum_div b
        	# when Power
        	else
        		__sum_else b
        	end
        end

        def opt_sum(b) # :nodoc:
            return case b
            when 0
                self 
            when self 
                self * Two 
            else
                nil 
            end
        end

        def -(b)
        	return self if b == 0
        	b = b.symdescfy
        	return case b
        	when Neg
        		return self + b.argument
        	when Div
        		__sub_div b
        	# when Power
        	else
        		__sub_else b
        	end	
        end

        def opt_sub(b) # :nodoc:
            return case b
            when 0
                self 
            when self 
                ZERO
            else
                nil 
            end
        end

        def get_size # :nodoc:
        	size = @left.get_size + 
                  (@left.is_a?(Sum) || @left.is_a?(Sub) ? 0 : 2)
            size += 3
            size += @right.get_size + 
                   (@right.is_a?(BinaryOp) ? 0 : 2)
            return size 
        end

        def to_s(io = nil)
        	_io = io || __new_io(get_size)
        	__op_append(io,@left,:l)
        	__io_append(_io,SPACE,DIV_ID,SPACE)
            __op_append(io,@right,:r)
            return io ? io : (_io.close; _io.string)
        end
	end

private

    def __op_append(io,branch,kind)
        case kind 
        when :l 
        	branch.is_a?(Sum) || branch.is_a?(Sub) ? 
        	    __io_append(io,LPAR,branch,RPAR) :
        	    __io_append(io,branch)
        when :r 
        	branch.is_a?(BinaryOp) ? 
        	    __io_append(io,LPAR,branch,RPAR) :
        	    __io_append(io,branch)
        else
        	raise Bug,"Unknown branch type #{kind}"
        end
    end

    def __sum_div(b)
        return self * TWO if self == b 
        return (@left * b.right + b.left * @right) / @right * b.right
    end

    def __sum_else(b)
        # return Nan if b.nan?
        return Sum.new(self,b)  
    end

    def __sub_div(b)
        return ZERO if self == b 
        return (@left * b.right - b.left * @right) / @right * b.right
    end

    def __sub_else(b)
        return Nan if b.nan?
        return Sub.new(self,b)  
    end

end