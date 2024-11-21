# frozen_string_literal: true

require_relative "base"
require "google/apis/drive_v3"

module Powerpoint
  module GoogleServices
    class Template < Base
      attr_reader :pptx_path, :template_name

      CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.presentationml.presentation"

      def initialize(args)
        super()

        args.each { |k, v| instance_variable_set(:"@#{k}", v) }
      end

      def self.upload_source(args)
        new(args).send(:upload_source)
      end

      def self.get_template(args = {})
        new(args).send(:get_template)
      end

      def self.remove_template(args = {})
        new(args).send(:remove_template)
      end

      private

      def upload_source
        raise "PPTX path is required" if pptx_path?
        raise "Template not found" unless File.exist?(pptx_path)
        raise "Template must be a .pptx file" unless File.extname(pptx_path) == ".pptx"

        filename = File.basename(pptx_path, ".pptx")

        template_metadata = Google::Apis::DriveV3::File.new(name: "#{filename}_template")

        drive.create_file(
          template_metadata,
          upload_source: pptx_path,
          content_type: CONTENT_TYPE,
        )
      end

      def get_template # rubocop:disable Naming/AccessorMethodName
        if template_name?
          drive.list_files.files.filter { |file| file.name.include?("_template") }.sample
        else
          drive.list_files(q: "name='#{template_name}_template'").files.first
        end
      end

      def remove_template
        raise "Template name is required" if template_name?

        template = get_template

        raise "Template not found" unless template

        drive.delete_file(template.id)
      end

      def template_name?
        template_name.nil? || template_name.empty?
      end

      def pptx_path?
        pptx_path.nil? || pptx_path.empty?
      end
    end
  end
end
