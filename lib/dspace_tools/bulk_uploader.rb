class DspaceTools
  class BulkUploader
    attr :dspace_error

    def initialize(path, collection_id, user)
      @dspace_error = nil
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

    def dspace_command
      @dspace_command 
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
      @dspace_command = 
        "%s import ItemImport -w -a -e %s -c %s -s %s -m %s 2>&1" % 
                          @data
      @local_mapfile_path = File.join(DspaceTools::Conf.root_path, 
                                      'public', 
                                      'map_files')
    end

    def import_submission
      begin
        @dspace_output = `#{dspace_command}` 
      rescue RuntimeError => e
        raise(DspaceTools::ImportError.new("DSpace upload failed: %s" % 
                                           e.message))
      end
    end
      
    def copy_map_file_to_local
      if File.exists?(@map_path) && open(@map_path).read.strip != ''
        FileUtils.mv @map_path, @local_mapfile_path
      else
        @dspace_error = DspaceError.create!(eperson_id: @user.id, 
                                     collection_id: @collection_id,
                                     error: @dspace_output)
        raise(DspaceTools::ImportError.new(
          'DSpace upload failed: empty mapfile'))
      end
    end

  end
end
