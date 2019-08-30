#!/bin/bash -e

#
#   WordPress Installer
#   ------------------
#   This script installs the latest version of WordPress as well as various useful plugins and a boilerplate theme.
#
#   To use this script, go to the directory you want to install Wordpress to and run this command:
#
#   curl -O https://raw.githubusercontent.com/jasewarner/wordpress-installer/master/wordpress.sh
#
#   Run the script with: sh ./wordpress.sh
#

#
#   Output colours
#   ------------------
#

GREEN='\033[0;32m'
NC='\033[0m' # No Color

#
#   Install WordPress
#   ------------------
#

clear
echo "${GREEN}"
echo "+---------------------+"
echo "| WordPress Installer |"
echo "+---------------------+"
echo "${NC}"

read -r -p $'\e[34mDatabase Name: \e[0m' dbname
read -r -p $'\e[34mDatabase Username: \e[0m' dbuser
read -r -s -p $'\e[34mDatabase Password: \e[0m' dbpass; echo
stty echo
read -r -p $'\e[34mDatabase Hostname: \e[0m' dbhost
read -r -p $'\e[34mTheme name (e.g. My WP Theme): \e[0m' theme_name
read -r -p $'\e[34mTheme author: \e[0m' theme_author
read -r -p $'\e[34mTheme author URI: \e[0m' theme_author_uri
read -r -p $'\e[34mTheme description: \e[0m' theme_description
read -r -p $'\e[34mRun install? (Y/n) \e[0m' run

if [ "$run" == n ] ; then
exit

else
printf '\n'
echo "Downloading the latest version of Wordpress... "
curl --remote-name --silent --show-error https://wordpress.org/latest.tar.gz
echo "${GREEN}Done! ✅${NC}"
printf '\n'

echo "Uncompressing the file... "
tar --extract --gzip --file latest.tar.gz
rm latest.tar.gz
echo "${GREEN}Done! ✅${NC}"
printf '\n'

