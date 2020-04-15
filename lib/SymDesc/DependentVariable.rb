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

  class DependentVar < Variable

  	class << self
      undef_method :sym_config
      undef_method :__new__
      undef_method :__var_name
      undef_method :__ensure_config

      def new(var, *args)
        obj = self.allocate
        obj.send :initialize, var, *args
        return obj
      end
  	end

  	attr_reader :name, :args, :diff
  
    def initialize(var, *args)
    	__arg_check(Variable, var, msg: "Expected Variable or DependentVar, not %s")
    	__arg_check(Variable, *args, msg: "Expected Variable or DependentVar, not %s")
      @name = var 
      @args = args
      @exp  = nil
    end

    def ==(b)
    	return b.is_a?(DependentVar) && 
    	       (@name == b.name)     &&
    	       (@args == b.args)
    end

    def to_s(io = nil)
      _io = io || __new_io(get_size)
      __io_append(_io,@name, LPAR, args.join(","), RPAR)
      io ? io : (_io.close; _io.string)
    end

    def to_ruby(io = nil)
      raise NotImplementedError, ":to_ruby not implemented yet for DependentVar. Use subs?"
    end

    def get_size # :nodoc:
      size = 6 + @name.get_size + (@args.empty? ? 0 : @args.size - 1)
      @args.each do |arg|
      	size = arg.get_size 
      end 
      return size
    end

    def depends_on?(v)
      @args.include? v
    end

    def diff(*v)
    	__diff(v) do |var|
        Differential.new self, v
    	end
    end

    def equals(b)
    	b    = b.symdescfy
      @exp = b
      return self
    end

    def argument
    	@args.dup 
    end

  private 

    def __arg_check(type, *args, msg: "")
      args.each do |arg|
        raise ArgumentError, msg % arg.class unless arg.is_a? type
      end
    end
  end

end