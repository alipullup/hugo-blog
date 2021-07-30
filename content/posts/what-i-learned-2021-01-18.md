---
title: "What I Learned 2021-01-18"
date: 2021-01-18
tags: ["what-i-learned"]
draft: false
---

- [bladeRF-wiphy](https://www.nuand.com/bladeRF-wiphy/) is a complete 802.11 implementation,
  including the VHDL! This would've been a great read before I started my last job.
- Spent a bunch more time updating PTP 1588 transparent clock code to deal with VLANs
	- What happens to trunk port vs. access
	- What happens with VLANs - port based VLAN vs. native
	- What happens if the domain doesn't match
	- Which counters are helpful in debugging
	- ... and so on ...


## IEEE 1588/PTP delay request response

Online discussions of PTP/1588 give the formula:  `delay = [(t2 - t1) + (t4 - t3)]/2`.

However, I find this confusing: I think it is better written as `[(t4 - t1) - (t3 - t2)]/2`.

![PTP delay request response](/image/ptp-delay-request-response.png)

1. The total exchange using timestamps from master: `t4 - t1 = (receivedTimestamp of Delay_Resp - originalTimestamp of Sync)`
2. Subtract from this, the time from the slave: `t3 - t2`, which should leave `t_ms + t_sm` (time from master to slave, and time from slave to master)
3. Assuming these two are equivalent to `t_transit`, we are left with `2 * t_transit`, thus the division by 2 leaves us the single direction path delay.


```
meanPathDelay =
	[ (receivedTimestamp of Delay_Resp - originalTimestamp of Sync) 
	- (t3 - t2) 
	- correctionField of Sync 
	- correctionField of Delay_Resp ] / 2
```

## How to give good feedback on written assignments

These are from [Coursera's Giving Feedback](https://coursera.community/study-tips-6/giving-feedback-116) post.

There is a tortured [backronym](https://en.wikipedia.org/wiki/Backronym) pressed into service: F.A.S.T 

- Feed-forward: Explain *why* feedback will help: focus on goals and future
- Actionable: Specific, actionable information
- Succinct: Focus only on the most important things
- Timely

I think it's useful to have a checklist:

- If applicable: introduce your background, and say something positive
- If applicable: refer to any industry specific guidelines (criteria used to evaluate)
- Does the task accomplish what it set out to do?
- If there are technical requirements: focus on these, example:
	- Format: title, front-matter, bibliography, footnotes etc.
	- Citations, evidence
- If applicable: is enough background provided for a reader to understand the task?
- If applicable: are links to further reading, or previous work, provided?
- If applicable: are their tables / charts / figures? are they legible?
- If applicable: are confidence intervals given for point estimates?
- If applicable: point to flaws in reasoning
	- If applicable: logical fallacies, or false reasoning
	- If applicable: contradictory or overlooked aspects
- Provide concrete solutions to major problems found
- Obvious: punctuation, typos, spelling, word form, etc.
