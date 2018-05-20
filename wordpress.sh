#!/bin/sh
#
# 	WordPress Installer
# 	------------------
# 	This script installs the latest version of WordPress as well as various useful plugins.
#
# 	To use this script, go to the directory you want to install Wordpress to in the terminal and run this command:
#
# 	curl -O https://raw.githubusercontent.com/jasewarner/wordpress-installer/master/wordpress.sh
#
# 	There you go.
#

# Latest version of WP
clear
printf "\e[1mWordpress Bash Install\e[0m\n\n"

read -e -p "Database Name: " dbname
read -e -p "Database Username: " dbuser
read -e -p "Database Password: " dbpass
read -e -p "Database Hostname: " dbhost
read -e -p "Run install? (Y/n) " run

if [ "$run" == n ] ; then
exit

else
printf "\nDownloading the latest version of Wordpress... "
curl --remote-name --silent --show-error https://wordpress.org/latest.tar.gz
printf "Done!\n"

printf "Uncompressing the file... "
tar --extract --gzip --file latest.tar.gz
rm latest.tar.gz
printf "Done!\n"

printf "Putting the files in place... "
cp -R -f wordpress/* .
rm -R wordpress
printf "Done!\n"

printf "Configuring Wordpress... "
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/$dbname/g" wp-config.php
sed -i "s/username_here/$dbuser/g" wp-config.php
sed -i "s/password_here/$dbpass/g" wp-config.php
sed -i "s/localhost/$dbhost/g" wp-config.php

# Set authentication unique keys and salts in wp-config.php
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

printf "Done!\n"

printf "Applying folders and files permissions... "
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
printf "Done!\n"

# Yoast SEO
echo "Fetching Yoast-SEO plugin...";
wget --quiet https://downloads.wordpress.org/plugin/wordpress-seo.zip;
unzip -q wordpress-seo.zip;
mv wordpress-seo wordpress/wp-content/plugins/

# Cleanup
echo "Cleaning up temporary files and directories...";
rm *.zip

# Move stuff into current directory
mv wordpress/* .;
rm -rf wordpress;

# Disable the built-in file editor
echo "Disabling file editor...";
echo "
/* Disable the file editor */
define(‘DISALLOW_FILE_EDIT’, true);" >> wp-config-sample.php

echo "Fantastisch! All done 🙌";
