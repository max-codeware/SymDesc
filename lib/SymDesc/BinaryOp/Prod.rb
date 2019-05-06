
module SymDesc

    class Prod < BinaryOp

        class <<self
            def new(left,right)
                return ZERO  if left == 0 || right == 0
                return left  if right == 1
                return right if left == 1
                return super
            end
        end

        def +(b)
            return TWO * b if self == b 
            b = b.symdescfy
            return case b
                when Variable
                	__sum_variable b 
                when Prod,Div
                	__sum_prod_div b 
                else
                	__sum_else b 
            end
        end

        def opt_sum(b) #:nodoc:
        end

        def -(b)
        end

        def opt_sub(b) # :nodoc:
        end

        def to_s(io = nil)
        end

        def =~(b) # :nodoc:
        	return (@left.is_a? Number) && (@right == b)
        end

    private

        def __sum_variable(b)
            return self =~ b ? (Prod.new(@left + 1, @right)) : Sum.new(self,b)
        end

        def __sum_prod_div(b)
        end

        def __sum_else(b)
            return self =~ b ? (Prod.new(@left + 1, @right)) : Sum.new(self,b)
        end

    end


end