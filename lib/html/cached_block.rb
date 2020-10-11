# frozen_string_literal: true

module HTML
  class CachedBlock
    attr_reader :type, :cache_key

    def initialize(cache_key, &content_block)
      @cache_key = cache_key.respond_to?(:cache_key) ? cache_key.cache_key : cache_key
      @content_block = content_block
      @type = :cached_block
    end

    def fetch_or_render(store, &on_uncached)
      store.fetch(cache_key) do
        on_uncached.call(children)
      end
    end

    def children
      @children ||= TagSet.new(&content_block)
    end

    private

    attr_reader :content_block
  end
end
