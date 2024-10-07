# frozen_string_literal: true

require "spec_helper"
require "powerpoint/util"

RSpec.describe Powerpoint::Util do
  subject(:util) { dummy_class.new }

  let(:dummy_class) do
    Class.new do
      include Powerpoint::Util
    end
  end

  describe "#pixle_to_pt" do
    it "converts pixels to points correctly" do
      expect(util.pixle_to_pt(1)).to eq(12_700)
      expect(util.pixle_to_pt(0)).to eq(0)
      expect(util.pixle_to_pt(2.5)).to eq(31_750)
    end
  end

  describe "#render_view" do
    let(:template_name)  { "template.erb" }
    let(:path)           { "output.txt" }
    let(:variables)      { { name: "John Doe" } }
    let(:template_content) { "Hello, <%= name %>!" }
    let(:expected_output)  { "Hello, John Doe!" }

    before do
      allow(util).to receive(:read_template).with(template_name).and_return(template_content)
      allow(File).to receive(:open).with(path, "w")
    end

    it "renders the template and writes to the specified path" do
      file_double = instance_double(File)
      allow(File).to receive(:open).with(path, "w").and_yield(file_double)
      expect(file_double).to receive(:<<).with(expected_output)

      util.render_view(template_name, path, variables)
    end
  end

  describe "#read_template" do
    let(:filename)      { "template.erb" }
    let(:view_path)     { "/path/to/views" }
    let(:full_path)     { "#{view_path}/#{filename}" }
    let(:template_content) { "Template Content" }

    before do
      stub_const("Powerpoint::VIEW_PATH", view_path)
      allow(File).to receive(:read).with(full_path).and_return(template_content)
    end

    it "reads the template file from the correct path" do
      expect(util.read_template(filename)).to eq(template_content)
    end
  end

  describe "#require_arguments" do
    let(:required_arguments) { [:name, :age] }

    context "when all required arguments are present" do
      let(:arguments) { { name: "John", age: 30, city: "New York" } }

      it "does not raise an error" do
        expect { util.require_arguments(required_arguments, arguments) }.not_to raise_error
      end
    end

    context "when a required argument is missing" do
      let(:arguments) { { name: "John" } }

      it "raises an ArgumentError" do
        expect { util.require_arguments(required_arguments, arguments) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#copy_media" do
    let(:extract_path)    { "extract/path" }
    let(:image_path)      { "path/to/image.jpg" }
    let(:image_name)      { "image.jpg" }
    let(:destination_path) { "#{extract_path}/ppt/media/#{image_name}" }

    before do
      allow(File).to receive(:basename).with(image_path).and_return(image_name)
      allow(File).to receive(:exist?).with(destination_path).and_return(false)
      allow(FileUtils).to receive(:copy_file)
    end

    it "copies the image to the correct destination when the file does not exist" do
      expect(FileUtils).to receive(:copy_file).with(image_path, destination_path)
      util.copy_media(extract_path, image_path)
    end

    context "when the file already exists at the destination" do
      before do
        allow(File).to receive(:exist?).with(destination_path).and_return(true)
      end

      it "does not copy the file" do
        expect(FileUtils).not_to receive(:copy_file)
        util.copy_media(extract_path, image_path)
      end
    end
  end

  describe "#merge_variables" do
    let(:binding_context) { binding }
    let(:variables)       { { name: "Alice", age: 25 } }

    it "sets local variables in the binding" do
      util.merge_variables(binding_context, variables)
      expect(binding_context.local_variable_get(:name)).to eq("Alice")
      expect(binding_context.local_variable_get(:age)).to eq(25)
    end

    context "when variables are empty" do
      let(:variables) { {} }

      it "returns the original binding without changes" do
        expect(util.merge_variables(binding_context, variables)).to eq(binding_context)
      end
    end
  end
end
