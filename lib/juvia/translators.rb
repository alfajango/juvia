module Juvia
  module Translators
    TRANSLATORS = %w(code_colorer)

    TRANSLATORS.each do |p|
      require "juvia/translators/#{p}"
    end

    def self.process(translator, site_id, options={})
      translator_class = translator.downcase.gsub(/\s/, '_')
      raise "Not a valid translation type: #{translator_class}" unless TRANSLATORS.any?{ |t| t == translator_class }

      Juvia::Translators.const_get(translator_class.camelize).send(:process, site_id, options)
    end
  end
end
