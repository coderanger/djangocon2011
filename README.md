= Getting started with this Chef repo =

If you already have Ruby installed (OS X does) just run `gem install chef` to get our latest release. You can use Hosted Chef (http://www.opscode.com/hosted-chef/) as the server side since you 
don't need more than the 5 free nodes. After signing up with Hosted Chef you will need to download both your own key and the organization validator key, and download a knife.rb config file. Install
all of these to ~/.chef folder. Upload the cookbooks with `knife cookbook upload -a` and the roles with ``for f in roles/*.rb; do knife role from file `basename $f`; done``.

== Configuring cloud credentials ==

http://wiki.opscode.com/display/chef/Launch+Cloud+Instances+with+Knife shows a general overview but to get EC2 working quickly just ``gem install knife-ec2`` and add the following to your knife.rb:

    knife[:aws_access_key_id]  = '<your key id>'
    knife[:aws_secret_access_key] = '<your access key>'
    knife[:aws_ssh_key_id] = '<your ssh key name>'
    knife[:flavor] = 'm1.small'
    knife[:image] = 'ami-7000f019'

== Launching servers ==

To start a single server running all components:

    knife ec2 server create -x ubuntu -r 'role[base],role[pkg]' -d ubuntu10.04-apt

or to start 5 machines running all the parts:

    knife ec2 server create -x ubuntu -r 'role[base],role[packaginator_database_master]' -d ubuntu10.04-apt
    knife ec2 server create -x ubuntu -r 'role[base],role[packaginator_task_broker]' -d ubuntu10.04-apt
    knife ec2 server create -x ubuntu -r 'role[base],role[packaginator_application_server]' -d ubuntu10.04-apt
    knife ec2 server create -x ubuntu -r 'role[base],role[packaginator_application_server]' -d ubuntu10.04-apt 
    knife ec2 server create -x ubuntu -r 'role[base],role[packaginator_load_balancer]' -d ubuntu10.04-apt
