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

  #   ____                _              _
  #  / ___|___  _ __  ___| |_ __ _ _ __ | |_
  # | |   / _ \| '_ \/ __| __/ _` | '_ \| __|
  # | |__| (_) | | | \__ \ || (_| | | | | |_
  #  \____\___/|_| |_|___/\__\__,_|_| |_|\__|

  ##
  # This is the base class of all math (and numeric)
  # constants that must be inherited by all the specific
  # subclasses implementing a specific cons.
  #
  # Symbolic constants are represented only by a singleton
  # class, that is instances of these classes are not allowed.
  # The reason of this is, considered the nature of the represented
  # object, creating multiple instances of something constant is
  # pointless.
  class Constant
    REQUIRES_BASIC_OP = true
    extend Base
    class << self
      undef_method :new

      ##
      # :call-seq:
      #   const + obj -> new_obj
      #
      # Performs a symbolic sum between a symbolic constant
      # and `obj`, returning a new symbolic object.
      # Simplification is automatic.
      #
      # If `obj` is not a symbolic object, a conversion is attempted
      def +(b)
        b = b.symdescfy
        case b
        when Infinity
          b
        else
          super
        end
      end

      def opt_sum(b) # :nodoc:
        if b == Infinity
          return b
        end
        super
      end

      ##
      # :call-seq:
      #   const - obj -> new_obj
      #
      # Performs a symbolic subtraction between a symbolic constant
      # and `obj`, returning a new symbolic object.
      # Simplification is automatic.
      #
      # If `obj` is not a symbolic object, a conversion is attempted
      def -(b)
        b = b.symdescfy
        case b
        when Infinity
          -b
        else
          super
        end
      end

      def opt_sub(b) # :nodoc:
        b = b.symdescfy
        if b == Infinity
          return -b
        end
        super
      end

      ##
      # Returns the constant negated (wrapped in SymDesc::Neg class)
      def -@
        Neg.new(self)
      end

      def get_size # :nodoc:
        1
      end

      ##
      # :call-seq:
      #   diff(var) -> symbolic_zero
      #   diff(*var) -> array
      #
      # It performs the derivative of a math constant on a
      # symbolic variable or a set of symbolic variables.
      # If only one variable is provided, it returns only a
      # symbolic object, while if multiple variables are provided,
      # an array of symbolic zeroes is returned
      def diff(*v)
        __diff(v) { ZERO }
      end

      ##
      # :call-seq
      #   depends_on?(var) -> false
      #
      # It returns always false because a math constant doesn't
      # depend on any variable
      def depends_on?(v)
        __dep_check(v) { return false }
      end

      def ===(b)
        return true if self == b
        super
      end

      def vars(argv = [])
        argv
      end
    end
  end
end
