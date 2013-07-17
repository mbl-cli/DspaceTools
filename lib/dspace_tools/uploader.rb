class DspaceTools
  class Uploader
    attr_reader :params, :path, :incoming_path, :dir

    def self.clean(days = 1)
      tmp_dir = DspaceTools::Conf.tmp_dir
      threshold = 86400 * days
      now = Time.now.to_i
      dirs = Dir.entries(tmp_dir)
      dirs.select { |e| e.match /^dspace_[\d]{10}/ }.each do |dir|
        path = File.join(tmp_dir, dir)
        FileUtils.rm_rf(path) if (now - File.ctime(path).to_i) > threshold
      end
    end

    def initialize(params)
      error = DspaceTools::UploadError
      @params = params
      err_string = 'Collection is not selected'
      raise(error.new(err_string)) if params[:collection_id].to_i == 0
      @incoming_dir = @params[:dir] || 
        raise(error.new('Directory is not selected')) 
      @incoming_path = File.join(DspaceTools::Conf.dropbox_dir, @incoming_dir)
      @dir = get_dir
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

  end
end
