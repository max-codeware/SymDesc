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

module SymDesc
  class Variable
    def subs(dict)
      __check_type dict, Hash
      return dict[self] || dict[@name] || self
    end
  end

  class Number
    def subs(dict)
      __check_type dict, Hash
      self
    end
  end

  class BinaryOp
    def subs(dict)
      __check_type dict, Hash
      return @left.subs(dict).send self.class::OP, @right.subs(dict)
    end
  end

  class Neg
    def subs(dict)
      __check_type dict, Hash
      return -(@argument.subs)
    end
  end

  class Constant
    def self.subs(dict)
      __check_type dict, Hash
      self
    end
  end

  class Function
    def subs(dict)
      __check_type dict, Hash
      return self.class.new @argument.subs(dict)
    end
  end
end
