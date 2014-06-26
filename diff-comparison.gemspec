Gem::Specification.new do |s|
  s.name        = 'diff-comparison'
  s.version     = '0.0.1'
  s.date        = '2014-06-26'
  s.summary     = 'A gem to compare data structures to each other and get various data about their similarity.'
  s.description = 'A gem to compare data structures to each other and get various data about their similarity.'
  s.authors     = ['Aaron Unger']
  s.email       = 'aunger@concord.org'
  s.files       = Dir["{lib}/**/*.rb", "LICENSE", "*.md"]
  s.homepage    = 'http://rubygems.org/gems/diff-comparison'
  s.license     = 'MIT'

  s.add_dependency "diff-lcs", "~> 1.2"
  s.add_development_dependency "rspec", "~> 3.0"
end
