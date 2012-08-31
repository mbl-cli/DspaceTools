module DSpaceCSV
  class Transformer
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
    attr_reader :expander, :path

    def initialize(expander)
      @expander = expander
      @path = File.join(@expander.uploader.path, 'dspace')
      transform
    end

    private

    def transform
      csv_data = parse_csv
      process_data(csv_data)
    end

    def parse_csv
      csv_file = Dir.entries(@expander.path).select {|e| e.match(/\.csv$/)}[0]
      csv_string = open(File.join(@expander.path, csv_file), "r:utf-8").read.gsub(/\r\n?/, "\n")
      options = {:col_sep => ",", :row_sep => "\n", :headers => true}
      CSV.parse(csv_string, options)
    end

    def process_data(csv_data)
      count = -1
      csv_data.each do |row|
        count += 1
        path = File.join(@path, "%04d" % count) 
        FileUtils.mkdir_p(path)
        file = open(File.join(path, 'dublin_core.xml'), 'w:utf-8')
        file.puts build_xml_string(row)
        copy_files(row['Filename'], path)
        file.close
      end
    end

    def build_xml_string(data)
      Nokogiri::XML::Builder.new do |xml|
        xml.dublin_core do
          data.each do |header, value|
            next if header == "Filename" || value.nil? || value.empty?
            element, qualifier = header.strip.downcase.split
            qualifier = "none" if qualifier.nil?
            xml.dcvalue(:element => element, :qualifier => qualifier) do
              xml.text value
            end
          end
        end
      end.to_xml
    end
    
    def copy_files(filenames, path)
      contents = open(File.join(path, "contents"), "w:utf-8")
      filenames.split("|").each do |f|
        FileUtils.cp(File.join(@expander.path, f), path)
        contents.write("%s\tbundle:ORIGINAL\n" % f)
      end
      contents.close
    end

  end
end

