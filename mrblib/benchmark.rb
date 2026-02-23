module Benchmark
  VERSION = "0.5.0"

  CAPTION = "      user     system      total        real\n"
  FORMAT  = "%10.6f %10.6f %10.6f (%10.6f)\n"

  # -------------------------------------------------------------------
  # Tms
  # -------------------------------------------------------------------
  class Tms
    attr_reader :utime, :stime, :cutime, :cstime, :real, :total, :label

    def initialize(utime = 0.0, stime = 0.0, cutime = 0.0, cstime = 0.0, real = 0.0, label = nil)
      @utime  = utime
      @stime  = stime
      @cutime = cutime
      @cstime = cstime
      @real   = real
      @label  = label.to_s
      @total  = @utime + @stime + @cutime + @cstime
    end

    # arithmetic -------------------------------------------------------

    def +(other)
      Tms.new(
        @utime  + other.utime,
        @stime  + other.stime,
        @cutime + other.cutime,
        @cstime + other.cstime,
        @real   + other.real,
        @label
      )
    end

    def -(other)
      Tms.new(
        @utime  - other.utime,
        @stime  - other.stime,
        @cutime - other.cutime,
        @cstime - other.cstime,
        @real   - other.real,
        @label
      )
    end

    def *(x)
      Tms.new(
        @utime  * x,
        @stime  * x,
        @cutime * x,
        @cstime * x,
        @real   * x,
        @label
      )
    end

    def /(x)
      Tms.new(
        @utime  / x,
        @stime  / x,
        @cutime / x,
        @cstime / x,
        @real   / x,
        @label
      )
    end

    # formatting -------------------------------------------------------

    def format(fmt = nil, *args)
      # default: CRuby-style line
      if fmt.nil?
        return FORMAT % [@utime, @stime, @total, @real]
      end

      # special case used by bmbm: "total: %tsec"
      if fmt == "total: %tsec"
        return "total: %0.6fsec" % @total
      end

      # generic: use provided FORMAT-like string (no %u/%y/%t/%r extensions)
      # we assume fmt is a plain sprintf format for 4 floats
      if args.empty?
        return fmt % [@utime, @stime, @total, @real]
      else
        return fmt % args
      end
    end

    def to_s
      format
    end

    def inspect
      # CRuby-like object id (MRuby object_id is different)
      hex_id = (self.object_id << 1).to_s(16)

      parts = []
      instance_variables.each do |ivar|
        val = instance_variable_get(ivar)
        parts << "#{ivar}=#{val.inspect}"
      end

      "#<#{self.class}:0x#{hex_id} #{parts.join(", ")}>"
    end


  end

  # -------------------------------------------------------------------
  # Job (for bmbm)
  # -------------------------------------------------------------------
  class Job
    attr_reader :list, :width

    def initialize(width)
      @width = width
      @list  = []
    end

    def item(label = "", &blk)
      raise ArgumentError, "no block" unless block_given?
      label = label.to_s
      w = label.length
      @width = w if @width < w
      @list << [label, blk]
      self
    end

    alias report item
  end

  # -------------------------------------------------------------------
  # Report (for bm/benchmark)
  # -------------------------------------------------------------------
  class Report
    attr_reader :width, :format, :list

    def initialize(width = 0, format = nil)
      @width  = width
      @format = format
      @list   = []
    end

    def item(label = "", *fmt, &blk)
      raise ArgumentError, "no block" unless block_given?
      label = label.to_s
      w = label.length
      @width = w if @width < w
      res = Benchmark.measure(label, &blk)
      @list << res
      res
    end

    alias report item
  end

  # -------------------------------------------------------------------
  # Core API
  # -------------------------------------------------------------------
  def benchmark(caption = "", label_width = nil, format = nil, *labels)
    sync = $stdout.sync
    $stdout.sync = true
    label_width ||= 0
    label_width += 1
    report = Report.new(label_width, format)
    results = yield(report)

    print " " * report.width + caption unless caption.empty?
    report.list.each do |i|
      print i.label.to_s.ljust(report.width)
      print i.format # default line
    end

    if Array === results
      results.grep(Tms).each do |t|
        lab = (labels.shift || t.label || "").to_s
        print lab.ljust(label_width)
        print t.format
      end
    end

    report.list
  ensure
    $stdout.sync = sync unless sync.nil?
  end

  def bm(label_width = 0, *labels, &blk)
    benchmark(CAPTION, label_width, FORMAT, *labels, &blk)
  end

  def bmbm(width = 0)
    job = Job.new(width)
    yield(job)
    width = job.width + 1
    sync = $stdout.sync
    $stdout.sync = true

    # rehearsal
    puts 'Rehearsal '.ljust(width + CAPTION.length, '-')
    ets = job.list.inject(Tms.new) do |sum, (label, item)|
      print label.ljust(width)
      res = Benchmark.measure(&item)
      print res.format
      sum + res
    end.format("total: %tsec")
    print " #{ets}\n\n".rjust(width + CAPTION.length + 2, '-')

    # take
    print ' ' * width + CAPTION
    job.list.map do |label, item|
      print label.ljust(width)
      res = Benchmark.measure(label, &item)
      print res
      res
    end
  ensure
    $stdout.sync = sync unless sync.nil?
  end

  # -------------------------------------------------------------------
  # Timing backend (MRuby)
  # -------------------------------------------------------------------
  def measure(label = "")
    cpu_start = CPUUsage.snapshot
    timer = Chrono::Timer.new
    yield
    real = timer.elapsed
    cpu_end = CPUUsage.snapshot

    utime  = cpu_end[:user_time]   - cpu_start[:user_time]
    stime  = cpu_end[:system_time] - cpu_start[:system_time]
    cutime  = cpu_end[:child_user_time]   - cpu_start[:child_user_time]
    cstime  = cpu_end[:child_system_time] - cpu_start[:child_system_time]

    Tms.new(utime, stime, cutime, cstime, real, label)
  end

  def realtime
    timer = Chrono::Timer.new
    yield
    timer.elapsed
  end

  def ms
    realtime { yield } * 1000.0
  end

  module_function :benchmark, :measure, :realtime, :ms, :bm, :bmbm
end
