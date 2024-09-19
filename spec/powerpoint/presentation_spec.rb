# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe Powerpoint::Presentation do
  subject(:presentation) { described_class.new }

  let(:title)        { "Sample Title" }
  let(:subtitle)     { "Sample Subtitle" }
  let(:content)      { ["Paragraph 1", "Paragraph 2"] }
  let(:image_path)   { "spec/fixtures/images/img1.png" }
  let(:coords)       { { x: 100, y: 200, cx: 300, cy: 400 } }
  let(:save_path)    { "spec/fixtures/output.pptx" }

  before do
    allow(Powerpoint::Slide::Intro).to receive(:new).and_call_original
    allow(Powerpoint::Slide::Textual).to receive(:new).and_call_original
    allow(Powerpoint::Slide::Pictorial).to receive(:new).and_call_original
    allow(Powerpoint::Slide::TextPictureSplit).to receive(:new).and_call_original
    allow(Powerpoint::Slide::PictureDescription).to receive(:new).and_call_original
    allow_any_instance_of(Powerpoint::Slide::Base).to receive(:save)
  end

  describe "#initialize" do
    it "initializes with an empty slides array" do
      expect(presentation.slides).to eq([])
    end
  end

  describe "#add_intro" do
    context "when there is no existing intro slide" do
      it "creates a new Intro slide and adds it to the beginning of slides" do
        presentation.add_intro(title, subtitle)
        expect(presentation.slides.first).to be_a(Powerpoint::Slide::Intro)
        expect(presentation.slides.size).to eq(1)
        expect(Powerpoint::Slide::Intro).to have_received(:new).with(
          presentation: presentation,
          title: title,
          subtitile: subtitle,
        )
      end
    end

    context "when an intro slide already exists" do
      it "replaces the existing intro slide with the new one" do
        presentation.add_intro("Old Title", "Old Subtitle")
        expect(presentation.slides.size).to eq(1)
        expect(presentation.slides.first.title).to eq("Old Title")

        presentation.add_intro(title, subtitle)
        expect(presentation.slides.size).to eq(1)
        expect(presentation.slides.first.title).to eq(title)
      end
    end
  end

  describe "#add_textual_slide" do
    it "creates a new Textual slide and adds it to slides" do
      presentation.add_textual_slide(title, content)
      expect(presentation.slides.last).to be_a(Powerpoint::Slide::Textual)
      expect(presentation.slides.size).to eq(1)
      expect(Powerpoint::Slide::Textual).to have_received(:new).with(
        presentation: presentation,
        title: title,
        content: content,
      )
    end
  end

  describe "#add_pictorial_slide" do
    it "creates a new Pictorial slide and adds it to slides" do
      presentation.add_pictorial_slide(title, image_path, coords)
      expect(presentation.slides.last).to be_a(Powerpoint::Slide::Pictorial)
      expect(presentation.slides.size).to eq(1)
      expect(Powerpoint::Slide::Pictorial).to have_received(:new).with(
        presentation: presentation,
        title: title,
        image_path: image_path,
        coords: coords,
      )
    end
  end

  describe "#add_text_picture_slide" do
    it "creates a new TextPictureSplit slide and adds it to slides" do
      presentation.add_text_picture_slide(title, image_path, content)
      expect(presentation.slides.last).to be_a(Powerpoint::Slide::TextPictureSplit)
      expect(presentation.slides.size).to eq(1)
      expect(Powerpoint::Slide::TextPictureSplit).to have_received(:new).with(
        presentation: presentation,
        title: title,
        image_path: image_path,
        content: content,
      )
    end
  end

  describe "#add_picture_description_slide" do
    it "creates a new PictureDescription slide and adds it to slides" do
      presentation.add_picture_description_slide(title, image_path, content)
      expect(presentation.slides.last).to be_a(Powerpoint::Slide::PictureDescription)
      expect(presentation.slides.size).to eq(1)
      expect(Powerpoint::Slide::PictureDescription).to have_received(:new).with(
        presentation: presentation,
        title: title,
        image_path: image_path,
        content: content,
      )
    end
  end

  describe "#file_types" do
    before do
      allow_any_instance_of(Powerpoint::Slide::Base).to receive(:file_type).and_return("jpeg")
      presentation.add_pictorial_slide(title, image_path, coords)
      presentation.add_pictorial_slide(title, image_path, coords)
      presentation.add_textual_slide(title, content)
    end

    it "returns a unique array of file types from slides that respond to file_type" do
      expect(presentation.file_types).to eq(["jpeg"])
    end
  end
end
