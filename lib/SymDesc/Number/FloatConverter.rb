module SymDesc
    module FloatConverter
        class <<self
        	
            def float_to_ratio_ary(n,d)
                return (n && d) ? __float2ratio2(n,d) : __float2ratio1(n)
            end

            def ratio_to_sd_ratio(num,den)
            	ratio = nil
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
                            return ZERO if num == 0
                	    	ratio = yield(num,den)
                	end
                end
            end

        private

            def __float2ratio1(n)
            	num  = den = nil
            	sign = false
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
                return sign,num,den
            end
            
            def __float2ratio2(n,d)
            	num  = den = nil
            	sign = false
                if  n < 0 || d < 0
                    sign = !(n < 0 && d < 0)
                    n    = n.abs 
                    d    = d.abs
                end
                if (n.is_a? Integer) && (d.is_a? Integer)
                    num,den = n,d
                elsif (n.is_a? Float) || (d.is_a? Float) || (n.is_a? Rational) || (d.is_a? Rational)
                  	num,den   = __ratio_from_numeric2(n,d)
                end
                return sign,num,den
            end

            def float2ratio2(n,d)

            end

            def __ratio_from_numeric(n)
                @@precision ||= (SYM_CONFIG[:ratio_precision] || 1e-16)
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
                    break if (n - n1/d1.to_f).abs < n * @@precision
                end
                #t = n.round
                #return t,1 if (d1*t - n1/d1.to_f).abs < n * @@precision
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
        end
    end
end