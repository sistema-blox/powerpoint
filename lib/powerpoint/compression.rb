# frozen_string_literal: true

module Powerpoint
  class Compression
    def self.decompress_pptx(in_path, out_path)
      Zip::File.open(in_path) do |zip_file|
        zip_file.each do |f|
          f_path = File.join(out_path, f.name)

          FileUtils.mkdir_p(File.dirname(f_path))

          zip_file.extract(f, f_path) unless File.exist?(f_path)
        end
      end
    end

    def self.compress_pptx(in_path, out_path)
      raise Errno::ENOENT, "No such directory - #{in_path}" unless Dir.exist?(in_path)

      raise "#{out_path} already exists!" if File.exist?(out_path)

      Zip::File.open(out_path, Zip::File::CREATE) do |zip_file|
        Dir.glob("#{in_path}/**/*", ::File::FNM_DOTMATCH).each do |path|
          zip_path = path.gsub("#{in_path}/", "")

          next if zip_path == "." || zip_path == ".." || zip_path.include?("DS_Store")

          begin
            zip_file.add(zip_path, path)
          rescue Zip::ZipEntryExistsError
            raise "#{out_path} already exists!"
          end
        end
      end
    end
  end
end
