# Aria2 Pro Core

[![LICENSE](https://img.shields.io/github/license/P3TERX/Aria2-Pro-Core?style=flat-square)](https://github.com/P3TERX/Aria2-Pro-Core/blob/master/LICENSE)
![GitHub All Releases](https://img.shields.io/github/downloads/P3TERX/Aria2-Pro-Core/total?label=Downlaods&style=flat-square&color=red)
[![GitHub Stars](https://img.shields.io/github/stars/P3TERX/Aria2-Pro-Core.svg?style=flat-square&label=Stars&logo=github)](https://github.com/P3TERX/Aria2-Pro-Core/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/P3TERX/Aria2-Pro-Core.svg?style=flat-square&label=Forks&logo=github)](https://github.com/P3TERX/Aria2-Pro-Core/fork)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/P3TERX/Aria2-Pro-Core/Aria2%20Builder?label=Actions&logo=github&style=flat-square)

Aria2 static binaries for GNU/Linux with some powerful feature patches.

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/P3TERX/Aria2-Pro-Core?style=for-the-badge)](https://github.com/P3TERX/Aria2-Pro-Core/releases/latest)

## Changes

* option `max-connection-per-server`: change maximum value to `∞`
* option `min-split-size`: change minimum value to `1K`
* option `piece-length`: change minimum value to `1K`
* download: retry on slow speed (`lowest-speed-limit`) and connection close
* download: add option `retry-on-400` to retry on http 400 bad request, which only effective if `retry-wait` > 0
* download: add option `retry-on-403` to retry on http 403 forbidden, which only effective if `retry-wait` > 0
* download: add option `retry-on-406` to retry on http 406 not acceptable, which only effective if `retry-wait` > 0
* download: add option `retry-on-unknown` to retry on unknown status code, which only effective if `retry-wait` > 0
* http: add option `http-want-digest` to choose whether to send the generated `Want-Digest` HTTP header or not (Not send by default)

## Installing

### Automatic script
```shell
curl -fsSL git.io/aria2c.sh | bash
```

### Manual installation
```shell
wget https://github.com/P3TERX/Aria2-Pro-Core/releases/download/[version]/aria2-[version]-static-linux-[arch].tar.gz
tar zxvf aria2-[version]-static-linux-[arch].tar.gz
sudo mv aria2c /usr/local/bin
```

### Uninstall
```shell
sudo rm -f /usr/local/bin/aria2c
```

## Building

### with script

Download script, execute script.
> **TIPS:** In today's containerization of everything, this is not recommended.
```shell
git clone https://github.com/P3TERX/Aria2-Pro-Core
cd Aria2-Pro-Core
bash aria2-gnu-linux-build.sh
```

### with docker

> **TIPS:** Docker minimum version 19.03, you can also use [buildx](https://github.com/docker/buildx).

Build Aria2 for current architecture platforms.
```shell
DOCKER_BUILDKIT=1 docker build \
    -o type=local,dest=. \
    github.com/P3TERX/Aria2-Pro-Core
```

**`dest`** can define the output directory. If there are no changes, there will be an archive file in the current directory when the build is completed.
```
$ ls -l 
-rw-r--r-- 1 p3terx p3terx 3744106 Jan 17 20:24 aria2-1.35.0-static-linux-amd64.tar.gz
```

Cross build Aria2 for other platforms, e.g.:
```
DOCKER_BUILDKIT=1 docker build \
    --build-arg BUILDER_IMAGE=ubuntu:14.04 \
    --build-arg BUILD_SCRIPT=aria2-gnu-linux-cross-build-armhf.sh \
    -o type=local,dest=. \
    github.com/P3TERX/Aria2-Pro-Core
```
> **`BUILDER_IMAGE`** variable defines the system image used for the build. In general, platforms other than `armhf` don't require it.
> **`BUILD_SCRIPT`** variable defines the script used for the cross build.

## External links

### Aria2

* [Aria2 homepage](https://aria2.github.io/)
* [Aria2 documentation](https://aria2.github.io/manual/en/html/)
* [Aria2 source code (Github)](https://github.com/aria2/aria2)

### Used external libraries

* [zlib](http://www.zlib.net/)
* [Expat](https://libexpat.github.io/)
* [c-ares](http://c-ares.haxx.se/)
* [SQLite](http://www.sqlite.org/)
* [OpenSSL](http://www.openssl.org/)
* [libssh2](http://www.libssh2.org/)
* [jemalloc](http://jemalloc.net/)

### Credits

* [q3aql/aria2-static-builds](https://github.com/q3aql/aria2-static-builds)
* [myfreeer/aria2-build-msys2](https://github.com/myfreeer/aria2-build-msys2)

## Licence

[![GPLv3](https://www.gnu.org/graphics/gplv3-127x51.png)](https://github.com/P3TERX/Aria2-Pro-Core/blob/master/LICENSE)
