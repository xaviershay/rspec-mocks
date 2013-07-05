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
    RSpec::Mocks::space.reset_all
  end
end

Benchmark.bmbm do |bm|
  perform_report.call(bm, "Don't find original - partial mock", false) { Foo.new }
  perform_report.call(bm, "Don't find original - test double",  false) { double }
  perform_report.call(bm, "Find original - partial mock",        true) { Foo.new }
  perform_report.call(bm, "Find original - test double",         true) { double }
end

=begin

$ ruby benchmarks/find_original_method_early.rb
10000 times - ruby 2.0.0
Rehearsal ----------------------------------------------------------------------
Don't find original - partial mock   1.340000   0.030000   1.370000 (  1.360113)
Don't find original - test double    1.050000   0.000000   1.050000 (  1.053425)
Find original - partial mock         1.390000   0.010000   1.400000 (  1.396489)
Find original - test double          1.080000   0.010000   1.090000 (  1.092451)
------------------------------------------------------------- total: 4.910000sec

                                         user     system      total        real
Don't find original - partial mock   1.340000   0.010000   1.350000 (  1.338365)
Don't find original - test double    1.020000   0.010000   1.030000 (  1.026720)
Find original - partial mock         1.320000   0.010000   1.330000 (  1.317098)
Find original - test double          1.000000   0.000000   1.000000 (  1.008340)

$ ruby benchmarks/find_original_method_early.rb
10000 times - ruby 1.9.3
Rehearsal ----------------------------------------------------------------------
Don't find original - partial mock   1.220000   0.020000   1.240000 (  1.241706)
Don't find original - test double    0.880000   0.010000   0.890000 (  0.880883)
Find original - partial mock         1.240000   0.010000   1.250000 (  1.252148)
Find original - test double          0.870000   0.010000   0.880000 (  0.885828)
------------------------------------------------------------- total: 4.260000sec

                                         user     system      total        real
Don't find original - partial mock   1.160000   0.010000   1.170000 (  1.169689)
Don't find original - test double    0.820000   0.010000   0.830000 (  0.832940)
Find original - partial mock         1.130000   0.000000   1.130000 (  1.135328)
Find original - test double          0.800000   0.010000   0.810000 (  0.812689)

$ ruby benchmarks/find_original_method_early.rb
10000 times - ruby 1.8.7
Rehearsal ----------------------------------------------------------------------
Don't find original - partial mock   0.890000   0.020000   0.910000 (  0.913835)
Don't find original - test double    0.780000   0.000000   0.780000 (  0.780691)
Find original - partial mock         1.060000   0.010000   1.070000 (  1.067452)
Find original - test double          0.890000   0.000000   0.890000 (  0.892688)
------------------------------------------------------------- total: 3.650000sec

                                         user     system      total        real
Don't find original - partial mock   0.850000   0.000000   0.850000 (  0.861013)
Don't find original - test double    0.670000   0.000000   0.670000 (  0.670548)
Find original - partial mock         0.840000   0.000000   0.840000 (  0.846817)
Find original - test double          0.650000   0.000000   0.650000 (  0.652909)

=end


