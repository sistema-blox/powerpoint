# frozen_string_literal: true

require "spec_helper"
require "powerpoint/slide/intro"

RSpec.describe Powerpoint::Slide::Intro do
  subject(:slide) { described_class.new(options) }

  let(:title) { "Welcome" }
  let(:subtitile) { "Introduction to Powerpoint" }
  let(:options) { { title: title, subtitile: subtitile, other_option: "value" } }

  describe "#initialize" do
    context "with required arguments" do
      it "sets instance variables based on options" do
        expect(slide.title).to eq(title)
        expect(slide.subtitile).to eq(subtitile)
        expect(slide.instance_variable_get(:@other_option)).to eq("value")
      end
    end

    context "missing required arguments" do
      context "when title is missing" do
        let(:options) { { subtitile: subtitile } }

        it "raises an ArgumentError" do
          expect { slide }.to raise_error(ArgumentError)
        end
      end

      context "when subtitile is missing" do
        let(:options) { { title: title } }

        it "raises an ArgumentError" do
          expect { slide }.to raise_error(ArgumentError)
        end
      end

      context "when both title and subtitile are missing" do
        let(:options) { {} }

        it "raises an ArgumentError" do
          expect { slide }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe "#save" do
    let(:extract_path) { "extract/path" }
    let(:index) { 1 }

    before do
      allow(slide).to receive(:save_rel_xml)
      allow(slide).to receive(:save_slide_xml)
      slide.save(extract_path, index)
    end

    it "calls save_rel_xml with correct arguments" do
      expect(slide).to have_received(:save_rel_xml).with("textual_rel.xml.erb", extract_path, index)
    end

    it "calls save_slide_xml with correct arguments" do
      expect(slide).to have_received(:save_slide_xml).with("intro_slide.xml.erb", extract_path, index)
    end
  end

  describe "#file_type" do
    it "returns nil" do
      expect(slide.file_type).to be_nil
    end
  end
end
