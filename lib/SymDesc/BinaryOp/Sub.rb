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
  class Sub < BinaryOp
    include Addition

    OP = :-

    class << self
      def new(left, right)
        return left if right == 0
        return right if left == 0
        #tmp = nil
        # if left.is_a?(Neg) && right.is_a?(Neg)
        #	return Sub.new
        return super
      end
    end

    def -@
      return Sub.new @right, @left
    end

    def to_s(io = nil)
      _io = io || __new_io(get_size)
      __io_append(_io, @left, SPACE, SUB_ID, SPACE, @right)
      if !io
        _io.close
        return _io.string
      end
      io
    end

    private

    def __sum_else(b)
      if tmp = @left.opt_sum(b)
        tmp - @right
      elsif tmp = @right.opt_sum(b)
        @left - tmp
      else
        Sum.new self, b
      end
    end

    def __sub_else(b)
      if tmp = @left.opt_sub(b)
        tmp - @right
      elsif tmp = @right.opt_sub(b)
        @left - tmp
      else
        Sub.new self, b
      end
    end
  end
end
