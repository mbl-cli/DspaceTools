module DSpaceCSV
  def self.authenticate(username, password)
    self::Conf.users[username] && self::Conf.users[username]["hash"] == Digest::SHA1.hexdigest(password + "\n")
  end
    
  def self.submit(path, collection_id, user)
    remote_path = File.join(DSpaceCSV::Conf.remote_tmp_dir, 'csv_' + path.match(/(dspace_[\d]+)/)[1])
    `ssh #{DSpaceCSV::Conf.remote_login} 'mkdir -p #{remote_path}'`
    Dir.entries(path).each do |e|
      next unless e.match(/[\d]{4}/)
      dir_path = File.join(path, e)
      remote_dir_path = File.join(remote_path, e)
      `scp -r #{dir_path} #{DSpaceCSV::Conf.remote_login}:#{remote_path}`
      params = [DSpaceCSV::Conf.dspace_path, user["email"], collection_id, remote_dir_path, File.join(remote_dir_path, 'dublin_core.xml') ]
      dspace_command = "%s import ItemImport -a -e %s -c %s -s %s -m %s" % params
      # /dspace/bin/dspace import ItemImport -a -e drielinger@mbl.edu -c 28 -s /tmp/csv_dspace_7773576859/ -m /tmp10242012BMI
      params[0] ? `ssh #{DSpaceCSV::Conf.remote_login} '#{dspace_command}'` : puts(dspace_command)
    end
  end

end
