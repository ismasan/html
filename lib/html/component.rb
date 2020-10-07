# frozen_string_literal: true

module HTML
  class Component
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

      @content_block = block_given? ? block : nil
      @tag_set = TagSet.new
    end

    def to_s
      Renderer.render(self)
    end

    def children
      render
      tag_set
    end

    def render
      nil
    end

    private

    attr_reader :props, :content_block, :tag_set

    def content
      return nil unless content_block

      content_block.call(self)
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
