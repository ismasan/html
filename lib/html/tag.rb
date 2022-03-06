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
      return args.first if args.first.kind_of?(Component) || args.first.kind_of?(Tag)

      attributes = args.last.kind_of?(Hash) ? args.pop : {}
      if args.first.is_a?(Symbol) # tag name
        name = args.shift

        content = if block_given?
          TagSet.new(&block)
        elsif args.first.respond_to?(:to_s)
          TextNode.new(args.first)
        else
          raise ArgumentError, "Can't use #{args.first} as tag content, must respond to #to_s"
        end

        ContentTag.new(name, content, attributes)
      elsif args.first.respond_to?(:to_s)
        TextNode.new(args.first)
      end
    end

    attr_reader :type, :name, :attributes

    def inspect
      %(<#{self.class.name} #{name} #{attributes.inspect} >)
    end

    def to_s
      HTML.renderer.render(self)
    end

    private

    def prepare_attributes(attrs)
      attrs.each.with_object({}) do |(k, v), ret|
        ret[k] = [v].flatten
      end
    end
  end

  class TextNode
    attr_reader :type

    def initialize(txt)
      @txt = txt
      @type = :text_node
    end

    def to_s
      @txt.to_s
    end
  end

  class ContentTag < Tag
    attr_reader :type, :content

    def initialize(name, content, attributes)
      @name, @attributes = name, prepare_attributes(attributes)
      @content = content
      @type = :content_tag
    end
  end
end
