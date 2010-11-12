require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'

# RDoc parameters
@rdoc_title = 'RightResource API documentation'
@rdoc_main = 'README.rdoc'
begin
  require 'sdoc'
rescue LoadError => e
  warn e
  @rdoc_tmpl = 'direct'
end

#task :default => ['rdoc', 'package']
gem_spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.8.5'
  s.summary = 'RightResource: RightScale Resource API wrapper'
  s.name = 'rightresource'
  s.author = 'Satoshi Ohki'
  s.email = ['roothybrid7', 'gmail.com'].join('@')
  s.version = '0.2.7'
  s.homepage = 'https://github.com/satsv/rightresource'
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = FileList['CHANGELOG', @rdoc_main, 'LICENSE', 'lib/**/*.rb']
  s.has_rdoc = true
  s.rdoc_options << '--title' << @rdoc_title
  s.rdoc_options <<  '--main' << @rdoc_main
  s.rdoc_options << '--template' << @rdoc_tmpl if @rdoc_tmpl
  s.extra_rdoc_files = [@rdoc_main]
  s.add_dependency('json')
  s.add_dependency('rest-client')
  s.add_dependency('crack')
  s.description = <<EOF
RightScale Resource API wrapper.
see. RightScale API
http://support.rightscale.com/12-Guides/03-RightScale_API
http://support.rightscale.com/15-References/RightScale_API_Reference_Guide
EOF
end

Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

Rake::RDocTask.new(:rdoc) do |doc|
  doc.rdoc_files.include(@rdoc_main, 'lib/**/*.rb')
  doc.main = @rdoc_main
  doc.title = @rdoc_title
  doc.rdoc_dir = 'rdoc'
  doc.template = @rdoc_tmpl if @rdoc_tmpl
end
