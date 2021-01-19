---
title: "What I Learned 2021-01-04"
date: 2021-01-04
tags: ["what-i-learned"]
draft: false
---

- There exists IEE [802.11bb](https://en.wikipedia.org/wiki/Li-Fi)
  which is a light based protocol (aka "Li-Fi").
- [BER-TLV and SIMPLE-TLV](https://stackoverflow.com/questions/18853800/simple-tlv-vs-ber-tlv)
  can be used to create a Type/Length/Value mapping. What's interesting:
  - Type or Length can be variable length (SIMPLE-TLV fixes tag from 1..254 and length from 1..3 bytes)
  - Variable length encoding as follows:
	- If value <= 0x7F: output value
	- If value <= 0xFF: output 0x81, followed by value
	- If value <= 0xFFFF: output 0x82, followed by big-endian value
  - Type has bit 5 (0x20) set if it's a container. A container must contain other TLVs.
  - Type may have bit 7:6 (mask 0xC0) set to 1 to indicate application specific
  - Wikipedia has a [registry of types](https://en.wikipedia.org/wiki/X.690#Types)
- EEVblog has a nice overview of [thermal resistance](https://www.youtube.com/watch?v=8ruFVmxf0zs)
  Some notes I took:
  - Thermal resistance °C/W - with a RθJ-C (junction to case) of 10, if I dissipated 1W, then at 20°C ambient, the junction temperature would be 30°C
  - The Rθ given in the data sheet for heat sinks are ideal - add 30% or so due to spreading resistance
  - Air flow over heat sink is the main factor 
- The Wikipedia page on [thermal management](https://en.wikipedia.org/wiki/Thermal_management_(electronics))
  has more information, including a link to Chapter 15 PDF of "Heat and Mass Transfer: Fundamentals and Applications".
