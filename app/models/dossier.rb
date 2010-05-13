class Dossier < ActiveRecord::Base
  default_scope :order => 'signature'
  
  # Importer
  def self.import_from_csv(path)
    # Load file at path using ; as delimiter
    rows = FasterCSV.read(path, :col_sep => ';')
    
    # Select rows containing main dossier records by simply testing on two columns in first row
    dossier_rows = rows.select{|row| row[0] && row[0].split('.').count == 3}

    transaction do
      for row in dossier_rows
        dossier = self.new(
          :signature => row[0],
          :title     => row[1],
          :kind      => row[9],
          :location  => row[10]
        )
        
        dossier.save!
      end
    end
  end
end
