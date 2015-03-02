require 'pry'
module CachedAccessor

  def cached_accessor(*methods)
    methods.each do |method|
      define_method "#{method}" do
        instance_variable_get("@#{method}")
      end

      define_method "#{method}=" do |new_value|
        getter = instance_variable_get("@#{method}")
        instance_variable_set("@old_#{method}", getter)
        instance_variable_set("@#{method}", new_value)
      end

      define_method "old_#{method}" do
        instance_variable_get("@old_#{method}")
      end

      define_method "rollback_#{method}" do
        old = instance_variable_get("@old_#{method}")
        instance_variable_set("@#{method}", old)
        instance_variable_set("@old_#{method}", nil)
      end

    end
  end
end
