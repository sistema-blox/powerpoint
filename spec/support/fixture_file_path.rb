# frozen_string_literal: true

def fixture_file_path(filename)
  File.expand_path(File.join("spec/fixtures", filename), __dir__)
end
