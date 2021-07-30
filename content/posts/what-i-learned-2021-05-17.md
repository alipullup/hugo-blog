---
title: "What I Learned 2021-05-17"
date: 2021-05-17
tags: ["what-i-learned"]
draft: false
---

- Another way of saying "real time system", is to state that the "tempo" (time) is a critical factor.
- Summary of the paper [Communication Breakdown: Analyzing CPU Usage in Commercial Web Workloads](https://users.cs.duke.edu/~alvy/papers/ispass04.pdf) from 2004.
	- Static vs. dynamic web loads use CPU differently (duh!)
	- Depending on workload, scheduling overhead (if many threads are spawned for short lived clients), networking overhead (TCP/IP and driver) dominate. 
	- For longer lived connections, the scheduling overhead is no longer the bottleneck, instead it's the web server.
	- For dynamic content, the bottleneck is the application server.
- From the paper [Rules of Thumb in Data Engineering](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/ms_tr_99_100_rules_of_thumb_in_data_engineering.pdf) from 1999
	- "A system needs 8 MIPS/MBpsIO, but the instruction rate and IO rate must be measured on the relevant workload"
	- Let's assume a CPI of 3, then 
- From [OpenVPN Access Server system requirements](https://openvpn.net/vpn-server-resources/openvpn-access-server-system-requirements/)
	- "on a modern CPU with an AES-NI chipset you need approximately 12MHz for each megabit per second (Mbps) transferred in one direction"
	- "a modern 4-core system at 3GHz would count as 12,000MHz, which equates to approximately 1,000Mbps maximum throughput"
- From the [Netgate Hardware Sizing Guide](https://docs.netgate.com/pfsense/en/latest/hardware/size.html)
	- ARM Cortex A53, 1.2 GHz (2), TCP 656 Mbit/s, IMIX 190 Mbit/s
	- ARMv7 Cortex-A9, 1.6 GHz (2), TCP 2.44 Gbit/s, IMIX 1.04 Gbit/s, 
	- Intel Atom C3558, 2.2 GHz (4), TCP 6.81 Gbit/s, IMIX 1.85 Gbit/s
- From Netgate Hardware Sizing Guide, throughput at 500 Kpps (no hardware model specified)
	- 64 bytes: 244 Mbps
	- 500 bytes: 1.87 Gbps
	- 1000 bytes: 3.73 Gbps
- From the Netgate Hardware Sizing Guide, IPsec throughput by hardware model:
	- ARM Cortex A53, 1.2 GHz (2), IPSec: AES-128-CBC + SHA1, TCP 1460B: 74.2 Mbit/s, IMIX: 46 Mbit/s
	- ARMv7 Cortex-A9, 1.6 GHz (2), IPSec: AES-128-CBC + SHA1, TCP 1460B: 453 Mbit/s, IMIX: 108 Mbit/s
	- Intel Atom C3558, 2.2 GHz (4), IPSec: AES-128-GCM, TCP 1460B: 1.28 Gbit/s, IMIX: 385 Mbit/s
- The [Go language template system](https://golang.org/pkg/html/template/) parses HTML, CSS, and 
  automatically does [proper escaping](https://rawgit.com/mikesamuel/sanitized-jquery-templates/trunk/safetemplate.html#problem_definition)
