---
title: "My experience with micro-services"
date: 2016-09-16
draft: false
---


# Overview

I wrote the following after my experience in architecting a system around [microservices](https://en.wikipedia.org/wiki/Microservices).

The implementation did not go as smoothly as expected, and I wanted to reflect on what went wrong.

To channel Jamie Z:

> Some people, when faced with a problem think “I know, I’ll use microservices.” Now they have 2^N problems.

I think we used microservices for the wrong reasons:

*   If you’re worried about future extensibility, then use a well defined interface to a library.
*   If you’re worried about the scheduling/interaction between different people or groups, then use coordinated sprints or mock implementations.

Our application:

*   Used to be monolithic
*   It was split into different programs because different people worked on different pieces
*   Each service was a layer: our hope was to replace each layer with something new, as needed

Old architecture:

```
Application ---> Resource X
    |----------> Resource Y
    +----------> Resource Z
```

New architecture:

```
Application ---> Resource X
    |
Application Y -> Resource Y
    |
Application Z -> Resource Z
```


Good:

*   Work & deploy independently
*   Isolate errors
*   Test independently
*   Well-defined external interface

Bad:

*   Needed some sort of supervisor process when one application crashed
*   Needed backward/forward compatibility checks
*   More error scenarios (Application Y and Application Z could fail independently)
*   Hard to diagnose errors
*   Hard to diagnose performance issues
    *   Have to look through multiple log files and correlate log file entries
    *   Have to correlate multiple counters