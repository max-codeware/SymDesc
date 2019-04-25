require_relative "test.rb"

class TestInt < Test::Unit::TestCase
    
    def setup
    	@i = Int.new 5
    end


    def test_new
    	assert @i.is_a?(Int), "Wrong initialization of SymDesc::Int"
    	assert @i.frozen?,    "SymDesc::Int objects are expected to be frozen"
    	assert_equal @i, 5,   "SymDesc::Int initialized with a wrong value"

        i = Int.new -5

        assert (i.is_a?(Neg) && i.argument.is_a?(Int)),  "Wrong initialization of SymDesc::Int with negative Integer"
        assert_equal i.argument.value, 5,                "Negative SymDesc::Int initialized with wrong value"
    end

    def test_sum
    	r = Ratio.new 1,2
    	assert (@i + r).is_a?(Ratio),"Sum between SymDesc::Int and SymDesc::Ratio failed"
        i2 = Int.new 2
        assert_equal (@i + i2), 7,   "Sum between Int and Int failed"
        assert_equal (@i + 2), 7,    "Sum between Int and Integer failed"

        i2 = -i2
        assert_equal (@i + i2), 3,   "Sum between Int and -Int failed"
        assert (@i + var(:x)).is_a?(Sum), "Sum betwen Int and other symbolic object failed"
    end

    def test_opt_sum
    	i = Int.new 10
    	assert (@i.opt_sum(i)).is_a? Int 
    	assert_nil @i.opt_sum var(:x)
    end

    def test_sub
    	r = Ratio.new 1,2
    	assert (@i - r).is_a?(Ratio),"Sum between SymDesc::Int and SymDesc::Ratio failed"
        i2 = Int.new 2
        assert_equal (@i - i2), 3,   "Sum between Int and Int failed"
        assert_equal (@i - 2), 3,    "Sum between Int and Integer failed"

        i2 = -i2
        assert_equal (@i - i2), 7,   "Sum between Int and -Int failed"
        assert (@i - var(:x)).is_a?(Sub), "Sum betwen Int and other symbolic object failed"
    end

    def test_opt_sub
    	i = Int.new 2
    	assert (@i.opt_sub(i)).is_a? Int 
    	assert_nil @i.opt_sum var(:x)
    end

    def test_eq
    	i = Int.new 5
        assert (@i == i), "Comparison berween SymDesc::Int(5) and SymDesc::Int(5) failed"

        assert (@i == 5),  "Comparison between SymDesc::Int(5) and 5 failed"
        assert_false (@i == var(:x) )
    end

    def test_to_s
        s = @i.to_s
        assert_equal s, "5"

        io = StringIO.new
        @i.to_s(io).close
        assert_equal io.string, "5",  "String returned from to_s(io) doesn't match"
    end

    def test_get_size
        int = Int.new 321
        assert_equal @i.get_size, 1
        assert_equal int.get_size,3
    end

end