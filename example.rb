# Example usage of mruby-benchmark
#
# This demonstrates the usage of the Benchmark module
# which is similar to CRuby's built-in Benchmark class

# Example 1: Using Benchmark.realtime
puts "Example 1: Benchmark.realtime"
time = Benchmark.realtime do
  1000000.times { |i| i * 2 }
end
puts "Time elapsed: #{time} seconds"
puts

# Example 2: Using Benchmark.measure
puts "Example 2: Benchmark.measure"
result = Benchmark.measure("calculation") do
  1000000.times { |i| i * 2 }
end
puts result
puts

# Example 3: Using Benchmark.bm
puts "Example 3: Benchmark.bm"
u = Benchmark.bm(15) do |x|
  x.report("multiplication") { 1000000.times { |i| i * 2 } }
  x.report("addition") { 1000000.times { |i| i + 2 } }
  x.report("division") { 1000000.times { |i| i / 2 } }
end
p u
puts

# Example 4: Using Benchmark.bmbm (rehearsal + real run)
puts "Example 4: Benchmark.bmbm"
Benchmark.bmbm(15) do |x|
  x.report("multiplication") { 500000.times { |i| i * 2 } }
  x.report("addition") { 500000.times { |i| i + 2 } }
end
