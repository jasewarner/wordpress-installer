# WordPress Installer

A shell for installing WordPress along with useful plugins and a <a href="https://github.com/jasewarner/gulp-wordpress">boilerplate theme</a> packaged with Gulp.js.

## Synopsis

I was looking around for a useful script to speed up the setting-up process for a WordPress site.

After looking around, I found a couple of great scripts by <a href="https://github.com/snaptortoise/wordpress-quick-install">@snaptortoise</a> and <a href="https://github.com/darlanrod/wordpress-shell-script-install/blob/master/wp.sh">@darlanrod</a>.
However I needed more features to speed up my day-to-day WordPress work, so I built on top of the fantastic work these guys did to get it to where I needed it to be.

## Installation

`cd` into the project root and run the following in command-line:

`curl https://raw.github.com/jasewarner/wordpress-installer/master/wordpress | sh`

Then run the script: `sh ./wordpress.sh`

It will download the latest version of WordPress, along with the latest version of all the plugins listed in the shell script and install them to the current directory, as well as the boilerplate theme.

> Quick tip: if `wget` throws an error when attempting to retrieve the plugins, you will most likely need to install it! To do so, in the command-line, run `brew install wget`. 
