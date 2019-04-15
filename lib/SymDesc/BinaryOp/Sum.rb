module SymDesc
    
    #  ____                  
    # / ___| _   _ _ __ ___  
    # \___ \| | | | '_ ` _ \ 
    #  ___) | |_| | | | | | |
    # |____/ \__,_|_| |_| |_|

    class Sum < BinaryOp

    	class <<self
            def new(left,right)
            	return left if right == 0
            	return right if left == 0
            	if left.is_a?(Neg) && right.is_a?(Neg)
            		return Neg.new super(left.argument,right.argument)
                elsif left.is_a? Neg
                	return Sub.new(right,left.argument)
                elsif right.is_a? Neg
                	return Sub.new(left,right.argument)
                end
                return super(left,right)
            end		
    	end

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
                	if (tmp = @left.opt_sum(b))
                		Sum.new(tmp,@right)
                	elsif (tmp = @right.opt_sum(b))
                        Sum.new(@left,tmp)
                    else
                    	Sum.new(self,b)
                    end
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
    end
end