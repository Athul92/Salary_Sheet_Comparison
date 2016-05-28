class Makemodel < ActiveRecord::Migration
  def self.import(file,project_name,file_name,start_row,end_row,unique,last_column)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(start_row.to_i)
    i=0
    header.count.times do
      unless header[i].nil?
        header[i]= header[i].gsub(/[^0-9A-Za-z]/, '').downcase
      end
      i+=1
    end
    name = "#{project_name.downcase}"+"#{file_name.downcase}"
    create_table name.pluralize do |t|
      header.each do |head|
        t.string head
      end
    end
    model_file = File.join("app", "models", name.singularize+".rb")
    model_name = name.singularize.capitalize
    File.open(model_file, "w+") do |f|
      f << "class #{model_name} < ActiveRecord::Base\nend"
    end

    ((start_row.to_i+1)..end_row.to_i).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      #should find a logic to find the model class that is being created
      product = Object.const_get(name.capitalize).new
      product.attributes = row.to_hash
      product.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Csv.new(file.path, nil, :ignore)
      when ".xls" then Roo::Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
