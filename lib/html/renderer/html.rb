# frozen_string_literal: true

require 'html/renderer'

module HTML
  class Renderer
    class Html < Renderer
      WHITESPACE = ' '
      HTML5 = "<!DOCTYPE html>\n<html"
      UNARY_TAGS = %i[
        area
        base
        br
        col
        embed
        hr
        img
        input
        link
        meta
        param
        source
        track
        wbr
      ].freeze

      private

      def visit_content_tag(node)
        if UNARY_TAGS.include?(node.name)
          String.new('<') << node.name.to_s << render_attributes(node.attributes) << ' />'
        else
          case node.name
          when :html5
            String.new(HTML5) << render_attributes(node.attributes) << '>' << visit(node.content) << '</html>'
          else
            String.new('<') << node.name.to_s << render_attributes(node.attributes) << '>' << visit(node.content) << '</' << node.name.to_s << '>'
          end
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

      def render_attributes(attributes)
        return '' unless attributes.any?

        WHITESPACE + attributes.map do |k, v|
          case v.first
          when TrueClass
            k
          when FalseClass
            # omit
            nil
          when Hash
            # k 'data', v.first {foo: 'bar'}
            v.first.each.with_object([]) { |(key, val), r| r << attribute_pair(k, key, val) }.join(WHITESPACE)
          else
            [k, %("#{v.join(WHITESPACE)}")].join('=')
          end
        end.compact.join(WHITESPACE)
      end

      def attribute_pair(k, key, val)
        val.is_a?(TrueClass) ? %(#{k}-#{key}) : %(#{k}-#{key}="#{val}")
      end
    end
  end
end
