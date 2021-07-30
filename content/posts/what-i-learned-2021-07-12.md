---
title: "What I Learned 2021-07-12"
date: 2021-07-12
tags: ["what-i-learned"]
draft: false
---

- The Microsoft [Bcrypt* functions are for ephemeral keys, while Ncrypt* are for persistent keys](https://stackoverflow.com/questions/40596395/cng-when-to-use-bcrypt-vs-ncrypt-family-of-functions)
- Sample [C++ source code to sign using Windows Ncrypt* API](https://github.com/microsoft/Windows-classic-samples/blob/27ffb0811ca761741502feaefdb591aebf592193/Samples/Security/SignHashWithPersistedKeys/cpp/SignHashWithPersistedKeys.cpp)
- Code from [OpenVPN using Microsoft Ncrypt* API](https://github.com/OpenVPN/openvpn/blob/51d85a9d287f44c373eaa514c6a52e1078c27c43/src/openvpn/cryptoapi.c)
- Stanford [CS166](http://web.stanford.edu/class/cs166/) has great presentations on
	- [Approximate Membership Queries](http://web.stanford.edu/class/cs166/lectures/12/Slides12.pdf): Bloom filter, XOR filter
	- [Hashing and Sketching](http://web.stanford.edu/class/cs166/lectures/08/Slides08.pdf)
- [VRF](https://www.cisco.com/c/en/us/td/docs/voice_ip_comm/cucme/vrf/design/guide/vrfDesignGuide.html), [Virtual Routing and Forwarding](https://en.wikipedia.org/wiki/Virtual_routing_and_forwarding)
- [Software bill of materials](https://en.wikipedia.org/wiki/Software_bill_of_materials)
- [Appropriate Software Security Control Types for Third Party Service and Product Providers](http://docs.ismgcorp.com/files/external/WP_FSISAC_Third_Party_Software_Security_Working_Group.pdf)
	- Mentioned the "vBSIMM" framework, which seems to be a consulting framework for making money
	- However, the graphic associated with it was useful:
	- Requirements and design: Security architecture review, threat modeling, risk control
	- Development: Code review, Open source security validation, binary static scan (?)
	- Q/A: "Dynamic scan" (?)
	- Production: Penetration testing, Web application firewall, Configuration management, Incident response
- [WLAN Manager PowerShell script](https://github.com/jchristens/Install-WLANManager) to disable Wifi when connected to Ethernet
- [Microsoft 365 network connectivity test](https://connectivity.office.com/) for diagnosing Teams jitter
- [RealTerm](https://sourceforge.net/projects/realterm/) serial terminal emulator