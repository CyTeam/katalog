class SpellChecker
  def self.kt_speller
    speller = Aspell.new1('dict-dir' => Rails.root.join('db', 'aspell').to_s, 'lang' => 'kt', 'encoding' => 'UTF-8')
    speller.set_option('ignore-case', 'true')
    speller.suggestion_mode = Aspell::NORMAL

    speller
  end

  def self.de_speller
    speller = Aspell.new1('lang' => 'de_CH', 'encoding' => 'UTF-8')
    speller.set_option('ignore-case', 'true')
    speller.suggestion_mode = Aspell::NORMAL

    speller
  end

  def self.suggestions(query)
    spelling_suggestion = {}
    query.gsub(/[\w\']+/) do |word|
      if word =~ /[0-9]/
        word
      elsif kt_speller.check(word)
        word
      else
        # word is wrong
        suggestion = kt_speller.suggest(word).first
        # if suggestion.blank?
        # Try harder
        # spell_checker.suggestion_mode = Aspell::BADSPELLER
        # suggestion = spell_checker.suggest(word).first
        # end

        if suggestion
          suggestion = de_speller.suggest(suggestion).first
        else
          suggestion = de_speller.suggest(word).first
        end

        # We get UTF-8 encoded answers from our spell checker
        suggestion = suggestion.force_encoding('UTF-8') if suggestion

        spelling_suggestion[word] = suggestion if suggestion.present? && !Dossier.by_text(suggestion).empty? && !(suggestion =~ %r{#{word}} || suggestion.nil?)
      end
    end

    spelling_suggestion
  end
end
