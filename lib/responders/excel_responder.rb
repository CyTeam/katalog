module Responders
  class ExcelResponder < ActionController::Responder
    # Responder
    def to_format
      raise "XLS"
      if @resources
        send_data(Dossier.to_xls(@resources),
          :filename => "dossiers_#{@resources.first.signature}.xls",
          :type => 'application/vnd.ms-excel')
      else
        send_data(@resource.to_xls,
          :filename => "dossier_#{@resource.signature}.xls",
          :type => 'application/vnd.ms-excel')
      end
    end
  end
end
