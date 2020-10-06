# frozen_string_literal: true

module HTML
  class TagSet
    def initialize(&block)
      @tags = []
      config(block) if block_given?
    end

    def tag(*args, &blk)
      t = Tag.build(*args, &blk)
      @tags << t
      t
    end

    def component(key, *args, &blk)
      comp = HTML::Component.registry.fetch(key).new(*args, &blk)
      @tags << comp
      comp
    end

    def to_s
      Renderer.render(self)
    end

    def to_ast
      {
        type: :tag_set,
        tags: tags.map(&:to_ast)
      }
    end

    def inspect
      %(<#{self.class.name} [#{tags.map(&:inspect)}]>)
    end

    private

    attr_reader :tags

    def config(block)
      ret = block.call(self)
      tag(ret) unless ret == tags.last
    end
  end
end
