module SymDesc
    
    #  ____  _                         ___        
    # | __ )(_)_ __   __ _ _ __ _   _ / _ \ _ __  
    # |  _ \| | '_ \ / _` | '__| | | | | | | '_ \ 
    # | |_) | | | | | (_| | |  | |_| | |_| | |_) |
    # |____/|_|_| |_|\__,_|_|   \__, |\___/| .__/ 
    #                           |___/      |_| 

    class BinaryOp
    	include Base

        attr_reader :left,:right

    	def initialize(left,right)
    		@left  = left
    		@right = right
    	end

        def ==(b)
        	(self.class == b.class) && 
        	(((left == b.left) && (right == b.right))  ||
        	((left  == b.right) && (right == b.left)))
        end

        def get_size # :nodoc:
            return @left.get_size + @right.get_size + 3
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