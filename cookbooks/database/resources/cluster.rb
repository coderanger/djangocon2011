#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: database
# Resource:: cluster
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

require 'net/http'
require 'weakref'

include Chef::Mixin::RecipeDefinitionDSLCore

def initialize(*args)
  super
  @action = :create
  @servers = {}
end

actions :create

attribute :id, :kind_of => String, :name_attribute => true
attribute :master_role, :kind_of => [String, NilClass], :default => nil
attribute :slave_role, :kind_of => [String, NilClass], :default => nil
attr_reader :servers

# Used to grab the type attribute from a block
class TypeGetter
  def type(db_type=nil)
    @type = db_type if db_type
    @type
  end
  def method_missing(*args, &block)
    # Ignored
  end
end

# This can probably be made cleaner by aliasing the original method_missing, put the main logic in here, and make method_missing a tiny wrapper
def database_server(&block)
  getter = TypeGetter.new
  getter.instance_eval(&block)
  raise "Database type not specified" unless getter.type
  method_missing(getter.type, &block)
end

def method_missing(db_type, &block)
  resource = @servers[db_type]
  if !resource
    resource = super("database_server", "#{name}::#{db_type}") do end
    # Make this a weakref to prevent a cycle between this resource and the sub resources
    resource.type db_type.to_s
    resource.database_cluster WeakRef.new(self)
    @servers[db_type] = resource
    resource.instance_eval(&block)
  end
  resource
end

def database(type, name)
  raise "No database server for #{type} in cluster #{name}" unless @servers[type]
  @servers[type].sub_resources.select{|sub_type, sub_name| sub_type == "database" && sub_name == name}.first
end

def database_user(type, name)
  raise "No database server for #{type} in cluster #{name}" unless @servers[type]
  @servers[type].sub_resources.select{|sub_type, sub_name| sub_type == "user" && sub_name == name}.first
end

def is_master?
  @master_role ||= "#{id}_database_master"
  @master_role_exists ||= begin
    Chef::Role.load(@master_role)
    true
  rescue HTTPServerException => e
    raise unless e.response.is_a? Net::HTTPNotFound
    false
  end
  if @master_role_exists
    node['roles'].include? @master_role
  else
    true
  end
end

def is_slave?
  @slave_role ||= "#{id}_database_slave"
  node['roles'].include? @slave_role
end
