# frozen_string_literal: true

module HTML
  class Renderer
    WHITESPACE = ' '

    def visit(node)
      return visit_component(node) if node.kind_of?(Component)

      short_name = node.class.to_s.split('::').last
      send("visit_#{short_name}", node)
    end

    def visit_UnaryTag(tag)
      %(<#{tag.name}#{render_attributes(tag.attributes)} />)
    end

    def visit_ContentTag(tag)
      %(<#{tag.name}#{render_attributes(tag.attributes)}>#{visit(tag.content)}</#{tag.name}>)
    end

    def visit_TextNode(node)
      node.to_s
    end

    def visit_TagSet(set)
      set.tags.map { |tag| visit(tag) }.join
    end

    def visit_component(component)
      visit(component.render)
    end

    private

    def render_attributes(attributes)
      return '' unless attributes.any?

      WHITESPACE + attributes.map do |k, v|
        [k, %("#{v.join(WHITESPACE)}")].join('=')
      end.join(WHITESPACE)
    end
  end
end
