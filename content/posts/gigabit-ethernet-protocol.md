---
title: "Gigabit Ethernet Protocol"
date: 2006-01-24
draft: false
---

# Introduction

This document gives a brief overview of a UDP based data transfer protocol. The protocol was implemented on a Xilinx FPGA, and a portable C client running on a Windows or Linux machine.

*   Bandwidth was managed by specifying an inter-packet gap (IPG) interval. The FPGA would send a data packet, wait the IPG amount, then send the next packet.
*   Round-trip time (RTT) was determined using a timestamp embedded int he packets.
*   Loss was detected using sequence numbers, and managed using NAK packets.

Packets arriving to the Xilinx FPGA are diverted to a control processor for handling,. We are not using a soft microprocessor in the FPGA. The FPGA is responsible for interfacing with the data store and sending data packets to the client.


```
--Message--> FPGA <---> Microprocessor
              |
           Data Store
```


We faced various challenged, but broadly we had to worry about:

1.  Ensuring the control process had enough of a TCP/IP implementation to function on a company’s LAN.
2.  Making sure the control process could respond fast enough to client requests.
3.  Coding up the portable C client to run in user-space, while responding quickly to changing network conditions.

Of the above, (3) was the most difficult. Each client’s network is slightly different, and there are various things we have to manage:

