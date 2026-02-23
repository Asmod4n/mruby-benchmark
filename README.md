# mruby-benchmark

Benchmark class for mruby, similar to CRuby's built-in Benchmark module.

## Description

This gem provides a Benchmark module for mruby that allows you to measure and compare the performance of your code. It uses [mruby-chrono](https://github.com/Asmod4n/mruby-chrono) for precise timing and [mruby-cpuusage](https://github.com/Asmod4n/mruby-cpuusage) for CPU usage measurements.

## Installation

Add the following line to your `build_config.rb`:

```ruby
MRuby::Build.new do |conf|
  # ... (other configurations)

  conf.gem github: 'Asmod4n/mruby-benchmark'
end
```

## Dependencies

This gem depends on:
- [mruby-chrono](https://github.com/Asmod4n/mruby-chrono) - for time measurement
- [mruby-cpuusage](https://github.com/Asmod4n/mruby-cpuusage) - for CPU usage tracking

## Usage

### Benchmark.realtime

Returns the elapsed real time for executing the given block as a Float.

```ruby
time = Benchmark.realtime do
  # code to benchmark
  1000000.times { |i| i * 2 }
end
puts "Time elapsed: #{time} seconds"
```

### Benchmark.measure

Measures the execution time of the given block and returns a `Benchmark::Tms` object.

```ruby
result = Benchmark.measure do
  1000000.times { |i| i * 2 }
end
puts result
# Output: user time, system time, total time, and real time
```

### Benchmark.bm

Runs multiple benchmarks with formatted output.

```ruby
Benchmark.bm(20) do |x|
  x.report("multiplication:") { 1000000.times { |i| i * 2 } }
  x.report("addition:") { 1000000.times { |i| i + 2 } }
  x.report("division:") { 1000000.times { |i| i / 2 } }
end
```

### Benchmark.bmbm

Runs benchmarks twice - first as a rehearsal, then as the real measurement. This helps eliminate initialization overhead.

```ruby
Benchmark.bmbm(20) do |x|
  x.report("multiplication:") { 500000.times { |i| i * 2 } }
  x.report("addition:") { 500000.times { |i| i + 2 } }
end
```

### Benchmark::Tms

The `Tms` class represents timing measurements with the following attributes:

- `utime` - User CPU time
- `stime` - System CPU time
- `cutime` - User CPU time of child processes
- `cstime` - System CPU time of child processes
- `real` - Elapsed real time
- `label` - Optional label for the measurement

You can perform arithmetic operations on `Tms` objects:

```ruby
tms1 = Benchmark.measure { sleep 0.1 }
tms2 = Benchmark.measure { sleep 0.2 }
total = tms1 + tms2
diff = tms2 - tms1
```

## Example

See [example.rb](example.rb) for a complete example.

## License

Apache-2.0 License - see [LICENSE](LICENSE) file for details.

## Author

Hendrik Beskow
