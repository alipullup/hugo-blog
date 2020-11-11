---
title: "Disk Encryption Overview"
date: 2008-09-16
draft: false
---

# Introduction

This document describes disk encryption implemented using a combination of software and FPGA.



```
--Data-->FPGA-->Disks
           |
    Microcontroller
```
</pre>

The data was encrypted using AES, in counter mode, with flexible key width.

For various reasons, we did not use an [authenticated encryption](https://en.wikipedia.org/wiki/Authenticated_encryption) mode.

A FPGA was responsible for encryption, to keep up with the high data rate. Control software running on a microcontroller was responsible for loading up the AES key schedule during bulk streaming operations.

During normal operations, the microcontroller went _through_ the FPGA to access the disks. Software running on the microcontroller was responsible for managing the disks otherwise.

# Encryption Overview

We encrypt all data before writing to disk. There are two reasons for doing this:

1.  Quick erase: destroy all data by destroying the keys.
2.  Secure transport: securely transport the disks by transmitting the keys separately.

We begin by describing how data flows through the system, and then how quick erase and secure transport are implemented.

## Data Flow Models

![Encryption Data Flow](images/encryption_overview_data_flow.png)

## Encryption pseudo-code

This is a simplified way of looking at encryption: a function is given data from a disk, and it encrypts that data and writes it out. In reality, this done in parallel by the FPGA.


```
    Encrypt_Disk_Data (Meta  : Metadata, 
                       Sess  : Session_Info,
                       D     : int, -- disk number
                       Data  : UINT128[])
     --  Depending on Meta.Mode, this will either read a key 
     --  from disk, or read a key from the disk and combine it
     --  with a key from removable storage.
     Key : UINT128 := Get_Disk_Key (Meta, D);
     --  Initialize encryption context using the given key.
     Ctx : Aes_Context_Type := AES_Initialize (Key);
     --  The counter is a 128-bit value that is derived using:
     --  - The disk seed for disk D, which was originally derived 
     --    from the disk serial number.
     --  - The session seed, which is a random 64-bit number, 
     --    chosen session creation.
     Counter := Initialize_Counter (Meta, Sess, D);
     For I = 0 to length (Data) loop
       Increment_Counter (Counter);
       E : UINT128 := AES_Counter_Encrypt (Ctx, Counter, Data[I]);
       Disk_Write (D, I, E);
     End;
```

Where:

* `UINT128` is an unsigned 128-bit quantity.
* `Data` is an array of 128-bit values.
* `Get_Disk_Key`, `AES_Initialize`, `AES_Counter_Encrypt`, `Initialize_Counter`, `Increment_Counter`, and `Disk_Write` are external functions.

# Critical Analysis

A formal security proof is not presented here. However, it is noted that the security of data on disks depends entirely upon:

1.  Disk keys used for encryption. Below we will lay out the threat model we protect against.
2.  Counter value. We’ve taken care to ensure that the counter is globally unique. This is addressed in the section titled `Counter` above.
3.  AES implementation. The FPGA implementation has been tested with known vectors, and also been verified by decrypting the data with a known-good software implementation. We talk some more about this below in `Encryption Primitives Used`.
4.  AES usage. We’re using the well known counter mode for AES. In the section `Counter mode weaknesses` we talk about this some more.

## Threat Model

We assume that the recorder operates in a secure environment. Thus there are no protections against physical attacks.

(REMOVED)

## Encryption Primitives Used

The following encryption primitives are used. We also given some implementation details:

*   **AES(FGPA)**: A hardware (FPGA) implementation of AES is used for encryption of optical data.
*   **AES(C)**: A reference implementation of AES (written in the `C` programming language) is used by the software to encrypt metadata written to disk.
*   **SHA256**: (REMOVED)
*   **SHA256 HMAC**: (REMOVED)
*   **MD5**: (REMOVED)
*   **(REMOVED) RNG**: The (REMOVED) random number generator is used to generate:
    *   The per-disk keys during initial formatting.
    *   The session ID start during initial formatting (XX-bit number, see `Software Entities`).
    *   The session seed during session creation (YY-bit number, see `Software Entities`).

## Counter mode weaknesses

*   **Data integrity**: Counter mode doesn’t provide any message integrity. There is no MAC used, thus it possible to change the data on disk.
*   **Key reuse**: The key is randomly generated, and given a good RNG, the probability of key use is extremely low.
*   **Counter uniqueness**: The counter is chosen to be globally unique. Thus it is very unlikely that the same counter is used for two separate sessions.

## Entropy

Entropy in an embedded environment is a difficult problem. The system may be rebooted frequently and the random bytes may be needed soon after a reboot.

* We can’t rely on network I/O to generate random bytes. The client may be using a crossover cable.
* We don’t get a lot of entropy from disks, as the disks are only used when requested by the user.
* We can’t rely on user interaction to generate random bytes.

(REMOVED)
