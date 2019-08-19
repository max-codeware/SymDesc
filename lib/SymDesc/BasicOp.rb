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
      __op b do |v|
        case v
        when Neg
          self - v.argument
        when 0
          self
        when self
          SymDesc::TWO * self
        when Nan
          v
        else
          Sum.new(self, v)
        end
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
      __op b do |v|
        case v
        when Neg
          self + v.argument
        when 0
          self
        when self
          SymDesc::ZERO
        when Nan
          v
        else
          Sub.new(self, v)
        end
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
      __op b do |v|
        case v
        when 0, Nan
          v
        when self
          Power.new(self, SymDesc::TWO)
        when Neg
          -(self * v.argument)
        else
          v.is_a?(Number) ? Prod.new(v, self) : Prod.new(self, v)
        end
      end
    end

    def opt_prod(b)
      case b
      when 0, Nan
        b
      when self
        Power.new(self, SymDesc::TWO)
      when Neg
        (tmp = opt_prod(b.argument)) ? -tmp : tmp
      else
        nil
      end
    end

    def /(b)
      __op b do |v|
        case v
        when 0
          Infinity
        when Nan
          v
        when Neg
          -(self / v.argument)
        else
          Div.new(self, v)
        end
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

    def **(b)
      __op b do |v|
        case v
        when 0
          SymDesc::ONE
        when Neg
          SymDesc::ONE / self ** v.value
        when Nan
          v
        else
          Power.new(self, v)
        end
      end
    end

    def opt_pow(b)
      case b
      when 0
        SymDesc::ONE
      when Neg
        (tmp = opt_pow(b.argument)) ? SymDesc::ONE / tmp : tmp
      when Nan
        b
      else
        nil
      end
    end

    protected

    def __op(v)
      yield v.symdescfy
    end
  end
end
