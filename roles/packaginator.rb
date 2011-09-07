name "packaginator"
description "packaginator core requrements."
run_list(
  "recipe[postgresql::client]",
  "recipe[packaginator]"
)
