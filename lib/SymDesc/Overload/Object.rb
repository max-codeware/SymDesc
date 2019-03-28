class Object
    def is_symbolic?
        return false
    end

    def symdescfy
   		  return self if self.is_symbolic?
   		  begin
   		  	  return self.to_symdesc
   		  rescue 
            raise SymDesc::SymDescError, "Can't convert #{self.class} into a symbolic object"
        end
    end
end
