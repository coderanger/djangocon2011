name "packaginator_task_broker"
run_list "recipe[redis::server]", "role[packaginator]"
