# frozen_string_literal: true

module HTML
  class Component
    NOOP_CONTENT_BLOCK = ->(*) {}

    def self.registry
      @registry ||= {}
    end

    def self.register(key, constructor)
      registry[key] = constructor
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

    def self.slot(key, opts = {})
      slots[key] = opts
    end

    def self.render(*args, &block)
      new(*args, &block).to_s
    end

    attr_reader :type

    def initialize(props = {}, &block)
      @type = :component
      @props = self.class.props.each.with_object({}) do |(key, opts), ret|
        raise ArgumentError, "expects #{key}" unless props.key?(key)

        ret[key] = props[key]
      end

      @content_block = block_given? ? block : NOOP_CONTENT_BLOCK
      @slots = SlotRecorder.new(self.class.slots, &@content_block)
      @tag_set = TagSet.new
    end

    def to_s
      Renderer.render(self)
    end

    def children
      @children ||= (
        trailing = render
        tag_set.handle_trailing_content(trailing)
      )
    end

    private

    attr_reader :props, :content_block, :tag_set, :slots

    def render
      nil
    end

    def content
      @content ||= TagSet.new(&content_block)
    end

    def tag(*args, &block)
      tag_set.tag(*args, &block)
      # HTML.tag(*args, &block)
    end

    def component(*args, &block)
      tag_set.component(*args, &block)
    end
  end
end
