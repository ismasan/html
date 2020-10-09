# frozen_string_literal: true

require "html/version"
require 'html/renderer'
require 'html/renderer/html'
require 'html/null_cache'
require 'html/in_mem_cache'

module HTML
  class Error < StandardError; end

  class << self
    attr_accessor :cache_store, :renderer
  end

  self.cache_store = NullCache.new
  self.renderer = Renderer::Html
end

require 'html/inheritable_class_settings'
require 'html/cached_block'
require 'html/tag_set'
require 'html/tag'
require 'html/component'
