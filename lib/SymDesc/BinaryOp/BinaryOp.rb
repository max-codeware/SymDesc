module SymDesc
    
    #  ____  _                         ___        
    # | __ )(_)_ __   __ _ _ __ _   _ / _ \ _ __  
    # |  _ \| | '_ \ / _` | '__| | | | | | | '_ \ 
    # | |_) | | | | | (_| | |  | |_| | |_| | |_) |
    # |____/|_|_| |_|\__,_|_|   \__, |\___/| .__/ 
    #                           |___/      |_| 

    # This class represents a generic binary operation and it is inherited
    # by the main algebric operations
    class BinaryOp
    	include Base

        attr_reader :left,:right

    	# It creates and initializes a new instance of binary operation
        # ensuring the passed arguments are of symboli type.
        def initialize(left,right)
            [left,right].each { |v| raise ArgumentError, 
                "Expected symbolic object but #{v.class} found" unless v.is_symbolic? }
    		@left  = left
    		@right = right
    	end

        # :call-seq:
        #   self == obj
        # Returns true only if 'obj' represents the same operation
        # with the same arguments
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