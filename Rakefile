require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'

#task :default => ['rdoc', 'package']
gem_spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.8.5'
  s.summary = 'RightResource: RightScale Resource API wrapper'
  s.name = 'rightresource'
  s.author = 'Satoshi Ohki'
  s.email = ['roothybrid7', 'gmail.com'].join('@')
  s.version = '0.2.0'
  s.homepage = 'https://github.com/satsv/rightresource'
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = FileList['CHANGELOG', 'README.rdoc', 'LICENSE', 'lib/**/*.rb']
#  s.has_rdoc = true
#  s.rdoc_options << '--title' << 'RightResource API documentation' <<
#    '--main' << 'README.rdoc' << '--rdoc_dir' << 'rdoc' << '--template' << 'direct'
#  s.extra_rdoc_files = ['README.rdoc']
  s.add_dependency('json')
  s.add_dependency('rest-client')
  s.add_dependency('crack')
  s.description = <<EOF
RightScale Resource API wrapper.
EOF
end

Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

require 'sdoc'
Rake::RDocTask.new(:rdoc) do |doc|
  doc.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
  doc.main = 'README.rdoc'
  doc.title = 'RightResource API documentation'
  doc.rdoc_dir = 'rdoc'
  doc.template = 'direct'
end
