# frozen_string_literal: true

require "spec_helper"
require "powerpoint/slide/pictorial"

RSpec.describe Powerpoint::Slide::Pictorial do
  subject(:slide) { described_class.new(options) }

  let(:presentation) { double("Presentation") }
  let(:title)        { "Sample Title" }
  let(:image_path)   { "spec/fixtures/images/img1.png" }
  let(:options)      { { presentation:, title:, image_path:, coords: } }
  let(:coords)       { {} } # Starting with empty coords to trigger default_coords

  describe "#initialize" do
    context "with required arguments" do
      it "sets instance variables based on options" do
        expect(slide.presentation).to eq(presentation)
        expect(slide.title).to eq(title)
        expect(slide.image_path).to eq(image_path)
      end

      it "sets @image_name based on image_path" do
        expect(slide.image_name).to eq(File.basename(image_path))
      end

      context "when coords is empty" do
        before do
          # Stub dimensions before slide is instantiated
          allow_any_instance_of(described_class).to receive(:dimensions).and_return([800, 600])
        end

        it "sets @coords using default_coords" do
          slide_instance = described_class.new(options)
          expected_coords = slide_instance.send(:default_coords)
          expect(slide_instance.coords).to eq(expected_coords)
        end
      end

      context "when coords are provided" do
        let(:coords) { { x: 100, y: 200, cx: 300, cy: 400 } }

        it "uses provided coords" do
          expect(slide.coords).to eq(coords)
        end
      end
    end

    context "missing required arguments" do
      context "when presentation is missing" do
        let(:options) { { title: title, image_path: image_path } }

        it "raises an ArgumentError" do
          expect { slide }.to raise_error(ArgumentError)
        end
      end

      context "when title is missing" do
        let(:options) { { presentation: presentation, image_path: image_path } }

        it "raises an ArgumentError" do
          expect { slide }.to raise_error(ArgumentError)
        end
      end

      context "when image_path is missing" do
        let(:options) { { presentation: presentation, title: title } }

        it "raises an ArgumentError" do
          expect { slide }.to raise_error(ArgumentError)
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
      expect(slide).to have_received(:save_rel_xml).with("pictorial_rel.xml.erb", extract_path, index)
    end

    it "calls save_slide_xml with correct arguments" do
      expect(slide).to have_received(:save_slide_xml).with("pictorial_slide.xml.erb", extract_path, index)
    end
  end

  describe "#default_coords" do
    context "when dimensions are available" do
      before do
        allow(slide).to receive(:dimensions).and_return([800, 600])
        slide.instance_variable_set(:@coords, slide.send(:default_coords))
      end

      it "calculates coords based on image dimensions" do
        slide_width   = slide.send(:pixle_to_pt, 720)
        default_width = slide.send(:pixle_to_pt, 550)
        image_width   = slide.send(:pixle_to_pt, 800)
        image_height  = slide.send(:pixle_to_pt, 600)

        new_width  = [default_width, image_width].min
        ratio      = new_width / image_width.to_f
        new_height = (image_height * ratio).round

        expected_coords = {
          x: (slide_width / 2) - (new_width / 2),
          y: slide.send(:pixle_to_pt, 120),
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
