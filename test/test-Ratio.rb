
class TestRatio < Test::Unit::TestCase

	def setup
        @r = SymDesc::Ratio.new(1,3)
	end

    def test_new
        assert @r.is_a?(SymDesc::Ratio), "Wrong initialization of SymDesc::Ratio"
        assert_equal @r,1/3.to_r,        "Wrong representation of a rational"
        r = SymDesc::Ratio.new(2.5)
        assert_equal r, 5/2.to_r,        "Wrong conversion from float to rational"

        r = SymDesc::Ratio.new(1/3.0)
        assert_equal r,1/3.to_r,         "Wrong conversion from float to rational"

        r = SymDesc::Ratio.new(5)
        assert r.is_a?(SymDesc::Int),    "Conversion of Integer to Rational should return Int"
        assert_equal r,5,                "5 must be equal to itself"

        #r = SymDesc::Ratio.new(-1.25)
        #assert r.is_a?(SymDesc::Neg),    "Conversion of -1.25 should return Neg"
        #assert_equal r,-5/4.to_r,        "Conversion of -1.25 to -4/5 failed"

        assert_raise(ArgumentError)       { SymDesc::Ratio.new("")           }
        assert_raise(NotImplementedError) { SymDesc::Ratio.new(Float::NAN)   }
        assert_raise(NotImplementedError) { SymDesc::Ratio.new(Float::NAN,5) }
    end

    def test_simplifications
        r = SymDesc::Ratio.new(2,6)
        assert_equal @r,r,    "Wrong simplification of rational"

        r = SymDesc::Ratio.new(2.5,2.5)
        assert r.is_a?(SymDesc::Int), "Simplification was expected to return an Int"
        assert_equal r,1,             "2.5/2.5 was expected to return 1"

        r = SymDesc::Ratio.new(20/7.to_r,20/7.to_r)
        assert r.is_a?(SymDesc::Int), "Simplification was expected to return an Int"
        assert_equal r,1,             "(20/7) / (20/7) was expected to return 1"

        r = SymDesc::Ratio.new(0.4,2/7.to_r)
        assert r.is_a?(SymDesc::Ratio), "Simplification was expected to return a Ratio"
        assert_equal r,7/5.to_r,        "(0.4) / (2/7) was expected to return 7/5"

        r = SymDesc::Ratio.new(0.8,2.to_r)
        assert r.is_a?(SymDesc::Ratio), "Simplification was expected to return a Ratio"
        assert_equal r,0.4,           "0.8 / 2 was expected to return 0.4"
    end

    def test_to_s
        assert_equal @r.to_s, "1/3"
        io = StringIO.new 
        @r.to_s(io)
        io.close
        assert_equal io.string, "1/3", "String returned from to_s(io) doesn't match"
    end

    def test_eq
        tmp = SymDesc::Ratio.new(1,3)
        assert (@r == tmp),      "Comparison between same Ratio failed"
        assert (@r == 1/3.to_r), "Comparison between Ratio and Rational failed"
        assert (@r == 1.0/3),    "Comparison between Ratio and Float failed"
    end

    def test_sum

    end

end