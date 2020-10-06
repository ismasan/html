# frozen_string_literal: true

module HTML
  class Renderer
    WHITESPACE = ' '

    def visit(node)
      send("visit_#{node.fetch(:type)}", node)
    end

    def visit_unary_tag(node)
      %(<#{node[:name]}#{render_attributes(node[:attributes])} />)
    end

    def visit_content_tag(node)
      %(<#{node[:name]}#{render_attributes(node[:attributes])}>#{visit(node[:content])}</#{node[:name]}>)
    end

    def visit_text_node(node)
      node[:content]
    end

    def visit_tag_set(node)
      node[:tags].map { |tag| visit(tag) }.join
    end

    def visit_component(node)
      node[:content] ? visit(node[:content]) : nil
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
