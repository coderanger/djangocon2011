#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: postgresql
# Resource:: user
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

# NOTE: Delete all this and use the postgres gem <NPK>

include Chef::Provider::Postgresql::Base

action :validate do
  @new_resource.superuser false if @new_resource.superuser.nil?
  @new_resource.create_db false if @new_resource.create_db.nil?
  @new_resource.create_role false if @new_resource.create_role.nil?
  @new_resource.inherit true if @new_resource.inherit.nil?
  @new_resource.login true if @new_resource.login.nil?
  @new_resource.connection_limit(-1) unless @new_resource.connection_limit
  raise "#{@new_resource}: connection_limit attribute must be an Integer, not #{@new_resource.connection_limit.inspect}:#{@new_resource.connection_limit.class}" unless @new_resource.connection_limit.is_a?(Integer)
end

action :create do
  unless exists?
    parts = [@new_resource.username]
    parts << (@new_resource.superuser ? "SUPERUSER" : "NOSUPERUSER")
    parts << (@new_resource.create_db ? "CREATEDB" : "NOCREATEDB")
    parts << (@new_resource.create_role ? "CREATEROLE" : "NOCREATEROLE")
    parts << (@new_resource.inherit ? "INHERIT" : "NOINHERIT")
    parts << (@new_resource.login ? "LOGIN" : "NOLOGIN")
    parts << "CONNECTION LIMIT #{@new_resource.connection_limit}"
    parts << "PASSWORD '#{quote(@new_resource.password)}'" if @new_resource.password
    create_statement = "CREATE ROLE #{parts.join(' ')}"
    query(create_statement)
    @new_resource.updated_by_last_action(true)
  end
end

action :drop do
  if exists?
    shell_out!("dropuser #{@new_resource.username}", :user => "postgres")
    @new_resource.updated_by_last_action(true)
  end
end

action :grant do
  @new_resource.grant.each do |priv, target|
    grant_statement = "GRANT #{priv} ON #{target} TO #{@new_resource.username}"
    Chef::Log.info("#{@new_resource}: granting access with statement [#{grant_statement}]")
    query(grant_statement)
    @new_resource.updated_by_last_action(true)
  end
end

private
def exists?
  query("SELECT COUNT(*) FROM pg_user WHERE usename='#{@new_resource.username}'") == "1"
end
