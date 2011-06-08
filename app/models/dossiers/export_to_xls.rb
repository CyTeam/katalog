# Export to Excel
# ===============
require 'spreadsheet'
require 'stringio'
require 'iconv'

module Dossiers
  module ExportToXls
    extend ActiveSupport::Concern

    module InstanceMethods
      # Exports the current dossier to an Excel file.
      def to_xls
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet(:name => "Dossier-No.: #{id}") # Encoding problem when using title
        present_numbers = numbers.present
        
        label_columns = Dossier.xls_columns.inject([]) do |out, column|
          out << I18n.t(column, :scope => 'activerecord.attributes.dossier')
        end

        present_numbers.each do |number|
          label_columns << number.period
        end

        sheet.row(0).concat(label_columns)

        value_columns = Dossier.xls_columns.inject([]) do |out, column|
          case column
            when :container_type
              out << containers.last.container_type.code
            when :location
              out << containers.last.location.code
            else
              out << self.send(column)
          end
        end
        
        present_numbers.each do |number|
          value_columns << number.amount
        end
        
        sheet.row(1).concat(value_columns)

        # Return as XLS String
        xls = StringIO.new
        book.write xls
        xls.string
      end
    end

    module ClassMethods
      # Exports some dossiers to an Excel file.
      def to_xls(dossiers)
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet(:name => "Dossier-Signature: #{dossiers.first.signature}") # Encoding problem when using title
        present_numbers = DossierNumber.default_periods_as_s
        row = 0

        label_columns = xls_columns.inject([]) do |out, column|
          out << I18n.t(column, :scope => 'activerecord.attributes.dossier')
        end

        present_numbers.each do |number|
          label_columns << number
        end

        sheet.row(row).concat(label_columns)
        row += 1

        dossiers.each do |dossier|
          value_columns = xls_columns.inject([]) do |out, column|
            case column
              when :container_type
                unless dossier.containers.empty?
                  out << dossier.containers.last.container_type.code
                else
                  out << ''
                end
              when :location
                unless dossier.containers.empty?
                  out << dossier.containers.last.location.code
                else
                  out << ''
                end
              else
                out << dossier.send(column)
            end
          end

          dossier.numbers.each do |number|
            value_columns << number.amount
          end unless dossier.kind_of?Topic


          present_numbers.each do |number|
            value_columns << dossier.amount(number)
          end if dossier.kind_of?Topic

          sheet.row(row).concat(value_columns)
          row += 1
        end

        # Return as XLS String
        xls = StringIO.new
        book.write xls
        xls.string
      end

      private # :nodoc

      def xls_columns
        [:signature, :title, :container_type, :location, :related_to, :keywords]
      end
    end
  end
end
