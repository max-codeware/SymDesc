# MIT License
#
# Copyright (c) 2020 Massimiliano Dal Mas
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
  class Differential
  	REQUIRES_BASIC_OP = true
    include Base

    def self.new(exp, var)
      @exp = exp.symdescfy
      var = var.symdescfy
      if exp == var
        ONE
      elsif !exp.depends_on?(var)
        ZERO
      elsif exp.is_a? DependentVar
        index = exp.args.index(var)
        super(exp, index)
      else
        exp.diff(var)
      end  
    end

    def initialize(exp, arg_index)
      __check_type(arg_index, Integer)
      @exp = exp 
      @arg_index = [arg_index]
    end

    def to_s(io = nil)
      _io = io || __new_io(get_size)
      __io_append(_io, "Diff", indices, LPAR, @exp, RPAR)
      io ? io : (_io.close; _io.string)
    end

    alias :inspect :to_s

    def indices
      @arg_index.map(&:next)
    end

    def get_size 
      7 + @exp.get_size + @arg_index.size * 2 - 1
    end

    def depends_on?(v)
      @exp.depends_on? v
    end

    def diff(*v)
      args = @exp.args
      __diff(v) do |var| 
        idx = __get_dep_idx_wrt(var)
        if idx.empty?
          raise Bug, "No dependency on `#{var}' found"
        else
          d = ZERO
          idx.each do |i|
            cloned = self.clone 
            cloned.arg_index << i
            d += cloned * args[i].diff(v)
          end
          next d
        end
      end
    end

  protected
    
    def arg_index
      @arg_index
    end

    def arg_index=(array)
      @arg_index = array
    end

  private

  def __get_dep_idx_wrt(v)
    idx = []
    @exp.args.each_with_index do |arg, i|
      idx << i if arg.depends_on?(v)
    end
    return idx
  end
    
  end
end