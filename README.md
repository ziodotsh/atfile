<h1 align="center">
    ATFile
</h1>

<p align="center">
    Store and retrieve files on the <a href="https://atproto.com/">ATmosphere</a> (like <a href="https://bsky.app">Bluesky</a>)<br />
    <em>Written entirely in Bash Shell. No <span title="Deno is pretty cool tho">NodeJS</span> here!</em>
</p>

<p align="center">
    <strong>
        <a href="https://github.com/ziodotsh/atfile/releases/latest">⬇️ Get ATFile</a> &nbsp;|&nbsp;
        <a href="https://tangled.sh/@zio.sh/atfile/issues/new">💣 Submit Issue</a> &nbsp;|&nbsp;
        <a href="https://bsky.app/profile/did:web:zio.sh"> 🦋 @zio.sh</a>
    </strong>
</p>

<hr />

## ✨ Quick Start

```sh
curl -sSL https://zio.sh/atfile/install.sh | bash
echo 'ATFILE_USERNAME="<your-atproto-username>"' > ~/.config/atfile.env  # e.g. alice.bsky.social, did:plc:vdjlpwlhbnug4fnjodwr3vzh, did:web:twitter.com
echo 'ATFILE_PASSWORD="<your-atproto-password>"' >> ~/.config/atfile.env
atfile help
```

## 👀 Using

### ✅ Requirements

* **OS¹**
    * 🟡 **Linux**: GNU, MinGW and Termux only; musl² not supported
    * 🟢 **macOS**: Compatible with built-in version of Bash (3.2)
    * 🟡 **Windows**: MinGW (Cygwin, Git Bash, MSYS2, etc.) and WSL (see Linux caveats above)
        * This repository **does not** provide a native version for Windows
    * 🟢 **BSD**: FreeBSD, NetBSD and OpenBSD; other non-detected BSDs should work (see ¹)
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
* **PDS:** [Bluesky PDS](https://github.com/bluesky-social/pds)
    * Other PDSs (such as [millipds](https://github.com/DavidBuchanan314/millipds)) remain untested, but if they implement standard `com.atproto.*` endpoints, there should be no reason these won't work
    * Filesize limits cannot be automatically detected. By default, this is 100MB
        * To change this on Bluesky PDS, set `PDS_BLOB_UPLOAD_LIMIT=<bytes>`
        * If the PDS is running behind Cloudflare, the Free plan imposes a 100MB upload limit
        * This tool, nor setting a higher filesize limit, does not workaround [video upload limits on Bluesky](https://bsky.social/about/blog/09-11-2024-video). Videos are served via a [CDN](https://video.bsky.app), and adding larger videos to post records yields errors on the app
* **ATProto account**
    * `bsky.network` (`@*.bsky.social`) accounts supported
      * If you can, limit the amount of files you upload to Bluesky's servers. It's a miracle this even works with, what's currently, an entirely free service.
      * Heed the copyright warning: **do not upload copyrighted files.**
    * `did:web` accounts supported!

### 🤔 _(Todo)_

_(Todo)_

## 🏗️ Building

_(Todo)_

---

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
    * Set `ATFILE_FORCE_OS=<os>`<br />This overrides the OS detected. Possible values:
       * BSD: `bsd-freebsd`, `bsd-netbsd`, `bsd-openbsd`
       * Linux: `linux`, `linux-mingw`, `linux-musl`, `linux-termux`
       * Other: `haiku`, `macos`, `solaris`
* **²** musl-powered distros do not use GNU/glibc packages, and have problems currently
    * Known musl distros: Alpine, Chimera, Dragora, Gentoo (musl), Morpheus, OpenWrt, postmarketOS, Sabotage, Void
    * Bypassing OS detection (see ¹) will work, but dates will not be handled correctly
* **³** As long as you have Bash installed, running from another shell will not be problematic ([`#!/usr/bin/env bash`](https://tangled.sh/@zio.sh/atfile/blob/main/atfile-install.sh#L1) forces Bash)
