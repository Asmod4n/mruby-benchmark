module Benchmark
  # Benchmark::Tms class holds timing results
  class Tms
    attr_reader :utime, :stime, :cutime, :cstime, :real, :label

    def initialize(utime = 0.0, stime = 0.0, cutime = 0.0, cstime = 0.0, real = 0.0, label = "")
      @utime = utime
      @stime = stime
      @cutime = cutime
      @cstime = cstime
      @real = real
      @label = label
    end

    def total
      @utime + @stime + @cutime + @cstime
    end

    def to_s
      format("%s %10.6f %10.6f %10.6f (%10.6f)\n",
             @label.ljust(20),
             @utime,
             @stime,
             total,
             @real)
    end

    def +(other)
      Tms.new(@utime + other.utime,
              @stime + other.stime,
              @cutime + other.cutime,
              @cstime + other.cstime,
              @real + other.real)
    end

    def -(other)
      Tms.new(@utime - other.utime,
              @stime - other.stime,
              @cutime - other.cutime,
              @cstime - other.cstime,
              @real - other.real)
    end
  end

  # Report class for formatting benchmark output
  class Report
    attr_reader :list

    def initialize(width = 0)
      @width = width
      @list = []
    end

    def item(label = "", &blk)
      print label.ljust(@width)
      res = Benchmark.measure(&blk)
      print res
      @list << res
    end

    alias report item
  end

  module_function

  # Returns elapsed real time for executing the given block
  def realtime(&blk)
    chrono = Chrono.new
    blk.call
    chrono.elapsed
  end

  # Measures the execution time of the given block
  def measure(label = "", &blk)
    cpu_start = CPUUsage.new
    chrono = Chrono.new
    
    blk.call
    
    elapsed = chrono.elapsed
    cpu_end = CPUUsage.new
    
    utime = cpu_end.user - cpu_start.user
    stime = cpu_end.system - cpu_start.system
    
    Tms.new(utime, stime, 0.0, 0.0, elapsed, label)
  end

  # Runs multiple benchmarks with formatted output
  def bm(label_width = 0, *labels, &blk)
    sync = $stdout.sync
    $stdout.sync = true
    
    puts "%s %10s %10s %10s %10s" % ["", "user", "system", "total", "real"]
    
    report = Report.new(label_width)
    blk.call(report)
    
    $stdout.sync = sync
    report.list
  end

  # Runs benchmarks twice - rehearsal and real
  def bmbm(width = 0, &blk)
    sync = $stdout.sync
    $stdout.sync = true
    
    puts "Rehearsal " + "-" * 51
    bm(width, &blk)
    
    puts "-" * 60
    puts
    
    results = bm(width, &blk)
    
    $stdout.sync = sync
    results
  end
end
