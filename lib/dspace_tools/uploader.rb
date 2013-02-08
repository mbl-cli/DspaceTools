class DspaceTools
  class Uploader
    attr_reader :params, :file, :dir, :path, :zip_file

    def self.clean(days = 1)
      tmp_dir = DspaceTools::Conf.tmp_dir
      threshold = 86400 * days
      now = Time.now.to_i
      Dir.entries(tmp_dir).select {|e| e.match /^dspace_[\d]{10}/}.each do |dir|
        path = File.join(tmp_dir, dir)
        FileUtils.rm_rf(path) if (now - File.ctime(path).to_i) > threshold
      end
    end

    def initialize(params)
      @params = params
      @file = @params["file"] || raise(DspaceTools::UploadError.new("No file to upload")) 
      @dir = get_dir
      copy_file
      @zip_file = File.join(@path, @file[:filename])
    end

    private
    
    def get_dir
      res = nil
      until res
        res = "dspace_%010d" % rand(9999999999)
        @path = File.join(DspaceTools::Conf.tmp_dir, res)
        @path = res = nil if File.exists?(@path)
      end
      res
    end

    def copy_file
      FileUtils.mkdir(@path)
      FileUtils.cp(@file[:tempfile].path, File.join(@path, @file[:filename]))
    end
  end
end
