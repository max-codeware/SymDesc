
class TestRatio < Test::Unit::TestCase

	def setup
        @r = Ratio.new(1,3)
	end

    def test_new
        assert @r.is_a?(Ratio), "Wrong initialization of Ratio"
        assert_equal @r,1/3.to_r,        "Wrong representation of a rational"
        r = Ratio.new(2.5)
        assert_equal r, 5/2.to_r,        "Wrong conversion from float to rational"

        r = Ratio.new(1/3.0)
        assert_equal r,1/3.to_r,         "Wrong conversion from float to rational"

        r = Ratio.new(5)
        assert r.is_a?(Int),    "Conversion of Integer to Rational should return Int"
        assert_equal r,5,                "5 must be equal to itself"

        r = Ratio.new(-1.25)
        assert r.is_a?(Neg),    "Conversion of -1.25 should return Neg"
        assert_equal r,-5/4.to_r,        "Conversion of -1.25 to -4/5 failed"

        assert_raise(ArgumentError)       { Ratio.new("")           }
        assert_raise(NotImplementedError) { Ratio.new(Float::NAN)   }
        assert_raise(NotImplementedError) { Ratio.new(Float::NAN,5) }
    end

    def test_simplifications
        r = Ratio.new(2,6)
        assert_equal @r,r,    "Wrong simplification of rational"

        r = Ratio.new(2.5,2.5)
        assert r.is_a?(Int), "Simplification was expected to return an Int"
        assert_equal r,1,             "2.5/2.5 was expected to return 1"

        r = Ratio.new(20/7.to_r,20/7.to_r)
        assert r.is_a?(Int), "Simplification was expected to return an Int"
        assert_equal r,1,             "(20/7) / (20/7) was expected to return 1"

        r = Ratio.new(0.4,2/7.to_r)
        assert r.is_a?(Ratio), "Simplification was expected to return a Ratio"
        assert_equal r,7/5.to_r,        "(0.4) / (2/7) was expected to return 7/5"

        r = Ratio.new(0.8,2.to_r)
        assert r.is_a?(Ratio), "Simplification was expected to return a Ratio"
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
        tmp = Ratio.new(1,3)
        assert (@r == tmp),      "Comparison between same Ratio failed"
        assert (@r == 1/3.to_r), "Comparison between Ratio and Rational failed"
        assert (@r == 1.0/3),    "Comparison between Ratio and Float failed"
    end

    def test_sum
        comp = 2/3.to_r
        assert_equal @r + @r, comp,       "Sum between Ratio and Ratio failed"
        assert_equal @r + 1.0/3, comp,    "Sum between Ratio and Float failed"
        assert_equal @r + 1/3.to_r, comp, "Sum between Ratio and Rational failed" 

        comp = 16/3.to_r
        assert_equal @r + 5, comp,                  "Sum between Ratio and Integer failed"
        assert_equal @r + Int.new(5),comp, "Sum between Ratio and Int failed"

        assert_equal @r + 2.0/4, 5/6.to_r,          "Sum between Ratio and Float failed" 

        comp = 4/9.to_r
        r1   = Ratio.new 7.0/9
        r2   = -@r 
        assert_equal r1 + r2, comp,  "Sum between Ratio and Neg(Ratio) failed"
    end

    def test_opt_sum
        r  = Ratio.new 2.5
        i  = Int.new   5
        n  = @r.opt_sum r
        assert n.is_a?(Ratio), ":opt_sum Returned a wrong type"
        n  = @r.opt_sum i 
        assert n.is_a?(Ratio), ":opt_sum Returned a wrong type"

        x = Variable.new :x
        assert_nil @r.opt_sum(x), ":opt_sum was expected to return nil on non Number objects"
    end


    def test_sub
        r  = Ratio.new 5,2
        r1 = Ratio.new 3,2

        comp = 1
        assert_equal r - r1,       comp,  "Subtraction between Ratio and Ratio failed"
        assert_equal r - 3/2.0,    comp,  "Subtraction between Ratio and Float failed"
        assert_equal r - 3/2.to_r, comp,  "Subtraction between Ratio and Rational failed" 

        comp = 1/2.to_r
        assert_equal r - 2, comp,                  "Subtraction between Ratio and Integer failed"
        assert_equal r - Int.new(2),comp, "Subtraction between Ratio and Int failed"

        assert_equal r - 3.0/7, 29/14.to_r,        "Subtraction between Ratio and Float failed" 

        comp = 17/6.to_r
        r2   = -@r 
        assert_equal r - r2, comp,  "Subtraction between Ratio and Neg(Ratio) failed"
    end

    def test_opt_sub
        r  = Ratio.new 5,2
        i  = Int.new   2
        n  = r.opt_sub @r
        assert n.is_a?(Ratio), ":opt_sum Returned a wrong type"
        n  = r.opt_sub i 
        assert n.is_a?(Ratio), ":opt_sum Returned a wrong type"

        x = Variable.new :x
        assert_nil r.opt_sub(x), ":opt_sub was expected to return nil on non Number objects"
    end

end