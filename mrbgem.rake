MRuby::Gem::Specification.new('mruby-benchmark') do |spec|
  spec.license = 'Apache-2.0'
  spec.author  = 'Hendrik Beskow'
  spec.summary = 'Benchmark class for mruby'
  spec.version = '0.1.0'

  spec.add_dependency 'mruby-chrono'
  spec.add_dependency 'mruby-cpuusage', github: 'Asmod4n/mruby-cpuusage', branch: "main"
  spec.add_dependency 'mruby-sprintf'
  spec.add_dependency 'mruby-string-ext'
  spec.add_dependency 'mruby-metaprog'
  spec.add_test_dependency 'mruby-io'
  spec.add_test_dependency 'mruby-sleep'
end
