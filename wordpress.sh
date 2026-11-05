#!/usr/bin/env bash
set -euo pipefail

#
#   WordPress Installer
#   ------------------
#   Installs the latest version of WordPress, selected plugins,
#   and a boilerplate theme.
#

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check required dependencies
for cmd in curl tar unzip perl; do
  if ! command -v "$cmd" &>/dev/null; then
    echo -e "${RED}Error: Required command '$cmd' is not installed.${NC}" >&2
    exit 1
  fi
done

clear
echo -e "${GREEN}"
echo "+---------------------+"
echo "| WordPress Installer |"
echo "+---------------------+"
echo -e "${NC}"

read -r -p "$(echo -e "${BLUE}Database Name: ${NC}")" dbname
read -r -p "$(echo -e "${BLUE}Database Username: ${NC}")" dbuser
read -r -s -p "$(echo -e "${BLUE}Database Password: ${NC}")" dbpass
echo
read -r -p "$(echo -e "${BLUE}Database Hostname [localhost]: ${NC}")" dbhost
dbhost=${dbhost:-localhost}

read -r -p "$(echo -e "${BLUE}Theme name (e.g. My WP Theme): ${NC}")" theme_name
read -r -p "$(echo -e "${BLUE}Theme author: ${NC}")" theme_author
read -r -p "$(echo -e "${BLUE}Theme author URI: ${NC}")" theme_author_uri
read -r -p "$(echo -e "${BLUE}Theme description: ${NC}")" theme_description
read -r -p "$(echo -e "${BLUE}Run install? (Y/n) ${NC}")" run

if [[ "$run" =~ ^[Nn]$ ]]; then
  echo "Installation aborted."
  exit 0
fi

printf '\n'

#
#   Download and extract WordPress
#   ------------------
#
echo "Downloading and extracting WordPress..."
curl -sSL https://wordpress.org/latest.tar.gz | tar -xz --strip-components=1
echo -e "${GREEN}Done! ✅${NC}\n"

#
#   Configure wp-config.php
#   ------------------
#
echo "Configuring wp-config.php..."
cp wp-config-sample.php wp-config.php

