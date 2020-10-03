# frozen_string_literal: true

module HTML
  LINE_BREAK = "\n"
  WHITESPACE = ' '

  class Tag
    def initialize(name, *opts, &content_block)
      @name = name
      @attributes = opts.last.kind_of?(Hash) ? prepare_attributes(opts.last) : {}
      @content = if block_given?
                   yield(TagSet.new)
                 elsif !opts.first.kind_of?(Hash)
                   prepare_content(opts.first)
                 else
                   raise ArgumentError, "don't know how to handle #{opts.inspect}"
                 end
    end

    def to_s
      if content.nil?
        %(<#{name}#{render_attributes} />)
      else
        %(<#{name}#{render_attributes}>#{content.to_s}</#{name}>)
      end
    end

    private

    attr_reader :name, :attributes, :content

    def prepare_attributes(attrs)
      attrs.each.with_object({}) do |(k, v), ret|
        ret[k] = [v].flatten
      end
    end

    def prepare_content(ctn)
      return nil unless ctn

      raise ArgumentError, "content must respond to #to_s, but got #{ctn.inspect}" unless ctn.respond_to?(:to_s)

      ctn
    end

    def render_attributes
      return '' unless attributes.any?

      WHITESPACE + attributes.map do |k, v|
        [k, %("#{v.join(WHITESPACE)}")].join('=')
      end.join(WHITESPACE)
    end
  end

  class TagSet
    def initialize
      @tags = []
    end

    def tag(*args, &blk)
      tags << Tag.new(*args, &blk)
      self
    end

    def to_s
      LINE_BREAK + tags.map(&:to_s).join(LINE_BREAK) + LINE_BREAK
    end

    private

    attr_reader :tags
  end
end
