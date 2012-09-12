xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.Workbook({
  'xmlns' => "urn:schemas-microsoft-com:office:spreadsheet", 
  'xmlns:o' => "urn:schemas-microsoft-com:office:office",
  'xmlns:x' => "urn:schemas-microsoft-com:office:excel",    
  'xmlns:html' => "http://www.w3.org/TR/REC-html40",
  'xmlns:ss' => "urn:schemas-microsoft-com:office:spreadsheet" 
  }) do

  xml.Worksheet 'ss:Name' => t('.sheet.day_report') do
    xml.Table do
      xml.Row do
        %w{ type from_time to_time duration distance fuel_used }.each do |column_name|
          next if 'fuel_used' == column_name and !@vehicle.fuel_sensor
          xml.Cell { xml.Data t(".column.#{column_name}"), 'ss:Type' => 'String' }
        end
      end

      for movement in @movements
        xml.Row do
          xml.Cell { xml.Data t('.' + (movement.parking ? 'parking_title' : 'movement_title')), 'ss:Type' => 'String' }
          xml.Cell { xml.Data movement.from_time.to_formatted_s(:date_time), 'ss:Type' => 'String' }
          xml.Cell { xml.Data movement.to_time.to_formatted_s(:date_time), 'ss:Type' => 'String' }
          xml.Cell { xml.Data duration_human(movement.elapsed_time), 'ss:Type' => 'String' }
          xml.Cell { xml.Data((movement.parking ? '' : decimal_human(movement.distance_km)), 'ss:Type' => 'Number') }
          xml.Cell { xml.Data(((0 == movement_fuel_used(movement)) ? '' : movement_fuel_used(movement)), 'ss:Type' => 'Number') } if @vehicle.fuel_sensor
        end
      end
    end
  end
end
