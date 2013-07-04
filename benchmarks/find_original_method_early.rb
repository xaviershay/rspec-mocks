$LOAD_PATH.unshift "./lib"
require 'rspec/mocks'
require "rspec/mocks/standalone"

=begin
This benchmark script is for troubleshooting the performance of
#264. To use it, you have to edit the code in #264 a bit: add a
wrap the call in `MethodDouble#initialize` to `find_original_method`
in a conditional like `if $find_original`.

That allows the code below to compare the perf of stubbing a method
with the original method being found vs. not.
=end

require 'benchmark'

n = 10000

Foo = Class.new(Object) do
  n.times do |i|
    define_method "meth_#{i}" do
    end
  end
end

puts "#{n} times - ruby #{RUBY_VERSION}"

perform_report = lambda do |bm, label, find_original, &create_object|
  bm.report(label) do
    dbl = create_object.call
    $find_original = find_original

    n.times do |i|
      dbl.stub("meth_#{i}")
    end
  end
end

Benchmark.bmbm do |bm|
  perform_report.call(bm, "Don't find original - partial mock", false) { Foo.new }
  perform_report.call(bm, "Don't find original - test double",  false) { double }
  perform_report.call(bm, "Find original - partial mock",        true) { Foo.new }
  perform_report.call(bm, "Find original - test double",         true) { double }
end

Benchmark.bmbm do |bm|
  perform_report.call(bm, "Don't find original - test double",  false) { double }
  perform_report.call(bm, "Don't find original - partial mock", false) { Foo.new }
  perform_report.call(bm, "Find original - test double",         true) { double }
  perform_report.call(bm, "Find original - partial mock",        true) { Foo.new }
end

Benchmark.bmbm do |bm|
  perform_report.call(bm, "Don't find original - test double",  false) { double }
  perform_report.call(bm, "Don't find original - partial mock", false) { Foo.new }
  perform_report.call(bm, "Find original - partial mock",        true) { Foo.new }
  perform_report.call(bm, "Find original - test double",         true) { double }
end

Benchmark.bmbm do |bm|
  perform_report.call(bm, "Don't find original - partial mock", false) { Foo.new }
  perform_report.call(bm, "Don't find original - test double",  false) { double }
  perform_report.call(bm, "Find original - test double",         true) { double }
  perform_report.call(bm, "Find original - partial mock",        true) { Foo.new }
end

Benchmark.bmbm do |bm|
  perform_report.call(bm, "Find original - partial mock",        true) { Foo.new }
  perform_report.call(bm, "Find original - test double",         true) { double }
  perform_report.call(bm, "Don't find original - partial mock", false) { Foo.new }
  perform_report.call(bm, "Don't find original - test double",  false) { double }
end

Benchmark.bmbm do |bm|
  perform_report.call(bm, "Find original - test double",         true) { double }
  perform_report.call(bm, "Find original - partial mock",        true) { Foo.new }
  perform_report.call(bm, "Don't find original - partial mock", false) { Foo.new }
  perform_report.call(bm, "Don't find original - test double",  false) { double }
end

Benchmark.bmbm do |bm|
  perform_report.call(bm, "Find original - partial mock",        true) { Foo.new }
  perform_report.call(bm, "Find original - test double",         true) { double }
  perform_report.call(bm, "Don't find original - test double",  false) { double }
  perform_report.call(bm, "Don't find original - partial mock", false) { Foo.new }
end

Benchmark.bmbm do |bm|
  perform_report.call(bm, "Find original - test double",         true) { double }
  perform_report.call(bm, "Find original - partial mock",        true  { Foo.new }
  perform_report.call(bm, "Don't find original - test double",  false) { double }
  perform_report.call(bm, "Don't find original - partial mock", false) { Foo.new }
end

=begin

For some reason, the order of the above reports seems to matter:

10000 times - ruby 1.9.3
Rehearsal ----------------------------------------------------------------------
Find original - test double          2.120000   0.070000   2.190000 (  2.185778)
Don't find original - test double    1.910000   0.030000   1.940000 (  1.947988)
Find original - partial mock         2.580000   0.030000   2.610000 (  2.608137)
Don't find original - partial mock   2.910000   0.030000   2.940000 (  2.942059)
------------------------------------------------------------- total: 9.680000sec

                                         user     system      total        real
Find original - test double          5.040000   0.070000   5.110000 (  5.119846)
Don't find original - test double    3.790000   0.040000   3.830000 (  3.817811)
Find original - partial mock         4.380000   0.030000   4.410000 (  4.413322)
Don't find original - partial mock   4.650000   0.030000   4.680000 (  4.686825)

vs:

10000 times - ruby 1.9.3
Rehearsal ----------------------------------------------------------------------
Don't find original - test double    1.330000   0.030000   1.360000 (  1.358339)
Find original - test double          2.680000   0.070000   2.750000 (  2.754501)
Don't find original - partial mock   2.350000   0.020000   2.370000 (  2.376022)
Find original - partial mock         3.250000   0.040000   3.290000 (  3.282563)
------------------------------------------------------------- total: 9.770000sec

                                         user     system      total        real
Don't find original - test double    3.200000   0.030000   3.230000 (  3.239421)
Find original - test double          5.850000   0.080000   5.930000 (  5.935021)
Don't find original - partial mock   4.220000   0.030000   4.250000 (  4.255652)
Find original - partial mock         4.820000   0.040000   4.860000 (  4.861439)

vs:

10000 times - ruby 1.9.3
Rehearsal ----------------------------------------------------------------------
Find original - test double          2.070000   0.070000   2.140000 (  2.143821)
Find original - partial mock         2.170000   0.030000   2.200000 (  2.195870)
Don't find original - test double    2.400000   0.030000   2.430000 (  2.441740)
Don't find original - partial mock   2.900000   0.030000   2.930000 (  2.930675)
------------------------------------------------------------- total: 9.700000sec

                                         user     system      total        real
Find original - test double          5.070000   0.080000   5.150000 (  5.139914)
Find original - partial mock         3.970000   0.030000   4.000000 (  4.007102)
Don't find original - test double    4.270000   0.030000   4.300000 (  4.299003)
Don't find original - partial mock   4.690000   0.040000   4.730000 (  4.721315)

vs:

10000 times - ruby 1.9.3
Rehearsal ----------------------------------------------------------------------
Don't find original - partial mock   1.400000   0.030000   1.430000 (  1.428854)
Don't find original - test double    1.580000   0.020000   1.600000 (  1.600588)
Find original - partial mock         2.240000   0.030000   2.270000 (  2.265163)
Find original - test double          4.080000   0.080000   4.160000 (  4.157190)
------------------------------------------------------------- total: 9.460000sec

                                         user     system      total        real
Don't find original - partial mock   3.210000   0.020000   3.230000 (  3.247126)
Don't find original - test double    3.520000   0.040000   3.560000 (  3.553430)
Find original - partial mock         4.100000   0.030000   4.130000 (  4.136000)
Find original - test double          6.990000   0.080000   7.070000 (  7.065039)

=end

