module SymDesc
    
    #  ____                  
    # / ___| _   _ _ __ ___  
    # \___ \| | | | '_ ` _ \ 
    #  ___) | |_| | | | | | |
    # |____/ \__,_|_| |_| |_|

    # This class represents a sum between two symbolic objects
    class Sum < BinaryOp

    	class <<self

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

        # :call-seq:
        #   sum + obj -> new_obj
        #
        # It adds `obj` to `sum` returning
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
    			return Sum.new(tmp,@right)
    		elsif tmp = @right.opt_sum(b) 
    			return Sum.new(@left,tmp)
    		end
    		nil 
    	end

        # :call-seq:
        #   sum - obj -> new_obj
        #
        # It subtracts `obj` to `sum` returning
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
            	return Sum.new(tmp,@right)
            elsif tmp = @right.opt_sub(b)
            	return Sum.new(@left,tmp)
            end
            nil
    	end

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
            	Sum.new(tmp,@right)
            elsif (tmp = @right.opt_sum(b))
                Sum.new(@left,tmp)
            else
            	Sum.new(self,b)
            end
        end

        def __sub_else(b)
        	if (tmp = @left.opt_sub(b))
            	Sum.new(tmp,@right)
            elsif (tmp = @right.opt_sub(b))
                Sum.new(@left,tmp)
            else
            	Sum.new(self,b)
            end
        end
    end
end