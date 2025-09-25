<h1 align="center">
    ATFile
</h1>

<p align="center">
    Store and retrieve files on the <a href="https://atproto.com/">ATmosphere</a> (like <a href="https://bsky.app">Bluesky</a> or <a href="https://tngl.sh">Tangled</a>)<br />
    <em>Written entirely in Bash Shell. No <span title="Deno is pretty cool tho">NodeJS</span> here!</em>
</p>

<hr />

## ✨ Quick Start

```sh
curl -sSL https://zio.sh/atfile.sh | bash
echo 'ATFILE_USERNAME="<your-atproto-username>"' > ~/.config/atfile.env # e.g. alice.bsky.social, did:plc:wshs7t2adsemcrrd4snkeqli, did:web:zio.sh
echo 'ATFILE_PASSWORD="<your-atproto-password>"' >> ~/.config/atfile.env
atfile help
```

## 👀 Detailed Usage

### ✅ Requirements

* **OS¹**
    * 🟡 **Linux**: GNU, MinGW and Termux only; musl² not supported
    * 🟢 **macOS**: Compatible with built-in version of Bash (3.2)
    * 🔴 **Windows**: No native version available
      * Run with MinGW (Cygwin, Git Bash, MSYS2, etc.) or WSL (see Linux caveats above)
    * 🟢 __*BSD__: FreeBSD, NetBSD, OpenBSD, and other *BSD's
    * 🟢 **Haiku**: [Yes, really](https://bsky.app/profile/did:plc:kv7sv4lynbv5s6gdhn5r5vcw/post/3lboqznyqgs26)
    * 🔴 **Solaris**: <span title="Don't we all?">Has issues</span>; low priority
    * 🔴 **SerenityOS**: Untested
* **Bash³:** 3.x or later
* **Packages**
    * [`curl`](https://curl.se)
    * [ExifTool (`exiftool`)](https://exiftool.org) _(optional: set `ATFILE_DISABLE_NI_EXIFTOOL=1` to ignore)_
    * [`file`](https://www.darwinsys.com/file) _(only on *BSD, macOS, or Linux)_
    * [GnuPG (`gpg`)](https://gnupg.org) _(optional: needed for `upload-crypt`, `fetch-crypt`)_
    * [`jq`](https://jqlang.github.io/jq)
    * [MediaInfo (`mediainfo`)](https://mediaarea.net/en/MediaInfo) _(optional: set `ATFILE_DISABLE_NI_MEDIAINFO=1` to ignore)_
    * `md5sum` _(optional: set `ATFILE_DISABLE_NI_MD5SUM=1` to ignore)_
        * Both GNU and BusyBox versions supported
    * [`websocat`](https://github.com/vi/websocat) _(optional: needed for `stream`)_
* **ATProto account**
    * Limit the amount of files you upload, and avoid copyrighted files, if using a managed PDS<br /><em>(e.g. [Blacksky](https://pds.blacksky.app), [Bluesky](https://bsky.social), [Spark](https://pds.sprk.so), [Tangled](https://tngl.sh), or any other independent PDS you don't own)</eM>
    * Supports accounts with `did:plc` and `did:web` identities
    * Supports PDSs running [Bluesky PDS](https://github.com/bluesky-social/pds) and [millipds](https://github.com/DavidBuchanan314/millipds)
      * Other PDSs remain untested, but if they implement standard `com.atproto.*` endpoints, there should be no reason these won't work
      * Filesize limits cannot be automatically detected. By default, this is 100MB
          * To change this on Bluesky PDS, set `PDS_BLOB_UPLOAD_LIMIT=<bytes>`
          * If the PDS is running behind Cloudflare, the Free plan imposes a 100MB upload limit
          * This tool, nor setting a higher filesize limit, **does not workaround [video upload limits on Bluesky](https://bsky.social/about/blog/09-11-2024-video).** Videos are served via a [CDN](https://video.bsky.app), and adding larger videos to post records yields errors

### ⬇️ Downloading & Installing

There are three ways of installing ATFile. Either:

#### Automatic ("`curl|bash`")

```
curl -sSL https://zio.sh/atfile.sh | bash
```

This will automatically fetch the latest version of ATFile and install it in an appropriate location, as well as creating a blank configuration file. Once downloaded and installed, the locations used will be output. They are as follows:

* __Linux/*BSD/Solaris/SerenityOS__
  * Install: `$HOME/.local/bin/atfile`
    * As `sudo`/`root`: `/usr/local/bin/atfile`
  * Config: `$HOME/.config/atfile.env`, **or** `$XDG_CONFIG_HOME/atfile.env` (if set)
* **macOS**
  * Install: `$HOME/.local/bin/atfile`
    * As `sudo`/`root`: `/usr/local/bin/atfile`
  * Config: `$HOME/Library/Application Support/atfile.env`
* **Haiku**
  * Install: `/boot/system/non-packaged/bin/atfile`
  * Config: `$HOME/config/settings/atfile.env`

#### Manually

See [tags on @zio.sh/atfile](https://tangled.org/@zio.sh/atfile/tags), and download the required version under **Artifacts** &mdash; this can be stored and run from anywhere (and is identical to the version `curl|bash` fetched. Consider renaming to `atfile.sh` (as ATFile can update itself, making a fixed version in the filename nonsensical), and mark as executable (with `chmod +x atfile.sh`).

Config locations are identical to those above (see **Automatic ("`curl|bash`")** above).

#### Repository

If you've pulled this repository, you can also use ATFile by simply calling `./atfile.sh` &mdash; it functions just as a regular compiled version of ATFile, including reading from the same config file. Debug messages are turned on by default: disable these by setting `ATFILE_DEBUG=0`.

Config locations are identical to those above (see **Automatic ("`curl|bash`")** above).

**Using a development version against your ATProto account could potentially inadvertently damage records.**

### ⌨️ Using

See `atfile help`.

## 🏗️ Building

To compile, run `./atfile.sh build`. The built version will be available at `./bin/atfile-<version>[+git.<hash>].sh`.

### Environment variables

Various environment variables can be exported to control various aspects of the development version. These are as follows:

* `ATFILE_DEVEL_ENABLE_PIPING` <em>&lt;int&gt; (default: `0`)</em><br />Allow piping (useful to test installation) _(e.g. `cat ./atfile.sh | bash`)_
* `ATFILE_DEVEL_ENABLE_PUBLISH` <em>&lt;int&gt; (default: `0`)</em><br />Publish build to ATProto repository (to allow for updating) as the last step when running `release`. Several requirements must be fulfilled to succeed:
  * `ATFILE_DEVEL_DIST_USERNAME` must be set<br />By default, this is set to `$did` in `atfile.sh` (see **🏗️ Building ➔ Meta**). Ideally, you should not set this variable as updates in the built version will not be fetched from the correct place
  * `ATFILE_DEVEL_DIST_PASSWORD` must be set
  * No tests should return an **Error** (**Warning** is acceptable)
  * Git commit must be <a href="https://git-scm.com/docs/git-tag">tagged</a>

Other `ATFILE_DEVEL_` environment variables are visible in the codebase, but these are computed internally and cannot be set/modified.

### Directives

Various build directives can be set in files to control various aspects of the development version. These are set with `# atfile-devel=` directive at the top of the file, using commas to separate values. These are as follows:

* `ignore-build`<br />Do not include file in the final compiled build

### Meta

Various meta variables can be set to be available in the final compiled build (usually found in `help`). These are found in `atfile.sh` under `# Meta`. These variables are as follows:

* `author` <em>&lt;string&gt;</em><br />Copyright author
* `did` <em>&lt;did&gt;</em><br />DID of copyright author. Also used as the source for published builds, unless `ATFILE_DEVEL_DIST_USERNAME` is set (see **🏗️ Building ➔ Environment variables**)
* `repo` <em>&lt;uri&gt;</em><br />Repository URL of source code
* `version` <em>&lt;string&gt;</em><br />Version in the format of `<major>.<minor>[.<patch>]`. **Not following this format will cause unintended issues.** Git hashes (`+git.abc1234`) are added automatically during build when a <a href="https://git-scm.com/docs/git-tag">git tag</a> is **not** applied to the current commit
* `year` <em>&lt;int&gt;</em><br />Copyright year

## ⌨️ Contributing

Development takes place on [Tangled (@zio.sh/atfile)](https://tangled.sh/@zio.sh/atfile), with [GitHub (ziodotsh/atfile)](https://github.com/ziodotsh/atfile) acting as a mirror. Use Tangled for your contributions, for both <a href="https://tangled.org/@zio.sh/atfile/issues">Issues</a> and <a href="https://tangled.org/@zio.sh/atfile/pulls">Pulls</a>. As Tangled is powered by ATProto, you already have an account (unsure? Try <a href="https://tangled.org/login">logging in with your Bluesky handle</a>).

When submitting Pulls, **target the `dev` branch**: `main` is the current stable production version, and Pulls will be rejected targeting this branch.

## 🤝 Acknowledgements

* **Paul Frazee** &mdash; [🦋 @pfrazee.com](https://bsky.app/profile/did:plc:ragtjsm2j2vknwkz3zp4oxrd)<br /><a href="https://bsky.app/profile/did:plc:ragtjsm2j2vknwkz3zp4oxrd/post/3l63zzvthqj2o">His kind words</a>
* **Laurens Hof** &mdash; [🦋 @laurenshof.online](https://bsky.app/profile/did:plc:mdjhvva6vlrswsj26cftjttd)<br />Featuring ATFile on [The Fediverse Report](https://fediversereport.com): _["Last Week in the ATmosphere – Oct 2024 week 4"](https://fediversereport.com/last-week-in-the-atmosphere-oct-2024-week-4/)_
* **Samir** &mdash; [🐙 @bdotsamir](https://github.com/bdotsamir)<br />Testing, and diagnosing problems with, support for macOS (`macos`)
* **Astra** &mdash; [🦋 @astra.blue](https://bsky.app/profile/did:plc:ejy6lkhb72rxvkk57tnrmpjl)<br />[Various PRs](https://github.com/ziodotsh/atfile/pulls?q=is%3Apr+author%3Aastravexton); testing, and diagnosing problems with, support for MinGW (`linux-mingw`) and Termux (`linux-termux`)
* _(Forgot about you? [You know what to do](https://tangled.sh/@zio.sh/atfile/pulls/new))_

---

* **¹** You can bypass OS detection in one of two ways:
    * Set `ATFILE_DISABLE_UNSUPPORTED_OS_WARN=1`<br />Be careful! There's a reason some OSes are not supported
    * Set `ATFILE_FORCE_OS=<os>`<br />This overrides the OS detected. Possible values: `bsd`, `haiku`, `linux`, `linux-mingw`, `linux-musl`, `linux-termux`, `macos`, `serenity`, and `solaris`.
* **²** musl-powered distros do not use GNU/glibc packages, and have problems currently
    * Known musl distros: Alpine, Chimera, Dragora, Gentoo (musl), Morpheus, OpenWrt, postmarketOS, Sabotage, Void
    * Bypassing OS detection (see ¹) will cause unintended behavior
* **³** As long as you have Bash installed, running from another shell will not be problematic ([`#!/usr/bin/env bash`](https://tangled.sh/@zio.sh/atfile/blob/main/atfile-install.sh#L1) forces Bash)
