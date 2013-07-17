class DspaceTools
  
  def self.version
    open(File.join(File.dirname(__FILE__), '..', 'VERSION')).read.strip
  end

  def self.password_authorization(params)
    return nil unless (params[:email] && params[:password])
    Eperson.where(email: params[:email], 
                  password: Digest::MD5.hexdigest(params[:password])).first
  end

  def self.api_key_authorization(params, path)
    return nil unless (params[:api_key] && params[:api_digest])
    api_key = ApiKey.where(:public_key => params[:api_key]).first
    digest = Digest::SHA1.hexdigest(path + api_key.private_key)[0..7]
    success = api_key && digest == params[:api_digest]
    success ? api_key.eperson : nil
  end

  def self.last_updated
    last_date = `git log --date=short --pretty=format:"%ad" -1`
    last_date =~ /fatal/ ? "" : "Code updated on #{last_date}"
  end
  
end
