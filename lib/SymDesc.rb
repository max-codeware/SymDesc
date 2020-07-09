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

##
# This module is internally used to determine whether the CAS
# system is running under ruby or mruby.
module ENGINE
  class << self
    def ruby?
      RUBY_ENGINE == "ruby"
    end

    def mruby?
      RUBY_ENGINE == "mruby"
    end
  end
  freeze
end

module SymDesc
  class RecursionError < SystemStackError; end
  class SymDescError < StandardError; end

  if ENGINE.mruby?
    engine = :mruby
    if !Kernel.respond_to? :require
      raise SymDescError, "mrbgem-require not found for mruby. Please install it"
    end
    require File.expand_path("./SymDesc/Extra/mruby.rb", File.dirname(__FILE__))
  elsif ENGINE.ruby?
    engine = :ruby
    require_relative "SymDesc/Extra/ruby.rb"
  else
    raise SymDescError, "Ruby engine #{RUBY_ENGINE} not supported yet"
  end

  SYM_CONFIG = {
    :ratio_precision => 1e-16,      # Precision adopted to convert floats into rationals
    :symdesc_engine => engine,      # Engine SymDesc is running on (ruby/mruby)
    :var_scope => :global,          # Scope of symbolic variables (:global/:local)
  }

  %w|
    SymDesc/Overload/Numeric.rb
    SymDesc/Overload/Object.rb
    SymDesc/Overload/Symbol.rb
    SymDesc/Overload/Kernel.rb
    SymDesc/Dynamic.rb
    SymDesc/Base.rb
    SymDesc/BasicOp
    SymDesc/Variable.rb
    SymDesc/DependentVar.rb
    SymDesc/Neg.rb
    SymDesc/Differential.rb
    SymDesc/Number/Number.rb
    SymDesc/Number/Int.rb
    SymDesc/Number/Ratio.rb
    SymDesc/BinaryOp/BinaryOp.rb
    SymDesc/BinaryOp/Addition.rb
    SymDesc/BinaryOp/Sum.rb
    SymDesc/BinaryOp/Sub.rb
    SymDesc/BinaryOp/Prod.rb
    SymDesc/BinaryOp/Div.rb
    SymDesc/BinaryOp/Power.rb
    SymDesc/Constants/Constant.rb
    SymDesc/Constants/E.rb
    SymDesc/Constants/Pi.rb
    SymDesc/Constants/Nan.rb
    SymDesc/Constants/Infinity.rb
    SymDesc/Functions/Function.rb
    SymDesc/Functions/Log.rb
    SymDesc/Functions/Sin.rb
    SymDesc/Functions/Cos.rb
    SymDesc/Util/Subs.rb
    SymDesc/Util/Clone.rb
  |.each do |file|
    require_relative file
  end

  ZERO = Int.new 0
  ONE = Int.new 1
  TWO = Int.new 2
end
