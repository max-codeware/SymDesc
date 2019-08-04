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
  class Power < BinaryOp

  	def +(b)
  		return case b
  		when Neg
  			return self - b.argument
  		when 0
  			self 
  		when self
  			@left == 2 ? @left ** (@right + 1) : Prod.new(TWO,self)
  		else
  			return Sum.new(self,b)
  		end
  	end

  	def opt_sum(b) # :nodoc:
  		return case b
  		when Neg
  			opt_sub b.argument
  		when 0
  			self
  		when self
  			self + b 
  		else
  			nil
  		end
  	end

  	def -(b)
  		return case b
  		when Neg 
  			self + b.argument
  		when 0
  			self 
  		when self
  			ZERO
  		else
  			return Sub.new(self,b)
  		end
  	end

  	def opt_sub(b) # :nodoc:
  		return case b
  		when Neg
  			opt_sum b.argument
  		when 0
  			self
  		when self
  			ZERO
  		else
  			nil
  		end
  	end

  	def -@
  		Neg.new(self)
  	end

    def get_size # :nodoc:
    	return @left.get_size                  +
    	       (@left.is_a?(BinaryOp) ? 2 : 0) + 
    	       3                               +
    	       @right.get_size                 +
    	       (@right.is_a?(BinaryOp) ? 2 : 0)
    end

    def to_s(io = nil)
    	_io = io || __new_io(get_size)
    	@left.is_a?(BinaryOp) ? __io_append(_io,LPAR,@left,RPAR) : __io_append(_io,@left)
    	__io_append(_io,SPACE,POW_ID,SPACE)
    	@right.is_a?(BinaryOp) ? __io_append(_io,LPAR,@right,RPAR) : __io_append(_io,@right)
    end


    # Returns true if the base of the power is `b`.
    # ```
    # op = 2 ** var(:x)
    # op.power_of? 2  #=> true
    # op.power_of? 3  #=> false
    # ```
    def power_of?(b)
        @left == b
    end

  private
  	
  	
  end
end