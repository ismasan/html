# frozen_string_literal: true

module HTML
  class TagSet
    attr_reader :type, :tags

    def initialize(&block)
      @tags = []
      @type = :tag_set
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

    def inspect
      %(<#{self.class.name} [#{tags.map(&:inspect)}]>)
    end

    def handle_trailing_content(ctn)
      tag(ctn) if ctn != tags.last && (ctn.kind_of?(String) || ctn.respond_to?(:type))
      self
    end

    private

    def config(block)
      handle_trailing_content(block.call(self))
    end
  end
end
