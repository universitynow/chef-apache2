#
# Cookbook Name:: apache2_test
# Recipe:: default
#
# Copyright 2012, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'apache2::default'

package_name = node['apache']['package']
listen_ports = node['apache']['listen_ports']
apache_dir = node['apache']['dir']
log_dir = node['apache']['log_dir']
perl_pkg = node['apache']['perl_pkg']

control_group 'Default recipe apache config' do
  control 'Apache Service' do
    it 'Should install Apache2' do
      expect(package(package_name)).to be_installed
    end
    it 'Should install perl' do
      expect(package(perl_pkg)).to be_installed
    end

    it 'should be listening on port(s) ' + listen_ports.join(' ') do
      listen_ports.each do |listen|
        expect(port(listen)).to be_listening
      end
    end
  end
  control 'Files/Directories' do
    %w(sites-available sites-enabled mods-available mods-enabled conf-available conf-enabled).each do |dir|
      it 'should create ' + dir do
        expect(file("#{apache_dir}/#{dir}")).to be_directory
      end
    end
    %w(default default.conf 000-default 000-default.conf).each do |site|
      it 'should delete symlink for ' + site do
        expect(file("#{apache_dir}/sites-enabled/#{site}")).to_not be_symlink
      end
      it 'should delete ' + site do
        expect(file("#{apache_dir}/sites-available/#{site}")).to_not be_symlink
      end
    end
    it 'should delete conf.d directory' do
      expect(file("#{apache_dir}/conf.d")).to_not be_directory
    end
    it 'creates log dir' do
      expect(file(log_dir)).to be_directory
    end
    %w(a2ensite a2dissite a2enmod a2dismod a2enconf a2disconf).each do |modscript|
      it 'deletes symlinks' do
        expect(file("/usr/sbin/#{modscript}")).to_not be_symlink
      end
      it 'creates templates' do
        expect(file("/usr/sbin/#{modscript}")).to be_file
      end
    end
  end
end
