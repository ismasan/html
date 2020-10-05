# frozen_string_literal: true

module HTML
  LINE_BREAK = "\n"
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
        args.first
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

    def render_attributes
      return '' unless attributes.any?

      WHITESPACE + attributes.map do |k, v|
        [k, %("#{v.join(WHITESPACE)}")].join('=')
      end.join(WHITESPACE)
    end
  end

  class UnaryTag < Tag
    def initialize(name, attributes = {})
      @name, @attributes = name, prepare_attributes(attributes)
    end

    def to_s
      %(<#{name}#{render_attributes} />)
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
    def initialize(name, content, attributes)
      @name, @attributes = name, prepare_attributes(attributes)
      @content = content
    end

    def to_s
      %(<#{name}#{render_attributes}>#{content.to_s}</#{name}>)
    end

    private

    attr_reader :content
  end

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
      LINE_BREAK + tags.map(&:to_s).join(LINE_BREAK) + LINE_BREAK
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
