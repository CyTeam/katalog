namespace :katalog do
  desc 'Set up a fresh cloned git repo for operation'
  task :setup do
    ['database'].each do |file|
      example_file = Rails.root.join('config', "#{file}.yml.example")
      real_file    = Rails.root.join('config', "#{file}.yml")

      if !File.exist?(real_file)
        sh "cp #{example_file} #{real_file}"
      else
        puts "#{real_file} already exists!"
      end
    end
  end

  namespace :ts do
    desc 'Export word_form and exception lists'
    task export_lists: :environment do
      sh "mkdir -p #{Rails.root.join('config', 'sphinx')}"
      SphinxAdminWordForm.send(:export_file)
      SphinxAdminException.send(:export_file)
    end
  end

  namespace :aspell do
    desc 'Update the aspell wordlist'
    task update: :environment do
      word_list = Rails.root.join('db', 'aspell', 'aspell.de_CH.pws')

      File.open(word_list, 'w') do |f|
        f.puts("personal_repl-1.1 de_CH #{Tag.uniq.pluck(:name).size} utf-8")
        f.puts(Tag.uniq.pluck(:name))
      end
    end
  end
end
