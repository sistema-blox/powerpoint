# frozen_string_literal: true

require "spec_helper"
require "powerpoint/compression"
require "fileutils"
require "zip"
require "tmpdir"
require "pry-byebug"

RSpec.describe Powerpoint::Compression do
  let(:pptx_file)     { "spec/fixtures/sample.pptx" }
  let(:extract_path)  { Dir.mktmpdir }
  let(:compress_path) { Dir.mktmpdir }
  let(:output_pptx)   { "#{compress_path}/output.pptx" }

  after do
    FileUtils.remove_entry(extract_path) if Dir.exist?(extract_path)
    FileUtils.remove_entry(compress_path) if Dir.exist?(compress_path)
    File.delete(output_pptx) if File.exist?(output_pptx)
  end

  describe ".decompress_pptx" do
    context "when given a valid pptx file" do
      it "extracts the contents to the specified directory" do
        Powerpoint::Compression.decompress_pptx(pptx_file, extract_path)
        expect(Dir.children(extract_path)).not_to be_empty
      end

      it "creates the correct files and directories" do
        Powerpoint::Compression.decompress_pptx(pptx_file, extract_path)
        expect(File).to exist("#{extract_path}/[Content_Types].xml")
        expect(Dir).to exist("#{extract_path}/ppt")
        expect(Dir).to exist("#{extract_path}/docProps")
      end
    end

    context "when given an invalid pptx file path" do
      it "raises a Zip::Error" do
        expect do
          Powerpoint::Compression.decompress_pptx("invalid/path.pptx", extract_path)
        end.to raise_error(Zip::Error)
      end
    end
  end

  describe ".compress_pptx" do
    context "when given a valid directory" do
      before do
        # Set up a sample directory structure to compress
        FileUtils.mkdir_p("#{compress_path}/ppt/slides")
        File.write("#{compress_path}/[Content_Types].xml", "<Types></Types>")
        File.write("#{compress_path}/ppt/presentation.xml", "<Presentation></Presentation>")
      end

      it "creates a pptx file at the specified output path" do
        Powerpoint::Compression.compress_pptx(compress_path, output_pptx)
        expect(File).to exist(output_pptx)
      end

      it "includes the correct files in the pptx archive" do
        Powerpoint::Compression.compress_pptx(compress_path, output_pptx)
        extracted_files = []
        Zip::File.open(output_pptx) do |zip_file|
          zip_file.each { |entry| extracted_files << entry.name }
        end
        expect(extracted_files).to include("[Content_Types].xml")
        expect(extracted_files).to include("ppt/presentation.xml")
      end
    end

    context "when the output pptx already exists" do
      before do
        # Create a sample directory to compress
        FileUtils.mkdir_p("#{compress_path}/ppt/slides")
        File.write("#{compress_path}/[Content_Types].xml", "<Types></Types>")
        File.write("#{compress_path}/ppt/presentation.xml", "<Presentation></Presentation>")

        # Create an existing output file
        FileUtils.touch(output_pptx)
      end

      it "raises an error and does not overwrite the existing file" do
        expect do
          Powerpoint::Compression.compress_pptx(compress_path, output_pptx)
        end.to raise_error(RuntimeError, /already exists/)
      end
    end

    context "when given an invalid directory path" do
      it "raises an Errno::ENOENT error" do
        non_existent_path = "/path/that/does/not/exist"

        expect do
          Powerpoint::Compression.compress_pptx(non_existent_path, output_pptx)
        end.to raise_error(Errno::ENOENT, /No such directory/)
      end
    end
  end
end
