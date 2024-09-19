# frozen_string_literal: true

require_relative "base"
require "fileutils"
require "erb"
require "powerpoint/util"

module Powerpoint
  module Slide
    class Textual < Base
      include Powerpoint::Util

      attr_reader :title, :content

      def initialize(options = {})
        require_arguments([:title, :content], options)

        super
      end

      def save(extract_path, index)
        save_rel_xml("textual_rel.xml.erb", extract_path, index)
        save_slide_xml("textual_slide.xml.erb", extract_path, index)
      end
    end
  end
end
