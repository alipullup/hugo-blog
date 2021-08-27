---
title: "What I Learned 2021-08-09"
date: 2021-08-09
tags: ["what-i-learned"]
draft: false
---

- Paper summary of [Recurring opinions or productive improvements—what agile teams actually discuss in retrospectives](https://link.springer.com/article/10.1007/s10664-016-9464-2)
	- Retrospectives frequently discuss tools, resources, schedules, but no action is taken
	- Software testing tools were rarely discussed in a positive fashion
	- Overall, I'm not sure what to take away from this - more reflection is needed
- The book titled [The Leprechauns of Software Engineering](https://leanpub.com/leprechauns) seems interesting. However the associated [blog](https://leprechauns-book.tumblr.com/) doesn't load for me. 
- Paper summary of [Selecting among Weibull, Log-normal, and Gamma distributions](https://www4.stat.ncsu.edu/~boos/library/mimeo.archive/ISMS__1609.pdf)
	- Use "selection" statistics calculated from the data - location (mean) known, scale and shape unknown
	- [Type I censored](https://en.wikipedia.org/wiki/Censoring_(statistics)) - stop experiment at predetermined time
	- This is before LaTeX - math rendering is hard to understand.
	- Conclusion: use R with [fitdistrplus](https://cran.r-project.org/web/packages/fitdistrplus/vignettes/paper2JSS.pdf) package! Also see [this stackoverflow question](https://stats.stackexchange.com/questions/132652/how-to-determine-which-distribution-fits-my-data-best).
- Perfectly nonlinear and almost perfectly nonlinear functions
	- [Blog post](https://www.johndcook.com/blog/2020/10/09/perfectly-nonlinear-functions/)
	- [Bent functions](https://en.wikipedia.org/wiki/Bent_function)
- Good way to explain logarithms to kids: a logarithm is [just the number of digits](https://probablydance.com/2021/07/29/a-logarithm-is-just-the-number-of-digits/)
- I routinely use [fzf](https://github.com/junegunn/fzf) and [delta](https://github.com/dandavison/delta) on the command line.
- [broot](https://github.com/Canop/broot) is an alternative to the [tree](https://en.wikipedia.org/wiki/Tree_(command)) command for listing directories.
- [comby](https://github.com/comby-tools/comby) is a tool for structural code search and replace. Seems similar to [semgrep](https://github.com/returntocorp/semgrep). I haven't use either of these tools. 
- The amazing Fabrice Bellard created a [5G NR](https://bellard.org/lte/) implementation!
