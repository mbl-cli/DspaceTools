require "CSV"
require "bundler/setup"
require "nokogiri"

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
        @filename = filename
    end

    # assume Filename exists in each row
    # Filename cannot have a '.' except for the extension
    def transform_rows
        @csv.each do |row|
            filename = "#{File.basename(row['Filename'], ".*")}.xml"
            file = File.new(filename, 'w')
            builder = Nokogiri::XML::Builder.new do |xml|
                xml.dublin_core {
                    row.each do |header, value|
                        puts "value! #{value}"
                        next if header == "Filename"
                        element, qualifier = header.strip.downcase.split
                        qualifier = "none" if qualifier.nil?
                        xml.dcvalue(:element => element, :qualifier => qualifier){
                            xml.text value
                        }
                    end
                }
            end
            file.puts builder.to_xml
            file.close
        end
    end
end
