name "packaginator_database_master"
description "Database master for the packaginator application."
run_list(
  "recipe[postgresql::server]",
  "recipe[packaginator::database]"
)

override_attributes :postgresql => {:listen => '*'}