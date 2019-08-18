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

  #  _   _
  # | \ | | ___  __ _
  # |  \| |/ _ \/ _` |
  # | |\  |  __/ (_| |
  # |_| \_|\___|\__, |
  #             |___/

  ##
  # This class represents the unary negation of a symbolic
  # object. It simply wraps a symbolic expression and manipulates
  # it accurding to unary negation.
  class Neg
    include Base

    attr_reader :argument

    class << self

      ##
      # Creates a new negated expression with automatic
      # simplification if necessary.
      # If the passed object is not a symbolic one,
      # a conversion is attempted.
      def new(arg)
        arg = arg.symdescfy
        return arg if arg == 0
        return arg.argument if arg.is_a? Neg
        return super(arg)
      end
    end

    def initialize(argument)
      @argument = argument
    end

    ##
    # :call-seq:
    #   neg + obj -> new_obj
    #
    # It sums `obj` to `neg` returning a new object
    # as result of the operation.
    #
    # Automatic simplifications are:
    # ```
    # (-a) + b    -> b - a
    # (-a) + (-b) -> -(a + b)
    # ```
    #
    # If `obj` is not symbolic, a conversion is attempted
    def +(b)
      b = b.symdescfy
      case b
      when Neg
        -(@argument + b.argument)
      else
        b - @argument
      end
    end

    def opt_sum(b) # :nodoc:
      if b.is_a? Neg
        tmp = @argument.opt_sum b.argument
        tmp &&= -tmp
      else
        tmp = b.opt_sub @argument
      end
      tmp
    end

    ##
    # :call-seq:
    #   neg - obj -> new_obj
    #
    # It subtracts `obj` to `neg` returning a new object
    # as result of the operation.
    #
    # Automatic simplifications are:
    # ```
    # (-a) - b    -> -(a + b)
    # (-a) - (-b) -> b - a
    # ```
    #
    # If `obj` is not symbolic, a conversion is attempted
    def -(b)
      b = b.symdescfy
      case b
      when Neg
        b.argument - @argument
      else
        -(@argument + b)
      end
    end

    def opt_sub(b) # :nodoc:
      if b.is_a? Neg
        tmp = b.argument.opt_sub @argument
      else
        tmp = b.opt_sum @argument
        tmp &&= -tmp
      end
      tmp
    end

    ##
    # :call-seq:
    #   neg * obj -> new_obj
    #
    # It multiplies `neg` and `obj` returning a new object
    # as result of the operation.
    #
    # Automatic simplifications are:
    # ```
    # (-a)(-b)    -> ab
    # -a * b      -> -(ab)
    # ```
    #
    # If `obj` is not symbolic, a conversion is attempted
    def *(b)
      b = b.symdescfy
      case b
      when Neg
        @argument * b.argument
      else
        -(@argument * b)
      end
    end

    def opt_prod(b) # :nodoc:
      if b.is_a? Neg
        tmp = @argument.opt_prod b.argument
      else
        tmp = @argument.opt_prod b
        tmp &&= -tmp
      end
      tmp
    end

    ##
    # :call-seq:
    #   neg / obj -> new_obj
    #
    # It divides `neg` by `obj` returning a new object
    # as result of the operation.
    #
    # Automatic simplifications are:
    # ```
    # (-a)\(-b)   -> -(a\b)
    # (-a)\b      -> -(b\a)
    # ```
    #
    # If `obj` is not symbolic, a conversion is attempted
    def /(b)
      b = b.symdescfy
      case b
      when Neg
        @argument / b.argument
      else
        -(@argument / b)
      end
    end

    def opt_div(b) # :nodoc:
      if b.is_a? Neg
        tmp = @argument.opt_div b.argument
      else
        tmp = @argument.opt_div b
        tmp &&= -tmp
      end
      tmp
    end

    ##
    # :call-seq:
    #   -neg -> argument
    #
    # It performs the unary negation of `neg`.
    # Since simplification is automatic it returns the
    # argument of `neg`
    def -@
      @argument
    end

    ##
    # :call-seq:
    #   `neg` == `obj`
    #
    # It compares `obj` with `neg`, returning true if `obj`
    # is a Neg and has the same argument.
    def ==(obj)
      obj = obj.symdescfy
      return true if obj.is_a?(Neg) && obj.argument == argument
      false
    end

    ##
    # :call-seq:
    #   to_s -> string
    #   to_s(str_io) -> str_io
    #
    # If no argument is provided, it returns a string representation
    # of the unary negation. If a StringIO object is passed, the string
    # representation is appended to the buffer and this last is returned.
    def to_s(io = nil)
      _io = io || __new_io(get_size)
      case argument
      when Sum, Sub
        __io_append(_io, SUB_ID, "(", @argument, ")")
      else
        __io_append(_io, SUB_ID, @argument)
      end
      return io ? io : (_io.clese; _io.string)
    end

    alias :inspect :to_s

    def get_size # :nodoc:
      extra = 1
      if (@argument.is_a? Sum) || (@argument.is_a? Sub)
        extra += 2
      end
      return @argument.get_size + extra
    end

    def depends_on?(v)
      __dep_check(v) { @argument.depends_on? v }
    end

    def diff(*v)
      __diff(v) { |var| @argument.depends_on?(var) ? -@argument.diff(var) : ZERO }
    end
  end
end
