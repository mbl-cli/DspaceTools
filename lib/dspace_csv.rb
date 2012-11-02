module DSpaceCSV
  def self.authenticate(username, password)
    self::Conf.users[username] && self::Conf.users[username]["hash"] == Digest::SHA1.hexdigest(password + "\n")
  end
    
  def self.submit(path, collection_id, user)
    remote_path = File.join(DSpaceCSV::Conf.remote_tmp_dir, 'csv_' + path.match(/(dspace_[\d]+)/)[1])
    `scp -r #{path} #{DSpaceCSV::Conf.remote_login}:#{remote_path}`
    map_file = Time.now().to_s[0..18].gsub(/[\-\s]/,'_') + '_mapfile_' + user["name"].downcase.gsub(' ', '_')
    params = [DSpaceCSV::Conf.dspace_path, user["email"], collection_id, remote_path, File.join(DSpaceCSV::Conf.remote_tmp_dir, map_file)]
    dspace_command = "%s import ItemImport -a -e %s -c %s -s %s -m %s" % params
    if params[0] 
      results = `ssh #{DSpaceCSV::Conf.remote_login} '#{dspace_command}'` 
      local_mapfile_path = File.join(DSpaceCSV::Conf.root_path, 'public', 'map_files')
      `scp #{DSpaceCSV::Conf.remote_login}:#{File.join(DSpaceCSV::Conf.remote_tmp_dir, map_file)} #{local_mapfile_path}`
      `ssh #{DSpaceCSV::Conf.remote_login} 'find #{File.join(DSpaceCSV::Conf.remote_tmp_dir, "csv_dspace_*")} -maxdepth 0 -mtime 1 -exec rm -rf {} \;'`
    else
      puts(dspace_command)
    end
    [map_file, results]
  end

end
