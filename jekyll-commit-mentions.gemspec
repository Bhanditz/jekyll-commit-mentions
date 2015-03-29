Gem::Specification.new do |s|
  s.name        = "jekyll-commit-mentions"
  s.summary     = "Github commit sha mention support for your jekyll site"
  s.version     = "0.1.3"
  s.authors     = ["harish shetty"]
  s.email       = "support@workato.com"

  s.homepage    = "https://github.com/workato/jekyll-commit-mentions"
  s.licenses    = ["mit"]
  s.files       = ["lib/jekyll-commit-mentions.rb", "lib/commit_mention_filter.rb" ]

  s.add_dependency "jekyll", '~> 2.0'
  s.add_dependency "html-pipeline", '~> 1.9.0'
  s.add_dependency "nokogiri", [">= 1.4", "<= 1.6.5"]
  s.add_dependency "github-markdown"

  s.add_development_dependency  'rake'
  s.add_development_dependency  'rdoc'
  s.add_development_dependency  'shoulda'
  s.add_development_dependency  'minitest'
end
