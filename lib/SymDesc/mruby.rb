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
		def warn(msg)
			$stderr << "warning: #{msg}\n"
		end
	end

end

module ENGINE
	class <<self

	    def ruby?
	    	RUBY_ENGINE == "ruby"
	    end

	    def mruby?
	    	RUBY_ENGINE == "mruby"
	    end
	end
	freeze
end