# frozen_string_literal: true

require "html/version"

module HTML
  class Error < StandardError; end
end

require 'html/inheritable_class_settings'
require 'html/renderer'
require 'html/cached_block'
require 'html/tag_set'
require 'html/tag'
require 'html/component'
