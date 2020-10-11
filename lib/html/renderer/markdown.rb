# frozen_string_literal: true

require 'html/renderer'

module HTML
  class Renderer
    class Markdown < Renderer
      private

      def visit_unary_tag(node)
        nil
      end

      def visit_content_tag(node)
        content = visit(node.content)

        case node.name
        when :h1
          "# #{content}\n\n"
        when :h2
          "## #{content}\n\n"
        when :h3
          "### #{content}\n\n"
        when :h4
          "#### #{content}\n\n"
        when :h5
          "##### #{content}\n\n"
        when :h6
          "###### #{content}\n\n"
        when :li
          "* #{content}\n"
        when :em
          "_#{content}_"
        when :strong
          "**#{content}**"
        when :a
          %((#{content})[#{node.attributes[:href]}])
        else
          "#{content}\n\n"
        end
      end

      def visit_text_node(node)
        node.to_s
      end

      def visit_tag_set(node)
        node.children.map { |tag| visit(tag) }.join
      end

      def visit_component(node)
        visit(node.children)
      end
    end
  end
end
