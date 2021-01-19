---
title: "What I Learned 2021-01-11"
date: 2021-01-11
tags: ["what-i-learned"]
draft: false
---

- [PTP](https://en.wikipedia.org/wiki/Precision_Time_Protocol) has 1-Step and 2-Step implementations. 
  In PTP 1-Step, the time stamp from the master clock is included in the first *Sync* message.
- PTP transparent clocks adjust the `correctionField` in *Sync* and *Delay_Request* messages
- PTP transparent clock can use the [PTPv2 Reserved](http://wiki.hevs.ch/uit/index.php5/Standards/Ethernet_PTP/frames)
  field (offset 16, size 4 bytes) to store a timestamp on ingress.
- PTP has a Peer to Peer (P2P) mode, as well as the normal End to End (E2E) mode
- The Peer to Peer mode uses *PDelay_Request*, and *PDelay_Response* messages in 1-Step mode,
  and additional *PDelay_Response_Follow_Up* message in 2-Step mode.
- The Peer to Peer mode calculates the path delay between two nodes (usually directly connected).
  The benefit of P2P mode is that a 1-Step transparent clock can set the `correctionField` to contain
  the RX path delay, transit delay, and TX path delay, thus a *Delay_Request* message isn't necessary.
- Useful PTP resources:
	- [Slide deck by NetTimeLogic](https://www.nettimelogic.com/resources/PTP%20Basics.pdf)
	- [Agilent PTP Tutorial](https://www.nist.gov/system/files/documents/el/isd/ieee/tutorial-basic.pdf)
	- [NIST IEEE 15888 Power Profile Test Plan](https://www.nist.gov/publications/1588-power-profile-test-plan)
	- Not sure how to get other information for free on internet. Most of what I used via IEEE, and non-free.
- There is apparently a *vibrant* community around hacking anti-cheating software!
	- Apparently games use hardware identifiers ("HWID") to uniquely identify a PC - [list of hardware identifiers](https://www.unknowncheats.me/forum/anti-cheat-bypass/333662-methods-retrieving-unique-identifiers-hwids-pc.html)
		- Most of these seem to be serial numbers: disk, NIC, motherboard, monitor, graphics card, etc.
		- There are various APIs for retrieving the serial numbers (e.g. registry read vs. direct query)
		- Other things found on a PC: file system / volume id, file times
		- MACs of neighboring devices (e.g. gateway / router)
	- To bypass anti-cheat users rely on buggy/faulty drivers to access memory - [list of drivers allowing memory write](https://www.unknowncheats.me/forum/anti-cheat-bypass/334557-vulnerable-driver-megathread.html)
	- To bypass anti-cheat some users will [use a PCIe device to write to system memory](https://github.com/ufrisk/pcileech) - but [games can fight back](https://blog.esea.net/esea-hardware-cheats/amp/)

## IEEE 1588/PTP transparent clock residency time correction

Here's what I gathered from reading the standard.

|Message Type|Correction E2E|Correction P2P|
|--- |--- |--- |
|Sync|Yes - 11.5.2.1|Yes - 11.5.2.1|
|Follow_Up|No - 11.5.2.1|No - 11.5.2.1|
|Delay_Req|Yes - 11.5.3.2|Discard - 10.3|
|Delay_Resp|No - 11.5.3.2|Discard - 10.3|
|Pdelay_Req|Allowed, not required - 11.5.4.1|Yes - 11.5.4.2|
|Pdelay_Resp|No - 11.5.4.2|No - 11.5.4.2|
|Pdelay_Resp_Follow_up|No - 11.5.4.2|No - 11.5.4.2|

NIST has a [power profile test plan](https://www.nist.gov/publications/1588-power-profile-test-plan). 
This can serve as a starting point for testing IEEE 1588.

The standard does not address VLANs (e.g. should we respond to `Pdelay_Req` coming in without a VLAN tag?).
The PTP profiles are also quite tricky: e.g. C37.238-2011 vs. C37.238-2017 changed quite a lot (all mention of VLANs
was removed in the newer standard!).