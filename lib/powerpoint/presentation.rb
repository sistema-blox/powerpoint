# frozen_string_literal: true

require "zip/filesystem"
require "fileutils"
require "tmpdir"
require "powerpoint"

module Powerpoint
  class Presentation
    include Powerpoint::Util

    attr_reader :slides

    def initialize
      @slides = []
    end

    def add_intro(title, subtitile = nil)
      slide = Powerpoint::Slide::Intro.new(presentation: self, title:, subtitile:)

      if existing_intro_slide.nil?
        @slides.insert(0, slide)
      else
        @slides[@slides.index(existing_intro_slide)] = slide
      end
    end

    def add_textual_slide(title, content = [])
      @slides << Powerpoint::Slide::Textual.new(presentation: self, title:, content:)
    end

    def add_pictorial_slide(title, image_path, coords = {})
      @slides << Powerpoint::Slide::Pictorial.new(
        presentation: self,
        title:,
        image_path:,
        coords:,
      )
    end

    def add_text_picture_slide(title, image_path, content = [])
      @slides << Powerpoint::Slide::TextPictureSplit.new(
        presentation: self,
        title:,
        image_path:,
        content:,
      )
    end

    def add_picture_description_slide(title, image_path, content = [])
      @slides << Powerpoint::Slide::PictureDescription.new(
        presentation: self,
        title:,
        image_path:,
        content:,
      )
    end

    def save(path)
      Dir.mktmpdir do |dir|
        extract_path = "#{dir}/extract_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}"

        # Copy template to temp path
        FileUtils.copy_entry(Powerpoint::TEMPLATE_PATH, extract_path)

        # Remove keep files
        Dir.glob("#{extract_path}/**/.keep").each do |keep_file|
          FileUtils.rm_rf(keep_file)
        end

        # Render/save generic stuff
        render_view("content_type.xml.erb", "#{extract_path}/[Content_Types].xml")
        render_view("presentation.xml.rel.erb", "#{extract_path}/ppt/_rels/presentation.xml.rels")
        render_view("presentation.xml.erb", "#{extract_path}/ppt/presentation.xml")
        render_view("app.xml.erb", "#{extract_path}/docProps/app.xml")

        # Save slides
        slides.each.with_index(1) do |slide, index|
          slide.save(extract_path, index)
        end

        # Create .pptx file
        File.delete(path) if File.exist?(path)

        Powerpoint::Compression.compress_pptx(extract_path, path)
      end

      path
    end

    def file_types
      slides.filter_map { |slide| slide.file_type if slide.respond_to?(:file_type) }.uniq
    end

    private

    def existing_intro_slide
      @slides.find { |s| s.class == Powerpoint::Slide::Intro }
    end
  end
end
