class DspaceTools
  class BulkUploader

    def initialize(path, collection_id, user)
      @path = path
      @collection_id = collection_id
      @user = user
      get_instance_vars
    end

    def submit
      import_submission
      copy_map_file_to_local
      @map_file
    end

    private
    
    def get_instance_vars
      @map_file = Time.now().to_s[0..18].
        gsub(/[\-\s]/,'_') + '_mapfile_' + @user.email.gsub(/[\.@]/, '_')
      @map_path = File.join(DspaceTools::Conf.tmp_dir, @map_file)
      @data = [DspaceTools::Conf.dspace_path, 
               @user.email, 
               @collection_id, 
               @path, 
               @map_path,]
      @dspace_command = "%s import ItemImport -w -a -e %s -c %s -s %s -m %s" % 
                          @data
      @local_mapfile_path = File.join(DspaceTools::Conf.root_path, 
                                      'public', 
                                      'map_files')
    end

    def dspace_command
      @dspace_command || 
        raise(DspaceTools::ImportError("dspace command not defined"))
    end
   
    def import_submission
      error = DspaceTools::ImportError
      begin
        results = `#{dspace_command}` 
      rescue
        raise(error.new('Dspace upload failed'))
      end
    end
      
    def copy_map_file_to_local
      error = DspaceTools::ImportError
      if File.exists?(@map_path) && open(@map_path).read.strip != ''
        FileUtils.mv @map_path, @local_mapfile_path
      else
        raise(error.new('Failed to generate map file, DSpace upload failed'))
      end
    end

  end
end
