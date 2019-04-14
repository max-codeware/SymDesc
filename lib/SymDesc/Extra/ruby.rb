if ENGINE.ruby?

module Kernel
	alias :_warn :warn

	def warn(msg, loc = nil)
		loc &&= "#{loc}: "
		_warn "#{loc}warning: #{msg}\n"
	end 
end

end