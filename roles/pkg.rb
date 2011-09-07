name "pkg"
run_list(
  "role[base]",
  "role[packaginator_database_master]",
  "role[packaginator_task_broker]",
  "role[packaginator_application_server]",
  "role[packaginator_load_balancer]"
)
