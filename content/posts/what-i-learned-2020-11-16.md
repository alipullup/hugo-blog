---
title: "What I Learned 2020-11-16"
date: 2020-11-16
tags: ["what-i-learned"]
draft: false
---

- Linux [device tree](https://elinux.org/Device_Tree_Usage) 
  [documentation can be written in YAML](https://lwn.net/Articles/771621/).
- Linux has [hot and cold pages](https://lwn.net/Articles/14768/) - for data a device will
  DMA to, you'd want to use a cold pages (using `GPF_COLD` allocation flag) - 
  also see [this link](https://www.kernel.org/doc/gorman/html/understand/understand009.html)
- Freescale [DPAA1 platforms will be getting support for XDP](https://lore.kernel.org/netdev/AM6PR04MB39764B6CAEEA27863F52A419ECE30@AM6PR04MB3976.eurprd04.prod.outlook.com/)!
- 16-bit sign extension bug bites again: `(ntohs(value) << 16)` will sign-extend when assigned to a 64-bit value
- A [return trampoline](https://support.google.com/faqs/answer/7625886)
  ("retpoline") may be enabled in GCC using `-mindirect-branch=thunk-extern` for the Linux kernel.
  Mitigation on Windows can be verified using [this PowerShell script](https://github.com/Microsoft/SpeculationControl).
  I had forgotten about this until I ran into it today.
- In the critical path every cycle matters: touching an additional byte could mean another dirty cache-line. 
- Instead of using `#ifdef CONFIG_xxx` in the Linux kernel, use `IS_ENABLED(CONFIG_xxx)` -
  [see definition](https://elixir.bootlin.com/linux/latest/source/include/linux/kconfig.h#L73)
- Aside: the above lets one easily search the code and find outdated features.
- Can I have a generic empty function callback function? e.g. `void generic_callback(void)` which is
  used as a stub for concrete `void actual_callback(int)` or such? It depends on calling conventions
  and who cleans the parameters. When [caller cleans up](https://en.wikipedia.org/wiki/X86_calling_conventions#Caller_clean-up)
  yes, otherwise no. Another concern is global optimization and
  [devirtualization](https://stackoverflow.com/questions/7046739/lto-devirtualization-and-virtual-tables).
- Windows file system takes `wchar_t` but really treats it like `uint16_t` (ill-formed UTF-16 allowed).
  [See this link](https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file?redirectedfrom=MSDN#maxpath).
  As I understand it, it's not UCS-2, as UCS-2 is fixed width. 
  [This link](https://simonsapin.github.io/wtf-8/#ill-formed-utf-16) calls it "WTF-16".
  From the same source, I learned of the [WTF-8](https://simonsapin.github.io/wtf-8/) encoding, which
  is "a hack intended to be used internally in self-contained systems with components that need to 
  potentially ill-formed UTF-16 for legacy reasons".
  It seems like this causes its own set of issues.
- [Windows's paths are complicated](https://googleprojectzero.blogspot.com/2016/02/the-definitive-guide-on-win32-to-nt.html).
  Apparently the function `RtlDosPathNameToRelativeNtPathName_U` converts from various formats to the "NT" format.
  Also see the following pages by Microsoft: 
  [Security Considerations: International Features](https://docs.microsoft.com/en-us/windows/win32/intl/security-considerations--international-features)
  , and 
  [File path formats on Windows systems](https://docs.microsoft.com/en-us/dotnet/standard/io/file-path-formats#canonicalizing-separators).
- Every recent Windows version has a .NET compiler installed! `c:\Windows\Microsoft.NET\Framework\v4.0.30319>csc.exe`
- As look at bug reports, it's shocking how common certain errors are. Most of the reported errors are in the error path.
  I mostly agree with [CWE Top 25](http://cwe.mitre.org/top25/archive/2020/2020_cwe_top25.html), except
  I would put use of uninitialized memory or forgetting to unlock / lock higher. I suppose it depends on
  the programming language. I'm using C these days. In C++, using RAII and `std::lock_guard` would get
  rid of many errors. 
- Jay Carlson has an [amazing embedded Linux](https://jaycarlson.net/embedded-linux/) page!
