---
title: "What I Learned 2021-07-05"
date: 2021-07-05
tags: ["what-i-learned"]
draft: false
---

- Some links for firmware signing
	- [OpenPOWER sb-signing-utils](https://github.com/open-power/sb-signing-utils)
	- [OpenBSD Signify](https://github.com/aperezdc/signify)
	- Open source [Tripwire](https://github.com/Tripwire/tripwire-open-source)
	- NetBSD's [mtree](https://github.com/archiecobbs/nmtree)
- Microsoft's file checksum integrity verifier doesn't have a Linux port
- [Best practices for firmware code signing](https://www.opencompute.org/documents/ibm-white-paper-best-practices-for-firmware-code-signing) by Open Compute
- Intel has the [eSPI protocol](https://www.intel.com/content/dam/support/us/en/documents/software/chipset-software/327432-004_espi_base_specification_rev1.0_cb.pdf) for tunneling I2C etc.
- How to [fractionally encode bits](https://hbfs.wordpress.com/2011/11/01/fractional-bits-part-i/)
	- Basically given some numbers n_0 ... n_k all less than N, we can encode them as: n_0 + n_1 * N^1 + n_2 * N^2 + ... + n_k * N^k
	- When decoding we can use division, and modulo to retrieve n_0 ... n_k
- [Finite state entropy](http://fastcompression.blogspot.com/2013/12/finite-state-entropy-new-breed-of.html)
- Must disable VLAN support in Windows for my VirtualBox VM to send/receive VLAN tagged frames
- [VirtualBox incantation](https://superuser.com/questions/641933/how-to-get-virtualbox-vms-to-use-hosts-dns) needed to resolve corporate LAN addresses
