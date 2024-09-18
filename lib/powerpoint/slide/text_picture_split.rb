# frozen_string_literal: true

require_relative "base"
require "zip/filesystem"
require "fileutils"
require "fastimage"
require "erb"

module Powerpoint
  module Slide
    class TextPicSplit < Base
      include Powerpoint::Util

      attr_reader :title, :content, :image_name, :image_path, :coords

      def initialize(options = {})
        require_arguments([:presentation, :title, :image_path, :content], options)

        super

        @coords = default_coords
        @image_name = File.basename(@image_path)
      end

      def save(extract_path, index)
        copy_media(extract_path, @image_path)
        save_rel_xml("text_picture_split_rel.xml.erb", extract_path, index)
        save_slide_xml("text_picture_split_slide.xml.erb", extract_path, index)
      end

      private

      def default_coords
        start_x = pixle_to_pt(360)
        default_width = pixle_to_pt(300)

        image_width, image_height = dimensions.map { |d| pixle_to_pt(d) }
        new_width = [default_width, image_width].min
        ratio = new_width / image_width.to_f
        new_height = (image_height.to_f * ratio).round

        { x: start_x, y: pixle_to_pt(120), cx: new_width, cy: new_height }
      end
    end
  end
end
