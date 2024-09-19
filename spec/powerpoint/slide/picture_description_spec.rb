# frozen_string_literal: true

require "spec_helper"
require "powerpoint/slide/picture_description"

RSpec.describe Powerpoint::Slide::PictureDescription do
  subject(:slide) { described_class.new(options) }

  let(:presentation) { double("Presentation") }
  let(:title)        { "Sample Title" }
  let(:content)      { ["Paragraph 1", "Paragraph 2"] }
  let(:image_path)   { "spec/fixtures/images/test_image.jpg" }
  let(:options)      { { presentation: presentation, title: title, image_path: image_path, content: content } }

  describe "#initialize" do
    context "with required arguments" do
      it "sets instance variables based on options" do
        expect(slide.title).to eq(title)
        expect(slide.content).to eq(content)
        expect(slide.image_path).to eq(image_path)
        expect(slide.image_name).to eq(File.basename(image_path))
      end

      it "sets @coords using default_coords" do
        expected_coords = slide.send(:default_coords)
        expect(slide.coords).to eq(expected_coords)
      end
    end

    context "missing required arguments" do
      context "when presentation is missing" do
        let(:options) { { title: title, image_path: image_path, content: content } }

        it "raises an ArgumentError" do
          expect { described_class.new(options) }.to raise_error(ArgumentError)
        end
      end

      context "when title is missing" do
        let(:options) { { presentation: presentation, image_path: image_path, content: content } }

        it "raises an ArgumentError" do
          expect { described_class.new(options) }.to raise_error(ArgumentError)
        end
      end

      context "when image_path is missing" do
        let(:options) { { presentation: presentation, title: title, content: content } }

        it "raises an ArgumentError" do
          expect { described_class.new(options) }.to raise_error(ArgumentError)
        end
      end

      context "when content is missing" do
        let(:options) { { presentation: presentation, title: title, image_path: image_path } }

        it "raises an ArgumentError" do
          expect { described_class.new(options) }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe "#save" do
    let(:extract_path) { "extract/path" }
    let(:index)        { 1 }

    before do
      allow(slide).to receive(:copy_media)
      allow(slide).to receive(:save_rel_xml)
      allow(slide).to receive(:save_slide_xml)
      slide.save(extract_path, index)
    end

    it "calls copy_media with correct arguments" do
      expect(slide).to have_received(:copy_media).with(extract_path, image_path)
    end

    it "calls save_rel_xml with correct arguments" do
      expect(slide).to have_received(:save_rel_xml).with("picture_description_rels.xml.erb", extract_path, index)
    end

    it "calls save_slide_xml with correct arguments" do
      expect(slide).to have_received(:save_slide_xml).with("picture_description_slide.xml.erb", extract_path, index)
    end
  end

  describe "#default_coords" do
    context "when dimensions are available" do
      before do
        allow(slide).to receive(:dimensions).and_return([800, 600])
        slide.instance_variable_set(:@coords, slide.send(:default_coords))
      end

      it "calculates coords based on image dimensions" do
        slide_width    = slide.send(:pixle_to_pt, 720)
        default_width  = slide.send(:pixle_to_pt, 550)
        default_height = slide.send(:pixle_to_pt, 300)

        image_width  = slide.send(:pixle_to_pt, 800)
        image_height = slide.send(:pixle_to_pt, 600)

        capped_width  = [default_width, image_width].min
        w_ratio       = capped_width / image_width.to_f

        capped_height = [default_height, image_height].min
        h_ratio       = capped_height / image_height.to_f

        ratio       = [w_ratio, h_ratio].min

        new_width   = (image_width.to_f * ratio).round
        new_height  = (image_height.to_f * ratio).round

        expected_coords = {
          x: (slide_width / 2) - (new_width / 2),
          y: slide.send(:pixle_to_pt, 60),
          cx: new_width,
          cy: new_height,
        }

        expect(slide.coords).to eq(expected_coords)
      end
    end

    context "when dimensions are empty" do
      before do
        allow(slide).to receive(:dimensions).and_return([])
        slide.instance_variable_set(:@coords, slide.send(:default_coords))
      end

      it "returns an empty hash" do
        expect(slide.coords).to eq({})
      end
    end
  end
end
