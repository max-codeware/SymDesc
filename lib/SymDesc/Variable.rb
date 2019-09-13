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

  # __     __         _       _     _
  # \ \   / /_ _ _ __(_) __ _| |__ | | ___
  #  \ \ / / _` | '__| |/ _` | '_ \| |/ _ \
  #   \ V / (_| | |  | | (_| | |_) | |  __/
  #    \_/ \__,_|_|  |_|\__,_|_.__/|_|\___|

  ##
  # This class describes a symbolic variable. It can be resolved
  # with a numerical value or substituted with another expression.
  class Variable
    REQUIRES_BASIC_OP = true
    include Base

    class << self
      alias :__new :new
      private :__new

      VAR_ID = "@__vars__"
      private_constant :VAR_ID

      def sym_config # :nodoc:
        @@sym_config ||= (SYM_CONFIG[:var_scope] || :global)
      end

      def __new__(name, object) # :nodoc:
        name = __var_name name
        __ensure_config :local unless object.is_a? Dynamic
        if object.instance_variable_defined? VAR_ID
          v = object.instance_variable_get VAR_ID
          var = v[name] || (v[name] = __new(name))
        else
          var = __new(name)
          object.instance_variable_set VAR_ID, { name => var }
        end
        return var
      end

      def new(name)
        name = __var_name name
        __ensure_config :global
        @@syms ||= {}
        return @@syms[name] || (@@syms[name] = super(name))
      end

      private

      def __var_name(name)
        name = name.to_sym if name.is_a? String
        raise ArgumentError,
              "A variable name must be a Symbol or a String" unless name.is_a? Symbol
        return name
      end

      def __ensure_config(type)
        @@sym_config ||= (SYM_CONFIG[:var_scope] || :global)
        case @@sym_config
        when :local
          unless type == :local
            msg = "Warning: variable creation without a definition scope. Use `vars' method instead"
            loc = caller[1]
            warn msg, loc
          end
        when :global
          raise SymDescError,
                "Variable configuration set to global (requested #{type})" unless type == :global
        else
          raise SymDescError, "Invalid variable visibility configuration (got #{@@sym_config})"
        end
      end
    end

    attr_reader :name, :default_value

    def initialize(name) # :nodoc:
      @name = name
      @default_value = nil
    end

    def default_value=(value)
      raise ArgumentError, "Numeric value expected but \
                    #{value.is_a?(Class) ? value : value.class} found" unless value.is_a? Numeric
      @default_value = value
    end

    # :call-seq:
    #   var + obj -> new_obj
    #
    # It sums `obj` to the variable `var` returning
    # a new symbolic object. Simplification is automatic.
    #
    # If `obj` is not a symbolic object, a conversion is attempted
    def +(b)
      b = b.symdescfy
      case b
      # when self.class
      #   __sum_self b
      # when Neg
      #   self - b.argument
      when BinaryOp
        b + self
        # when Numeric
        #   __sum_numeric b
      else
        #   Sum.new(self, b)
        super
      end
    end

    def opt_sum(b) # :nodoc:
      # return self if b == 0
      # if self == b
      #   return Prod.new(TWO, self)
      # end
      # nil
      return self + b if self =~ b
      super
    end

    # :call-seq:
    #   var - obj -> new_obj
    #
    # It subtracts `obj` to the variable `var` returning
    # a new symbolic object. Simplification is automatic.
    #
    # If `obj` is not a symbolic object, a conversion is attempted
    def -(b)
      b = b.symdescfy
      case b
      # when self.class
      #   __sub_self b
      # when Neg
      #   self + b.argument
      when BinaryOp
        __sub_binaryop b
        # when Numeric
        #   __sub_numeric b
      else
        #  Sub.new(self, b)
        super
      end
    end

    def opt_sub(b) # :nodoc:
      # return self if b == 0
      return self - b if self =~ b
      super
    end

    def *(b)
      b = b.symdescfy
      case b
      when Prod, Div, Power
        b * self
      else
        super
      end
    end

    def opt_prod(b)
      (self =~ b) ? self * b : super
    end

    # :call-seq:
    #   var == obj -> true or false
    #
    # It compares `var` with `obj`, returning true if `obj`
    # is a Variable and has the same name
    def ==(b)
      return true if b.is_a?(Variable) && (b.name == name)
      false
    end

    def =~(b) # :nodoc:
      case b
      when Variable
        self == b
      when Prod, Div
        b =~ self
      else
        false
      end
    end

    # :call-seq:
    #   to_s -> string
    #   to_s(str_io) -> str_io
    #
    # If no argument is provided, it returns a string representation
    # of the symbolic variable. If a StringIO object is passed, the string
    # representation is appended to the buffer and this last is returned.
    def to_s(io = nil)
      if io
        __io_append(io, name)
        return io
      else
        return name.to_s
      end
    end

    alias :inspect :to_s

    def get_size # :nodoc:
      return @name.size
    end

    ##
    # :call-seq:
    #   depends_on?(var) -> true or false
    #
    # It returns true if the provided variable is equal to self
    def depends_on?(v)
      __dep_check(v) { return v == self }
    end

    def diff(*v)
      __diff(v) { ONE }
    end

    def vars(argv = [])
      argv << self unless argv.include? self
      argv
    end

    private

    # def __sum_self(b)
    #   return Prod.new(TWO, self) if self == b
    #   Sum.new(self, b)
    # end

    # def __sum_numeric(b)
    #   return self if b.zero?
    #   b = b.symdescfy if b.is_a? Float
    #   Sum.new(self, b)
    # end

    # def __sub_self(b)
    #   return ZERO if self == b
    #   Sub.new(self, b)
    # end

    def __sub_binaryop(b)
      tmp = nil
      case b
      when Sum
        tmp = self - b.left - b.right
      when Sub
        tmp = self - b.left + b.right
      when Prod
        if b =~ self
          tmp = (b.left == 2) ? self : Prod.new(ONE - l, self)
        end
      when Div
        if b =~ self
          n = self * b.right - b.left
          tmp = n / b.right
        end
      end
      return tmp || Sub.new(self, b)
    end

    # def __sub_numeric(b)
    #   return self if b == 0
    #   b = b.symdescfy if b.is_a? Float
    #   return Sub.new(self, b)
    # end
  end
end
