module SymDesc
    class Sub < BinaryOp

    	include Addition

    	OP = :-

    	class <<self
            def new(left,right)
            	return left if right == 0
            	return right if left == 0
            	#tmp = nil
            	# if left.is_a?(Neg) && right.is_a?(Neg)
            	#	return Sub.new
            	return super
            end
    	end

    	def -@
    		return Sub.new @right, @left
    	end

    	def to_s(io = nil)
    		_io = io || __new_io(get_size)
    		__io_append(_io,@left,SPACE,SUB_ID,SPACE,@right)
    		if !io 
    			_io.close 
    			return _io.string 
    		end
    		io
    	end

    	alias :inspect :to_s

    private 

        def __sum_else(b)
            if tmp = @left.opt_sum(b)
            	tmp - @right 
            elsif tmp = @right.opt_sum(b)
            	@left - tmp 
            else
            	Sum.new self, b 
            end
        end

        def __sub_else(b)
            if tmp = @left.opt_sub(b)
            	tmp - @right 
            elsif tmp = @right.opt_sub(b)
            	@left - tmp 
            else
            	Sub.new self, b 
            end
        end
    end
end