
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
    
    		RATIO_PRECISION = SYM_CONFIG[:ratio_precision] || 1e-16
    		private_constant :RATIO_PRECISION
    
            alias   :__new :new 
            private :__new
    
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
    
            # TODO: checking against Infinity and Nan
            def __ensure_rationalizable(*values)
            	values.each do |v|
            		unless (v.is_a? Integer)  || 
            			   (v.is_a? Float)    || 
            			   (v.is_a? Rational) || 
            			   (v.nil?)
    
            		    raise ArgumentError,
            		    "Expected Integer of Float but #{v.class} found"
            		end
            	end
            end
    
            def __have_nan_or_infinity(*val)
                val.each do |v|
                	return true if v == Float::INFINITY || v == Float::NAN
                end
                false
            end
    
            def __real_from_numeric(n)
                if n.is_a? Integer
                	return n,1
                end
                if n.is_a? Rational 
                	return n.numerator,n.denominator
                end
                fn = n.floor
                if 1 - RATIO_PRECISION < n - fn 
                	return fn + 1,1
                end
     
            end
    
            # Given two numbers `a` and `b`, and knowing
            # at least one is a float (or a rational) computes
            # the numerator and the denominator of the division
            # `a/b`
            def __real_from_numeric2(a,b)
                n1,d1 = __real_from_numeric(a)
                n2,d2 = __real_from_numeric(b)
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
    	end
    
    
        # Here begins the Ratio class
    
    	attr_reader :numerator
    	attr_reader :denominator
    
    	def initialize(n,d)
            @numerator   = n
            @denominator = d
            freeze
    	end
    
    	def +(b)
    
        end 
    
        def opt_sum(b)
    
        end
    
        def -(b)
    
        end
    
        def opt_sub
    
        end
    
        def -@
    
        end
    
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
    
        def to_s(io = nil)
        	if io 
                __io_append(io,@numerator, DIV_ID, @denominator) 
            else
               return "#{@numerator}/#{@denominator}"
           end
        end
    
    private
        
    end
end