
#
# Read notes on what needs to be done for pyspark here:
# http://blog.cloudera.com/blog/2015/09/how-to-prepare-your-apache-hadoop-cluster-for-pyspark-jobs/
#

node.override.anaconda.accept_license = "yes"
node.override.anaconda.owner = node.kagent.user
node.override.anaconda.group = node.kagent.group
node.override.anaconda.flavor = "x86_64"
node.override.anaconda.python = "python2"

# Changing the install path led to problems.
#node.override.anaconda.install_root = node.anaconda.dir


include_recipe "anaconda::default"


template "#{node.kagent.base_dir}/anaconda/spec-file.txt" do
  source "spec-file.txt.erb"
  owner node.anaconda.user
  group node.anaconda.group
  mode "0440"
  action :create
end  


link node.anaconda.base_dir do
  action :delete
  only_if "test -L #{node.anaconda.base_dir}"
end

link node.anaconda.base_dir do
  owner node.anaconda.user
  group node.anaconda.group
  to node.anaconda.home
end

magic_shell_environment 'PATH' do
  value "$PATH:#{node.anaconda.base_dir}/bin"
end



bash "update_conda" do
  user node.kagent.user
  code <<-EOF
   #{node.anaconda.base_dir}/bin/conda update conda -y -q
   #{node.anaconda.base_dir}/bin/conda update anaconda -y -q
# This is the hopsworks-wide default environment that all projects will clone their environment from.
   #{node.anaconda.base_dir}/bin/conda create -n hopsworksconda -y -q --file #{node.kagent.base_dir}/anaconda/spec-file.txt
 EOF
end
