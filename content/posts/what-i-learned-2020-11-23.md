---
title: "What I Learned 2020-11-23"
date: 2020-11-23
tags: ["what-i-learned"]
draft: false
---

- [USB UserBenchmark](https://usb.userbenchmark.com/) website has benchmarks of USB flash drives.
- Linux supports "WWAN" (LTE) modems - I have no idea how these work! There is the
  USB [cdc_mbim](https://www.kernel.org/doc/Documentation/networking/cdc_mbim.txt) driver,
  but now there's talk of adding a "WWAN" device. There are command line programs such as
  [qmicli](https://www.freedesktop.org/software/libqmi/man/latest/qmicli.1.html),
  [mmcli](https://www.freedesktop.org/software/ModemManager/man/1.0.0/mmcli.8.html), and
  [mbicli](https://www.freedesktop.org/software/libmbim/man/latest/mbimcli.1.html).
- [TuxMake](https://gitlab.com/Linaro/tuxmake) provides "portable and repeatable Linux kernel builds".
  There is also [TuxBuild](https://gitlab.com/Linaro/tuxbuild) which provides Linux kernel builds
  as a service. Both tools are by Linaro.
- The manual page for [git log](https://git-scm.com/docs/git-log) is quite ... rich.
- [GPL requires attribution](https://www.gnu.org/licenses/gpl-3.0.html#section5).
  If the product has a user interface, it should display an "appropriate" notice.
  Documentation should also include such a notice.
  For example, [NETGEAR uses this notice](https://www.downloads.netgear.com/files/GPLnotice.pdf).
- [drgn](https://github.com/osandov/drgn) is a programmable debugger (Python), mainly for use with the Linux kernel.
  It is an alternative to the [crash](https://github.com/crash-utility/crash) utility.
- `netdev_dbg()` is preferred to `pr_debug()` (or `printk()`) for network devices.
- `__has_attribute(x)` is supported on gcc >= 5, clang >= 2.9 and icc >= 17.
  Good way to check whether a compiler supports a feature.
- Adding custom data to Linux SKB can be done using
  [SKB extensions](https://www.youtube.com/watch?v=3xelUe_mTko) (see [API link](https://01.org/linuxgraphics/gfx-docs/drm/networking/kapi.html#c.skb_ext)).
  Extension memory is released when the SKB is free'd, and cloning is handled. 
  Motivated by the limited `cb` size, and difficulty in adding extensions. When SKB extensions make sense:
  - Data is related to skb/packet aggregate, and
  - Data should be free'd when skb is free'd, and
  - Data is not going to be needed in the normal case (udp, tcp, ...), and
  - No actions needed on clone/free (e.g. callbacks)
- Alternatives to adding data in SKB extensions:
  - Store data in shared info `struct skb_shared_info` block (unchanged on clone), or
  - Add second control buffer block at end of `struct sk_buff`, or
  - Add a control block at end of `struct skb_buff_fclones` (only works for outgoing SKBs allocated via `alloc_skb_fclone`)

  