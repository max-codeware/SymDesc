module SymDesc
    class BinaryOp
    	include Base

        attr_reader :left,:right

    	def initialize(left,right)
    		@left  = left
    		@right = right
    	end

        def ==(b)
        	(self.class = b.class) && 
        	(((left == b.left) && (right == b.right))  ||
        	((left  == b.right) && (right == b.left)))
        end

    protected 
        def left=(b)
        	@left = left
        end

        def right=(b)
        	@right = right
        end
    end

end