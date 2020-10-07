# frozen_string_literal: true

module HTML
  class TagSet
    attr_reader :type, :tags

    def initialize(&block)
      @tags = []
      @type = :tag_set
      config(block) if block_given?
    end

    def any?
      tags.any?
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

    def slot(*_)
      # Slots are a noop. See SlotRecorder
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

  class SlotRecorder
    def initialize(definitions, &block)
      @definitions = definitions
      @slots = {}
      block.call(self) if block_given?
      # populate defaults
      @definitions.each do |key, d|
        next if @slots.key?(key)

        slot(key, &d.default)
      end
    end

    def tag(*_)
    end

    def component(*_)
    end

    def slot(key, content = nil, &block)
      raise ArgumentError, "slot :#{key} is not registered" unless @definitions.key?(key)

      @slots[key] = content || TagSet.new(&block)
    end

    def [](key)
      @slots.fetch(key)
    end
  end
end
