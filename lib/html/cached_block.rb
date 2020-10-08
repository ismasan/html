# frozen_string_literal: true

module HTML
  class CachedBlock
    attr_reader :type

    def initialize(cache_key, &content_block)
      @cache_key = cache_key.respond_to?(:cache_key) ? cache_key.cache_key : cache_key
      @content_block = content_block
      @type = :cached_block
    end

    def fetch_or_render(store, &on_uncached)
      if content = store[cache_key]
        return content
      else
        uncached_content = TagSet.new(&content_block)
        content = on_uncached.call(uncached_content)
        store[cache_key] = content
        content
      end
    end

    private

    attr_reader :cache_key, :content_block
  end
end
