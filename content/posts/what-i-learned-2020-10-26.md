---
title: "What I Learned 2020-10-26"
date: 2020-10-26
draft: false
---

- Linux facility [MODULE_SOFTDEP](https://stackoverflow.com/questions/29717761/how-do-i-define-dependency-among-kernel-modules) for adding dependency between modules, even if one doesn't use the symbol from the other
- Linux macros for dealing with [atomic sections of code](https://elixir.bootlin.com/linux/latest/source/include/linux/kernel.h#L258), see [this API page](https://www.kernel.org/doc/html/latest/driver-api/basics.html)
  - `non_block_start()` / `non_block_end()`
  - `might_sleep()` / `cant_sleep()` / `might_sleep_if(cond)`
  - `cant_migrate()`
- Linux has deprecated `in_irq()` / `in_interrupt()` - see [this email](https://lore.kernel.org/dri-devel/20200914204209.256266093@linutronix.de/)
- Use a passed in parameter instead, e.g. `may_sleep`
- Use `lockdep_assert_held(lock)` for checking
- MACSec 802.1AE uses hostapd/wpa_supplicant to do L2 security! (AES-GCM)
- Linux can use bonding or [team](https://github.com/jpirko/libteam/wiki/Bonding-vs.-Team-features), which seems to be a newer implementation
- Linux kernel documentation on [speculative side channel attacks](https://dri.freedesktop.org/docs/drm/staging/speculation.html): `array_index_nospec`