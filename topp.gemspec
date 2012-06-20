Gem::Specification.new do |s|
  s.name        = 'topp'
  s.version     = '1.0.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Theo Hultberg']
  s.email       = ['theo@burtcorp.com']
  s.homepage    = 'http://github.com/burtcorp/topp'
  s.summary     = 'Finds top pages'
  s.description = 'Traverses a site looking for the top linked-to pages'

  s.add_dependency 'poltergeist'

  s.files         = Dir.glob("lib/rich_parser/parser/**/*")
  s.test_files    = Dir.glob("spec/rich_parser/parser/**/*")
end
