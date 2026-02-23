MRuby::Gem::Specification.new('mruby-benchmark') do |spec|
  spec.license = 'MIT'
  spec.author  = 'Hendrik Beskow'
  spec.summary = 'Benchmark class for mruby'
  spec.version = '0.1.0'

  spec.add_dependency 'mruby-chrono', github: 'Asmod4n/mruby-chrono'
  spec.add_dependency 'mruby-cpuusage', github: 'Asmod4n/mruby-cpuusage'
end
