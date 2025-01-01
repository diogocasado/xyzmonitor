
# xyzmonitor

A simple tool to monitor Linux server machines.

## Usage

Run for help:

```
xyzmonitor -h
```

Check /etc/xyzmonitor/default.conf with parameters.

To install the systemd timer service:

```
xyzmonitor -i 15
```

## Features

* Zero dependencies, besides what's usually shipped with distros
* Shell script based, Bash 4.4+ compatible
* Modular, every stat has its separate bash script
* Customizable, simply drop a .bash file to extend
* Self-documented, the idea is to make it as transparent/safe as possible
* Templatable output
* Outputs to Discord, Slack and Google Chat

## Why you should trust this project?

You should not. Just like with any other software.
I encourage you to take a look at the code yourself and decide if it's safe to install in your server.

## Compatibility

The following Linux distributions have been tested with, possibly compatible with many others.

 * Debian | ✓ 12 | 
 * Ubuntu | ✓ 22.04 LTS | ✓ 24.04 LTS |

## How it works

xyzmonitor is basically a collection of small scripts that update environment variables while iterating through phases.

Modules are loaded from:

* /usr/local/etc/xyzmonitor/xyz.d/*.bash
* /etc/xyzmonitor/xyz.d/*.bash

When loading a module, it calls:

```
[filename]_invoke "init"
[filename]_init
```

Modules should register their parameters with:

xyzcfg "MODULE_VAR" "User configurable parameter description"
xyzenv "MODULE_VAR" "Module output variable description"
xyzfun "MODULE_FUN" "Description of a function provided by the module"

Notes on conventions:

* All modules should prefix global variables with its filename and make it uppercase. E.g.: net.bash will prefix as NET_VAR.
* Modules callbacks are also prefixed with filename but all lowercase.
* Module functions should be uppercase if generating output (like being referenced from template), or lowercase if just doing something.

Configuration files are loaded from:

* /etc/xyzmonitor/conf.d/*.conf

Each configuration file is loaded and executed individually. This allows multiple outputs to be generated.

Relevant phases are:

* pre: check whatever is necessary
* set: collect environment data
* write: write data output (to external services as well)
* post: update things that need updating when successful 

At each phase the module's callbacks will be invoked according to:

```
[filename]_invoke "phase"
[filename]_[phase]
```

## Packaging Debian/Ubuntu 

After cloning the repo, run under the project directory:

```
dpkg-buildpackage -b
```

It should generate a `xyzmonitor_x.y.z-n_all.deb` file under the parent directory.

The packaged can be installed using:

```bash
gdebi -n package.deb
```

## Want to contribute?

Great! Send pull requests.

Thanks for using.

