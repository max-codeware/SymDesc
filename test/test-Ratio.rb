
class TestRatio < Test::Unit::TestCase

	def setup
        @r = SymDesc::Ratio.new(1,3)
	end

    def test_new
        assert @r.is_a?(SymDesc::Ratio), "Wrong initialization of SymDesc::Ratio"
        assert_equal @r,1/3.to_r,        "Wrong representation of a rational"
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
        #assert @r == 1/3.to_r, "Comparison between same Ratio and Rational failed"
    end

end