
require_relative "Number.rb"

module SymDesc
    #  ____       _   _       
    # |  _ \ __ _| |_(_) ___  
    # | |_) / _` | __| |/ _ \ 
    # |  _ < (_| | |_| | (_) |
    # |_| \_\__,_|\__|_|\___/ 
    
    # Ratio is a representation of a rational number
    # in a symbolic form. This allows to express numeric
    # fractions with an infinite precision, as well as 
    # performing simplifications between numbers.
    class Ratio < Number
    
       # Reopening Ratio metaclass to perform some metaprogramming 
       # and to ensure a correct simplification to the given inputs
    
    	class <<self
    
            # Constant defining the approximation error
            # when a Float number is converted into a symbolic
            # rational
    		RATIO_PRECISION = SYM_CONFIG[:ratio_precision] || 1e-16
    		private_constant :RATIO_PRECISION
    

            alias   :__new :new 
            private :__new 
    
            # :call-seq:
            #   new(Integer)  -> SymDesc::Int
            #   new(Float)    -> SymDesc::Ratio
            #   new(Rational) -> SymDesc::Ratio
            #   new(Integer,Integer) -> SymDesc::Ratio
            #
            # Creates a new symbolic rational performing the needed
            # simplifications. Parameters `n` and `d` can be Integer,
            # Float or Rational. If only 'n' is given, a new Ratio
            # is created with the correct simplifications. 
            # If both 'n' and 'd' are provided, a new rational is created
            # simplifying `n/d` fraction.
            #
            # Note: A SymDesc::Int is returned if the fraction is in the form
            # `n/1`.
            #
            # No support for Float::INFINITY or Float::NAN
            def new(n,d = nil)
            	__ensure_rationalizable(n,d)
            	num   = den = ratio = nil
            	sign  = false
            	if !__have_nan_or_infinity(n,d)
                    if d 
                    	if  n < 0 || d < 0
                    		sign = true unless n < 0 && d < 0
                    	    n    = n.abs 
                    	    d    = d.abs
                    	end
                        if (n.is_a? Integer) && (d.is_a? Integer)
                        	num,den = n,d
                        elsif (n.is_a? Float) || (d.is_a? Float) || (n.is_a? Rational) || (d.is_a? Rational)
                        	num,den   = __ratio_from_numeric2(n,d)
                        end
                    else
                    	if n < 0
                    		sign = true
                    	    n    = n.abs
                    	end
                        case n 
                            when Integer 
                            	num,den = n,1
                            when Float 
                            	num,den = __ratio_from_numeric(n)
                            when Rational 
                            	num,den = n.numerator,n.denominator
                        end
                    end
                end
                if num && den
                	m    = __mcd(num,den)
                	num /= m 
                	den /= m
                	case den 
                	    when 1
                	    	ratio = num.symdescfy
                	    when 0
                	    	if num == 0
                	    		ratio = Nan
                	    	else
                	    		ratio = Infinity
                	    	end
                	    else
                	    	ratio = __new(num,den)
                	end
                end
                if ratio 
                	return Neg.new(ratio) if sign
                	return ratio 
                end
                raise NotImplementedError, 
                    "Symbolic rationals for \
                        #{n}" << (d ? " and #{d} " : " " << "not implemented yet")
            end
    
        private 
    
            
            def __ensure_rationalizable(*values)
            	values.each do |v|
            		unless (v.is_a? Integer)  || 
            			   (v.is_a? Float)    || 
            			   (v.is_a? Rational) || 
            			   (v.nil? && values.size > 1)
    
            		    raise ArgumentError,
            		    "Expected Integer of Float but #{v.class} found"
            		end
            	end
            end
    
            def __have_nan_or_infinity(*val)
                val.each do |v|
                    if v.is_a? Float
                	    return true if v.nan? || v.infinite?
                    end
                end
                false
            end
    
            def __ratio_from_numeric(n)
                if n.is_a? Integer
                	return n,1
                end
                if n.is_a? Rational 
                	return n.numerator,n.denominator
                end
                n1, n2 = 1,0
                d1, d2 = 0,1
                v      = n
                loop do
                    v1  = v.floor
                    tmp = n1
                    n1  = v1 * n1 + n2 
                    n2  = tmp

                    tmp = d1
                    d1  = v1 * d1 + d2 
                    d2  = tmp
                    v   = 1.0/(v - v1)
                    break if v == Float::INFINITY
                    break if (n - n1/d1.to_f).abs < n * RATIO_PRECISION
                end
                return n1,d1
            end
    
            # Given two numbers `a` and `b`, and knowing
            # at least one is a float (or a rational) computes
            # the numerator and the denominator of the division
            # `a/b`
            def __ratio_from_numeric2(a,b)
                n1,d1 = __ratio_from_numeric(a)
                n2,d2 = __ratio_from_numeric(b)
                return n1*d2, d1*n2
            end
    
            def __mcd(a,b)
            	return 1 if a.zero? || b.zero?
                a,b = b,a unless b < a 
                while b != 0 
                    a,b = b, a % b 
                end 
                return a 
            end
    	end # End metaclass
    
    	attr_reader :numerator
    	attr_reader :denominator
    
    	def initialize(n,d)
            @numerator   = n
            @denominator = d
            freeze
    	end
    
    	def +(b)
            b = b.symdescfy
            return case b 
                when Ratio 
                    if denominator == b.denominator
                        num = numerator + b.numerator
                        den = denominator
                    else 
                        n1,n2 = numerator,   b.numerator
                        d1,d2 = denominator, b.denominator
                        num = n1 * d2 + n2 * d1
                        den = d1 * d2
                    end
                    Ratio.new num,den
                when Int 
                    d = denominator
                    Ratio.new numerator + v.value * d, d
                when BinaryOp 
                    b + self 
                when Neg 
                    self - b.value 
                else 
                    Sum.new b, self 
            end
        end 
    
        def opt_sum(b) # :nodoc:
            b = b.symdescfy
            return self + b if b.is_a? Number 
            nil
        end
    
        def -(b)
    
        end
    
        def opt_sub # :nodoc:
            b = b.symdescfy
            return self - b if b.is_a? Number 
            nil
        end
    
        # Returns SymDesc::Ratio negated (wrapped in SymDesc::Neg class)
        def -@
            return Neg.new self
        end
    
        # :call-seq:
        #    ratio == obj -> true or false
        #
        # Returns true only if the `obj` is a SymDesc::Ratio
        # or a Float or a Rational and it represents the same numeric value 
        def ==(b)
            return case b
                when Rational,Ratio 
                	(@numerator == b.numerator) && 
                	(@denominator == b.denominator)
                when Float 
                	self == b.symdescfy
                else
                	false
            end
        end
    
        # :call-seq:
        #   to_s -> string
        #   to_s(str_io) -> str_io
        #
        # If no argument is provided, it returns a string representation
        # of the fraction. If a StringIO object is passed, the string
        # representation is appended to the buffer and the buffer is returned. 
        def to_s(io = nil)
        	if io 
                __io_append(io,@numerator, DIV_ID, @denominator) 
            else
               return "#{@numerator}/#{@denominator}"
            end
            io
        end
    
    private
        
    end
end