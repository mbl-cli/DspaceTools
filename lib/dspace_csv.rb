module DSpaceCSV
  def self.authenticate(username, password)
    self::Conf.users[username] && self::Conf.users[username]["hash"] == Digest::SHA1.hexdigest(password + "\n")
  end
    
  def self.submit(path, collection_id, user)
    Dir.entries(path).each do |e|
      next unless e.match(/[\d]{4}/)
      path = File.join(path, e)
      params = [ user["email"], collection_id, path, File.join(path, 'dublin_core.xml') ]
      puts "path_to/dspace import ItemImport -a -e %s -c %s -s %s -m %s" % params
    end
  end

end
