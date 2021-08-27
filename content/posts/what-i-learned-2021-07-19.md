---
title: "What I Learned 2021-07-19"
date: 2021-07-19
tags: ["what-i-learned"]
draft: false
---

- Learned about Maven, [Bouncy Castle Crypto APIs](https://www.bouncycastle.org/), [CMS](https://en.wikipedia.org/wiki/Cryptographic_Message_Syntax), [RFC5652](https://datatracker.ietf.org/doc/html/rfc5652), and [RFC3161](https://www.ietf.org/rfc/rfc3161.txt) timestamps. Firmware signature for the win!
- [smidump](https://linux.die.net/man/1/smidump) can pretty print MIBs
- [Cisco audit logs](https://www.cisco.com/en/US/docs/ios/security/configuration/guide/sec_rout_audit_logs_support_TSD_Island_of_Content_Chapter.html) includes hashes. At first I thought this would be a [linear hash chain](https://en.wikipedia.org/wiki/Hash_chain) for  non-repudiation, e.g. to ensure no one tampers with the logs. It turns out to be simpler: they periodically hash the output of `show running-config`, the file system etc. and put this in the audit logs. 
- IANA has a [large list of protocol registries](https://www.iana.org/protocols) with assigned numbers. Interesting read.