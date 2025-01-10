# frozen_string_literal: true

require_relative "base"
require "fileutils"
require "erb"

module Powerpoint
  module Slide
    class Textual < Base
      attr_reader :title, :content

      def initialize(options = {})
        require_arguments([:title, :content], options)

        super
      end

      def save(args = {})
        if google?
          send(:"save_google_#{prefix}", **args)
        else
          save_rel_xml("textual_rel.xml.erb", **args)
          save_slide_xml("textual_slide.xml.erb", **args)
        end
      end

      private

      def save_google_textual(presentation:, index:)
        fields = { title:, content: }

        object_id_prop = get_object_id_prop(presentation, prefix.to_sym, index)

        requests = fields.map do |field, content|
          presentation.replace_all_text(prefix:, field: field.to_s, content:, object_id_prop:)
        end

        requests << presentation.update_slides_position(object_id_prop:, index:)
      end

      def save_google_bullet(presentation:, index:)
        object_id_prop = get_object_id_prop(presentation, prefix.to_sym, index)

        requests = []

        requests << presentation.replace_all_text(prefix:, field: "title", content: title, object_id_prop:)
        requests << presentation.update_bullet_style(shape_id(presentation, object_id_prop), content.join("\n"))
        requests << presentation.update_slides_position(object_id_prop:, index:)
      end

      def prefix
        return @prefix if defined?(@prefix)

        @prefix = content.is_a?(Array) ? "bullet" : "textual"
      end
    end
  end
end
