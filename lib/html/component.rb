# frozen_string_literal: true

module HTML
  class Component
    def self.props
      @props ||= {}
    end

    def self.prop(key)
      props[key] = true
    end

    def self.render(*args, &block)
      new(*args, &block).to_s
    end

    def initialize(props = {}, &block)
      @props = self.class.props.keys.each.with_object({}) do |key, ret|
        raise ArgumentError, "expects #{key}" unless props.key?(key)

        ret[key] = props[key]
      end

      @content_block = block_given? ? block : nil
    end

    def to_s
      render.to_s
    end

    private

    attr_reader :props, :content_block

    def render
      ''
    end

    def content
      content_block ? content_block.call(self) : nil
    end

    def tag(*args, &block)
      HTML.tag(*args, &block)
    end
  end
end
