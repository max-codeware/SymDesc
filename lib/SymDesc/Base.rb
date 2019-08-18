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

#  ____
# | __ )  __ _ ___  ___
# |  _ \ / _` / __|/ _ \
# | |_) | (_| \__ \  __/
# |____/ \__,_|___/\___|

##
# SymDesc::Base is the basic module included or extedned by
# all the symbolic objects. It includes some basic methods,
# constants and virtual methods that should be common
# to all the objects or classes.
module SymDesc::Base
  SUM_ID = "+"
  SUB_ID = "-"
  MUL_ID = "*"
  DIV_ID = "/"
  POW_ID = "**"
  SPACE = " "
  LPAR = "("
  RPAR = ")"

  REQUIRES_BASIC_OP = false

  class Bug < StandardError; end

  def self.included(klass)
    if klass.const_defined?(:REQUIRES_BASIC_OP) && klass::REQUIRES_BASIC_OP
      klass.include SymDesc::BasicOp
    end
  end

  def self.extended(klass)
    if klass.const_defined?(:REQUIRES_BASIC_OP) && klass::REQUIRES_BASIC_OP
      klass.extend SymDesc::BasicOp
    end
  end

  ##
  # Returns always true. Every object that includes
  # this module or class that extends SymDesc::Base is
  # automatically considered as symbolic
  def is_symbolic?
    return true
  end

  def =~(b) # :nodoc:
    false
  end

  %w|+ - * / **
     opt_sum opt_sub opt_prod opt_div opt_pow
     get_size to_s
     diff diff!
     sub sub!
     depends_on?|.each do |name|
    abstract_method name
  end

  protected

  ##
  # Method used as helper routine to append the string representation
  # of symbolic objects to the buffer. This helps improving performances
  # avoiding many allocations of little strings.
  def __io_append(io, *args)
    raise ArgumentError,
          "Expected StringIO (#{io.class}) found" unless io.is_a? StringIO
    args.each do |a|
      begin
        if a.is_symbolic?
          a.to_s(io)
        else
          io << a
        end
      rescue SystemStackError => e
        raise RecursionError, "\
                    Recursive call to :__io_append detected\n\
                    #{e.backtrace}"
      end
    end
  end

  ##
  # This is an internal helper routine for differential operation. It unifies the operations
  # on the provided splat to the method `diff' exposed as API.
  # It accepts only an array of variables as argument and a block with the code for the differential.
  #
  # The usage is this:
  # ```
  # class Variable
  #   def diff(*vars)
  #     return __diff(vars) { |var| var == self ? 1 : 0 }
  #   end
  # end
  # ```
  #
  # So that the behavour of `Variable#diff` is:
  # ```
  # x,y,z = var :x, :y, :z
  #
  # x.diff x     #=> 1
  # x.diff y     #=> 0
  # x.diff x,y,z #=> [1,0,0]
  # x.diff       #=> []
  # ```
  def __diff(ary)
    raise Bug, "Internal method `__diff' accepts only an array as argument" unless ary.is_a? Array
    if ary.size == 1
      return yield ary[0]
    else
      return ary.map { |var| (var.is_a?(Variable) && depends_on?(var)) ? yield(var) : ZERO }
    end
  end

  # This is a helper function for method `depends_on` that avoids duplications of code
  # for the argumet check.
  #
  # The usage is this:
  # ```
  # def depends_on?(v)
  #   __dep_check(v) { ... }
  # end
  # ```
  # This routine doesn't affect the result of the passed block
  def __dep_check(v)
    raise ArgumentError, "Expected Variable but #{v.is_a?(Class) ? v : v.class}" unless v.is_a? Variable
    yield
  end

  if ENGINE.mruby?

    ##
    # Optimized string buffer for mruby engine
    def __new_io(size)
      return StringIO.new String.buffer(size)
    end
  else

    ##
    # Optimized string buffer for ruby engine
    def __new_io(size)
      return StringIO.new String.new(capacity: size)
    end
  end
end
