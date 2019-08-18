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

  #  ____                _
  # |  _ \ _ __ ___   __| |
  # | |_) | '__/ _ \ / _` |
  # |  __/| | | (_) | (_| |
  # |_|   |_|  \___/ \__,_|

  class Prod < BinaryOp
    class << self
      def new(left, right)
        return ZERO if left == 0 || right == 0
        return left if right == 1
        return right if left == 1
        return super
      end
    end

    def +(b)
      return TWO * b if self == b
      b = b.symdescfy
      case b
      when Variable
        __sum_variable b
      when Prod, Div
        __sum_prod_div b
      else
        __sum_else b
      end
    end

    def opt_sum(b) #:nodoc:
      return self =~ b ? (self + b) : nil
    end

    def -(b)
      return ZERO if self == b
      b = b.symdescfy
      case b
      when Variable
        __sub_variable b
      when Prod, Div
        __sub_prod_var b
      else
        __sub_else b
      end
    end

    def opt_sub(b) # :nodoc:
      return self =~ b ? (self - b) : nil
    end

    def to_s(io = nil)
      _io = io || __new_io(get_size)
      __prod_append(_io, @left)
      __io_append(_io, SPACE, MUL_ID, SPACE)
      __prod_append(_io, @right)
      return io ? io : (_io.close; _io.string)
    end

    def =~(b) # :nodoc:
      return false unless (@left.is_a? Number)
      case b
      when Variable
        (@right == b)
      when Prod
        (b.left.is_a? Number) && (@right == b.right)
      when Div
        (@right == b.left) && (b.right.is_a? Number)
      else
        @right == b
      end
    end

    def get_size # :nodoc:
      size = @left.get_size +
             (@left.is_a?(Prod) ? 0 : 2)
      size += 3
      size += @right.get_size +
              (@right.is_a?(Prod) ? 0 : 2)
      return size
    end

    # Returns true if the formact of the product is in
    # the form `n * v` where `n` is a number and `v` a
    # symbolic variable
    def nv_form?
      (@left.is_a?(Number) && @right.is_a?(Variable))
    end

    private

    def __prod_append(io, branch)
      unless (branch.is_a? Prod) || !(branch.is_a? BinaryOp)
        __io_append(io, LPAR, branch, RPAR)
      else
        __io_append(io, branch)
      end
    end

    def __sum_variable(b)
      return self =~ b ? (Prod.new(@left + 1, @right)) : Sum.new(self, b)
    end

    def __sum_prod_div(b)
      return Sum.new(self, b) unless self =~ b
      case b
      when Prod
        (@left + b.left) * (@right)
      when div
        (@left / b.right) * @right
      end
    end

    alias :__sum_else :__sum_variable
    # def __sum_else(b)
    #     return self =~ b ? (Prod.new(@left + 1, @right)) : Sum.new(self,b)
    # end

    def __sub_variable(b)
      return self =~ b ? (@left - 1 * @right) : Sub.new(self, b)
    end

    def __sub_prod_div(b)
      return Sub.new(self, b) unless self =~ b
      case b
      when Prod
        (@left - b.left) * (@right)
      when Div
        r = bright
        Ratio.new(@left * r - 1, r) * @right
      end
    end

    alias :__sum_else :__sum_variable
    # def __sub_else(b)
    #     return self =~ b ? (@left - 1, @right) : Sub.new(self,b)
    # end

  end
end
