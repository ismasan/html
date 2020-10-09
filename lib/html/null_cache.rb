# frozen_string_literal: true

module HTML
  class NullCache
    def fetch(_key, &block)
      block.call
    end
  end
end
