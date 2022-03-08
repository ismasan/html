# frozen_string_literal: true

require 'concurrent/hash'

module HTML
  module InheritableClassSettings
    def inherited(child)
      __class_settings.each do |k, v|
        child.__class_settings[k] = Concurrent::Hash.new
        v.each do |sk, sv|
          child.__class_settings[k][sk] = sv
        end
      end
    end

    def __class_settings
      # This assignment itself is not thread-safe
      @__class_settings ||= Concurrent::Hash.new
    end

    def def_settings(name, setter: nil)
      define_singleton_method name do
        __class_settings[name] ||= Concurrent::Hash.new
      end

      if setter
        define_singleton_method setter do |prop_key, prop_value|
          send(name)[prop_key] = prop_value
        end
      end
    end
  end
end
