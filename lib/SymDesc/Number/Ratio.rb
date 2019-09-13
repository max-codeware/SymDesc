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

require_relative "FloatConverter"

module SymDesc
  #  ____       _   _
  # |  _ \ __ _| |_(_) ___
  # | |_) / _` | __| |/ _ \
  # |  _ < (_| | |_| | (_) |
  # |_| \_\__,_|\__|_|\___/

  ##
  # Ratio is a representation of a rational number
  # in a symbolic form. This allows to express numeric
  # fractions with an infinite precision, as well as
  # performing simplifications between numbers.
  class Ratio < Number

    # Reopening Ratio metaclass to perform some metaprogramming
    # and to ensure a correct simplification to the given inputs

    class << self

      ##
      # :call-seq:
      #   new(Integer)  -> SymDesc::Int
      #   new(Float)    -> SymDesc::Ratio
      #   new(Rational) -> SymDesc::Ratio
      #   new(Integer,Integer) -> SymDesc::Ratio
      #
      # Creates a new symbolic rational performing the needed
      # simplifications. Parameters `n` and `d` can be Integer,
      # Float or Rational. If only 'n' is given, a new Ratio
      # is created with the correct simplifications.
      # If both 'n' and 'd' are provided, a new rational is created
      # simplifying `n/d` fraction.
      #
      # Note: A SymDesc::Int is returned if the fraction is in the form
      # `n/1`.
      #
      # No support for Float::INFINITY or Float::NAN
      def new(n, d = nil)
        __ensure_rationalizable(n, d)
        if !__have_nan_or_infinity(n, d)
          sign, num, den = FloatConverter.float_to_ratio_ary(n, d)
        end
        if ratio = FloatConverter.ratio_to_sd_ratio(num, den) { |n, d| super(n, d) }
          return sign ? Neg.new(ratio) : ratio
        end
        raise NotImplementedError,
              "Symbolic rationals for \
                        #{n}" << (d ? " and #{d} " : " ") << "not implemented yet"
      end

      private

      def __ensure_rationalizable(*values)
        values.each do |v|
          unless (v.is_a? Integer) ||
                 (v.is_a? Float) ||
                 (v.is_a? Rational) ||
                 (v.nil? && values.size > 1)
            raise ArgumentError,
                  "Expected Integer of Float but #{v.class} found"
          end
        end
      end

      def __have_nan_or_infinity(*val)
        val.each do |v|
          return true if (v.is_a? Float) && (v.nan? || v.infinite?)
        end
        false
      end
    end # End metaclass

    attr_reader :numerator
    attr_reader :denominator

    if ENGINE.mruby?
      def initialize(n, d) # :nodoc:
        @numerator = n.to_i
        @denominator = d.to_i
        freeze
      end
    else
      def initialize(n, d) # :nodoc:
        @numerator = n
        @denominator = d
        freeze
      end
    end

    ##
    # :call-seq:
    #   ratio + obj -> new_obj
    #
    # Performs a symbolic sum between a symbolic rational
    # and `obj`, returning a new symbolic object if the operation
    # creates a new tree branch, or a symbolic number if
    # `obj` is a SymDesc::Number. Simplification is automatic.
    #
    # If b is not a symbolic object, a conversion is attempted
    def +(b)
      b = b.symdescfy
      case b
      when Infinity
        b
      when Number
        __sum_number b
      when BinaryOp
        b + self
      else
        super
      end
    end

    def opt_sum(b) # :nodoc:
      # b = b.symdescfy
      return self + b if b.is_a?(Number)
      super
    end

    ##
    # :call-seq:
    #   ratio - obj -> new_obj
    #
    # Performs a symbolic subtraction between a symbolic rational
    # and `obj`, returning a new symbolic object if the operation
    # creates a new tree branch, or a symbolic number if
    # `obj` is a SymDesc::Number. Simplification is automatic.
    #
    # If b is not a symbolic object, a conversion is attempted
    def -(b)
      b = b.symdescfy
      case b
      when Infinity
        -b
      when Number
        __sub_number b
      when BinaryOp
        __sub_binary_op b
      when Neg
        self + b.argument
      else
        super
      end
    end

    def opt_sub(b) # :nodoc:
      # b = b.symdescfy
      return self - b if b.is_a?(Number)
      super
    end

    ##
    # :call-seq:
    #   ratio ** obj -> new_obj
    #
    # Performs a symbolic power between a symbolic rational
    # and `obj`, returning a new symbolic object if the operation
    # creates a new tree branch, or a symbolic number if
    # `obj` is a SymDesc::Number. Simplification is automatic.
    #
    # If b is not a symbolic object, a conversion is attempted
    def **(b)
      b = b.symdescfy
      case b
      when Infinity
        b
      when Int
        return Ratio.new(@numerator ** b.value, @denominator ** b.value)
      else
        super
      end
    end

    def opt_pow(b) # :nodoc:
      if b.is_a? Int
        return self ** b
      end
      super
    end

    ##
    # :call-seq:
    #    ratio == obj -> true or false
    #
    # Returns true only if the `obj` is a SymDesc::Ratio
    # or a Float or a Rational and it represents the same numeric value
    def ==(b)
      case b
      when Rational, Ratio
        (@numerator == b.numerator) &&
        (@denominator == b.denominator)
      when Float
        self == b.symdescfy
      else
        false
      end
    end

    ##
    # :call-seq:
    #   to_s -> string
    #   to_s(str_io) -> str_io
    #
    # If no argument is provided, it returns a string representation
    # of the fraction. If a StringIO object is passed, the string
    # representation is appended to the buffer and the buffer is returned.
    def to_s(io = nil)
      if io
        __io_append(io, @numerator, DIV_ID, @denominator)
      else
        return "#{@numerator}/#{@denominator}"
      end
      io
    end

    def get_size # :nodoc:
      return @numerator.get_size +
             @denominator.get_size +
             3
    end

    def to_ruby(io = nil)
      if io
        __io_append(io, @numerator, DIV_ID, @denominator.to_f)
      else
        return "#{@numerator}/#{@denominator.to_f}"
      end
      io
    end

    private

    def __sum_number(b)
      __send_op :+, b
    end

    def __sub_number(b)
      __send_op :-, b
    end

    def __send_op(op, b)
      if b.is_a? Ratio
        if denominator == b.denominator
          num = numerator.send op, b.numerator
          den = denominator
        else
          n1, n2 = numerator, b.numerator
          d1, d2 = denominator, b.denominator
          num = (n1 * d2).send op, n2 * d1
          den = d1 * d2
        end
        return Ratio.new num, den
      end
      d = denominator
      return Ratio.new numerator.send(op, b.value * d), d
    end

    def __sub_binary_op(b)
      case b
      when Sum
        self - b.left - b.right
      when Sub
        self - b.left + b.right
      else
        Sub.new b, self
      end
    end
  end
end
