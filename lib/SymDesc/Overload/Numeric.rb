class Integer

    def to_symdesc
        return SymDesc::Int.new(self)
    end 

end

class Float
    def to_symdesc
    	# return SymDesc::Infinity if self == INFINITY 
    	# return SymDesc::Nan      if self == NAN
        return SymDesc::Ratio.new(self)
    end
end

if self.class.const_defined? :Rational
    class Rational
        def to_symdesc
            return SymDesc::Ratio.new(self)
        end
    end
else
    tail = (ENGINE.mruby? ?  "for mruby" : "for ruby #{RUBY_VERSION}")
    warn "Rational class not supported #{tail}"
    class Rational
        class <<self
            undef_method :new
        end
        freeze
    end
end