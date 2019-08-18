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
  module BasicOp
    def +(b)
      case b
      when Neg
        self - b.argument
      when 0
        self
      when self
        TWO * self
      when Nan
        b
      else
        Sum.new(self, b)
      end
    end

    def opt_sum(b)
      case b
      when 0, self, Nan
        self + b
      when Neg
        opt_sub b.argument
      else
        nil
      end
    end

    def -(b)
      case b
      when Neg
        self + b.argument
      when 0
        self
      when self
        ZERO
      when Nan
        b
      else
        Sub.new(self, b)
      end
    end

    def opt_sub(b)
      case b
      when 0, self, Nan
        self - b
      when Neg
        opt_sum b.argument
      else
        nil
      end
    end

    def -@
      Neg.new self
    end

    def *(b)
      case b
      when 0, Nan
        b
      when Neg
        -(self * b.argument)
      else
        b.is_a?(Number) ? Prod.new(b, self) : Prod.new(self, b)
      end
    end

    def opt_prod(b)
      case b
      when 0, Nan
        b
      when Neg
        (tmp = opt_prod(b.argument)) ? -tmp : tmp
      else
        nil
      end
    end

    def /(b)
      case b
      when 0
        Infinity
      when Nan
        b
      when Neg
        -(self / b.argument)
      else
        Div.new(self, b)
      end
    end

    def opt_div(b)
      case b
      when 0, Nan
        self / b
      when Neg
        (tmp = opt_div(b.argument)) ? -tmp : tmp
      else
        nil
      end
    end
  end
end
