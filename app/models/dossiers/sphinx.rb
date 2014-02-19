# encoding: UTF-8

module Dossiers
  module Sphinx
    extend ActiveSupport::Concern

    included do
      # Sphinx configuration:
      # Free text search
      define_index do
        # Needed for tag/keyword search
        set_property :group_concat_max_len => 1048576

        # Disable delta update in Fallback environment, as we use it read-only
        set_property :delta => true unless Rails.env.fallback?

        # Indexed Fields
        indexes title
        indexes description
        indexes signature
        # Use _taggings relation to fix thinking sphinx issue #167
        indexes keyword_taggings.tag.name, :as => :keywords

        indexes direct_parents.title, :as => :parent_title

        # Weights
        set_property :field_weights => {
          :title    => 500,
          :parent_title => 5,
          :keywords => 10
        }

        # Attributes
        has created_at, updated_at
        has "type = 'Topic'", :type => :boolean, :as => :is_topic
        has type
        has internal
        has "signature LIKE '17%'", :type => :boolean, :as => :is_local
        has signature, :type => :string, :as => :signature_sort
      end
    end

    module ClassMethods
      def by_text(value, options = {})
        # Only include internal dossiers if user is logged in
        attributes = {}
        attributes[:internal] = false if (options.delete(:internal) == false)
        attributes[:is_topic] = false if options.delete(:skip_topics)

        params = {:retry_stale => true, :match_mode => :extended, :with => attributes, :sort_mode => :expr, :order => "@weight * (1.5 - is_local)"}
        params.merge!(options)
        query = build_query(value)
        params.merge!({:sort_mode => :extended, :order => 'signature ASC'}) if query.include?('@signature')

        search(query, params)
      end

      def split_search_words(query)
        sentences = []
        # Need a clone or slice! will do some harm
        value = query.clone
        while sentence = value.slice!(/\".[^\"]*\"/)
          sentences << sentence
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
            signatures << string
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

        return signatures, clean(words), clean(sentences)
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
          quoted_signatures = signatures.map{|signature| '"^' + signature + '*"'}
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

      private

      # Removes the apostrophe from the words.
      def clean(words)
        words.collect! {|word| Riddle.escape(word.delete('"')) }
      end
    end
  end
end
