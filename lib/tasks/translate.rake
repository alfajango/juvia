namespace :translate do
  desc "Translate comments with code colorer snippets to markdown"
  task :code_colorer => :environment do
    Site.all.each do |site|
      Juvia::Translators.process('code_colorer', site.id)
    end
  end
end
