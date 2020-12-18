---
title: "What I Learned 2020-12-07"
date: 2020-12-07
tags: ["what-i-learned"]
draft: false
---

- [ACM SIGPLAN Empirical Evaluation Guidelines](https://www.sigplan.org/Resources/EmpiricalEvaluation/)
	- Make benchmarks reproducible
	- Use full applications, not micro-benchmarks ("kernels")
	- Run many trials (5 isn't enough)
	- Report data distribution (histogram, along with summary statistics)
- If I had to run a benchmark, what would I do?
	- Ensure system is quiet, see [this link](https://easyperf.net/blog/2019/08/02/Perf-measurement-environment-on-Linux), and [this link](https://llvm.org/docs/Benchmarking.html)
		- Disable CPU frequency scaling / power management
		- Disable hyper threading
		- Disable ASLR
	- Test on different systems
		- Different CPU
		- Different OS
		- Different compilers
	- For micro-benchmarks use a standard library, like [Google's Benchmark](https://github.com/google/benchmark)
	- I wish there was an updated version of [stabilizer](https://github.com/ccurtsinger/stabilizer), or a similar tool that could run the same program loaded at different offsets, so I would figure out the sensitivity 
- [Scapy](https://scapy.net/) to the rescue! I needed to build a raw UDP frame and a colleague was sending packets, using 
  [tcpdump](https://en.wikipedia.org/wiki/Tcpdump) to capture when he could have done the following: 
  `Ether(dst='FF:FF:FF:FF:FF:FF', src='01:02:03:04:05:06') /IP(dst='255.255.255.255', src='192.168.1.1', id=5683, flags='DF') / UDP(sport=1234, dport=1234) / Raw('test\n')`
- Foo