# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{massive_record}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Companybook"]
  s.date = %q{2010-11-16}
  s.description = %q{HBase Ruby client API}
  s.email = %q{geeks@companybook.no}
  s.extra_rdoc_files = ["README.md", "lib/massive_record.rb", "lib/massive_record/base.rb", "lib/massive_record/cell.rb", "lib/massive_record/column.rb", "lib/massive_record/column_family.rb", "lib/massive_record/connection.rb", "lib/massive_record/migration.rb", "lib/massive_record/row.rb", "lib/massive_record/scanner.rb", "lib/massive_record/table.rb", "lib/massive_record/thrift/hbase.rb", "lib/massive_record/thrift/hbase_constants.rb", "lib/massive_record/thrift/hbase_types.rb"]
  s.files = ["README.md", "Rakefile", "lib/massive_record.rb", "lib/massive_record/base.rb", "lib/massive_record/cell.rb", "lib/massive_record/column.rb", "lib/massive_record/column_family.rb", "lib/massive_record/connection.rb", "lib/massive_record/migration.rb", "lib/massive_record/row.rb", "lib/massive_record/scanner.rb", "lib/massive_record/table.rb", "lib/massive_record/thrift/hbase.rb", "lib/massive_record/thrift/hbase_constants.rb", "lib/massive_record/thrift/hbase_types.rb", "Manifest", "massive_record.gemspec"]
  s.homepage = %q{http://github.com/CompanyBook/massive_record}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Massive_record", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{massive_record}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{HBase Ruby client API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
