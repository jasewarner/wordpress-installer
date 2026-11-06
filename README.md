# WordPress Installer

A lightweight shell script that automates setting up a clean WordPress install, essential plugins and a [boilerplate starter theme](https://github.com/jasewarner/gulp-wordpress/) packaged with Gulp.js.

## Author

[Jase Warner](https://jase.io/)

> If this project has been a help to you, feel free to [give this grateful developer a coffee](https://www.buymeacoffee.com/jasewarner/) ☕️

## Overview

I was looking around for a useful script to speed up the process when making a new WordPress project.

Inspired by earlier setup scripts from [@snaptortoise](https://github.com/snaptortoise/wordpress-quick-install/) and [@darlanrod](https://github.com/darlanrod/wordpress-shell-script-install/),
this project adds additional configuration steps, automated salt generation, and my own custom theme workflow.

## Prerequisites

Before running the script, make sure you have:
* A terminal environment with `curl`, `tar`, `unzip`, and `perl` installed.
* An empty MySQL database created, along with its username and password.

## Installation

Navigate to your target directory and download the installer:

`curl -O https://raw.githubusercontent.com/jasewarner/wordpress-installer/master/wordpress.sh`

Run the script: 

`bash wordpress.sh`

Follow the prompts to enter your database credentials and theme details. The script will take care of the rest:
downloading WordPress core files, configuring `wp-config.php`, applying secure permissions, and setting up the theme and plugins.

## Plugins

The installer fetches the latest version of:

* [Advanced Custom Fields](https://en-gb.wordpress.org/plugins/advanced-custom-fields/) †
* [Wordfence Security](https://en-gb.wordpress.org/plugins/wordfence/)

† I highly recommend purchasing the [Pro](https://www.advancedcustomfields.com/pro/) version!

## Starter Theme

The installer sets up a copy of my [blank-slate WordPress starter theme](https://github.com/jasewarner/gulp-wordpress/).

Key features:
* Pre-configured Gulp workflow for compiling SCSS and bundling modern JavaScript (ES6).
* Helpful SCSS utilities and mixins.
* Built in accordance with WordPress Coding Standards.
