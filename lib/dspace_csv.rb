module DSpaceCSV
  def self.authenticate(username, password)
    self::Conf.users[username] && self::Conf.users[username]["hash"] == Digest::SHA1.hexdigest(password + "\n")
  end
    
  def self.submit(path, collection_id, user)
    remote_path = File.join(DSpaceCSV::Conf.remote_tmp_dir, 'csv_' + path.match(/(dspace_[\d]+)/)[1])
    `scp -r #{path} #{DSpaceCSV::Conf.remote_login}:#{remote_path}`
    map_file = Time.now().to_s[0..9].gsub('-','_') + '_mapfile_' + user["name"].downcase.gsub(' ', '_')
    params = [DSpaceCSV::Conf.dspace_path, user["email"], collection_id, remote_path, File.join(remote_dir_path, map_file)]
    dspace_command = "%s import ItemImport -a -e %s -c %s -s %s -m %s" % params
    params[0] ? `ssh #{DSpaceCSV::Conf.remote_login} '#{dspace_command}'` : puts(dspace_command)
    `scp #{DSpaceCSV::Conf.remote_login}:#{File.join(DSpaceCSV::Conf.remote_tmp_dir, map_file)} #{DSpaceCSV::Conf.tmp_dir}`
    File.join(DSpaceCSV::Conf.tmp_dir, map_file)
  end

end
