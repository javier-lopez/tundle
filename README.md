## About

[![Build Status](https://travis-ci.org/chilicuil/tundle.png?branch=master)](https://travis-ci.org/chilicuil/tundle)

[Tundle](https://github.com/chilicuil/tundle/) is short for _tmux + bundle_ and is a [tmux](http://en.wikipedia.org/wiki/tmux) plugin manager.

<p align="center">
<img src="http://javier.io/assets/img/tundle.gif" alt="tundle"/>
</p>

Tundle is based on [tpm](https://github.com/tmux-plugins/tpm) with additional syntax sugar and relaxed dependency requirements.

## Quick start

1. Set up [Tundle](https://github.com/chilicuil/tundle/):

   ```
   $ git clone --depth=1 https://github.com/chilicuil/tundle ~/.tmux/plugins/tundle
   ```

2. Configure bundles:

   Sample `~/.tmux.conf`:

   ```
   run-shell "~/.tmux/plugins/tundle/tundle"

   #let tundle manage tundle, required!
   setenv -g @bundle "chilicuil/tundle" #set -g can be used if tmux >= 1.9

   #from GitHub
   setenv -g @BUNDLE "gh:chilicuil/tundle-plugins/tmux-sensible"
       #options
       #setenv -g @plugin-option "setting"
   setenv -g @plugin "tmux-plugins/tmux-battery"
   setenv -g @PLUGIN "github:tmux-plugins/tmux-sidebar:master"
   setenv -g @bundle "https://github.com/tmux-plugins/tmux-online-status:990737"

   #from non GitHub
   #setenv -g @bundle "git://git.domain.ltd/rep.git"

   #from web
   #setenv -g @bundle "http://domain.ltd/awesome-plugin"
   #setenv -g @bundle "ftp://domain.ltd/yet/another-awesome-plugin"

   #from file system
   #setenv -g @bundle "file://path/to/tmux-plugin"

   # Brief help
   # `prefix + I`       (I as in *I*install) to install configured bundles
   # `prefix + U`       (U as in *U*pdate) to update configured bundles
   # `prefix + alt + u` (u as in *u*install) to remove unused bundles
   # `prefix + alt + l` (l as in *l*ist) to list installed bundles
   ```

3. Install configured bundles:

   ```
   $ tmux source-file ~/.tmux.conf
   ```

Hit `prefix + I` (or run `here tmux free installation script` for CLI lovers)

Installation requires [Git](http://git-scm.com/) and triggers [`git clone`](http://gitref.org/creating/#clone) for each configured repo to `~/.tmux/plugins/`.

## Uninstalling

If by any reason you dislike [Tundle](https://github.com/chilicuil/tundle) you can uninstall it by removing the top tundle directory:

   ```
   $ rm -rf ~/.tmux/plugins/tundle
   ```

## Getting plugins

Common plugins are available in the following repositories:

* [tundle-plugins](https://github.com/chilicuil/tundle-plugins)
* [tmux-plugins](https://github.com/tmux-plugins), you may require up to date tmux and bash versions

## Inspiration and ideas from

* [tpm](https://github.com/tmux-plugins/tpm)
* [vundle](https://github.com/gmarik/vundle)
* [shundle](https://github.com/chilicuil/shundle)

## Also

* tundle was developed against tmux 1.6 and dash 0.5 on Linux
* tundle will try to run in as many platforms & shells as possible
* tundle tries to be as [KISS](http://en.wikipedia.org/wiki/KISS_principle) as possible

## TODO:
[Tundle](https://github.com/chilicuil/tundle/) is a work in progress, any ideas and patches are appreciated.

* better coverage tests
* improve install|update visualization
* parallel installation process
* make it rock!
