module SymDesc
    
    # This module contains the methods for
    # addition and subtraction operations
    # for SymDesc::Sum and SymDesc::Sub classes- 
    module Addition

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