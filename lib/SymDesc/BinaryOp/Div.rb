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

  #  ____  _
  # |  _ \(_)_   __
  # | | | | \ \ / /
  # | |_| | |\ V /
  # |____/|_| \_/
  class Div < BinaryOp
    OP = :/

    class << self
      def new(left, right)
        case
        when left == 0 && right == 0
          Nan
        when left == 0
          ZERO
        when right == 0
          left.is_a?(Neg) ? -Infinity : Infinity
        else
          super
        end
      end
    end

    def +(b)
      b = b.symdescfy
      case b
      when Div
        __sum_div b
        # when Power
      else
        super
      end
    end

    def opt_sum(b) # :nodoc:
      super
    end

    def -(b)
      b = b.symdescfy
      case b
      when Div
        __sub_div b
        # when Power
      else
        super
      end
    end

    def opt_sub(b) # :nodoc:
      super
    end

    def get_size # :nodoc:
      size = @left.get_size +
             (@left.is_a?(Sum) || @left.is_a?(Sub) ? 0 : 2)
      size += 3
      size += @right.get_size +
              (@right.is_a?(BinaryOp) ? 0 : 2)
      return size
    end

    def to_s(io = nil)
      _io = io || __new_io(get_size)
      __op_append(_io, @left, :l)
      __io_append(_io, SPACE, DIV_ID, SPACE)
      __op_append(_io, @right, :r)
      return io ? io : (_io.close; _io.string)
    end

    def diff(*v)
      __diff(v) do |var|
        lft = @left.diff(var)
        rht = @right.diff(var)
        return (lft * @right - @left * rht) / @right ** TWO
      end
    end

    private

    def __op_append(io, branch, kind)
      case kind
      when :l
        branch.is_a?(Sum) || branch.is_a?(Sub) || branch.is_a?(Power) ?
          __io_append(io, LPAR, branch, RPAR) :
          __io_append(io, branch)
      when :r
        branch.is_a?(BinaryOp) ?
          __io_append(io, LPAR, branch, RPAR) :
          __io_append(io, branch)
      else
        raise Bug, "Unknown branch type #{kind}"
      end
    end

    def __sum_div(b)
      return self * TWO if self == b
      return (@left * b.right + b.left * @right) / @right * b.right
    end

    def __sub_div(b)
      return ZERO if self == b
      return (@left * b.right - b.left * @right) / @right * b.right
    end
  end
end
