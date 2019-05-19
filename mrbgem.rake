MRuby::Gem::Specification.new('mruby-SymDesc') do |spec|
  spec.license = 'MIT'
  spec.author  = 'Massimiliano Dal Mas'
  spec.summary = ''
  spec.add_dependency('mruby-mtest', :github => 'iij/mruby-mtest')
  spec.add_dependency('mruby-require', :github => 'mattn/mruby-require')
end