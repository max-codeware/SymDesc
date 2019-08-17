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

  #  ____  _                         ___
  # | __ )(_)_ __   __ _ _ __ _   _ / _ \ _ __
  # |  _ \| | '_ \ / _` | '__| | | | | | | '_ \
  # | |_) | | | | | (_| | |  | |_| | |_| | |_) |
  # |____/|_|_| |_|\__,_|_|   \__, |\___/| .__/
  #                           |___/      |_|

  ##
  # This class represents a generic binary operation and it is inherited
  # by the main algebric operations
  class BinaryOp
    include Base

    attr_reader :left, :right

    ##
    # It creates and initializes a new instance of binary operation
    # ensuring the passed arguments are of symboli type.
    def initialize(left, right)
      [left, right].each { |v|
        raise ArgumentError,
              "Expected symbolic object but #{v.is_a?(Class) ? v : v.class} found" unless v.is_symbolic?
      }
      @left = left
      @right = right
    end

    def -@
      Neg.new self
    end

    def depends_on?(v)
      __dep_check(v) { return @left.depends_on(v) || @right.depends_on(v) }
    end

    ##
    # :call-seq:
    #   self == obj
    # Returns true only if 'obj' represents the same operation
    # with the same arguments
    def ==(b)
      (self.class == b.class) &&
      (((left == b.left) && (right == b.right)) ||
       ((left == b.right) && (right == b.left)))
    end

    def get_size # :nodoc:
      return @left.get_size + @right.get_size + 3
    end

    protected

    def left=(b)
      @left = left
    end

    def right=(b)
      @right = right
    end
  end
end
