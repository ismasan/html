# frozen_string_literal: true

require 'html/renderer'

module HTML
  class Renderer
    class Html < Renderer
      WHITESPACE = ' '

      private

      def visit_unary_tag(node)
        String.new('<') << node.name.to_s << render_attributes(node.attributes) << ' />'
      end

      def visit_content_tag(node)
        String.new('<') << node.name.to_s << render_attributes(node.attributes) << '>' << visit(node.content) << '</' << node.name.to_s << '>'
      end

      def visit_text_node(node)
        node.to_s
      end

      def visit_tag_set(node)
        node.tags.map { |tag| visit(tag) }.join
      end

      def visit_component(node)
        visit(node.children)
      end

      def render_attributes(attributes)
        return '' unless attributes.any?

        WHITESPACE + attributes.map do |k, v|
          [k, %("#{v.join(WHITESPACE)}")].join('=')
        end.join(WHITESPACE)
      end
    end
  end
end
