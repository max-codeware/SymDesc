module Kernel
    def var(*args)
    	return SymDesc::Variable.new(*args) if args.size == 1
    	return args.map! do |name|
            SymDesc::Variable.new name
        end
    end
end