class ApiKey < ActiveRecord::Base
  belongs_to :eperson

  def self.digest(path, key)
    Digest::SHA1.hexdigest(path.to_s + key.to_s)[0..7]
  end

  def self.get_public_key
    key = 0
    while true do
      rand_max = 0xffffffff - 0x10000000
      key = rand(rand_max).+(0x10000000).to_s(16)
      break if ApiKey.where(:public_key => key).empty?
    end
    key
  end

  def self.get_private_key
    rand_max = 0xffffffffffffffff - 0x1000000000000000
    key = rand(rand_max).+(0x1000000000000000).to_s(16)
  end


  def digest(path)
    ApiKey.digest(path, private_key)
  end

  def valid_digest?(a_digest, path)
    digest(path) == a_digest
  end
end

class DspaceError < ActiveRecord::Base
  belongs_to :eperson
end