1.  Unpredictable disk I/O. We have to know how much data is queued up by the operating system, by the driver, and in the disk queues.
2.  Unpredictable process scheduling. We decided to create a user-space client (not running as a kernel driver). In hindsight, it would’ve been better to invest the resources in creating some sort of driver. As it stands, the operating system may decide to run something else for 10 milliseconds.
3.  Unpredictable network conditions. We ended up suggesting the use of [hardware-based flow control](https://en.wikipedia.org/wiki/Ethernet_flow_control) to deal with various sources of packet loss.

Overall, the most difficult customer questions were never “it doesn’t work”, they were always “why is it sometimes slow?”.

To answer the “why is it slow” question, we ended up:

*   Adding tunable logging to the portable C client
*   Adding a tunable set of counters to the portable C client
*   Noticing “anomalies” in the client and logging them (e.g. sudden jump in RTT or loss)
*   Creating various “dry run” and “simulated data” modes to test individual pieces of the client:
    *   A mode to benchmark and test the disk bandwidth. Some times clients were running on a 5 year old laptop connected to a USB drive, when we recommended the latest blade server.
    *   A mode to benchmark and test the network bandwidth. Some cheap switches are terrible, and do bad things to packets.

# Message Format

There are various messages: some go from the FPGA to the C client, others go from the C client to the FPGA. All messages share a common header.

## General Header

Format of the general header:

|Field|Length (bytes)|Description|
|--- |--- |--- |
|Version|1|Identifies a protocol version. The first version of the protocol will be 0.|
|Type|1|Type of the message.  Currently we have the following types of messages defined:

DATA(0) – This message contains data.

ACK(1) – This is an acknowledgment message.

NAK(2) – This is a negative acknowledgment message.  
OPEN(3) – This is an open message.

CLOSE(4) – This is a close message.|
|Reserved|2|Reserved bytes for future use.  Should be set to zero (0) when transmitted.|
|||The rest of the message depends on the _Type_ field.|

## Data Message

The DATA message is sent by the **server to the client**. It contains a single block of data.

|Field|Length (bytes)|Description|
|--- |--- |--- |

|Estimated RTT (RTT)|4|The current estimated RTT in microseconds.|
|Block Number (BN)|2|Contains a block number.  The data in the message belongs to this block.|
|Time Stamp (TS)|4|Time stamp sent by server to client.  This will be echoed back by the client in the ACK.|
|Data (D)|Block_Size|Data for the block (BN). Note that this is a protocol constant.|


## ACK Message

The ACK message is sent by the **client to the server**. It tells the server how many blocks the client is ready to receive, and what blocks the client has received thus far.


|Field|Length (bytes)|Description|
|--- |--- |--- |
|Last In-order Block Received (LBR)|2|This identifies the last in-order block received. The server assumes that every block coming before this has been received by the client.|
|Time Stamp (TS)|4|Time stamp of the DATA packet this ACK references.|
|Window Size (WS)|2|The number of _DATA_ messages the receiver is ready to receive.|
|Reserved|4|Reserved bytes for future use.  Should be set to zero (0) when transmitted.|


## NAK Message

The NAK message is sent by the **client to the server**. It tells the server if any block has been lost.


|Field|Length (bytes)|Description|
|--- |--- |--- |
|Blocks Lost|2|How many blocks are lost.|
|Block Numbers||A list of all the block numbers that are lost.  The length of this in bytes will be 2 * Blocks Lost (each block is represented using two bytes).|
|End Marker|2|This special block number marks the end of the the packet and will be send to **End_Block_Marker**.|


# Sender Algorithm

Omitted

# Receiver Algorithm

Omitted

# Protocol atop UDP

When the protocol is implemented on top of IP/UDP, the full PDU will look something like:

|Protocol|Field|Offset|Length (bytes)|
|--- |--- |--- |--- |
|IP|Version + IHL|0|1|
|IP|TOS|1|1|
|IP|Total Length|2|2|
|IP|Identification|4|2|
|IP|Flags + Fragment Offset|6|2|
|IP|Time To Live|8|1|
|IP|Protocol (17, UDP)|9|1|
|IP|Header Checksum|10|2|
|IP|Source IP Address|12|4|
|IP|Dest. IP Address|16|4|
|IP|Options and Padding|20|0|
|UDP|Source Port|20|2|
|UDP|Destination Port|22|2|
|UDP|Length|24|2|
|UDP|Checksum|26|2|
|LR|Version|28|1|
|LR|Type|29|1|
|LR|Reserved|30|2|
|**Type** specific data.||||


This adds up to a total of 32 + 10 bytes for a DATA packet, not including the data.

# Protocol Performance

Assuming that we’re carrying the protocol atop UDP, and that:


```
Ethernet Overhead   ← 8 + 14 → 22 bytes 
IP + UDP Overhead   ← 20 + 8 → 28 bytes
Protocol Header Size    ← 4 + 2 + 4 → 10 bytes
Protocol Data Size  ← Block_Size → 1440
Ethernet FCS        ← 4 bytes
Ethernet IPG        ← 12 bytes

Total Overhead  ← 22 + 28 + 10 + 4 + 12 → 76 bytes
Total Bytes     ← Total Overhead + Block_Size
            → 76 + 1440 → 1516

Bandwidth       ← 10^9 bits / second
```

The efficiency will be:


```(Data sent in time T) / (Total data sent in time T)```

Assuming we can send

```(8 * Max_Window_Size * Block_Size)```

bits in time T, the actual amount on the wire is


```(8 * Max_Window_Size * Total Bytes)```

and note that we’ll have to wait one round-time trip (RTT) to for the remote to ACK these bytes, which we can throw in our equation as (RTT * BandWidth) bits.


```(8*MaxWindowSize*BlockSize)/(8*MaxWindowSize*TotalBytes+RTT*BandWidth)```


## Calculations

Here are some calculations given various window sizes, block sizes, and round-trip times

(Omitted)

## Real Time Requirements

To maintain optimal throughput, the server has to send ACK requests every so often. Specifically, the server should be able to send an ACK packet every `Max_Window_Size / 2` packets. Here are some numbers for a given window size and block size:

|Window Size|Block Size|Time to React|
|--- |--- |--- |
|1024|1440|0.0059|
|1024|8920|0.0365|
|2048|8920|0.0731|


The time given about is for 1000 Mbit/s speeds.

## IPG Calculations

Setting the inter-packet gap between packets can be used to scale the bandwidth.

Bandwidth is the amount of data sent in some period of time. The normal time taken (without any IPG) to send data is simply:


```DataSize / BandWidth```

By adding an inter packet gap, the time taken increases by IPG seconds. Thus, the achieved bandwidth is:


```AchievedBandWidth =  DataSize / (DataSize / BandWidth + IPG)```

Solving for IPG, we get the equation:


```-DataSize(AchievedBandWidth-BandWidth)/(AchievedBandWidth*BandWidth)```



Here are some calculations about required IPG values to achieve a given bandwidth:
|Data Size|Bandwidth|Achieved|IPG (us)|
|--- |--- |--- |--- |
|1500|1000|1000|0|
|1500|1000|800|3|
|1500|1000|400|18|


## Packet Loss

(Omitted)