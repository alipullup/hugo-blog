---
title: "U-Boot Notes"
date: 2013-06-13
draft: false
---

# Introduction

The following document contains some notes I took while debugging U-Boot board initialization for the MIPS and ARM platforms.

On one platform we had issues with the QSPI flash. On another platform we had memory issues. Yet another platform had issues with calling certain functions before some hardware was initialized.

* * *

# Startup

The system jumps to the `_start` routine. This is mapped to a known address in Flash.

![U-Boot Startup](images/uboot-startup-startS.png)

The `board_init_f` function calls various other functions:

![Function board_init_f](images/uboot-board_init_f.png)

# DTS File overview

A Device Tree Source (dts) file is compiled by the Device Tree Compiler (dtc) into a Device Tree Blob (dtb).

The dts file describes resources found on the chip, including:

*   Chip selects, and timings
*   I2C devices
*   etc.

![U-Boot DTS Overview](images/u-boot-dts--overview.png)

## Location

The =.dts= file is found in

(REMOVED)

## Format

The dts file consists of nodes, with properties and children.

*   Text strings (null terminated) are represented with double quotes:
    *   `string-property = "a string"`
*   ‘Cells’ are 32 bit unsigned integers delimited by angle brackets:
    *   `cell-property = <0xbeef 123 0xabcd1234>`
*   Binary data is delimited with square brackets:
    *   `binary-property = [0x01 0x23 0x45 0x67]`
*   Data of differing representations can be concatenated together using a comma:
    *   `mixed-property = "a string", [0x01 0x23 0x45 0x67], <0x12345678>`
*   Commas are also used to create lists of strings:
    *   `string-list = "red fish", "blue fish"`

## Conventions

*   Node may have an _address_: `name@0 { ... }`
*   Names can be up to 31 characters in length
*   Siblings must use different names, or different addresses:
    *   `flash0{} flash1{}`
    *   `flash@0{} flash@1{}`

## The `compatible` property

The `compatible` property is a list of strings:

1.  The first string specifies the exact device
2.  The following strings represent other devices that the device is _compatible_ with

## Addressing (=reg=, =#address-cells=, =#size-cells=)

Each addressable device gets a =reg= which is a list in the form

`reg = <addr1 len1 [addr2 len2] ...>`

The special variables `#address-cells` and `#size-cells` in the parent node are used to state how many cells are in each field.

## Resources

*   [Device Tree Usage](http://www.devicetree.org/Device_Tree_Usage)