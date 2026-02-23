assert('Benchmark') do
  assert_kind_of Module, Benchmark
end

assert('Benchmark::Tms') do
  assert_kind_of Class, Benchmark::Tms
end

assert('Benchmark::Tms#initialize') do
  tms = Benchmark::Tms.new(1.0, 2.0, 3.0, 4.0, 5.0, "test")
  assert_equal 1.0, tms.utime
  assert_equal 2.0, tms.stime
  assert_equal 3.0, tms.cutime
  assert_equal 4.0, tms.cstime
  assert_equal 5.0, tms.real
  assert_equal "test", tms.label
end

assert('Benchmark::Tms#total') do
  tms = Benchmark::Tms.new(1.0, 2.0, 3.0, 4.0, 5.0)
  assert_equal 10.0, tms.total
end

assert('Benchmark::Tms#+') do
  tms1 = Benchmark::Tms.new(1.0, 2.0, 3.0, 4.0, 5.0)
  tms2 = Benchmark::Tms.new(1.0, 1.0, 1.0, 1.0, 1.0)
  result = tms1 + tms2
  assert_equal 2.0, result.utime
  assert_equal 3.0, result.stime
  assert_equal 4.0, result.cutime
  assert_equal 5.0, result.cstime
  assert_equal 6.0, result.real
end

assert('Benchmark::Tms#-') do
  tms1 = Benchmark::Tms.new(2.0, 3.0, 4.0, 5.0, 6.0)
  tms2 = Benchmark::Tms.new(1.0, 1.0, 1.0, 1.0, 1.0)
  result = tms1 - tms2
  assert_equal 1.0, result.utime
  assert_equal 2.0, result.stime
  assert_equal 3.0, result.cutime
  assert_equal 4.0, result.cstime
  assert_equal 5.0, result.real
end

assert('Benchmark.realtime') do
  elapsed = Benchmark.realtime do
    sleep 0.1
  end
  assert_kind_of Float, elapsed
  assert_true elapsed >= 0.1
end

assert('Benchmark.measure') do
  result = Benchmark.measure do
    sleep 0.1
  end
  assert_kind_of Benchmark::Tms, result
  assert_kind_of Float, result.real
  assert_kind_of Float, result.utime
  assert_kind_of Float, result.stime
  assert_true result.real >= 0.1
end

assert('Benchmark.measure with label') do
  result = Benchmark.measure("test") do
    sleep 0.05
  end
  assert_equal "test", result.label
  assert_true result.real >= 0.05
end

assert('Benchmark.bm') do
  results = Benchmark.bm(10) do |x|
    x.report("test1") { sleep 0.05 }
    x.report("test2") { sleep 0.05 }
  end
  
  assert_kind_of Array, results
  assert_equal 2, results.length
  assert_kind_of Benchmark::Tms, results[0]
  assert_kind_of Benchmark::Tms, results[1]
end

assert('Benchmark.bmbm') do
  results = Benchmark.bmbm(10) do |x|
    x.report("test1") { sleep 0.05 }
    x.report("test2") { sleep 0.05 }
  end
  
  assert_kind_of Array, results
  assert_equal 2, results.length
  assert_kind_of Benchmark::Tms, results[0]
  assert_kind_of Benchmark::Tms, results[1]
end
