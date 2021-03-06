# encoding: UTF-8

# Export to Excel
# ===============
require 'spreadsheet'
require 'stringio'

module Dossiers
  module ExportToXls
    extend ActiveSupport::Concern

    # Exports the current dossier to an Excel file.
    def to_xls
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet(name: 'Katalog')

      label_columns = self.class.xls_columns.inject([]) do |out, column|
        out << I18n.t(column, scope: 'activerecord.attributes.dossier')
      end

      numbers.each do |number|
        label_columns << number.period
      end

      sheet.row(0).concat(label_columns)

      value_columns = self.class.xls_columns.inject([]) do |out, column|
        case column
          when :container_type
            out << containers.last.container_type.code
          when :location
            out << containers.last.location.code
          else
            out << send(column)
        end
      end

      numbers.each do |number|
        value_columns << number.amount
      end

      sheet.row(1).concat(value_columns)

      # Return as XLS String
      xls = StringIO.new
      book.write xls
      xls.string
    end

    module ClassMethods
      # Exports some dossiers to an Excel file.
      def to_xls(dossiers)
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet(name: 'Katalog')
        present_numbers = DossierNumber.default_periods_as_s
        row = 0

        label_columns = xls_columns.inject([]) do |out, column|
          out << I18n.t(column, scope: 'activerecord.attributes.dossier')
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
          end unless dossier.is_a? Topic

          present_numbers.each do |number|
            value_columns << dossier.amount(number)
          end if dossier.is_a? Topic

          sheet.row(row).concat(value_columns)
          row += 1
        end

        # Return as XLS String
        xls = StringIO.new
        book.write xls
        xls.string
      end

      def to_container_xls(dossiers)
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet(name: 'Katalog')
        row = 0

        dossiers.each do |dossier|
          unless dossier.containers.empty?
            dossier.containers.each do |container|
              sheet.row(row).concat([dossier.to_s, container.period, container.container_type.code, container.location.code])
              row += 1
            end
          else
            sheet.row(row).concat([dossier.to_s])
            row += 1
          end
        end

        # Return as XLS String
        xls = StringIO.new
        book.write xls
        xls.string
      end

      def xls_columns
        [:signature, :title, :container_type, :location, :related_to, :keywords]
      end
    end
  end
end
