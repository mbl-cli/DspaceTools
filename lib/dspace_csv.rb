module DSpaceCSV
  def self.authenticate(username, password)
    self::Conf.users[username]["hash"] == Digest::SHA1.hexdigest(password + "\n")
  end
end
