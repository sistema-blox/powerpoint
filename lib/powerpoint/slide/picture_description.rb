# frozen_string_literal: true

require_relative "base"
require "zip/filesystem"
require "fileutils"
require "fastimage"
require "erb"

module Powerpoint
  module Slide
    class PictureDescription < Base
      include Powerpoint::Util

      attr_reader :title, :content, :image_name, :image_path, :coords, :presentation

      def initialize(options = {})
        require_arguments([:presentation, :title, :image_path, :content], options)

        super

        @coords = default_coords
        @image_name = File.basename(@image_path)
      end

      def save(extract_path, index)
        copy_media(extract_path, @image_path)
        save_rel_xml("picture_description_rels.xml.erb", extract_path, index)
        save_slide_xml("picture_description_slide.xml.erb", extract_path, index)
      end

      private

      def default_coords
        slide_width = pixle_to_pt(720)
        default_width = pixle_to_pt(550)
        default_height = pixle_to_pt(300)

        return {} if dimensions.empty?

        image_width, image_height = dimensions.map { |d| pixle_to_pt(d) }

        capped_width = [default_width, image_width].min
        w_ratio = capped_width / image_width.to_f

        capped_height = [default_height, image_height].min
        h_ratio = capped_height / image_height.to_f

        ratio = [w_ratio, h_ratio].min

        new_width = (image_width.to_f * ratio).round
        new_height = (image_height.to_f * ratio).round

        { x: (slide_width / 2) - (new_width / 2), y: pixle_to_pt(60), cx: new_width, cy: new_height }
      end
    end
  end
end
