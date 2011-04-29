require "CSV"
require "bundler/setup"
require "nokogiri"
require "zip/zip"

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

    # string is value of uploaded csv
    # filename is the filename to be used as dirname
    def initialize(string, filename)
        @string = string.gsub(/\r\n?/, "\n")
        @options = {:col_sep => ",", :row_sep => "\n", :headers => true}
        @csv = CSV.parse(@string, @options)
        @zip_filename = "/tmp/#{File.basename(filename, '.csv')}.zip"
        File.unlink(@zip_filename) if File.exists?(@zip_filename)
        @zip = Zip::ZipFile.new(@zip_filename, true)
    end

    # assume Filename exists in each row
    # Filename cannot have a '.' except for the extension
    def transform_rows
        files = []
        @csv.each do |row|
            filename = "/tmp/#{File.basename(row['Filename'], ".*")}.xml"
            file = File.new(filename, 'w')
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
            @zip.add(File.basename(filename), file.path)
            file.close
        end
        @zip.close
        files.each {|file| File.unlink(file)}
        puts files.inspect
        @zip_filename
    end
end
