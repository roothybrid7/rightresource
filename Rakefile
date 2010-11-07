require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'sdoc'

#task :default => ['rdoc', 'package']
gem_spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "RightResource: RightScale Resource API wrapper"
  s.name = 'rightresource'
  s.author = 'Satoshi Ohki'
  s.email = ['roothybrid7', 'gmail.com'].join('@')
  s.version = "0.1.4"
  s.homepage = 'https://github.com/satsv/rightresource'
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = FileList['CHANGELOG', 'README', 'LICENSE', 'lib/**/*.rb']
  s.add_dependency('json')
  s.add_dependency('rest_client')
  s.add_dependency('crack')
  s.description = <<EOF
RightScale Resource API wrapper.
EOF
end

Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

Rake::RDocTask.new(:rdoc) do |doc|
  doc.rdoc_files.include('README', 'lib/**/*.rb')
  doc.main = "README"
  doc.title = "RightResource API documentation"
  doc.rdoc_dir = "rdoc"
  doc.template = "direct"
end
