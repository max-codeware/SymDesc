module Kernel
    def var(*args)
    	if Variable.sym_config == :global
    	    args.map! { |name| SymDesc::Variable.new name          }
    	else
    		args.map! { |name| SymDesc::Variable.__new__ name,self }
        end
        return (args.size == 1) ? args[0] : args
    end
end