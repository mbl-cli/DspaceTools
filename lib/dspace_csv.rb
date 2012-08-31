require 'rubygems'
require "bundler/setup"
require "nokogiri"
require "zip/zip"
require "csv"

class DSpaceCSV
  VALID_HEADERS = %w[Filename Contributor\ Advisor Contributor\ Author
        Contributor\ Editor Contributor\ Illustrator Contributor\ Other
        Contributor Coverage\ Spatial Coverage\ Temporal Creator
        Date\ Accessioned Date\ Available Date\ Copyright Date\ Created
        Date\ Issued Date\ Submitted Date\ Updated Date Description\ Abstract
        Description\ Provenance Description\ Sponsorship 
        Description\ Statementofresponsibility Description\ Tableofcontents 
        Description\ Uri Description\ Version Description Format\ Extent 
        Format\ Medium Format\ Mimetype Format Identifier\ Citation 
        Identifier\ Govdoc Identifier\ Isbn Identifier\ Ismn Identifier\ Issn 
        Identifier\ Other Identifier\ Sici Identifier\ Slug Identifier\ Uri 
        Identifier Language\ Iso Language\ rfc3066 Language Publisher 
        Relation\ Haspart Relation\ Hasversion Relation\ Isbasedon 
        Relation\ Isformatof Relation\ Ispartof Relation\ Ispartofseries 
        Relation\ Isreferencedby Relation\ Isreplacedby Relation\ Isversionof 
        Relation\ Replaces Relation\ Requires Relation\ Uri Relation 
        Rights\ Holder Rights\ Uri Rights Source\ Uri Source 
        Subject\ Classification Subject\ Ddc Subject\ Lcc Subject\ Lcsh 
        Subject\ Mesh Subject\ Other Subject Title\ Alternative Title Type]

        CODES = '#!/usr/bin/env ruby
require "fileutils"

FileUtils.rm_rf("./data") if File.directory? "./data"
Dir.mkdir("./data")

# grab all the .xml files
Dir.glob("*.xml").each do |xml_file|
  count_string = File.basename(xml_file, ".xml")
  f = open(xml_file)
  metadata_content = f.readlines
  f.close
  file_names = metadata_content.pop.strip.split("|") 
  # FileUtils.rm_r(count_string) if File.directory? count_string
  Dir.mkdir("./data/#{count_string}")
  w = open("./data/#{count_string}/dublin_core.xml", "w")
  metadata_content.each { |l| w.write(l) }
  w.close
  File.unlink(xml_file)
  w = open("./data/#{count_string}/contents", "w")
  file_names.each do |content_file|
    FileUtils.cp(content_file, "./data/#{count_string}/")
    w.write("%s\tbundle:ORIGINAL\n" % content_file) 
  end
  w.close
end'

    # string is value of uploaded csv
    # filename is the filename to be used as dirname
    def initialize(string, filename)
      @string = string.gsub(/\r\n?/, "\n")
      @options = {:col_sep => ",", :row_sep => "\n", :headers => true}
      @csv = CSV.parse(@string, @options)
      @zip_filename = "/tmp/#{File.basename(filename, '.csv')}.zip"
      File.unlink(@zip_filename) if File.exists?(@zip_filename)
      @script = make_script
      @zip = Zip::ZipFile.new(@zip_filename, true)
    end

    def make_script
      f = File.new('/tmp/dspace_directory_structure.rb', 'w')
      f.puts CODES
      f.close
      f
    end
    # assume Filename exists in each row
    # Filename cannot have a '.' except for the extension
    def transform_rows
      files = []
      count = -1
      @csv.each do |row|
        count += 1
        next if row['Filename'].nil?
        filename = "/tmp/%04d.xml" % count
        file = open(filename, 'w')
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.dublin_core {
            row.each do |header, value|
            next if header == "Filename"
            next if value.nil?
            next if value.empty?
            element, qualifier = header.strip.downcase.split
            qualifier = "none" if qualifier.nil?
            xml.dcvalue(:element => element, :qualifier => qualifier){
              xml.text value
            }
            end
          }
        end
        files << file.path
        file.puts builder.to_xml
        file.puts "#{row['Filename']}"
        @zip.add(File.basename(filename), file.path)
        file.close
      end
      @zip.add("dspace_directory_structure.rb", @script.path)
      @zip.close
      files.each {|file| File.unlink(file)}
      File.unlink(@script.path)
      puts files.inspect
      @zip_filename
    end
end
