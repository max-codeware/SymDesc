# MIT License
#
# Copyright (c) 2019 Massimiliano Dal Mas
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module SymDesc
  module FloatConverter
    class << self
      def float_to_ratio_ary(n, d)
        return (n && d) ? __float2ratio2(n, d) : __float2ratio1(n)
      end

      def ratio_to_sd_ratio(num, den)
        ratio = nil
        if num && den
          m = __mcd(num, den)
          num /= m
          den /= m
          case den
          when 1
            ratio = num.symdescfy
          when 0
            ratio = (num == 0) ? Nan : Infinity
          else
            ratio = (num == 0) ? ZERO : yield(num, den)
          end
        end
        return ratio
      end

      private

      def __float2ratio1(n)
        num = den = nil
        sign = false
        if n < 0
          sign = true
          n = n.abs
        end
        case n
        when Integer
          num, den = n, 1
        when Float
          num, den = __ratio_from_numeric(n)
        when Rational
          num, den = n.numerator, n.denominator
        end
        return sign, num, den
      end

      def __float2ratio2(n, d)
        num = den = nil
        sign = false
        if n < 0 || d < 0
          sign = !(n < 0 && d < 0)
          n = n.abs
          d = d.abs
        end
        if (n.is_a? Integer) && (d.is_a? Integer)
          num, den = n, d
        elsif (n.is_a? Float) || (d.is_a? Float) || (n.is_a? Rational) || (d.is_a? Rational)
          num, den = __ratio_from_numeric2(n, d)
        end
        return sign, num, den
      end

      def __ratio_from_numeric(n)
        @@precision ||= (SYM_CONFIG[:ratio_precision] || 1e-16)
        if n.is_a? Integer
          return n, 1
        elsif n.is_a? Rational
          return n.numerator, n.denominator
        end
        n1, n2 = 1, 0
        d1, d2 = 0, 1
        v = n
        loop do
          v1 = v.floor
          tmp = n1
          n1 = v1 * n1 + n2
          n2 = tmp

          tmp = d1
          d1 = v1 * d1 + d2
          d2 = tmp
          v = 1.0 / (v - v1)
          break if ((n - n1 / d1.to_f).abs < n * @@precision) || (v == Float::INFINITY)
        end
        #t = n.round
        #return t,1 if (d1*t - n1/d1.to_f).abs < n * @@precision
        return n1, d1
      end

      # Given two numbers `a` and `b`, and knowing
      # at least one is a float (or a rational), it computes
      # the numerator and the denominator of the division
      # `a/b`
      def __ratio_from_numeric2(a, b)
        n1, d1 = __ratio_from_numeric(a)
        n2, d2 = __ratio_from_numeric(b)
        return n1 * d2, d1 * n2
      end

      def __mcd(a, b)
        return 1 if a.zero? || b.zero?
        a, b = b, a unless b < a
        while b != 0
          a, b = b, a % b
        end
        return a
      end
    end
  end
end
