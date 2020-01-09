# Aria2 static builds for GNU/Linux

### Downloads

[On releases page](https://github.com/P3TERX/aria2-builder/releases)

### Install

* Automatic script:
```shell
curl -fsSL git.io/aria2c.sh | bash
```

* Manual installation:
```shell
tar zxvf aria2-[version]-static-linux-[arch].tar.gz
sudo mv aria2c /usr/local/bin
```

### Uninstall

```
sudo rm -f /usr/local/bin/aria2c
```

### Used external libraries

* http://www.zlib.net/
* http://expat.sourceforge.net/
* http://c-ares.haxx.se/
* http://www.sqlite.org/
* http://www.openssl.org/
* http://www.libssh2.org/

### External links

* [aria2 homepage](https://aria2.github.io/)
* [aria2 documentation](https://aria2.github.io/manual/en/html/)
* [aria2 source code (Github)](https://github.com/aria2/aria2)
