module DSpaceCSV
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
    end

  end
end

