namespace :katalog do
  desc "Set up a fresh cloned git repo for operation"
  task :setup do
    ['database'].each do |file|
      example_file = Rails.root.join('config',"#{file}.yml.example")
      real_file    = Rails.root.join('config',"#{file}.yml")

      if ! File.exists?(real_file)
        sh "cp #{example_file} #{real_file}"
      else
        puts "#{real_file} already exists!"
      end
    end
  end

  namespace :raspell do
    desc "Update the aspell wordlist"
    task :update => :environment do
      word_list = "#{Rails.root}/tmp/wordlist.txt"

      File.open(word_list, 'w') do |f|
          f.puts(Tag.select('DISTINCT name').all)
      end

      sh "aspell --encoding=UTF-8 --master=#{Rails.root}/db/aspell/kt.dat  --lang=kt create master #{Rails.root}/db/aspell/kt.rws < #{word_list}"
      sh "rm #{word_list}"
    end
  end
end
