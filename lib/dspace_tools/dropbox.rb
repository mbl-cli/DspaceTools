class DspaceTools

  class Dropbox
    attr_reader :dropbox_dir

    def initialize
      @dropbox_dir = Conf.dropbox_dir
    end

    def dirs
      return @dirs if @dirs
      @dirs = []
      Dir.entries(@dropbox_dir).each do |e|
        d_path = File.join(@dropbox_dir, e)
        if dir?(d_path)
          @dirs << OpenStruct.new(name: e, path: d_path, files: [])
          Dir.entries(d_path).each do |f|
            f_path = File.join(@dropbox_dir, @dirs.last.name, f)
            @dirs.last.files << { name: f, 
                                 path: f_path, 
                                 size: File.size(f_path) 
                               } if File.file?(f_path)
          end
        end
      end
      @dirs
    end

  private
  
    def dir?(path)
      File.directory?(path) && File.split(path).last.gsub('.', '') != ''
    end

  end
end
