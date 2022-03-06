# frozen_string_literal: true

module HTML
  class Proxy < BasicObject
    P_COMPONENT_METHOD = <<~EOF
      def %<name>s(*args, &block)
        @tagset.component(:%<name>s, *args, &block)
      end
    EOF
    P_TAG_METHOD = <<~EOF
      def %<name>s(*args, &block)
        @tagset.tag(:%<name>s, *args, &block)
      end
    EOF

    def initialize(tagset)
      @tagset = tagset
    end

    def tag(...)
      @tagset.tag(...)
    end

    def component(...)
      @tagset.component(...)
    end

    def slot(...)
      @tagset.slot(...)
    end

    def cache(...)
      @tagset.cache(...)
    end

    # #div(id: 'aa') do |t|
    #   t.h1 'title'
    # end
    def method_missing(name, *args, &block)
      code = if ::HTML::Component.registry.key?(name)
        P_COMPONENT_METHOD % { name: name }
      else
        P_TAG_METHOD % { name: name }
      end

      Proxy.class_eval(code, __FILE__, __LINE__)
      __send__(name, *args, &block)
    end
  end

  class TagSet
    attr_reader :type, :children, :proxy

    def initialize(&block)
      @children = []
      @type = :tag_set
      @proxy = Proxy.new(self)
      config(block) if block_given?
    end

    def any?
      children.any?
    end

    def tag(*args, &blk)
      Tag.build(*args, &blk).tap do |t|
        @children << t
      end
    end

    def component(key, *args, &blk)
      HTML::Component.registry.fetch(key).new(*args, &blk).tap do |comp|
        @children << comp
      end
    end

    def slot(*_)
      # Slots are a noop. See SlotRecorder
    end

    def cache(cache_key, &block)
      CachedBlock.new(cache_key, &block).tap do |c|
        @children << c
      end
    end

    def to_s
      HTML.renderer.render(self)
    end

    def inspect
      %(<#{self.class.name} [#{children.map(&:inspect)}]>)
    end

    def handle_trailing_content(ctn)
      tag(ctn) if ctn != children.last && (ctn.kind_of?(String) || ctn.respond_to?(:type))
      self
    end

    private

    def config(block)
      output = block.arity == 0 ? @proxy.instance_eval(&block) : block.call(@proxy)
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
