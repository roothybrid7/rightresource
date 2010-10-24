require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "RightResource: RightScale Resource API wrapper"
  s.name = 'rightresource'
  s.author = 'Satoshi Ohki'
  s.email = ["roothybrid7", "gmail.com"].join('@')
  s.version = "0.1.0"
  s.requirements << 'none'
  s.require_path = 'lib'
  s.autorequire = 'rake'
  s.files = FileList['CHANGELOG', 'README', 'LICENSE', 'lib/*.rb']
  s.description = <<EOF
RightScale Resource API wrapper.
EOF
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
