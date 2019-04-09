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
    end

    def test_opt_sum
    end

    def test_sub
    end

    def test_opt_sub
    end

    def test_eq
    	i = Int.new 5
        assert (@i == i), "Comparison berween SymDesc::Int(5) and SymDesc::Int(5) failed"

        assert (@i == 5),  "Comparison between SymDesc::Int(5) and 5 failed"
    end

    def test_to_s
        s = @i.to_s
        assert_equal s, "5"

        io = StringIO.new
        @i.to_s(io).close
        assert_equal io.string, "5",  "String returned from to_s(io) doesn't match"
    end

end