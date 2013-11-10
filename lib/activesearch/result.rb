require 'action_view'
require 'active_support/core_ext'

module ActiveSearch
  class Result < Hash

    DEFAULT_HIGHLIGHT_RADIUS = 50

    include ActionView::Helpers::TextHelper

    def initialize(result, text, options = {})
      @text = text
      result.to_hash.each do |k,v|
        unless v.nil? || k.to_s.start_with?('_')
          self[k.to_s] = v.respond_to?(:has_key?) && v.has_key?(I18n.locale.to_s) ? v[I18n.locale.to_s] : v
        end
      end

      self.build_highlighted_fields(options[:radius])
    end

    protected

    def build_highlighted_fields(radius = nil)
      radius = radius || DEFAULT_HIGHLIGHT_RADIUS

      self["highlighted"] = self.each_with_object({}) do |(k,v), h|
        if v.is_a?(String)
          h[k] = excerpt(v, text_words.first, radius: radius)
          h[k] = highlight(h[k], text_words, highlighter: '<em>\1</em>') unless h[k].nil?
        end
      end
    end

    def text_words
      @text_words ||= @text.scan(/\w+|\n/)
    end
  end
end