theme_slug=$(echo "${theme_name}" | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' | tr '[:upper:]' '[:lower:]')

# Safely inject DB credentials and custom settings before wp-settings.php inclusion
DB_NAME="$dbname" DB_USER="$dbuser" DB_PASS="$dbpass" DB_HOST="$dbhost" THEME_SLUG="$theme_slug" \
perl -i -pe '
  s/database_name_here/$ENV{DB_NAME}/ge;
  s/username_here/$ENV{DB_USER}/ge;
  s/password_here/$ENV{DB_PASS}/ge;
  s/localhost/$ENV{DB_HOST}/ge;

  # Insert settings before wp-settings.php is loaded
  if (/That\x27s all, stop editing!/) {
    $_ = "/** Disable the file editor */\ndefine( \x27DISALLOW_FILE_EDIT\x27, true );\n\n" .
         "/** Define default theme */\ndefine( \x27WP_DEFAULT_THEME\x27, \x27$ENV{THEME_SLUG}\x27 );\n\n" . $_;
  }
' wp-config.php

# Fetch and inject official salts safely
echo "Fetching official salts from api.wordpress.org..."
curl -sSL https://api.wordpress.org/secret-key/1.1/salt/ > salts.tmp 2>/dev/null || true

if grep -q "AUTH_KEY" salts.tmp 2>/dev/null; then
  perl -i -pe '
    if (/put your unique phrase here/) {
      if (!$done) {
        open my $fh, "<", "salts.tmp";
        print <$fh>;
        close $fh;
        $done = 1;
      }
      $_ = "";
    }
  ' wp-config.php
else
  echo "Notice: Could not reach salt API, generating secure salts locally..."
  perl -i -pe '
    BEGIN {
      @chars = ("a" .. "z", "A" .. "Z", 0 .. 9, split //, "!@#$%^&*()-_ []{}<>~+=,.;:/?|");
      sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
    }
    s/put your unique phrase here/salt()/ge;
  ' wp-config.php
fi
rm -f salts.tmp

rm -f wp-config-sample.php
echo -e "${GREEN}Done! ✅${NC}\n"

#
#   Set permissions
#   ------------------
#
echo "Applying folder and file permissions..."
find . -type d -exec chmod 755 {} +
find . -type f -exec chmod 644 {} +
echo -e "${GREEN}Done! ✅${NC}\n"

#
#   Install Plugins
#   ------------------
#
install_plugin() {
  local name="$1"
  local url="$2"
  echo "Installing plugin: ${name}..."
  curl -sSL -o plugin.zip "$url"
  unzip -q -o plugin.zip -d wp-content/plugins/
  rm -f plugin.zip
  echo -e "${GREEN}Done! ✅${NC}\n"
}

# ACF
install_plugin "Advanced Custom Fields" "https://downloads.wordpress.org/plugin/advanced-custom-fields.zip"

# Wordfence
install_plugin "Wordfence Security" "https://downloads.wordpress.org/plugin/wordfence.zip"

#
#   Clean default plugins and legacy themes
#   ------------------
#
echo "Removing default WordPress plugins..."
rm -rf wp-content/plugins/akismet wp-content/plugins/hello.php
echo -e "${GREEN}Done! ✅${NC}\n"

echo "Removing older default WordPress themes..."
rm -rf wp-content/themes/twenty{fifteen,sixteen,seventeen,nineteen,twenty,twentyone,twentytwo,twentythree} 2>/dev/null || true
echo -e "${GREEN}Done! ✅${NC}\n"

#
#   Install boilerplate theme (Gulp.js)
#   ------------------
#
echo "Downloading boilerplate theme..."
curl -sSL -o theme.zip "https://github.com/jasewarner/gulp-wordpress/archive/master.zip"
unzip -q theme.zip
mv gulp-wordpress-master wp-content/themes/"${theme_slug}"
rm -f theme.zip
echo -e "${GREEN}Done! ✅${NC}\n"

echo "Customising theme details..."
rm -f wp-content/themes/"${theme_slug}"/.gitignore

THEME_NAME="$theme_name" THEME_AUTHOR="$theme_author" THEME_URI="$theme_author_uri" \
THEME_DESC="$theme_description" THEME_SLUG="$theme_slug" \
perl -i -pe '
  s/<Theme_Name>/$ENV{THEME_NAME}/ge;
  s/<Theme_Author>/$ENV{THEME_AUTHOR}/ge;
  s/<Theme_Author_URI>/$ENV{THEME_URI}/ge;
  s/<Theme_Description>/$ENV{THEME_DESC}/ge;
  s/<Theme_Text_Domain>/$ENV{THEME_SLUG}/ge;
' wp-content/themes/"${theme_slug}"/style.css

if [ -f "wp-content/themes/${theme_slug}/assets/package.json" ]; then
  THEME_DESC="$theme_description" THEME_AUTHOR="$theme_author" THEME_SLUG="$theme_slug" \
  perl -i -pe '
    s/package-name/$ENV{THEME_SLUG}/ge;
    s/package-description/$ENV{THEME_DESC}/ge;
    s/author-name/$ENV{THEME_AUTHOR}/ge;
  ' wp-content/themes/"${theme_slug}"/assets/package.json
fi

# Replace theme handles and doc placeholders safely across all theme PHP files
THEME_SLUG="$theme_slug" THEME_AUTHOR="$theme_author" THEME_URI="$theme_author_uri" \
find wp-content/themes/"${theme_slug}" -type f -name "*.php" -exec perl -i -pe '
  s/theme-name/$ENV{THEME_SLUG}/ge;
  s/<Author>/$ENV{THEME_AUTHOR}/ge;
  s/<Package>/$ENV{THEME_SLUG}/ge;
  s?http://author\.com?$ENV{THEME_URI}?ge;
  s/Author Name/$ENV{THEME_AUTHOR}/ge;
' {} +

echo -e "${GREEN}Done! ✅${NC}\n"

#
#   Tidy up
#   ------------------
#
echo "Cleaning up installer script..."
rm -f "$0"

echo -e "${GREEN}Magnifique! All done 🤝${NC}"