
require_relative "Number.rb"

module SymDesc
    #  ___       _   
    # |_ _|_ __ | |_ 
    #  | || '_ \| __|
    #  | || | | | |_ 
    # |___|_| |_|\__|

    class Int < Number
    
        class <<self
            alias :__new :new
            private :__new
    
            def new(v)
                raise ArgumentError, 
                        "Expected Integer argument but #{v.class} found" unless v.is_a? Integer
                if v < 0
                    return Neg.new __new(v.abs)
                end
                return __new(v)
            end
        end
    
        attr_reader :value
    
        def initialize(n)
            @value = n
            freeze
        end
    
        def +(b)
            return case b 
                when Ratio, BinaryOp 
                    b + self
                when Int 
                    Number.new(value + b.value) 
                when Neg
                    self - b.value 
                else 
                    Sum.new(b,self)
            end
        end 
    
        def opt_sum(b)
            if b.is_a? Number
                return self + b 
            end
            nil
        end
    
        def -(b)
            return case b
                when Ratio 
                    __sub_ratio b
                when Int 
                    Number.new(value - b.value)
                when Neg
                    self + b.value 
                else
                    Sub.new(self,b)
            end
        end
    
        def opt_sub(b)
            if b.is_a? Number
                return self - b 
            end
            nil
        end
    
        def -@
            Neg.new(self)
        end
    
        def to_s(io = nil)
            __io_append(io,value) if io
            value.to_s 
        end
    
        def ==(b)
            return case b 
                when  Int
                    value == b.value 
                when Numeric 
                    value == b 
                else 
                    false 
            end 
        end
    
    
    
    private
    
        def __sub_ratio(b)
            n = value * b.denominator - b.numerator
            Ratio.new(n,b.denominator) 
        end
        
        
    end

end