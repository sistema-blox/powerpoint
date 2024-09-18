# frozen_string_literal: true

module Powerpoint
  module Slide
    class Base
      def initialize(options = {})
        options.each { |k, v| instance_variable_set(:"@#{k}", v) }
      end

      def file_type
        return unless defined?(@image_path)

        File.extname(image_name).delete(".")
      end

      private

      def save_rel_xml(view_name, extract_path, index)
        render_view(
          view_name,
          "#{extract_path}/ppt/slides/_rels/slide#{index}.xml.rels",
          index:,
        )
      end

      def save_slide_xml(view_name, extract_path, index)
        render_view(view_name, "#{extract_path}/ppt/slides/slide#{index}.xml")
      end

      def dimensions
        return @dimensions if defined?(@dimensions)

        @dimensions = FastImage.size(image_path)
      end
    end
  end
end
