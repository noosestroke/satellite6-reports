lib = File.expand_path('/opt/theforeman/tfm/root/usr/share', __FILE__ + 'lib/')
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|

  gem.name        = "satellite6-reports"
  gem.version     = 0.1
  gem.authors     = ["Noosestroke"]
  gem.email       = ["noosestroke@gmail.com"]
  gem.homepage    = "https://github.com/noosestroke/satellite6-reports"
  gem.summary     = ""
  gem.description = ""

  gem.files = ["bin/satellie6-reports"]

  gem.add_dependency "apipie-bindings"
  gem.add_dependency "highline"
end
