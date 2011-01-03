PDFKit.configure do |config|
  config.wkhtmltopdf = '/home/roman/.rvm/gems/ruby-1.8.7-p302@katalog/bin/wkhtmltopdf'
  config.default_options = {
    :page_size => 'A4',
    :print_media_type => true
  }
end
