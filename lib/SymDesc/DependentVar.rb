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

  #  ____                            _            _ __     __         
  # |  _ \  ___ _ __   ___ _ __   __| | ___ _ __ | |\ \   / /_ _ _ __ 
  # | | | |/ _ \ '_ \ / _ \ '_ \ / _` |/ _ \ '_ \| __\ \ / / _` | '__|
  # | |_| |  __/ |_) |  __/ | | | (_| |  __/ | | | |_ \ V / (_| | |   
  # |____/ \___| .__/ \___|_| |_|\__,_|\___|_| |_|\__| \_/ \__,_|_|   
  #            |_|     

  ##                                               
  # This class implements a generic function such as
  # ```
  # x(t)
  # x(y(t), j)
  # ...
  # ```
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

    undef_method :default_value
    undef_method :"default_value="

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

    alias :inspect :to_s

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
      __check_type(v, Variable)
      return true if self == v 
      @args.each { |arg| return true if arg.depends_on? v} 
      return false
    end

    def diff(*v)
    	__diff(v) do |var|
        next ONE if self == var
        dep_vars = __get_dep_vars_wrt(var)
        if dep_vars.empty?
          raise Bug, "Dependency on #{var} not found"
        elsif dep_vars.size == 1 && dep_vars.first == var
          d = Differential.new(self, var)
        else 
          d = ZERO
          __tmp = var(:__tmp)
          dep_vars.each do |dv| 
            tmp = subs({dv => __tmp}, recursive: false)
            d += tmp.diff(__tmp).subs({__tmp => dv}) * dv.diff(var) 
          end
        end
        next d
    	end
    end

    def equals(b)
    	b    = b.symdescfy
      @exp = b
      return self
    end

    def arguments
    	@args.dup 
    end

    def vars(argv = [])
      argv << self.to_var
      @args.each { |a| a.vars(argv) }
      argv 
    end

    def free_vars(argv = [])
      @args.each { |a| a.free_vars(argv) }
      argv
    end

    def dependent_vars(argv = [])
      argv << self unless argv.include? self
      @args.each { |a| a.dependent_vars argv }
      argv 
    end
      

  private 

    def __get_dep_vars_wrt(v)
      vars = []
      @args.each do |arg|
        vars << arg if arg.depends_on?(v)
      end
      return vars
    end

    def __arg_check(type, *args, msg: "")
      args.each do |arg|
        raise ArgumentError, msg % arg.class unless arg.is_a? type
      end
    end
  end

end