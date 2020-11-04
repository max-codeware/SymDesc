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

module Kernel
  def var(*args)
    if SymDesc::Variable.sym_config == :global
      args.map! { |name| SymDesc::Variable.new name }
    else
      args.map! { |name| SymDesc::Variable.__new__ name, self }
    end
    return (args.size == 1) ? args[0] : args
  end

  def cas(*args)
    args.map! { |v| v.is_a?(Symbol) ? var(v) : v.symdescfy }
    return (args.size == 1) ? args[0] : args
  end

  def diff(obj, v)
    if obj.is_a? Array 
      return obj.map do |el|
        el.symdescfy.diff(v)
      end 
    end
    return obj.symdescfy.diff(v)
  end

  def abstract_method(name)
    define_method name do |*args|
      raise NotImplementedError, "Method `#{name}' for #{self.class} not implemented yiet"
    end
  end

  def dynamic(&block)
    SymDesc::Dynamic.new.instance_eval &block
  end

  private :var, :cas, :dynamic, :diff
end
