# frozen_string_literal: true

require "fastimage"
require "spec_helper"
require "powerpoint/util"
require "powerpoint/slide/base"

RSpec.describe Powerpoint::Slide::Base do
  subject(:slide) { described_class.new(options) }

  let(:image_path) { fixture_file_path("images/img1.png") }
  let(:options) { { image_path:, other_option: "value" } }

  describe "#initialize" do
    it "sets instance variables based on options" do
      expect(slide.instance_variable_get(:@image_path)).to eq(image_path)
      expect(slide.instance_variable_get(:@other_option)).to eq("value")
    end
  end

  describe "#file_type" do
    context "when @image_name is not defined" do
      it "returns nil" do
        expect(slide.file_type).to be_nil
      end
    end

    context "when @image_name is defined" do
      before do
        slide.instance_variable_set(:@image_name, "image_name.jpg")
      end

      it "returns file type" do
        expect(slide.file_type).to eq("jpg")
      end
    end
  end

  describe "#dimensions" do
    let(:dimensions) { [800, 600] }

    before do
      slide.instance_variable_set(:@image_path, image_path)

      allow(FastImage).to receive(:size).with(image_path).and_return(dimensions)
    end

    context "when @dimensions is not defined" do
      it "calculates and returns image dimensions" do
        expect(slide.send(:dimensions)).to eq(dimensions)

        expect(FastImage).to have_received(:size).with(image_path)
      end
    end

    context "when @dimensions is already defined" do
      before do
        slide.instance_variable_set(:@dimensions, dimensions)
      end

      it "returns memoized dimensions" do
        expect(slide.send(:dimensions)).to eq(dimensions)
        expect(FastImage).not_to have_received(:size)
      end
    end
  end
end
