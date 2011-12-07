module Dossiers
  module Sphinx
    extend ActiveSupport::Concern
    
    included do
      # Sphinx configuration:
      # Free text search
      define_index do
        # Needed for tag/keyword search
        set_property :group_concat_max_len => 1048576

        # Disable delta update in import as it slows down too much and otherwise do it delayed.
        set_property :delta => true unless Rails.env.import? or Rails.env.fallback?

        # Indexed Fields
        indexes title
        indexes signature
        # Use _taggings relation to fix thinking sphinx issue #167
        indexes keyword_taggings.tag.name, :as => :keywords

        # Weights
        set_property :field_weights => {
          :title    => 500,
          :keywords => 2
        }

        # Attributes
        has created_at, updated_at
        has type
        has internal
      end
    end

    module ClassMethods
      def by_text(value, options = {})
        attributes = {:type => 'Dossier'}
        attributes[:internal] = false if (options.delete(:internal) == false)
        
        params = {:match_mode => :extended, :rank_mode => :match_any, :with => attributes}
        params.merge!(options)
        
        query = build_query(value)
        search(query, params)
      end

      def split_search_words(query)
        sentences = []
        signature_range = signature_range(query)
        # Need a clone or slice! will do some harm
        value = query.clone
        while sentence = value.slice!(/\".[^\"]*\"/)
          sentences << sentence.delete('"');
        end

        strings = value.split(/[ %();,:-]/).uniq.select{|t| t.present?}
        words = []
        signatures = []
        strings.each do |string|
          if /^[0-9]*\.$/.match(string)
            # is an ordinal
            words << string
          elsif is_ordinal_signature?(string)
            # signature is as ordinal by index
            signatures << string + "."
          elsif is_signature?(string)
            if (string.include?'.') || string.length == 1
              signatures << string
            else
              words << string
            end
          else
            words << string.split('.')
          end
        end

        words = words.flatten

        return signatures, words, sentences, signature_range
      end

      def signature_range(query)
        signature_range = []

        if query.include?('-')
          range = query.split('-')

          is_range = range.inject([]) do |out, signature|
            out << is_ordinal_signature?(signature) || is_signature?(signature)

            out
          end

          unless is_range.include?(false)
            topics = Topic.by_range(range[0], range[1])

            signature_range = topics.inject([]) {|out, topic| out << topic.signature; out }
          end
        end

        signature_range
      end

      def is_ordinal_signature?(string)
        /^[0-9]{2}(\.[0-9A-Za-z])?$/.match(string)
      end

      def is_signature?(string)
        /^[0-9.]{1,8}$/.match(string)
      end

      # Build sphinx query from freetext
      def build_query(value)
        signatures, words, sentences = split_search_words(value)

        if signatures.present?
          quoted_signatures = signatures.map{|signature| '"' + signature + '*"'}
          signature_query = "@signature (#{quoted_signatures.join('|')})"
        end
        
        if sentences.present?
          quoted_sentences = sentences.map{|sentence| '"' + sentence + '"'}
          sentence_query = "@* (#{quoted_sentences.join('|')})"
        end

        if words.present?
          quoted_words = words.map {|word|
            if word.length < 2
              word
            elsif word.length == 2
              word + "*"
            elsif word.length > 2
              "+\"" + word + "*\"" + " | " + "\"*" + word + "*\""
            end
          }
          word_query = "@* (\"#{words.join(' ')}\" | (#{(quoted_words).join(' ')}))"
        end

        query = [signature_query, sentence_query, word_query].join(' ')

        return query.strip
      end
    end
  end
end
