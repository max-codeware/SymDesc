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
  class Number
    REQUIRES_BASIC_OP = true
    include Base

    ##
    # Returns SymDesc::Number negated (wrapped in SymDesc::Neg class)
    # This method is used by numeric subclasses
    def -@
      return Neg.new self
    end

    ##
    # :call-seq:
    #   number * obj -> new_obj
    #
    # Performs a symbolic multiplication between a symbolic rational
    # and `obj`, returning a new symbolic object if the operation
    # creates a new tree branch, or a symbolic number if
    # `obj` is a SymDesc::Number. Simplification is automatic.
    #
    # This method is used by SymDesc::Ratio ans SymDesc::Int
    # If b is not a symbolic object, a conversion is attempted
    def *(b)
      b = b.symdescfy
      case b
      when Number
        __prod_number(b)
      when Infinity
        b
      when Prod, Div
        b * self
      else
        super
      end
    end

    def opt_prod(b) # :nodoc:
      case b
      when Number, Infinity
        self * b
      else
        super
      end
    end

    ##
    # :call-seq:
    #   number / obj -> new_obj
    #
    # Performs a symbolic division between a symbolic number
    # and `obj`, returning a new symbolic object if the operation
    # creates a new tree branch, or a symbolic number if
    # `obj` is a SymDesc::Number. Simplification is automatic.
    #
    # This method is used by SymDesc::Ratio ans SymDesc::Int
    # If b is not a symbolic object, a conversion is attempted
    def /(b)
      b = b.symdescfy
      case b
      when Number
        __div_number(b)
      when Infinity
        ZERO
      else
        super
      end
    end

    def opt_div(b) # :nodoc:
      case b
      when Number, Infinity
        self / b
      else
        super
      end
    end

    def diff(*v)
      __diff(v) { ZERO }
    end

    ##
    # It returns always false since no number depends on any variable
    def depends_on?(v)
      __check_type(v, Variable)
      return false
    end

    ##
    # Same as `to_s`
    def inspect(io = nil)
      to_s io
    end

    alias :to_ruby :inspect

    def vars(argv = [])
      argv
    end

    protected

    def __prod_number(b)
      case
      when self.is_a?(Ratio) && b.is_a?(Ratio)
        Ratio.new(@numerator * b.numerator, @denominator * b.denominator)
      when self.is_a?(Int) && b.is_a?(Int)
        Int.new(@value * b.value)
      when self.is_a?(Int) && b.is_a?(Ratio)
        Ratio.new(@value * b.numerator, b.denominator)
      when self.is_a?(Ratio) && b.is_a?(Int)
        Ratio.new(b.value * @numerator, @denominator)
      else
        raise Bug, "Received unhandled Number type (#{b.inspect})"
      end
    end

    def __div_number(b)
      case
      when self.is_a?(Ratio) && b.is_a?(Ratio)
        Ratio.new(@numerator * b.denominator, @denominator * b.numerator)
      when self.is_a?(Int) && b.is_a?(Int)
        Ratio.new(@value, b.value)
      when self.is_a?(Int) && b.is_a?(Ratio)
        Ratio.new(@value * b.denominator, b.numerator)
      when self.is_a?(Ratio) && b.is_a?(Int)
        Ratio.new(@numerator, @denominator * b.value)
      else
        raise Bug, "Received unhandled Number type (#{b.inspect})"
      end
    end
  end
end
