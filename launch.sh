knife ec2 server create -x ubuntu -r 'role[base],role[packaginator_database_master]' -d ubuntu10.04-apt && \
knife ec2 server create -x ubuntu -r 'role[base],role[packaginator_task_broker]' -d ubuntu10.04-apt && \
knife ec2 server create -x ubuntu -r 'role[base],role[packaginator_application_server]' -d ubuntu10.04-apt && \
knife ec2 server create -x ubuntu -r 'role[base],role[packaginator_application_server]' -d ubuntu10.04-apt && \
knife ec2 server create -x ubuntu -r 'role[base],role[packaginator_load_balancer]' -d ubuntu10.04-apt
