class Symbol
	def to_symdesc
	    return SymDesc::Variable.new(self)
	end	
end