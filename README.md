# Project Everest

A verified, efficient TLS implementation, in C.

See [the website](https://project-everest.github.io)!

## The `everest` script

The role of this script is to:
- check that your development environment is sane;
- fetch known good revisions of miTLS, F\*, KreMLin, Vale and HACL
- run the voodoo series of commands that will lead to a successful build
- run whatever is known to be working tests.

For developers, this script also allows you to:
- record a new known set of good revisions.

This script is used heavily by [continuous
integration](https://github.com/project-everest/everest-ci) to pull, build &
test project everest.

## Pre-setup (Windows)

If you don't have a 64-bit Cygwin installed already, please download and run the
Cygwin 64-bit installer (along with Cygwin git), then launch this script from a
Cygwin prompt.

Install the production scons for Windows from this [share](http://scons.org/pages/download.html). After install, ensure that scons.bat is in the system path. 

## Usage

See `./everest help`

## Contributing

We welcome pull requests to this script, using the usual fork project + pull
request GitHub model. For members of Everest, Sreekanth Kannepali has the keys
to the everest project on GitHub and can grant write permissions on this
repository so that you can develop your feature in a branch directly. Jonathan
watches pull requests and will provide timely feedback unless he's on vacations
or in another timezone.
