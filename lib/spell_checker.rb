class SpellChecker
  def self.speller(personal: true)
    speller = FFI::Aspell::Speller.new('de_CH')
    speller.set('personal', 'db/aspell/aspell.de_CH.pws') if personal
    speller.suggestion_mode = 'normal'

    speller
  end

  def self.suggestions(query)
    spelling_suggestion = {}
    query.gsub(/[\w\']+/) do |word|
      if word =~ /[0-9]/
        word
      elsif speller.correct?(word)
        word
      else
        # word is wrong
        suggestion = speller.suggestions(word).first

        if suggestion
          suggestion = speller(personal: false).suggestions(suggestion).first
        else
          suggestion = speller(personal: false).suggestions(word).first
        end
        speller.close

        # We get UTF-8 encoded answers from our spell checker
        suggestion = suggestion.force_encoding('UTF-8') if suggestion

        spelling_suggestion[word] = suggestion if suggestion.present? && !Dossier.by_text(suggestion).empty? && !(suggestion =~ %r{#{word}} || suggestion.nil?)
      end
    end

    spelling_suggestion
  end
end
