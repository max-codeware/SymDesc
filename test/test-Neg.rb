require_relative "test.rb"

class TestNeg < Test::Unit::TestCase
    
    def setup
        @n       = Neg.new var(:x)
        @x, @y   = var :x,:y
        @_x, @_y = -@x, -@y
    end

    def test_new
        assert @n.is_a?(Neg), "Wrong initialization of SymDesc::Neg"
        assert Neg.new(@n).is_a?(Variable), "Wrong simplification for SymDesc::Neg (-(-a))"
        assert Neg.new(ZERO).is_a?(Int),    "Wrong simplification for SymDesc::Neg (-0)"
    end

    def test_sum
    	sum = -(@x + @y)
    	assert_equal @n + @_y,sum 

    	sub = @y - @x
    	assert_equal @n + @y, sub
    end

    def test_opt_sum
    	prod = -(Prod.new TWO,@x) 
    	assert_equal @n.opt_sum(@_x),prod 
        assert_equal @n.opt_sum(@x),ZERO
        assert_nil   @n.opt_sum @y
    end

    def test_sub
    	sub = @y - @x 
    	assert_equal @n - @_y, sub 

    	sum = -(@x + @y)
    	assert_equal @n - @y, sum
    end

    def test_opt_sub
        assert_equal @n.opt_sub(@_x),ZERO
        assert_equal @n.opt_sub(@x), -Prod.new(TWO,@x)
        assert_nil   @n.opt_sub @y
    end

    def test_unimus
    	assert_equal -@n, @x
    end

    def test_eq
    	assert_true  @n == @_x
    	assert_false @n == @_y
    end


    def test_to_s
    	assert_equal @n.to_s, "-x", "Wrong string representation of SymDesc::Neg"

        z = var :z
    	n2 = Neg.new(@y + z)

    	assert_equal n2.to_s, "-(y + z)", "Wrong string representation of SymDesc::Neg"

    	io  = StringIO.new 
    	res = @n.to_s(io)
    	assert io.is_a?(StringIO)
    	assert_equal io.string, "-x", "Wrong string representation of SymDesc::Neg appended to StringIO"
    end
end