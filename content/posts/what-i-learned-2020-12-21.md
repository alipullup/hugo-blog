---
title: "What I Learned 2020-12-21"
date: 2020-12-21
tags: ["what-i-learned"]
draft: false
---

- If I ever work for a company that produces silicon that must run on Linux (again),
  I would highly recommend nightly performance tests that use the newest kernel.
  Since I started reading the kernel mailing lists, I see how many performance regressions are
  introduced, and only reported by users.
  For example, see [this bug](https://bugzilla.kernel.org/show_bug.cgi?id=209913)
- I've lost a lot of trust in the standard bodies. After the
  [Dual EC DRBG backdoor](https://en.wikipedia.org/wiki/Dual_EC_DRBG), I ran into
  the controversy around the [WPA3 Dragonfly Handshake](https://sarwiki.informatik.hu-berlin.de/WPA3_Dragonfly_Handshake).
  The [mailing list threads](https://mailarchive.ietf.org/arch/msg/tls/M9Wrwd0iDEAk-PztgmrqIPEXvao/)
  are unprofessional, and sad to read. [Summary by arstechnica](https://arstechnica.com/information-technology/2013/12/critics-nsa-agent-co-chairing-key-crypto-standards-body-should-be-removed/).
  I first learned about this "drama" from [this Hacker News](https://news.ycombinator.com/item?id=6942145) post.
- There is a surprising amount of memory errors (e.g. double free, memory leak) in the Linux kernel.
  I wonder what workarounds exists? Or perhaps kernel drivers should be written in [Rust](https://www.rust-lang.org/)?
- Command to receive data over network, write to disk and calculate SHA1 checksum:
  `sudo -E bash -c 'nc -l -p 12345 | pv | tee /dev/sda >(sha1sum) >/dev/null'`
- The same as above, except sending via SSH
  `ssh user@host "sudo -E bash -c 'tee /dev/sda >(sha1sum) >/dev/null'" < localfile`
- Windows has no decent `netcat` that isn't flagged by my virus scanner. Ended up writing a simple Python script. 
- I had forgotten that I can exclude search terms, e.g. `-w3schools` e.g. `html img -w3schools`, see [Google Search Help](https://support.google.com/websearch/answer/2466433?hl=en)
