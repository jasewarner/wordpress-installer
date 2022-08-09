# WordPress Installer

A shell script for installing WordPress along with useful plugins and a [boilerplate theme](https://github.com/jasewarner/gulp-wordpress/) packaged with Gulp.js.

## Author

[Jase Warner](https://jase.io/)

> If this project has been a help to you, feel free to [give this grateful developer a coffee](https://www.buymeacoffee.com/jasewarner/) ☕️

## Synopsis

I was looking around for a useful script to speed up the setting-up process for a WordPress site.

After looking around, I found a couple of great scripts by [@snaptortoise](https://github.com/snaptortoise/wordpress-quick-install/) and [@darlanrod](https://github.com/darlanrod/wordpress-shell-script-install/).
However, I needed more features to speed up my day-to-day WordPress work, so I built on top of the fantastic work these guys did to get it to where I needed it to be.

## Prerequisites

In order to use this script, you will need to have `wget` installed. See instructions for Brew here: [https://formulae.brew.sh/formula/wget](https://formulae.brew.sh/formula/wget)

## Installation

`cd` into the project root and run the following in command-line:

`curl -O https://raw.githubusercontent.com/jasewarner/wordpress-installer/master/wordpress.sh`

Then run the script: `sh ./wordpress.sh`

It will download the latest version of WordPress, along with the latest version of all the plugins listed in the shell script and install them to the current directory, as well as the boilerplate theme.

> Quick tip: if `wget` throws an error when attempting to retrieve the plugins, you will most likely need to install it! To do so, in the command-line, run `brew install wget`. 

## Plugins

The script installs the following WordPress plugins:

* [Advanced Custom Fields](https://en-gb.wordpress.org/plugins/advanced-custom-fields/) †
* [ACF Content Analysis for Yoast SEO](https://en-gb.wordpress.org/plugins/acf-content-analysis-for-yoast-seo/)
* [Wordfence Security](https://en-gb.wordpress.org/plugins/wordfence/)
* [Yoast SEO](https://en-gb.wordpress.org/plugins/wordpress-seo/)

† I highly recommend purchasing the [Pro](https://www.advancedcustomfields.com/pro/) version!

## Theme

The script also installs my [blank slate WordPress theme](https://github.com/jasewarner/gulp-wordpress/) for Developers, packaged with Gulp.js for processing SCSS and JavaScript (ES6).

It also comes with some helpful SCSS mixins and was developed in accordance to the [WordPress Coding Standards](https://make.wordpress.org/core/handbook/best-practices/coding-standards/php/).
