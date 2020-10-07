# frozen_string_literal: true

module HTML
  class Renderer
    WHITESPACE = ' '

    def self.render(node)
      new.visit(node)
    end

    def visit(node)
      send("visit_#{node.type}", node)
    end

    def visit_unary_tag(node)
      %(<#{node.name}#{render_attributes(node.attributes)} />)
    end

    def visit_content_tag(node)
      %(<#{node.name}#{render_attributes(node.attributes)}>#{visit(node.content)}</#{node.name}>)
    end

    def visit_text_node(node)
      node.to_s
    end

    def visit_tag_set(node)
      node.tags.map { |tag| visit(tag) }.join
    end

    def visit_component(node)
      ctn = node.render
      ctn ? visit(ctn) : nil
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
