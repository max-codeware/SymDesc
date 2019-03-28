class Integer

    def to_symdesc
        return SymDesc::Int.new(self)
    end 

end

class Float
    def to_symdesc
        return SymDesc::Ratio.new(self)
    end
end

class Rational
    def to_symdesc
        return SymDesc::Ratio.new(self)
    end
end