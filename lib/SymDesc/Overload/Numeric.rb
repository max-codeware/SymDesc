class Integer

    L10 = Math.log(10)

    def to_symdesc
        return SymDesc::Int.new(self)
    end 
    
    def get_size # :nodoc:
        return 1 if self < 10
        return (Math.log(self) / L10).to_i + 1
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