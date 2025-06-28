<h1 align="center">
    ATFile
</h1>

<p align="center">
    Store and retrieve files on the <a href="https://atproto.com/">ATmosphere</a> (like <a href="https://bsky.app">Bluesky</a>)<br />
    <em>Written entirely in Bash Shell. No <span title="Deno is pretty cool tho">NodeJS</span> here!</em>
</p>

<hr />

## ✨ Quick Start

```sh
curl -sSL https://zio.sh/atfile/install.sh | bash
echo 'ATFILE_USERNAME="<your-atproto-username>"' > ~/.config/atfile.env # e.g. alice.bsky.social, did:plc:vdjlpwlhbnug4fnjodwr3vzh, did:web:twitter.com
echo 'ATFILE_PASSWORD="<your-atproto-password>"' >> ~/.config/atfile.env
atfile help
```

## 👀 Detailed Usage

### ✅ Requirements

* **OS¹**
    * 🟡 **Linux**: GNU, MinGW and Termux only; musl² not supported
    * 🟢 **macOS**: Compatible with built-in version of Bash (3.2)
    * 🟡 **Windows**: MinGW (Cygwin, Git Bash, MSYS2, etc.) and WSL (see Linux caveats above)
        * This repository **does not** provide a native version for Windows
    * 🟢 __*BSD__: FreeBSD, NetBSD, OpenBSD, and other *BSD's
    * 🟢 **Haiku**: [Yes, really](https://bsky.app/profile/did:plc:kv7sv4lynbv5s6gdhn5r5vcw/post/3lboqznyqgs26)
    * 🔴 **Solaris**: <span title="Don't we all?">Has issues</span>; low priority
* **Bash³:** 3.x or later
* **Packages**
    * [`curl`](https://curl.se)
    * [ExifTool (`exiftool`)](https://exiftool.org) _(optional: set `ATFILE_SKIP_NI_EXIFTOOL=1` to ignore)_
    * [`file`](https://www.darwinsys.com/file) _(only on *BSD, macOS, or Linux)_
    * [GnuPG (`gpg`)](https://gnupg.org) _(optional: needed for `upload-crypt`, `fetch-crypt`)_
    * [`jq`](https://jqlang.github.io/jq)
    * [MediaInfo (`mediainfo`)](https://mediaarea.net/en/MediaInfo) _(optional: set `ATFILE_SKIP_NI_MEDIAINFO=1` to ignore)_
    * `md5sum` _(optional: set `ATFILE_SKIP_NI_MD5SUM=1` to ignore)_
        * Both GNU and BusyBox versions supported
    * [`websocat`](https://github.com/vi/websocat) _(optional: needed for `stream`)_
* **ATProto account**
  *  Both [Bluesky PBC-operated](https://bsky.social) and self-hosted accounts supported
      * If you're using a `bsky.network` (`@*.bsky.social`) account,  limit the amount of files you upload to Bluesky PBC's servers. Heed the copyright warning: **do not upload copyrighted files**
      * `did:web` accounts supported!
    * Confirmed to work on [Bluesky PDS](https://github.com/bluesky-social/pds) and [millipds](https://github.com/DavidBuchanan314/millipds)
      * Other PDSs remain untested, but if they implement standard `com.atproto.*` endpoints, there should be no reason these won't work
      * Filesize limits cannot be automatically detected. By default, this is 100MB
          * To change this on Bluesky PDS, set `PDS_BLOB_UPLOAD_LIMIT=<bytes>`
          * If the PDS is running behind Cloudflare, the Free plan imposes a 100MB upload limit
          * This tool, nor setting a higher filesize limit, **does not workaround [video upload limits on Bluesky](https://bsky.social/about/blog/09-11-2024-video).** Videos are served via a [CDN](https://video.bsky.app), and adding larger videos to post records yields errors
  
### ⬇️ Downloading & Installing

There are three ways of installing ATFile. Either:

#### Automatic ("`curl|bash`")

```
curl -sSL https://zio.sh/atfile/install.sh | bash
```

This will automatically fetch the latest version of ATFile and install it in an appropriate location, as well as creating a blank configuration file. Once downloaded and installed, the locations used will be output. They are as follows:

* __Linux/Windows/*BSD/Solaris__
  * Install: `$HOME/.local/bin/atfile`
    * As `sudo`/`root`: `/usr/local/bin/atfile`
  * Config: `$HOME/.config/atfile.env`
* **macOS**
  * Install: `$HOME/.local/bin/atfile`
    * As `sudo`/`root`: `/usr/local/bin/atfile`
  * Config: `$HOME/Library/Application Support/atfile.env`
* **Haiku**
  * Install: `/boot/system/non-packaged/bin/atfile`
  * Config: `$HOME/config/settings/atfile.env`
    * `$HOME` is **always** `/home` on Haiku

If `$XDG_CONFIG_HOME` is set, this will overwrite the config directory (e.g. setting `XDG_CONFIG_HOME=$HOME/.local/share/atfile` will result in the config being stored at `$HOME/.local/share/atfile/atfile.env`). Custom config paths are supported, but set after-the-fact &mdash; see **Manually** below.

#### Manually

To install manually, see [tags on @zio.sh/atfile](https://tangled.sh/@zio.sh/atfile/tags), and download the required version under **Artifacts**. This can be stored and run from anywhere (and is identical to the version `curl|bash` fetched &mdash; this installed version can also be moved to custom locations at whim).

Don't forget to mark as executable with `chmod +x atfile.sh`. It's also a good idea to remove the version from the filename, as ATFile can update itself (with `atfile update`) and will overwrite the file (this functionality can be disabled with `ATFILE_DISABLE_UPDATER=1`).

Config locations are identical to those above (see **Automatic ("`curl|bash`")** above). To use a custom path, set `$ATFILE_PATH_CONF`. Variables can also be used (and overridden) with exports &mdash; see **`atfile help` ➔ Environment Variables** for more.

#### Repository

If you've pulled this repository, you can also use ATFile by simply calling `./atfile.sh` &mdash; it functions just as a regular compiled version of ATFile, including reading from the same config file. Debug messages are turned on by default: disable these by setting `ATFILE_DEBUG=0`.

To compile, run `./atfile.sh build`. The built version will be available at `./bin/atfile-<version>[+git.<hash>].sh`.

**Using a development version against your ATProto account could potentially inadvertently damage records.**

### Using

See `atfile help`.

## 🏗️ Building

_(Todo)_

## ⌨️ Contributing

Development mainly takes place on [Tangled](https://tangled.sh/@zio.sh/tangled), with [GitHub](https://github.com/ziodotsh/tangled) acting as a mirror. If possible, please use Tangled for your contributions: since it is powered by ATProto, you can log in using your Bluesky account.

When submitting Pull Requests, **target the `dev` branch**: `main` is the current stable production version, and PRs will be rejected targeting this branch.

## 🤝 Acknowledgements

* **Paul Frazee** &mdash; [🦋 @pfrazee.com](https://bsky.app/profile/did:plc:ragtjsm2j2vknwkz3zp4oxrd)<br /><a href="https://bsky.app/profile/did:plc:ragtjsm2j2vknwkz3zp4oxrd/post/3l63zzvthqj2o">His kind words</a>
* **Laurens Hof** &mdash; [🦋 @laurenshof.online](https://bsky.app/profile/did:plc:mdjhvva6vlrswsj26cftjttd)<br />Featuring ATFile on [The Fediverse Report](https://fediversereport.com): _["Last Week in the ATmosphere – Oct 2024 week 4"](https://fediversereport.com/last-week-in-the-atmosphere-oct-2024-week-4/)_
* **Samir** &mdash; [🐙 @bdotsamir](https://github.com/bdotsamir)<br />Testing, and diagnosing problems with, support for macOS (`macos`)
* **Astra** &mdash; [🦋 @astra.blue](https://bsky.app/profile/did:plc:ejy6lkhb72rxvkk57tnrmpjl)<br />[Various PRs](https://github.com/ziodotsh/atfile/pulls?q=is%3Apr+author%3Aastravexton); testing, and diagnosing problems with, support for MinGW (`linux-mingw`) and Termux (`linux-termux`).
* _(Forgot about you? [You know what to do](https://tangled.sh/@zio.sh/atfile/pulls/new))_

---

* **¹** You can bypass OS detection in one of two ways:
    * Set `ATFILE_SKIP_UNSUPPORTED_OS=1`<br />Be careful! There's a reason some OSes are not supported
    * Set `ATFILE_FORCE_OS=<os>`<br />This overrides the OS detected. Possible values: `bsd`, `haiku`, `linux`, `linux-mingw`, `linux-musl`, `linux-termux`, `macos`, and `solaris`.
* **²** musl-powered distros do not use GNU/glibc packages, and have problems currently
    * Known musl distros: Alpine, Chimera, Dragora, Gentoo (musl), Morpheus, OpenWrt, postmarketOS, Sabotage, Void
    * Bypassing OS detection (see ¹) will work, but dates will not be handled correctly
* **³** As long as you have Bash installed, running from another shell will not be problematic ([`#!/usr/bin/env bash`](https://tangled.sh/@zio.sh/atfile/blob/main/atfile-install.sh#L1) forces Bash)
