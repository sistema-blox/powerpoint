# frozen_string_literal: true

require_relative "base"
require "zip/filesystem"
require "fileutils"
require "fastimage"
require "erb"

module Powerpoint
  module Slide
    class Pictorial < Base
      include Powerpoint::Util

      attr_reader :image_name, :title, :coords, :image_path

      def initialize(options = {})
        require_arguments([:presentation, :title, :image_path], options)

        super

        @coords = default_coords if @coords.none?
        @image_name = File.basename(@image_path)
      end

      def save(extract_path, index)
        copy_media(extract_path, @image_path)
        save_rel_xml("pictorial_rel.xml.erb", extract_path, index)
        save_slide_xml("pictorial_slide.xml.erb", extract_path, index)
      end

      private

      def default_coords
        slide_width = pixle_to_pt(720)
        default_width = pixle_to_pt(550)

        image_width, image_height = dimensions.map { |d| pixle_to_pt(d) }
        new_width = [default_width, image_width].min
        ratio = new_width / image_width.to_f
        new_height = (image_height.to_f * ratio).round

        { x: (slide_width / 2) - (new_width / 2), y: pixle_to_pt(120), cx: new_width, cy: new_height }
      end
    end
  end
end
