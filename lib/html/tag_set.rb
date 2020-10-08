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
      Tag.build(*args, &blk).tap do |t|
        @tags << t
      end
    end

    def component(key, *args, &blk)
      HTML::Component.registry.fetch(key).new(*args, &blk).tap do |comp|
        @tags << comp
      end
    end

    def slot(*_)
      # Slots are a noop. See SlotRecorder
    end

    def cache(cache_key, &block)
      CachedBlock.new(cache_key, &block).tap do |c|
        @tags << c
      end
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
      output = block.arity == 0 ? instance_eval(&block) : block.call(self)
      handle_trailing_content(output)
    end
  end

  class SlotRecorder
    def initialize(definitions, &block)
      @definitions = definitions
      @slots = {}
      if block_given?
        block.arity == 0 ? instance_eval(&block) : block.call(self)
      end
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

    def cache(*_)
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
