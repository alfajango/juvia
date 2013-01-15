module Juvia
  module Translators
    class CodeColorer

      def self.process(site_id, options={})
        begin
          require 'htmlentities'
          htmlentities = true
        rescue LoadError
          STDERR.puts "Could not require 'htmlentities', so translators " +
                      "will not be able to escape or unescape comment content"
          htmlentities = false
        end

        site = Site.find(site_id)

        comments = site.comments

        comments.each do |comment|
          # match [cc]stuff[/cc\
          # [ccie_ruby]stuff[/cci_ruby]
          # [cc lang="ruby"]stuff[/cc]
          match = /\[cc([a-zA-Z]+)?(_([a-zA-Z]+))?(\s+[^\]]*)?\](\s*)?(((?!\[\/cc).)*)(\s*)?\[\/cc[^\]]*\]/m
          # e.g.
          #<MatchData "[ccie_ruby]blah[/ccie_ruby" 1:"ie" 2:"_ruby" 3:"ruby" 4:nil 5:nil 6:nil 7:"stuff", 8: "blah">
          # 1: abbr options
          # 2: -
          # 3: lang
          # 4: options, e.g. 'lang="ruby" tab_size="2" lines="40"'
          # 5: leading whitespace in code
          # 6: code content
          # 7: trailing whitespace in code
          # 8: -
          comment.content = comment.content.gsub(match) do |m|
            # Turn 'lang="ruby" tab_size="2" lines="40"' into {"lang" => "ruby", "tab_size" => "2", "lines" => "40"}
            abbr_opts = $1 || ""
            opts = ($4 || "").strip
            language = $3
            code = $6

            opts = Hash[opts.gsub(/[\"\']/, '').split(/\s+/).map{ |s| s.split('=') }]
            language ||= opts['lang']

            escaped = abbr_opts.include?('e') || opts['escaped']
            inline = abbr_opts.include?('i') || opts['inline']

            code = HTMLEntities.new.decode(code) if htmlentities && escaped

            if inline
              code = "`#{code}`"
            else
              code = "#{code}\n" unless code.match(/$\n/)
              code = "```#{language}\n#{code}```"
            end

            puts "Translating code:"
            puts code

            code
          end
          comment.save!
        end
      end
    end
  end
end

