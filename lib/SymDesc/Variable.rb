
module SymDesc

    # __     __         _       _     _      
    # \ \   / /_ _ _ __(_) __ _| |__ | | ___ 
    #  \ \ / / _` | '__| |/ _` | '_ \| |/ _ \
    #   \ V / (_| | |  | | (_| | |_) | |  __/
    #    \_/ \__,_|_|  |_|\__,_|_.__/|_|\___|

    # This class describes a symbolic variable. It can be resolved
    # with a numerical value or substituted with another expression.
    class Variable
    
    	include Base

        class <<self 

            alias :__new :new 
            private :__new


            VAR_ID = "@__vars__"
            private_constant :VAR_ID

            def sym_config # :nodoc:
                @@sym_config ||= (SYM_CONFIG[:var_scope] || :global)
            end

            def __new__(name,object) # :nodoc:
                name = __var_name name
                __ensure_config :local
                if object.instance_variable_defined? VAR_ID
                    v = object.instance_variable_get VAR_ID 
                    var = v[name] || (v[name] = __new(name))
                else
                    var = __new(name)
                    object.instance_variable_set VAR_ID, {name => var}
                end
                return var
            end

            def new(name)
                name = __var_name name
                __ensure_config :global
                @@syms ||= {}
                return @@syms[name] || (@@syms[name] = super(name))
            end

        private 

            def __var_name(name)
                name = name.to_sym if name.is_a? String
                raise ArgumentError, 
                     "A variable name must be a Symbol or a String" unless name.is_a? Symbol
                return name
            end


            def __ensure_config(type)
                @@sym_config ||= (SYM_CONFIG[:var_scope] || :global)
                case @@sym_config
                when :local 
                    unless type == :local
                        msg = "Warning: variable creation without a definition scope. Use `vars' method instead"
                        loc = caller[1]
                        warn msg,loc
                    end
                when :global
                    raise SymDescError, 
                    "Variable configuration set to global (requested #{type})" unless type == :global
                else
                    raise SymDescError, "Invalid variable visibility configuration (got #{@@sym_config})"
                end
            end
        end
    
    	attr_reader :name
    
    	def initialize(name) # :nodoc:
    		@name = name
    	end
    
        # :call-seq:
        #   var + obj -> new_obj
        #
        # It sums `obj` to the variable `var` returning
        # a new symbolic object. Simplification is automatic.
        #
        # If `obj` is not a symbolic object, a conversion is attempted
    	def +(b)
            b = b.symdescfy
            return case b 
                   
                when self.class 
                    __sum_self b 
                when Neg 
                	self - b.argument
                when BinaryOp
                	b + self
                when Numeric
                	__sum_numeric b
                else 
                	Sum.new(self,b)
            end
    	end
    
    	def opt_sum(b) # :nodoc:
            if self == b 
            	return Prod.new(TWO,self)
            end
            nil
    	end
    
        # :call-seq:
        #   var - obj -> new_obj
        #
        # It subtracts `obj` to the variable `var` returning
        # a new symbolic object. Simplification is automatic.
        #
        # If `obj` is not a symbolic object, a conversion is attempted
    	def -(b)
            b = b.symdescfy
            return case b 
                   
                when self.class 
                    __sub_self b 
                when Neg 
                	self + b.argument
                when BinaryOp
                	__sub_binaryop b
                when Numeric
                	__sub_numeric b
                else 
                	Sub.new(self,b)
            end
    	end
    
    	def opt_sub(b) # :nodoc:
    		return self - b if self =~ b
    		nil 
    	end

        # :call-seq:
        #   var == obj -> true or false
        #
        # It compares `var` with `obj`, returning true if `obj`
        # is a Variable and has the same name
        def ==(b)
            return true if b.is_a?(Variable) && (b.name == name)
            false 
        end
    
        def =~(b) # :nodoc:
        	return case b 
    
                when Variable
        	        self == b 
        	    when Product, Div
        	    	b =~ self 
        	    else 
        	    	false
        	end
        end
    
        # :call-seq:
        #   to_s -> string
        #   to_s(str_io) -> str_io
        #
        # If no argument is provided, it returns a string representation
        # of the symbolic variable. If a StringIO object is passed, the string
        # representation is appended to the buffer and this last is returned.
        def to_s(io = nil)
            if io 
                __io_append(io,name) 
                return io
            else
                return name.to_s 
            end
        end

        alias :inspect :to_s

        def get_size # :nodoc:
            return @name.size 
        end
    
    private
        
        def __sum_self(b)
        	return Prod.new(TWO,self) if self == b
        	Sum.new(self,b)
        end
    
        def __sum_numeric(b)
        	return self if b.zero?
        	b = b.symdescfy if b.is_a? Float
        	Sum.new(self,b)
        end
    
        def __sub_self(b)
        	return ZERO if self == b 
        	Sub.new(self,b)
        end
    
        def __sub_binaryop(b)
            tmp = nil
            case b 
                when Sum 
                	tmp = self - b.left - b.right
                when Sub 
                	tmp = self - b.left + b.right 
                when Prod
                	if b =~ self
                		if (l = b.left) == 2
                			tmp =  self
                		end
                		tmp = Prod.new(ONE - l,self)
                	end 
                when Div 
                	if b =~ self
                		n = self * b.right - b.left
                		tmp = n / b.right
                	end
            end
            return tmp || Sub.new(self,b)
        end
    
        def __sub_numeric(b)
            return self if b == 0
            b = b.symdescfy if b.is_a? Float 
            return Sub.new(self,b)
        end
    
    	
    end

end