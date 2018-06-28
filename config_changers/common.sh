# establish a root for things to look for
ENHUIFY_ROOT=~/git/maplebed/enhuify
# grab the password out of the config file
password=$(grep config.admin_secret $ENHUIFY_ROOT/config/initializers/enhuify.rb | sed -e 's/.* = "\(.*\)"/\1/')
