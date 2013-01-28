require_relative '../environment'
exit unless [:development, :test].include?(settings.environment)

class HttpSeeder
  HTTP_DIR = File.join(File.dirname(__FILE__), '..', 'spec', 'http')

  def walk_xml
    require 'ruby-debug'; debugger
    Dir.entries(HTTP_DIR).each do |file|
      if file[-4..-1] == '.xml'
        xml_text = open(File.join(HTTP_DIR, file)).read.gsub(/.*(<\?xml)/m, '\1')
        require 'ruby-debug'; debugger
        puts ''
      end
    end
  end


end


hs = HttpSeeder.new
hs.walk_xml

