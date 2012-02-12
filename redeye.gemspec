Gem::Specification.new do |s|
  s.name        = 'redeye'
  s.version     = '0.0.1'
  s.date        = '2012-02-12'
  s.summary     = "Redeye!"
  s.description = "Supervisor script that reloads process based on changes to file/directories"
  s.authors     = ["Chris Hernandez"]
  s.email       = 'c.scott.hernandez@gmail.com'
  s.files       = ["lib/redeye.rb", "lib/redeye/helpers.rb"]
  s.homepage    = 'https://github.com/christopherscott/redeye'
  s.executables << 'redeye'
end
