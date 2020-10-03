# frozen_string_literal: true

module HTML
  class Component
    def self.render(*args)
      new(*args).to_s
    end

    def to_s
      render.to_s
    end

    private

    def render
      ''
    end

    def tag(*args, &block)
      HTML.tag(*args, &block)
    end
  end
end
