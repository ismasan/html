require "html/version"

module HTML
  class Error < StandardError; end
end

require 'html/renderer'
require 'html/markdown'
require 'html/tag_set'
require 'html/tag'
require 'html/component'
