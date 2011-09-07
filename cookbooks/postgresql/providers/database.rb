#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: postgresql
# Provider:: database
#
# Copyright:: 2011, Opscode, Inc <legal@opscode.com>
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

include Chef::Provider::Postgresql::Base

action :validate do
end

action :create do
  unless exists?
    Chef::Log.debug("#{@new_resource}: Creating database #{new_resource.name}")
    shell_out!("createdb #{new_resource.owner ? "-O #{new_resource.owner}" : ""} #{new_resource.name}", :user => "postgres")
    @new_resource.updated_by_last_action(true)
  end
end

action :drop do
  if exists?
    Chef::Log.debug("#{@new_resource}: Dropping database #{new_resource.name}")
    shell_out!("dropdb #{new_resource.name}", :user => "postgres")
    @new_resource.updated_by_last_action(true)
  end
end

action :query do
  if exists?
    Chef::Log.debug("#{@new_resource}: Performing query [#{new_resource.sql}]")
    query(@new_resource.sql, @new_resource.name)
    @new_resource.updated_by_last_action(true)
  end
end

private
def exists?
  query("SELECT COUNT(*) FROM pg_database WHERE datname='#{@new_resource.name}'") == "1"
end
