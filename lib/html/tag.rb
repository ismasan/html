# frozen_string_literal: true

module HTML
  WHITESPACE = ' '

  # tag(:p, &block)
  # tag(:p, id: '11', &block)
  # tag(:p, 'hello', id: '11')
  # tag(:p, 'hello')
  # tag(:br)
  #
  def self.tag(*args, &block)
    Tag.build(*args, &block)
  end

  class Tag
    def self.build(*args, &block)
      attributes = args.last.kind_of?(Hash) ? args.pop : {}
      if args.first.is_a?(Symbol) # tag name
        name = args.shift
        return UnaryTag.new(name, attributes) unless args.any? || block_given?

        content = if block_given?
                    TagSet.new(&block)
                  elsif args.respond_to?(:to_s)
                    TextNode.new(args.first)
                  else
                    raise ArgumentError, "Can't use #{args.first} as tag content, must respond to #to_s"
                  end
        ContentTag.new(name, content, attributes)
      elsif args.first.respond_to?(:to_s)
        TextNode.new(args.first)
      end
    end

    attr_reader :name, :attributes

    def inspect
      %(<#{self.class.name} #{name} #{attributes.inspect} >)
    end

    private

    def prepare_attributes(attrs)
      attrs.each.with_object({}) do |(k, v), ret|
        ret[k] = [v].flatten
      end
    end
  end

  class UnaryTag < Tag
    def initialize(name, attributes = {})
      @name, @attributes = name, prepare_attributes(attributes)
    end

    def to_s
      Renderer.new.visit(self)
    end
  end

  class TextNode
    def initialize(txt)
      @txt = txt
    end

    def to_s
      @txt.to_s
    end
  end

  class ContentTag < Tag
    attr_reader :content

    def initialize(name, content, attributes)
      @name, @attributes = name, prepare_attributes(attributes)
      @content = content
    end

    def to_s
      Renderer.new.visit(self)
      # %(<#{name}#{render_attributes}>#{content.to_s}</#{name}>)
    end
  end

  class TagSet
    attr_reader :tags

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
      Renderer.new.visit(self)
    end

    def inspect
      %(<#{self.class.name} [#{tags.map(&:inspect)}]>)
    end

    private

    def config(block)
      ret = block.call(self)
      tag(ret) unless ret == tags.last
    end
  end
end
