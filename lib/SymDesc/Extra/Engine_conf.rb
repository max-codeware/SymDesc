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