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
    
    ##
    # This module contains the methods for
    # addition and subtraction operations
    # for SymDesc::Sum and SymDesc::Sub classes- 
    module Addition

    	##
        # :call-seq:
        #   op + obj -> new_obj
        #
        # It adds `obj` to `op` returning
        # a new symbolic object. Simplification is automatic.
        #
        # If `obj` is not a symbolic object, a conversion is attempted
        def +(b)
     		return self if b == 0
     		b = b.symdescfy
            return case b
                when Neg
                    self - b.argument 
                when Sum 
                 	self + b.left + b.right 
                when Sub 
                 	self + b.left - b.right
                else
                 	__sum_else b
            end
    	end 

    	def opt_sum(b) # :nodoc:
    		return self if b == 0
    		return Prod.new(TWO,self) if self == b 
    		if tmp = @left.opt_sum(b) 
    		    tmp.send self.class::OP,@right
    		elsif tmp = @right.opt_sum(b) 
    			@left.send self.class::OP, tmp
    		else 
    		    nil 
    		end
    	end

    	##
        # :call-seq:
        #   op - obj -> new_obj
        #
        # It subtracts `obj` to `op` returning
        # a new symbolic object. Simplification is automatic.
        #
        # If `obj` is not a symbolic object, a conversion is attempted
    	def -(b)
    		return self if b == 0
    		b = b.symdescfy
            return case b
                when Neg
                    self + b.argument 
                when Sum 
                	self - b.left - b.right 
                when Sub 
                	self - b.left + b.right
                else
                	__sub_else b
            end
    	end

    	def opt_sub(b) # :nodoc:
            return self if b == 0
            return ZERO if self == b 
            if tmp = @left.opt_sub(b)
            	tmp.send self.class::OP,@right
            elsif tmp = @right.opt_sub(b)
            	@left.send self.class::OP, tmp
            else
                nil
            end
    	end
    end
end