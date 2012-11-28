xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.Workbook({
  'xmlns' => "urn:schemas-microsoft-com:office:spreadsheet", 
  'xmlns:o' => "urn:schemas-microsoft-com:office:office",
  'xmlns:x' => "urn:schemas-microsoft-com:office:excel",    
  'xmlns:html' => "http://www.w3.org/TR/REC-html40",
  'xmlns:ss' => "urn:schemas-microsoft-com:office:spreadsheet" 
  }) do

  xml.Worksheet 'ss:Name' => t('.sheet.reports') do
    xml.Table do
      xml.Row do
        %w{ date parking movement parking_time movements_time active_time distance fuel fuel_norm fuel_fact refuels fuel_theft }.each do |column_name|
          next if 'fuel' == column_name and @vehicle.fuel_sensor
          next if %w{ fuel_norm fuel_fact refuels fuel_theft }.include?(column_name) and !@vehicle.fuel_sensor
          next if 'active_time' == column_name and Vehicle::FUEL_CALC_BY_MHOURS != @vehicle.fuel_calc_method
          xml.Cell { xml.Data t(".column.#{column_name}"), 'ss:Type' => 'String' }
        end
      end

      for report in @reports
        xml.Row do
          xml.Cell { xml.Data report.date_human, 'ss:Type' => 'String' }
          xml.Cell { xml.Data report.parking_count, 'ss:Type' => 'Number' }
          xml.Cell { xml.Data report.movement_count, 'ss:Type' => 'Number' }
          xml.Cell { xml.Data duration_human(report.parking_time), 'ss:Type' => 'String' }
          xml.Cell { xml.Data duration_human(report.movement_time), 'ss:Type' => 'String' }
          if Vehicle::FUEL_CALC_BY_MHOURS == @vehicle.fuel_calc_method
            xml.Cell { xml.Data duration_human(report.active_time), 'ss:Type' => 'String' }
          end
          xml.Cell { xml.Data((report.distance.to_f / 1000).round, 'ss:Type' => 'Number') }
          if @vehicle.fuel_sensor
            xml.Cell { xml.Data((Vehicle::FUEL_CALC_BY_MHOURS == @vehicle.fuel_calc_method ? report.fuel_norm.to_f : (report.fuel_norm.to_f / 1000)).round, 'ss:Type' => 'Number') }
            xml.Cell { xml.Data((report.fuel_used.to_f > 0 ? report.fuel_used.to_f : 0).round, 'ss:Type' => 'Number') }
            xml.Cell { xml.Data report.fuel_added.to_f.round, 'ss:Type' => 'Number' }
            xml.Cell { xml.Data report.fuel_stolen.to_f.round, 'ss:Type' => 'Number' }
          else
            xml.Cell { xml.Data((report.fuel_norm.to_f / 1000).round, 'ss:Type' => 'Number') }
          end
        end
      end
    end
  end
end
