p "Benchmarking Adapters::Thrift::Table.find()"


2.times do |index|
  MassiveRecord::Wrapper::Row.new.tap do |row|
    row.id = index.to_s
    row.values = {:base => {:first_name => "John-#{index}", :last_name => "Doe-#{index}" }}
    row.table = TABLE
    row.save
  end
end

n = 2000

Benchmark.bm do |x|
  x.report('old, single') do
    for i in 1..n do
      TABLE.find_old('1')
    end
  end

  x.report('new, single') do
    for i in 1..n do
      TABLE.find('1')
    end
  end



  x.report('old, multi') do
    for i in 1..n do
      TABLE.find_old(['1', '2'])
    end
  end

  x.report('new, multi') do
    for i in 1..n do
      TABLE.find(['1', '2'])
    end
  end



  x.report('old, multi, with options') do
    for i in 1..n do
      TABLE.find_old(['1', '2'], :select => ['base'])
    end
  end

  x.report('new, multi, with options') do
    for i in 1..n do
      TABLE.find(['1', '2'], :select => ['base'])
    end
  end
end

