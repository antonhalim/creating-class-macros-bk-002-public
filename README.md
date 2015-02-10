---
tags: metaprogramming, DSL, modules
languages: ruby
resources: 
---
# Building A DSL

Ruby comes with an quick an easy way to create accessors for an object's state.

``` ruby
class Person
  attr_accessor :name
end

steven = Person.new
steven.name = "Steven"
steven.name # => "Steven"
```

But if change a value, we wind up losing that object's previous value. I really
wish this code worked.

``` ruby
class Person
  extend CachedAccessor
  cached_accessor :name
end

steven = Person.new
steven.name = "Steven"
steven.name # => "Steven"
steven.name = "Blake"
steven.name # => "Blake"
steven.rollback_name
steven.name # => "Steven"
```

In order for this to work. We're going to have to write our own macro. We're
going to create a module named CachedAccessor that will add our
`cached_accessor` macro.

## Manhandling Ruby
When building a DSL, we have to move away from a lot of the normal ways of
doing things. The next sections will cover:

* Pragmatically getting and setting instance variables
* Defining methods, and naming them dynamically
* Calling methods at run-time

### Setting variables the hard way
We're used to setting instance variables this way:

``` ruby
class Person
  def name=(new_name)
    @name = new_name
  end

  def name
    @name
  end
end
```

Ruby offers another way of getting add setting instance variables:

``` ruby
class Person
  def name=(new_name)
    instance_variable_set("@name", new_name)
  end

  def name
    instance_variable_get("@name")
  end
end
```

You may be asking, "Why would you do it this way? it's way more typing!".
First, calm down, seriously... Second: The second argument is a string, which
means... WE CAN USE INTERPOLATION!

``` ruby
class Person
  def name=(new_name)
    variable_name = "name"
    instance_variable_set("@#{variable_name}", new_name)
  end

  def name
    variable_name = "name"
    instance_variable_get("@#{variable_name}")
  end
end
```

The first thing you pass to both instance_variable_get and instance_variable_set is the instance variable name including the `@`.

### Defining Methods the hard way

Let's go back to our class using our manual instance variable setting:

``` ruby
class Person
  def name=(new_name)
    variable_name = "name"
    instance_variable_set("@#{variable_name}", new_name)
  end

  def name
    variable_name = "name"
    instance_variable_get("@#{variable_name}")
  end
end
```

Ruby has another way of creating methods:

``` ruby
class Person
  define_method "name=" do |new_name|
    variable_name = "name"
    instance_variable_set("@#{variable_name}", new_name)
  end

  define_method "name" do
    variable_name = "name"
    instance_variable_get("@#{variable_name}")
  end
end
```

Here we created methods using the `define_method` method, and passed it the
name of the method, and a block. If the method takes arguments, we pass it as
arguments to the block.

OK, why's this cool? WE CAN USE INTERPOLATION!

``` ruby
class Person
  methods = ["name", "age"]
  methods.each do |method|
    define_method "#{method}=" do |new_value|
      instance_variable_set("@#{method}", new_value)
    end

    define_method method  do
      instance_variable_get("@#{method}")
    end
  end
end
```

### Dynamic Dispatch
One final thing. Imagine what it would take to get this method to work:
``` ruby
apply("upcase", to: "my string") #=> "MY STRING"
```

We would need to be able to send the `upcase` message to a string. The string
would respond by calling its `upcase` method. Lucky for us, Ruby has just the
thing!

``` ruby
# requires ruby > 2.1 
def apply(method, to:)
  to.public_send(method)
end
```
The `public_send` method is called on the object, and takes at least one argument, the
message to send. This is the same as calling `"my
string".public_send("upcase")`
