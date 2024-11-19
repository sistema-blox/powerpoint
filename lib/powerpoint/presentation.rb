# frozen_string_literal: true

require "zip/filesystem"
require "fileutils"
require "tmpdir"
require "powerpoint"
module Powerpoint
  class Presentation
    include Powerpoint::Util

    attr_reader :deck

    SAVE_METHOD = {
      local: :save_default,
      google: :save_google_slide,
    }

    def initialize
      @deck = []
    end

    def add_intro(title, subtitle = nil)
      slide = Powerpoint::Slide::Intro.new(presentation: self, title:, subtitle:)

      if existing_intro_slide.nil?
        @deck.insert(0, slide)
      else
        @deck[@deck.index(existing_intro_slide)] = slide
      end
    end

    def add_textual_slide(title, content = [])
      @deck << Powerpoint::Slide::Textual.new(presentation: self, title:, content:)
    end

    def add_pictorial_slide(title, image_path, coords = {})
      @deck << Powerpoint::Slide::Pictorial.new(
        presentation: self,
        title:,
        image_path:,
        coords:,
      )
    end

    def add_text_picture_slide(title, image_path, content = [])
      @deck << Powerpoint::Slide::TextPictureSplit.new(
        presentation: self,
        title:,
        image_path:,
        content:,
      )
    end

    def add_picture_description_slide(title, image_path, content = [])
      @deck << Powerpoint::Slide::PictureDescription.new(
        presentation: self,
        title:,
        image_path:,
        content:,
      )
    end

    def save(args = {})
      raise "Argument must be a hash" unless args.is_a?(Hash)

      save_method = SAVE_METHOD[Powerpoint.provider]

      raise "Invalid save method" if save_method.nil?

      send(save_method, args)

      args[:path]
    end

    private

    def save_google_slide(args)
      template_name = args[:template_name] || ""

      presentation = Powerpoint::GoogleServices::Presentation.new(template_name)

      requests = deck.map.with_index { |slide, index| slide.save(presentation:, index:) }.flatten

      presentation.save_presentation!(requests)
      presentation.remove_unused_slides!
      presentation.export_presentation(args[:path])
      presentation.delete_presentation!

      args[:path]
    end

    def save_default(args)
      path = args[:path]

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

        # Save deck
        deck.each.with_index(1) do |slide, index|
          slide.save(extract_path:, index:)
        end

        # Create .pptx file
        File.delete(path) if File.exist?(path)

        Powerpoint::Compression.compress_pptx(extract_path, path)
      end
    end

    def file_types
      deck.filter_map { |slide| slide.file_type if slide.respond_to?(:file_type) }.uniq
    end

    def existing_intro_slide
      @deck.find { |s| s.class == Powerpoint::Slide::Intro }
    end
  end
end