echo "Putting the files in place... "
cp -R -f wordpress/* .
rm -R wordpress
echo "${GREEN}Done! ✅${NC}"
printf '\n'

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

echo "${GREEN}Done! ✅${NC}"
printf '\n'

echo "Applying folder and file permissions... "
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
echo "${GREEN}Done! ✅${NC}"
printf '\n'

#
#   Install plugins
#   ------------------
#

#   ACF
echo "Fetching Advanced Custom Fields plugin...";
wget --quiet https://downloads.wordpress.org/plugin/advanced-custom-fields.5.8.3.zip;
unzip -q advanced-custom-fields.5.8.3.zip;
mv advanced-custom-fields/ wp-content/plugins/
echo "${GREEN}Done! ✅${NC}"
printf '\n'

#   ACF for Yoast SEO
echo "Fetching ACF Content Analysis for Yoast SEO plugin...";
wget --quiet https://downloads.wordpress.org/plugin/acf-content-analysis-for-yoast-seo.zip;
unzip -q acf-content-analysis-for-yoast-seo.zip;
mv acf-content-analysis-for-yoast-seo/ wp-content/plugins/
echo "${GREEN}Done! ✅${NC}"
printf '\n'

#   Contact Form 7
echo "Fetching Contact Form 7 plugin...";
wget --quiet https://downloads.wordpress.org/plugin/contact-form-7.zip;
unzip -q contact-form-7.zip;
mv contact-form-7/ wp-content/plugins/
echo "${GREEN}Done! ✅${NC}"
printf '\n'

#   Flamingo
echo "Fetching Flamingo plugin...";
wget --quiet https://downloads.wordpress.org/plugin/flamingo.zip;
unzip -q flamingo.zip;
mv flamingo/ wp-content/plugins/
echo "${GREEN}Done! ✅${NC}"
printf '\n'

#   W3 Total Cache
echo "Fetching W3 Total Cache plugin...";
wget --quiet https://downloads.wordpress.org/plugin/w3-total-cache.zip;
unzip -q w3-total-cache.zip;
mv w3-total-cache/ wp-content/plugins/
echo "${GREEN}Done! ✅${NC}"
printf '\n'

#   Wordfence Security
echo "Fetching Wordfence Security plugin...";
wget --quiet https://downloads.wordpress.org/plugin/wordfence.zip;
unzip -q wordfence.zip;
mv wordfence/ wp-content/plugins/
echo "${GREEN}Done! ✅${NC}"
printf '\n'

#   WordPress SEO a.k.a. Yoast
echo "Fetching WordPress SEO (a.k.a. Yoast) plugin...";
wget --quiet https://downloads.wordpress.org/plugin/wordpress-seo.zip;
unzip -q wordpress-seo.zip;
mv wordpress-seo/ wp-content/plugins/
echo "${GREEN}Done! ✅${NC}"
printf '\n'

#
#   Remove default WP plugins
#   ------------------
#
echo "Removing default WordPress plugins..."
rm -rf wp-content/plugins/akismet
rm -rf wp-content/plugins/hello.php
echo "${GREEN}Done! ✅${NC}"
printf '\n'

#
#   Remove older WordPress default themes
#   ------------------
#
echo "Removing default WordPress themes..."
rm -rf wp-content/themes/twentyfifteen
rm -rf wp-content/themes/twentysixteen
rm -rf wp-content/themes/twentyseventeen
rm -rf wp-content/themes/twentynineteen
echo "${GREEN}Done! ✅${NC}"
printf '\n'

#
#   Install boilerplate theme (packaged with Gulp.js)
#
#   https://github.com/jasewarner/gulp-wordpress
#   ------------------
#
theme_slug=$(echo "${theme_name}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '-' | tr '[:upper:]' '[:lower:]')

echo "Downloading boilerplate theme packaged with Gulp.js..."
curl -LOk --silent https://github.com/jasewarner/gulp-wordpress/archive/master.zip
echo "${GREEN}Done! ✅${NC}"
printf '\n'

echo "Uncompressing the zip file and moving it to the correct location..."
unzip -q master.zip
mv gulp-wordpress-master/ wp-content/themes/"${theme_slug}"
echo "${GREEN}Done! ✅${NC}"
printf '\n'

echo "Updating the theme details..."

#   remove theme git files
rm wp-content/themes/"${theme_slug}"/.gitignore

#   style.css
sed -i "" "s?<Theme_Name>?$theme_name?g" wp-content/themes/"${theme_slug}"/style.css
sed -i "" "s?<Theme_Author>?$theme_author?g" wp-content/themes/"${theme_slug}"/style.css
sed -i "" "s?<Theme_Author_URI>?$theme_author_uri?g" wp-content/themes/"${theme_slug}"/style.css
sed -i "" "s?<Theme_Description>?$theme_description?g" wp-content/themes/"${theme_slug}"/style.css
sed -i "" "s?<Theme_Text_Domain>?$theme_slug?g" wp-content/themes/"${theme_slug}"/style.css

#   gulp.js
sed -i "" "s?theme-name?$theme_slug?g" wp-content/themes/"${theme_slug}"/assets/gulpfile.js
sed -i "" "s?package-name?$theme_slug?g" wp-content/themes/"${theme_slug}"/assets/package.json
sed -i "" "s?package-description?$theme_description?g" wp-content/themes/"${theme_slug}"/assets/package.json
sed -i "" "s?author-name?$theme_author?g" wp-content/themes/"${theme_slug}"/assets/package.json

#   wp script handle
sed -i "" "s?theme-name?$theme_slug?g" wp-content/themes/"${theme_slug}"/functions/func-script.php

#   wp style handle
sed -i "" "s?theme-name?$theme_slug?g" wp-content/themes/"${theme_slug}"/functions/func-style.php

#   php theme files
sed -i "" "s?<Author>?$theme_author?g" wp-content/themes/"${theme_slug}"/*.php
sed -i "" "s?<Package>?$theme_slug?g" wp-content/themes/"${theme_slug}"/*.php
sed -i "" "s?<Author>?$theme_author?g" wp-content/themes/"${theme_slug}"/functions/*.php
sed -i "" "s?<Package>?$theme_slug?g" wp-content/themes/"${theme_slug}"/functions/*.php

#   add author admin credit to backend
sed -i "" "s?http://author.com?$theme_author_uri?g" wp-content/themes/"${theme_slug}"/functions/func-admin.php
sed -i "" "s?Author Name?$theme_author?g" wp-content/themes/"${theme_slug}"/functions/func-admin.php

echo "${GREEN}Done! ✅${NC}"
printf '\n'

#
#   Tidy up
#   ------------------
#

#   The final few steps
echo "And now the final few steps:"

#   Cleanup
printf '\n'
echo "Cleaning up temporary files and directories...";
rm -- *.zip

#   Remove installation script file
rm -rf wordpress.sh;

#   Disable the built-in file editor
echo "Disabling the file editor...";
echo "
/* Disable the file editor */
define('DISALLOW_FILE_EDIT', true);" >> wp-config.php

#   Remove wp-config-sample.php
echo "Removing wp-config-sample.php..."
rm -rf wp-config-sample.php

printf '\n'
echo "${GREEN}Fantastisch! All done 🙌${NC}";

fi
