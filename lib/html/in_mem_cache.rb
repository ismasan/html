# frozen_string_literal: true

module HTML
  class InMemCache
    def initialize
      @data = {}
    end

    def fetch(key, &block)
      entry = @data[key]
      return entry if entry

      if block_given?
        entry = block.call
        @data[key] = entry
        entry
      end
    end
  end
end
