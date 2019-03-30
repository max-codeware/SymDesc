
require_relative "Base.rb"

module SymDesc

    class Variable
    
    	include Base
    
    	attr_reader :name
    
    	def initialize(name)
    		if name.is_a? Symbol
    			name = name.to_s
    		end
    		raise ArgumentError, 
    		     "A variable name must be a Symbol or a String" unless name.is_a? String
    		@name = name
    	end
    
    	def +(b)
            return case b 
                   
                when self.class 
                    __sum_self b 
                when Neg 
                	self - b.value 
                when BinaryOp
                	b + self
                when Numeric
                	__sum_numeric b
                else 
                	Sum.new(self,b)
            end
    	end
    
    	def opt_sum(b)
            if self == b 
            	return Prod.new(TWO,self)
            end
            nil
    	end
    
    	def -(b)
            return case b 
                   
                when self.class 
                    __sub_self b 
                when Neg 
                	self + b.value 
                when BinaryOp
                	__sub_binaryop b
                when Numeric
                	__sub_numeric b
                else 
                	Sub.new(self,b)
            end
    	end
    
    	def opt_sub(b)
    		return self - b if self =~ b
    		nil 
    	end
    
        def =~(b)
        	return case b 
    
                when Variable
        	        self == b 
        	    when Product, Div
        	    	b =~ self 
        	    else 
        	    	false
        	end
        end
    
        def to_s(io = nil)
            if io 
                __io_append(io,name) 
            else
                return name.dup 
            end
        end
    
    private
        
        def __sum_self(b)
        	return Prod.new(TWO,self) if self == b
        	Sum.new(self,b)
        end
    
        def __sum_numeric(b)
        	return self if b.zero?
        	b = b.symdescfy if b.is_a? Float
        	Sum.new(self,b)
        end
    
        def __sub_self(b)
        	return ZERO if self == b 
        	Sub.new(self,b)
        end
    
        def __sub_binaryop(b)
            case b 
                when Sum 
                	return self - b.left - b.right
                when Sub 
                	return self - b.left + b.right 
                when Prod
                	if b =~ self
                		if (l = b.left) == 2
                			return self
                		end
                		return Prod.new(ONE - l,self)
                	end 
                when Div 
                	if b =~ self
                		n = self * b.right - b.left
                		return n / b.right
                	end
            end
            return Sub.new(self,b)
        end
    
        def __sub_numeric(b)
            return self if b == 0
            b = b.symdescfy if b.is_a? Float 
            return Sub.new(self,b)
        end
    
    	
    end

end