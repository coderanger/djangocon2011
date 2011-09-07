maintainer       "Opscode, Inc."
maintainer_email "cookbooks@opscode.com"
license          "Apache 2.0"
description      "Deploys and configures Django applications"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.99.12"

%w{ application python gunicorn supervisor }.each do |cb|
  depends cb
end
