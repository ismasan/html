# frozen_string_literal: true

module HTML
  class Renderer
    def self.render(node)
      new.visit(node)
    end

    def initialize(cache_store: HTML.cache_store)
      @cache_store = cache_store
    end

    def visit(node)
      send("visit_#{node.type}", node)
    end

    private

    attr_reader :cache_store

    def visit_cached_block(node)
      node.fetch_or_render(cache_store) do |uncached_content|
        visit(uncached_content)
      end
    end
  end
end
