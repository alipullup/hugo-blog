---
title: "What I Learned 2020-11-09"
date: 2020-11-11
draft: false
---


- Left shift of uint16_t promotes it to an int, and will sign-extend it if assigning a 64-bit value, e.g. code like:
`uint64_t x; uint16_t y=0x8000; x=y<<16;`
will assign `x` to `ffffffff80000000`
- TCP syn-cookies have lots of problems! Just
  [saw a fix](https://lore.kernel.org/netdev/CANn89iL2ADYh9n95ZMntGZ8vFmU2OzVJ0YKTpq8J+3A1Mh1Asw@mail.gmail.com/T/#t)
  and Google search found
  [various issues](https://access.redhat.com/solutions/30453)
  that have been
  [found](https://blog.cloudflare.com/syn-packet-handling-in-the-wild/) over time.
  Not clear if the syn cookie enabling is per-port or global.
- Qualcomm has an [IP Accelerator](https://lwn.net/Articles/770924/) built into some SoC. It seems like it has hardware perform NAT, routing, firewall.
- Intel [DPDK has support for LS1046](https://doc.dpdk.org/guides/platform/dpaa.html) -
  has support for cryptographic and hardware acceleration
- [PRP](https://en.wikipedia.org/wiki/Parallel_Redundancy_Protocol) is a protocol for redundancy - there exist a [commercial implementation](https://support.industry.siemens.com/cs/pd/1093505?pdti=pi&lc=en-ao&dl=en) for Windows
- Windows has a tunnel driver called [Wintun](https://www.wintun.net/) (GPL v2)- originally designed for WireGuard - perhaps it could be used for any custom protocol?
- Rant by Linus [against zero-copy](https://yarchive.net/comp/linux/zero-copy.html): the effort needed to lock pages is high, think of sending data from kernel buffers, instead of zero-copy from user buffers. Or, sending read-only data (e.g. file from disk) directly through kernel using "sendfile()".
- Linux has [ptr_ring](https://github.com/torvalds/linux/blob/master/include/linux/ptr_ring.h) header file for a circular ring of buffers. Interesting observations:
  - Each function for adding/removing data has a variant for IRQ/bottom-half/other
  - The index ("head" and "tail") is cache-aligned (on SMP systems only)
  - The "consume" function has a "batch" variant (to amortize the spinlock overhead I assume)
- [USB4](https://en.wikipedia.org/wiki/USB4) allows tunneling USB 3.2, DisplayPort 1.4, PCI Express(!)
- [RPC100](https://github.com/curtiszimmerman/rcp100) is a great little Linux router distribution
