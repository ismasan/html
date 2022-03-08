# frozen_string_literal: true

require 'concurrent/hash'

module HTML
  def self.define(...)
    Component.define(...)
  end

  class Component
    extend InheritableClassSettings
    def_settings :props
    def_settings :slots

    class Slot
      attr_reader :default
      def initialize(default: nil, &default_block)
        @default = if default
          default.respond_to?(:call) ? default : ->(_) { default }
        elsif block_given?
          default_block
        else
          nil
        end
      end
    end

    class Prop
      NOOP = ->(v) { v }

      attr_reader :default
      def initialize(transform: nil, default: nil, &block)
        @transform = transform || (block_given? ? block : NOOP)
        @default = default
      end

      def call(value)
        @transform.call(value)
      end
    end

    NOOP_CONTENT_BLOCK = ->(*) {}
    REGISTRY = Concurrent::Hash.new

    # ToDO: these class-level lazily defined vars are not thread-safe
    def self.registry
      REGISTRY
    end

    def self.register(constructor)
      registry[constructor.name] = constructor
    end

    def self.name(n = nil)
      if n
        @name = n
        registry[name.to_sym] = self
      end
      @name || super()
    end

    def self.prop(key, **opts, &transform)
      props[key] = Prop.new(**opts, &transform)
    end

    def self.slot(key, **opts, &default)
      slots[key] = Slot.new(**opts, &default)
    end

    def self.render(*args, &block)
      new(*args, &block).to_s
    end

    def self.build(&block)
      klass = Class.new(self)
      klass.define_method(:render) do
        instance_exec(builder, props, &block)
      end
      klass
    end

    def self.define(name, &block)
      build(&block).tap do |klass|
        klass.name(name)
      end
    end

    attr_reader :type, :name, :props

    def initialize(props = {}, &block)
      @type = :component
      @name = self.class.name
      @props = resolve_props(props)
      @content_block = block_given? ? block : NOOP_CONTENT_BLOCK
      @slots = SlotRecorder.new(self.class.slots, &@content_block)
      @tag_set = TagSet.new
    end

    def to_s
      HTML.renderer.render(self)
    end

    def children
      @children ||= (
        trailing = render
        tag_set.handle_trailing_content(trailing)
      )
    end

    private

    attr_reader :content_block, :tag_set, :slots

    def render
      nil
    end

    def content
      @content ||= TagSet.new(&content_block)
    end

    def builder
      @tag_set.proxy
    end

    def resolve_props(props)
      # Functional components take any props
      return props unless self.class.props.any?

      self.class.props.each.with_object({}) do |(key, prop), ret|
        ret[key] = props.key?(key) ? prop.call(props[key]) : prop.default
      end
    end
  end
end
