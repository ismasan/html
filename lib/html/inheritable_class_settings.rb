# frozen_string_literal: true

module HTML
  module InheritableClassSettings
    def inherited(child)
      __class_settings.each do |k, v|
        child.__class_settings[k] = {}
        v.each do |sk, sv|
          child.__class_settings[k][sk] = sv
        end
      end
    end

    def __class_settings
      @__class_settings ||= {}
    end

    def def_settings(name, setter: nil)
      define_singleton_method name do
        __class_settings[name] ||= {}
      end

      if setter
        define_singleton_method setter do |prop_key, prop_value|
          send(name)[prop_key] = prop_value
        end
      end
    end
  end
end
