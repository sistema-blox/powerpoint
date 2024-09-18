# frozen_string_literal: true

require_relative "base"
require "fileutils"
require "erb"

module Powerpoint
  module Slide
    class Intro < Base
      include Powerpoint::Util

      attr_reader :title, :subtitile

      def initialize(options = {})
        require_arguments([:title, :subtitile], options)

        super
      end

      def save(extract_path, index)
        save_rel_xml("textual_rel.xml.erb", extract_path, index)
        save_slide_xml("intro_slide.xml.erb", extract_path, index)
      end

      def file_type
        nil
      end
    end
  end
end
