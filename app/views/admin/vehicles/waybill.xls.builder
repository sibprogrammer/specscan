xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.Workbook({
  'xmlns' => "urn:schemas-microsoft-com:office:spreadsheet", 
  'xmlns:o' => "urn:schemas-microsoft-com:office:office",
  'xmlns:x' => "urn:schemas-microsoft-com:office:excel",    
  'xmlns:html' => "http://www.w3.org/TR/REC-html40",
  'xmlns:ss' => "urn:schemas-microsoft-com:office:spreadsheet" 
  }) do

  xml.Worksheet 'ss:Name' => t('.sheet.waybill') do
    xml.Table do
      xml.Row do
        xml.Cell { xml.Data "TODO", 'ss:Type' => 'String' }
      end
    end
  end
end
