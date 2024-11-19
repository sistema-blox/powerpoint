# frozen_string_literal: true

require "fastimage"
require "google/apis/slides_v1"

module Powerpoint
  module Slide
    class Base
      include Powerpoint::Util

      def initialize(options = {})
        options.each { |k, v| instance_variable_set(:"@#{k}", v) }
      end

      def file_type
        return if @image_name.nil?

        File.extname(@image_name).delete(".")
      end

      private

      def save_rel_xml(view_name:, extract_path:, index:)
        render_view(
          view_name,
          "#{extract_path}/ppt/slides/_rels/slide#{index}.xml.rels",
          index:,
        )
      end

      def save_slide_xml(view_name:, extract_path:, index:)
        render_view(view_name, "#{extract_path}/ppt/slides/slide#{index}.xml")
      end

      def dimensions
        return @dimensions if defined?(@dimensions)

        @dimensions = FastImage.size(@image_path) || []
      end

      def shape_id(presentation, object_id_prop)
        slide = presentation.presentation[:data].slides.find { |s| s.object_id_prop == object_id_prop }

        shape = slide.page_elements.find { |page| page.to_json.include?("{{bullet_content}}") }

        shape.object_id_prop
      end

      def get_object_id_prop(presentation, prefix, index)
        slide = presentation.presentation[:metadata][prefix].sample

        presentation.duplicate_slide(slide.object_id_prop, index)
      end
    end
  end
end
