# frozen_string_literal: true

require 'concurrent/hash'

module HTML
  class Component
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

    def self.props
      @props ||= {}
    end

    def self.prop(key, opts = {})
      props[key] = opts
    end

    def self.slots
      @slots ||= {}
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
        instance_exec(tag_set.proxy, &block)
      end
      klass
    end

    attr_reader :type, :name, :props

    def initialize(props = {}, &block)
      @type = :component
      @name = self.class.name
      @props = self.class.props.each.with_object({}) do |(key, opts), ret|
        raise ArgumentError, "expects #{key}" unless props.key?(key)

        ret[key] = props[key]
      end

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

    def tag(*args, &block)
      tag_set.tag(*args, &block)
    end

    def component(*args, &block)
      tag_set.component(*args, &block)
    end
  end
end
