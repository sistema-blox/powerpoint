# frozen_string_literal: true

require "spec_helper"
require "powerpoint/slide/textual"

RSpec.describe Powerpoint::Slide::Textual do
  subject(:slide) { described_class.new(options) }

  let(:title)   { "Sample Title" }
  let(:content) { ["Line 1", "Line 2"] }
  let(:options) { { title: title, content: content } }

  describe "#initialize" do
    context "with required arguments" do
      it "sets instance variables based on options" do
        expect(slide.title).to eq(title)
        expect(slide.content).to eq(content)
      end
    end

    context "missing required arguments" do
      context "when title is missing" do
        let(:options) { { content: content } }

        it "raises an ArgumentError" do
          expect { described_class.new(options) }.to raise_error(ArgumentError)
        end
      end

      context "when content is missing" do
        let(:options) { { title: title } }

        it "raises an ArgumentError" do
          expect { described_class.new(options) }.to raise_error(ArgumentError)
        end
      end

      context "when both title and content are missing" do
        let(:options) { {} }

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
      allow(slide).to receive(:save_rel_xml)
      allow(slide).to receive(:save_slide_xml)
      slide.save(extract_path, index)
    end

    it "calls save_rel_xml with correct arguments" do
      expect(slide).to have_received(:save_rel_xml).with("textual_rel.xml.erb", extract_path, index)
    end

    it "calls save_slide_xml with correct arguments" do
      expect(slide).to have_received(:save_slide_xml).with("textual_slide.xml.erb", extract_path, index)
    end
  end
end
