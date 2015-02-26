require 'pry'

module CachedAccessor
  def cached_accessor(*arguments)
    arguments.each do |argument|
      define_method "#{argument}=" do |new_value|
        instance_variable_set("@old_#{argument}", public_send(argument))
        instance_variable_set("@#{argument}", new_value)
      end
      define_method "#{argument}" do
        instance_variable_get("@#{argument}")
      end
      define_method "old_#{argument}" do
        instance_variable_get("@old_#{argument}")
      end
      define_method "rollback_#{argument}" do
        old = instance_variable_get("@old_#{argument}")
        instance_variable_set("@#{argument}", old)
        instance_variable_set("@old_#{argument}", nil)
      end
    end
  end
end
