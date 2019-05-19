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
	unless respond_to? :require_relative
	    def require_relative(file)
	    	filename = caller.first
	    	while filename[-1] != ':'
	    		filename.chop!
	    	end
	    	filename.chop!
	    	filename = File.expand_path filename
	        require File.expand_path(file,File.dirname(filename))
	    end
	end

	unless respond_to? :warn
		def warn(msg, loc = nil)
			loc &&= "#{loc}: "
			$stderr << "#{loc}warning: #{msg}\n"
		end
	end
end

class StringIO
	
	def initialize(string = "")
		@buffer = string
		@closed = false
	end

	def <<(obj)
        if !@closed
        	case obj
        	    when Numeric, Symbol
        	    	@buffer << obj.to_s
        	    else
        	    	@buffer << obj
        	end
        else
        	raise IOError, "(not opened for writing)"
        end
        self
    end

    def close
    	@closed = true
    end

    def closed?
    	@closed
    end

    def string
    	@buffer
    end
end

unless self.class.respond_to? :private_constant
    class Module
        def private_constant(*names); end
    end
end

Integer = Fixnum
