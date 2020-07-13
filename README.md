[![Build Status](https://travis-ci.com/max-codeware/SymDesc.svg?branch=master)](https://travis-ci.com/max-codeware/SymDesc)
[![Maintainability](https://api.codeclimate.com/v1/badges/81c27b0478dee8f92aec/maintainability)](https://codeclimate.com/github/max-codeware/SymDesc/maintainability)

# SymDesc
## A minimal computer algebra system for symbolic manipulation in Ruby
___
The aim of this project is to provide a simple and easy-to-use computer algebra system for symbolic
manipulation.

It represents math expressions through a binary tree and it provides an automatic basic simplification. 
Furthermore, it is possible to perform derivatives, substitutions and expression evaluation.

The project is still in an early stage, but it is usable and provides several opportunities.

## Compatibility
This library is compatible with Ruby >= 2.5.0 and mruby >= 2.0.1

## Installation

## Structure of the internal representation:
![Inheritance chain](res/inheritance_chain.png)
Modules are marked as `M`, while classes are marked as `C`

## CAS settings
This library allows the user to change some setting. They are saved in `SymDesc::SYM_CONFIG` on which a hash is saved.\
There are three keys inside:
```ruby
SYM_CONFIG = {
  :ratio_precision => 1e-16, 
  :symdesc_engine => engine,      
  :var_scope => :global,          
}
```
The first one indicates the error allowed for converting float numbers to rational. The default value is 
`1e-6`.\
The second key just refers to the type of ruby engine SymDesc is running on. It can be or `ruby` or `mruby`.
It's not a real setting, as any changement on the value won't produce any behaviour.\
The third setting indicates how a `Variable` object should be created. `:global` makes the library create a
unique instance for the whole program of a symbolic variable given its name. It means if we create a variable
called `x` with this setting enabled, there won't be two distinct instances called `x`.\
If `:var_scope` is set to `:local`, a variable has a unque definition only inside the object it was created.

All the settings must be changed at the beginning of the program, otherwise it won't be possible to modify them anymore.


## Provided interfaces
SymDesc provides different interfaces to give a more comfortable way to write math expressions.\
The two main functions are `var` and `cas`. Both accept an arbitrary number of arguments, and they return a
single result if only argument is provided, or an array if arguments are more than one or zero.\
`var` converts strings or ruby symbols into symbolic variables:
```ruby
x = var :x   # It creates a single variable named 'x'

x, y, z = var :x, :y, :z # It creates three variables simultaneously
```
This is the correct way to declare symbolic variables, as this method handles the user settings about the
scope of creation.

`cas` converts symbols or other objects to symbolic representations, as long as they implement a `to_symdesc`
method.\
Example:
```ruby
n1, n2 = cas 11, 2.33  #=> 11, 233/100

class MyClass < String 
  def initialize(name)
    super
  end

  def to_symdesc
    var self
  end
end

myvar = MyClass.new "v1"
r1    = cas myvar #=> v1:SymDesc::Variable  
```

### Creating expressions dynamically
An experimental feature has been introduced to allow expression creation without declaring symbols manually.
It is accessible throug a call to `dynamic` and passing a block of code containing the expression. Here an
example:
```ruby
my_exp = dynamic { x ** 2 + y * z ** 3} #=> x ** 2 + y * z ** 3
```
The above code is the same as:
```ruby
x, y, z = var :x, :y, :z 

my_exp = x ** 2 + y * z ** 3
```
However, the first line creates unique variables inside the block, not globally or locally as mentioned in
settings. 

## Examples
### FInding zeros of a funcrion using Newton's method
An example of metaprogramming employing this library is the research of zeros of a function through Newton's
method. It's an iterative algorithm, and its equation is in the form:
```
x[n+1] = x[n] - f(x[n])/f'(x[n])
```
Ir requires the evaluation of the fraction between  `f` and its derivative `f'` many times. SymDesc offers
two ways to do this: through the `call` method and the creation of a procedure.\
Let's see an example using the content of `my_exp` created previously:
```ruby
# Invoking 'call' on the expression`
my_exp.call(x: 4, y: 2, z: 3) #=> 70

# Exploiting a 'Proc' object
my_proc = my_exp.to_proc       #=> #<Proc:0x0000560f7a4bac50@(eval):2>
my_proc.call(x: 4, y: 2, z: 3) #=> 70
```
The difference between the two way is the first one is slightly slower, as it has to create inermediate
strings every time to represent the expression in ruby code.

The suitable one, for this example, is the second way due to the repetition of the operations.\
We can start implementing the Newton's algorithm: it takes a symbolic function and the starting point of the
iterations, returning the final value.
```ruby
def newton(f, start, tol = 1e-8, max_iter = 100)
  x = f.vars[0]         # Name o the variable 'f' depends on
  s = {x.name => start} # Dictionary of the solutions. Now it contains x[n]

  fp   = f.to_proc      # Creating a procedure of evaluation
  df   = f.diff(x)      # Calculating f'
  frac = (f/df).to_proc # Procedure of evaluation for the fracion

  k = 0
  f0 = fp.call(s)

  loop do 
    s[x.name] -= frac.call(s)

    # We need to check the tolerance
    f1 = f.call(s)
    if (f1 - f0).abs < tol 
      break 
    else
      f0 = fp.call(s)
    end

    # Checking the iterations
    k += 1
    break if k > max_iter
  end
  return s[x.name]
end
```
Now we can use this implementation to find a zero of a symbolic function:
```ruby
x    = var :x
exp  = (x - 7) ** 2 - 6
zero = newton(exp,4).round(2)
puts "Function #{exp} has a zero in x = #{zero}"
#=> Function (x - 7) ** 2 - 6 has a zero in x = 4.55
```

## To do

 * [ ] Better simplification for `Prod#*`
 * [ ] Generation of C code for the symbolic solution
 * [x] Variable-dependent functions (`x[t]`)
 * [ ] Test
