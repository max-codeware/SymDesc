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
