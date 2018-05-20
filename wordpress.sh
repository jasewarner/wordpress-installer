#!/bin/bash -e

#
#   WordPress Installer
# 	------------------
#   This script installs the latest version of WordPress as well as various useful plugins and a boilerplate theme.
#
#   To use this script, go to the directory you want to install Wordpress to and run this command:
#
#   curl -O https://raw.githubusercontent.com/jasewarner/wordpress-installer/master/wordpress.sh
#
#   Run the script with: sh ./wordpress.sh
#

#
#   Install WordPress
#   ------------------
#

clear
echo "WordPress Installer\n"

read -e -p "Database Name: " dbname
read -e -p "Database Username: " dbuser
read -s -p "Database Password: " dbpass; echo
stty echo
read -e -p "Database Hostname: " dbhost
read -e -p "Theme name (e.g. My WP Theme): " theme_name
read -e -p "Theme author: " theme_author
read -e -p "Theme author URI: " theme_author_uri
read -e -p "Theme description: " theme_description
read -e -p "Run install? (Y/n) " run

if [ "$run" == n ] ; then
exit

else
echo "\nDownloading the latest version of Wordpress... "
curl --remote-name --silent --show-error https://wordpress.org/latest.tar.gz
echo "Done! ✅\n"

echo "Uncompressing the file... "
tar --extract --gzip --file latest.tar.gz
rm latest.tar.gz
echo "Done! ✅\n"

echo "Putting the files in place... "
cp -R -f wordpress/* .
rm -R wordpress
echo "Done! ✅\n"

echo "Configuring WordPress... "
cp wp-config-sample.php wp-config.php
sed -i "" "s/database_name_here/$dbname/g" wp-config.php
sed -i "" "s/username_here/$dbuser/g" wp-config.php
sed -i "" "s/password_here/$dbpass/g" wp-config.php
sed -i "" "s/localhost/$dbhost/g" wp-config.php

#   Set authentication unique keys and salts in wp-config.php
perl -i -pe '
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

echo "Done! ✅\n"

echo "Applying folder and file permissions... "
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
echo "Done! ✅\n"

#
#   Install plugins
#   ------------------
#

#   ACF
echo "Fetching Advanced Custom Fields plugin...";
wget --quiet https://downloads.wordpress.org/plugin/advanced-custom-fields.zip;
unzip -q advanced-custom-fields.zip;
mv advanced-custom-fields/ wp-content/plugins/
echo "Done! ✅\n"

#   ACF for Yoast SEO
echo "Fetching ACF Content Analysis for Yoast SEO plugin...";
wget --quiet https://downloads.wordpress.org/plugin/acf-content-analysis-for-yoast-seo.zip;
unzip -q acf-content-analysis-for-yoast-seo.zip;
mv acf-content-analysis-for-yoast-seo/ wp-content/plugins/
echo "Done! ✅\n"

#   Contact Form 7
echo "Fetching Contact Form 7 plugin...";
wget --quiet https://downloads.wordpress.org/plugin/contact-form-7.zip;
unzip -q contact-form-7.zip;
mv contact-form-7/ wp-content/plugins/
echo "Done! ✅\n"

#   Flamingo
echo "Fetching Flamingo plugin...";
wget --quiet https://downloads.wordpress.org/plugin/flamingo.zip;
unzip -q flamingo.zip;
mv flamingo/ wp-content/plugins/
echo "Done! ✅\n"

#   W3 Total Cache
echo "Fetching W3 Total Cache plugin...";
wget --quiet https://downloads.wordpress.org/plugin/w3-total-cache.zip;
unzip -q w3-total-cache.zip;
mv w3-total-cache/ wp-content/plugins/
echo "Done! ✅\n"

#   Wordfence Security
echo "Fetching Wordfence Security plugin...";
wget --quiet https://downloads.wordpress.org/plugin/wordfence.zip;
unzip -q wordfence.zip;
mv wordfence/ wp-content/plugins/
echo "Done! ✅\n"

#   WordPress SEO a.k.a. Yoast
echo "Fetching WordPress SEO (a.k.a. Yoast) plugin...";
wget --quiet https://downloads.wordpress.org/plugin/wordpress-seo.zip;
unzip -q wordpress-seo.zip;
mv wordpress-seo/ wp-content/plugins/
echo "Done! ✅\n"

#
#   Remove default WP plugins
#   ------------------
#
echo "Removing default WordPress plugins..."
rm -rf wp-content/plugins/akismet
rm -rf wp-content/plugins/hello.php
echo "Done! ✅\n"

#
#   Remove older WordPress default themes
#   ------------------
#
echo "Removing default WordPress themes..."
rm -rf wp-content/themes/twentyfifteen
rm -rf wp-content/themes/twentysixteen
rm -rf wp-content/themes/twentyseventeen
echo "Done! ✅\n"

#
#   Install boilerplate theme (packaged with Gulp.js)
#   ------------------
#
theme_slug=$(echo "${theme_name}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '-' | tr A-Z a-z)

echo "Downloading boilerplate theme packaged with Gulp.js..."
curl -LOk --silent https://github.com/jasewarner/gulp-wordpress/archive/master.zip
echo "Done! ✅\n"

echo "Uncompressing the zip file and moving it to the correct location..."
unzip -q master.zip
mv gulp-wordpress-master/ wp-content/themes/${theme_slug}
echo "Done! ✅\n"

echo "Updating the theme details..."

#   remove theme git files
rm wp-content/themes/${theme_slug}/.gitignore

#   style.css
sed -i "" "s?<Theme_Name>?$theme_name?g" wp-content/themes/${theme_slug}/style.css
sed -i "" "s?<Theme_Author>?$theme_author?g" wp-content/themes/${theme_slug}/style.css
sed -i "" "s?<Theme_Author_URI>?$theme_author_uri?g" wp-content/themes/${theme_slug}/style.css
sed -i "" "s?<Theme_Description>?$theme_description?g" wp-content/themes/${theme_slug}/style.css
sed -i "" "s?<Theme_Text_Domain>?$theme_slug?g" wp-content/themes/${theme_slug}/style.css

#   gulp.js
sed -i "" "s?theme-name?$theme_slug?g" wp-content/themes/${theme_slug}/assets/gulpfile.js
sed -i "" "s?package-name?$theme_name?g" wp-content/themes/${theme_slug}/assets/package.json
sed -i "" "s?package-description?$theme_description?g" wp-content/themes/${theme_slug}/assets/package.json
sed -i "" "s?package-description?$theme_description?g" wp-content/themes/${theme_slug}/assets/package.json
sed -i "" "s?author-name?$theme_author?g" wp-content/themes/${theme_slug}/assets/package.json

#   wp scripts handle
sed -i "" "s?theme-name?$theme_slug?g" wp-content/themes/${theme_slug}/functions/func-script.php

echo "Done! ✅\n"

#
#   Tidy up
#   ------------------
#

#   The final few steps
echo "And now the final few steps:"

#   Cleanup
echo "\nCleaning up temporary files and directories...";
rm *.zip

#   Remove installation script file
rm -rf wordpress.sh;

#   Disable the built-in file editor
echo "Disabling the file editor...";
echo "
/* Disable the file editor */
define('DISALLOW_FILE_EDIT', true);" >> wp-config.php

#   Remove wp-config-sample.php
echo "Removing wp-config-sample.php...\n"
rm -rf wp-config-sample.php

echo "Fantastisch! All done 🙌";

fi
