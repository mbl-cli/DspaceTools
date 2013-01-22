class DSpaceCSV
  class Expander
    attr_reader :uploader, :path

    def initialize(uploader)
      @uploader = uploader
      @path = File.join(@uploader.path, "upload")
      unzip
    end

    private

    def unzip
      begin
        Zip::ZipFile.open(@uploader.zip_file) do |zip_file| 
          zip_file.each do |f|
            f_path=File.join(@path, f.name)
            FileUtils.mkdir_p(File.dirname(f_path))
            zip_file.extract(f, f_path) unless File.exist?(f_path)
          end
        end
      rescue Zip::ZipError => e
        raise DSpaceCSV::UploadError.new("Uploaded file is not in a valid zip format")
      end
      adjust_path
    end

    def adjust_path
      return if has_csv_file? 
      dirs = Dir.entries(@path).select{ |f| !['.', '_', '-'].include?(f[0]) && File.directory?(File.join(@path, f)) }
      if dirs.size == 1
        @path = File.join(@path, dirs[0]) 
      elsif dirs.size > 1
        raise DSpaceCSV::UploadError.new("Zip archive contains many folders") 
      end
    end

    def has_csv_file?
      !Dir.entries(@path).select { |f| f[-4..-1] == '.csv' }.empty?
    end

  end
end

