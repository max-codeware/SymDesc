
module SymDesc
    #  ___       _   
    # |_ _|_ __ | |_ 
    #  | || '_ \| __|
    #  | || | | | |_ 
    # |___|_| |_|\__|

    # This class represents and wraps an integer value
    # as a symbolic int.
    class Int < Number
    
        class <<self
    
            # :call-seq:
            #   new(i) -> new_int
            #
            # It creates a new SymDesc::Int from a ruby Integer.
            # If i < 0, the result is wrapped into SymDesc::Neg.
            def new(v)
                raise ArgumentError, 
                        "Expected Integer argument but #{v.class} found" unless v.is_a? Integer
                return ZERO if v.zero? && const_defined?(:ZERO)
                if v < 0
                    return Neg.new super v.abs
                end
                return super v
            end
        end
    
        attr_reader :value
    
        def initialize(n)
            @value = n
            freeze
        end
    
        # :call-seq:
        #   int + obj -> new_obj
        #
        # Performs a symbolic sum between a symbolic integer
        # and `obj`, returning a new symbolic object if the operation
        # creates a new tree branch, or a symbolic number if
        # `obj` is a SymDesc::Number. Simplification is automatic.
        #
        # If `obj` is not a symbolic object, a conversion is attempted
        def +(b)
            return self if b == 0
            return Int.new(@value + b) if b.is_a? Integer
            b = b.symdescfy
            return case b 
                when Ratio, BinaryOp 
                    b + self
                when Int 
                    Int.new(@value + b.value) 
                when Neg
                    self - b.argument 
                else 
                    Sum.new(b,self)
            end
        end 
    
        def opt_sum(b) # :nodoc:
            if b.is_a? Number
                return self + b 
            end
            nil
        end
    
        # :call-seq:
        #   int - obj -> new_obj
        #
        # Performs a symbolic subtraction between a symbolic integer
        # and `obj`, returning a new symbolic object if the operation
        # creates a new tree branch, or a symbolic number if
        # `obj` is a SymDesc::Number. Simplification is automatic.
        #
        # If `obj` is not a symbolic object, a conversion is attempted
        def -(b)
            return self if b == 0
            return Int.new(@value - b) if b.is_a? Integer
            b = b.symdescfy
            return case b
                when Ratio 
                    __sub_ratio b
                when Int 
                    Int.new(value - b.value)
                when Neg
                    self + b.argument 
                else
                    Sub.new(self,b)
            end
        end
    
        def opt_sub(b) # :nodoc:
            if b.is_a? Number
                return self - b 
            end
            nil
        end
    
        # Returns SymDesc::Int negated (wrapped in SymDesc::Neg class)
        def -@
            Neg.new(self)
        end
    
        # :call-seq:
        #   to_s -> string
        #   to_s(str_io) -> str_io
        #
        # If no argument is provided, it returns a string representation
        # of the integer value. If a StringIO object is passed, the string
        # representation is appended to the buffer and the buffer is returned. 
        def to_s(io = nil)
            if io
                __io_append(io,value) 
            else
                return @value.to_s 
            end
            io
        end

        alias :inspect :to_s
    
        # :call-seq:
        #    int == obj -> true or false
        #
        # Returns true only if the `obj` is a SymDesc::Int
        # or an Integer or a Rational and it represents the same 
        # numeric value 
        def ==(b)
            return case b 
                when  Int
                    @value == b.value 
                when Numeric 
                    @value == b 
                else 
                    false 
            end 
        end
    
    protected

        def get_size
            @value.get_size
        end
    
    private
    
        def __sub_ratio(b)
            n = value * b.denominator - b.numerator
            Ratio.new(n,b.denominator) 
        end
        
        
    end

end