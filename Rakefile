require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'fileutils'
require './lib/right_resource'

require 'rake/gempackagetask'
require 'rake/rdoctask'

#Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
#$hoe = Hoe.spec 'right_resource' do
#  self.developer 'Satoshi Ohki', ['roothybrid7', 'gmail.com'].join('@')
#  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
#  self.rubyforge_name       = self.name # TODO this is default value
#  # self.extra_deps         = [['activesupport','>= 2.0.2']]
#
#end

require 'newgem/tasks'
#Dir['tasks/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default

# task :default => [:spec, :features]
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
  s.version = '0.3.5'
  s.homepage = 'https://github.com/satsv/rightresource'
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = FileList['History.txt', @rdoc_main, 'LICENSE', 'lib/**/*.rb']
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
