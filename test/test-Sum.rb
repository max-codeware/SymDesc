require_relative "test.rb"

class TestSum < Test::Unit::TestCase
    def setup
        @x,@y = var :x,:y
        @sum  = @x + @y
    end

    def test_new
        assert @sum.is_a?(Sum), "Wrong initialization of SymDesc::Sum"

        sol = Neg.new(@sum)
        _x = -@x
        _y = -@y 
        assert_equal Sum.new(_x,_y), sol, "Wrong simplification {(-a) + (-b) => -(a + b)}"
        
        sol = Sub.new(@x,@y)
        assert_equal Sum.new(@x,_y), sol, "Wrong simplification {a + (-b) => a - b}"
        assert_equal Sum.new(_y,@x), sol, "Wrong simplification {(-a) + b => b - a}"

        assert_equal Sum.new(@x,ZERO), @x 
        assert_equal Sum.new(ZERO,@y), @y
    end

    def test_sum
    	num  = 3.to_symdesc
    	_num = -num
    	res  = Sub.new(@sum,num)
    	assert_equal @sum + _num,res 

    	k   = var :k
    	sum = k + num
    	res = Sum.new Sum.new(Sum.new(@x,@y),k), num
        assert_equal @sum + sum,res 

        sub = k - num 
        res = Sub.new Sum.new(Sum.new(@x,@y),k), num
        assert_equal @sum + sub, res

        # res = Sum.new Prod.new(TWO,@x), @y 
        # assert_equal @sum + @x, res 

        # res = Sum.new @x, Prod.new(TWO,@y)
        # assert_equal @sum + @y, res
    end

    def test_opt_sum
    end

    def test_sub
    end

    def test_opt_sub
    end

    def test_to_s
    	str = "x + y"
    	assert_equal @sum.to_s, str, "Wrong string representation for SymDesc::Sum"
    	io = StringIO.new

    	assert @sum.to_s(io).is_a? StringIO
    	io.close
    	assert_equal io.string,str, "Wrong string representation appended to StringIO"
    end

    def test_get_size
    end
end