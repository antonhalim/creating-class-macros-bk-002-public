---
tags: metaprogramming, dsl, modules
languages: ruby
resources: 
---
# Building A Dsl

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
steven.undo(:name)
steven.name # => "Steven"
```

In order for this to work. We're going to have to write our own macro. We're
going to create a module named CachedAccessor that will add our
`cached_accessor` macro.



