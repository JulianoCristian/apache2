#
# Cookbook:: apache2
# Resource:: apache2_conf
#
# Copyright:: 2008-2017, Chef Software, Inc.
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
include Apache2::Cookbook::Helpers

property :path, String,
         default: lazy { "#{apache_dir}/conf-available" },
         description: ''
property :root_group, String,
         default: lazy { default_apache_root_group },
         description: ''
property :template_cookbook, String,
         default: 'apache2',
         description: ''

action :enable do
  template ::File.join(new_resource.path, "#{new_resource.name}.conf") do
    cookbook new_resource.template_cookbook
    owner 'root'
    group new_resource.root_group
    backup false
    mode '0644'
    variables(
      apache_dir: apache_dir
    )
    notifies :restart, 'service[apache2]', :delayed
  end

  execute "a2enconf #{new_resource.name}" do
    command "/usr/sbin/a2enconf #{new_resource.name}"
    notifies :restart, 'service[apache2]', :delayed
    not_if { conf_enabled?(new_resource) }
    # not_if do
    #     ::File.symlink?("#{apache_dir}/conf-enabled/#{new_resource.name}") &&
    #       (::File.exist?(params[:conf_path]) ? ::File.symlink?("#{apache_dir}/conf-enabled/#{new_resource.name}") : true)
    #   end
  end
end

action :disable do
  execute "a2disconf #{new_resource.name}" do
    command "/usr/sbin/a2disconf #{new_resource.name}"
    notifies :reload, 'service[apache2]', :delayed
    only_if { conf_enabled?(new_resource) }
  end
end
