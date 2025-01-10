# frozen_string_literal: true

require_relative "base"
require "fileutils"
require "erb"

module Powerpoint
  module Slide
    class Intro < Base
      attr_reader :title, :subtitle

      def initialize(options = {})
        require_arguments([:title, :subtitle], options)

        super
      end

      def save(args = {})
        if google?
          save_google(**args)
        else
          save_rel_xml(view_name: "textual_rel.xml.erb", **args)
          save_slide_xml(view_name: "intro_slide.xml.erb", **args)
        end
      end

      def save_google(presentation:, index:)
        fields = { title:, subtitle: }

        object_id_prop = get_object_id_prop(presentation, :intro, index)

        requests = fields.map do |field, content|
          presentation.replace_all_text(prefix: "intro", field: field.to_s, content:, object_id_prop:)
        end

        requests << presentation.update_slides_position(object_id_prop:, index:)
      end

      def file_type
        nil
      end
    end
  end
end
