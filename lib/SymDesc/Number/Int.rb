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
  #  ___       _
  # |_ _|_ __ | |_
  #  | || '_ \| __|
  #  | || | | | |_
  # |___|_| |_|\__|

  ##
  # This class represents and wraps an integer value
  # as a symbolic int.
  class Int < Number
    class << self

      ##
      # :call-seq:
      #   new(i) -> new_int
      #
      # It creates a new SymDesc::Int from a ruby Integer.
      # If i < 0, the result is wrapped into SymDesc::Neg.
      def new(v)
        raise ArgumentError,
              "Expected Integer argument but #{v.class} found" unless v.is_a? Integer
        return ZERO if v.zero? && const_defined?(:ZERO)
        if v < 0
          return Neg.new super v.abs
        end
        return super v
      end
    end

    attr_reader :value

    def initialize(n)
      @value = n
      freeze
    end

    ##
    # :call-seq:
    #   int + obj -> new_obj
    #
    # Performs a symbolic sum between a symbolic integer
    # and `obj`, returning a new symbolic object if the operation
    # creates a new tree branch, or a symbolic number if
    # `obj` is a SymDesc::Number. Simplification is automatic.
    #
    # If `obj` is not a symbolic object, a conversion is attempted
    def +(b)
      return self if b == 0
      return Int.new(@value + b) if b.is_a? Integer
      b = b.symdescfy
      case b
      when Ratio, BinaryOp
        b + self
      when Int
        Int.new(@value + b.value)
      when Neg
        self - b.argument
      else
        Sum.new(b, self)
      end
    end

    def opt_sum(b) # :nodoc:
      if b.is_a? Number
        return self + b
      end
      nil
    end

    ##
    # :call-seq:
    #   int - obj -> new_obj
    #
    # Performs a symbolic subtraction between a symbolic integer
    # and `obj`, returning a new symbolic object if the operation
    # creates a new tree branch, or a symbolic number if
    # `obj` is a SymDesc::Number. Simplification is automatic.
    #
    # If `obj` is not a symbolic object, a conversion is attempted
    def -(b)
      return self if b == 0
      return Int.new(@value - b) if b.is_a? Integer
      b = b.symdescfy
      case b
      when Ratio
        __sub_ratio b
      when Int
        Int.new(value - b.value)
      when Neg
        self + b.argument
      else
        Sub.new(self, b)
      end
    end

    def opt_sub(b) # :nodoc:
      if b.is_a? Number
        return self - b
      end
      nil
    end

    ##
    # Returns SymDesc::Int negated (wrapped in SymDesc::Neg class)
    def -@
      Neg.new(self)
    end

    ##
    # :call-seq:
    #   to_s -> string
    #   to_s(str_io) -> str_io
    #
    # If no argument is provided, it returns a string representation
    # of the integer value. If a StringIO object is passed, the string
    # representation is appended to the buffer and the buffer is returned.
    def to_s(io = nil)
      return io ? (io << @value) : @value.to_s
    end

    alias :inspect :to_s

    ##
    # :call-seq:
    #    int == obj -> true or false
    #
    # Returns true only if the `obj` is a SymDesc::Int
    # or an Integer or a Rational and it represents the same
    # numeric value
    def ==(b)
      case b
      when Int
        @value == b.value
      when Numeric
        @value == b
      else
        false
      end
    end

    def get_size # :nodoc:
      @value.get_size
    end

    private

    def __sub_ratio(b)
      n = value * b.denominator - b.numerator
      Ratio.new(n, b.denominator)
    end
  end
end
