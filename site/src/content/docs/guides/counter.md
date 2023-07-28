---
section: Shipping
title: Shipping Reference Generator
description: A description of our shipment reference generator
tags:
  - mermaid
---


Within Viya, the counter functionality can be used to maintain number ranges and retrieve references from the range.<br><br>
The retrieved value is a reference and not a number per definition as the number can be formatted into a string.

The next chapters describe the possible interactions with the counter. At this moment the only method to interact is via an API. It is intended to provide a user interface for counter interaction in the near future.

## Create range
To create a range, following items are to be provided: 
- The reference of the counter 
  - The reference of the range is used to define the use case of the range. The available use cases of each definition is to be found table below.

|Reference type|Description
|---|---|
|Tracking number|Tracking number used for a carrier, mostly provided by the carrier.|
|EDI filename|Number used in the filename for EDI shipment files transmitted to the carrier via SFTP|

- Threshold
  - This is optional, if provided it will determine the threshold for the counter for the provided reference
  - If available references goes below the threshold: an alert is triggered
  - The alert is currently sent to an email address maintained in the shipping application code (in a configuration Yaml).
    - *It is expected to make this configurable by the users in the near future.*
  - **MUST** be an integer
- The start and end number 
  - The numbers **MUST** always be integers and can not contain any letters or special characters.
- The format of the range
  - Should be defined as a [custom numeric](https://learn.microsoft.com/en-us/dotnet/standard/base-types/custom-numeric-format-strings) format. The format defines how the string of the range is generated.
  - Example custom numeric format use cases:
  
|Format|Range start|Range End|Prefix|Suffix|Length|Example value
|--|--|--|--|--|--|--|
|VN{0:D6}|500000|999999|VN||8|VN500001
|GE{0:D8}NL|80914750|80922749|GE|NL|12|GE80914751NL
|{0:D7}|12345|99999|||7|0012346

<br>


## Delete range
The deletion of the range can be done on two levels which are described below
 - Delete the counter itself: 
    - This option allows to delete the all the number ranges that are setup for a specific reference type.
- Delete the range of a sequence
   - This options allows to delete only a sequence of the number range that is setup for a specific reference type. 

## Get status of the range
This allows to see what the status is of the range. <br>
The status shows per reference:<br>
* The start and end number are of the range.
* The number that will used next in the range
* The format that is used for the counter
* The status of the range, where there are 3 options
  * Active - This range is currently in use
  * Future - This range is not yet in use but will be used once the active range runs out and this is next in sequence
  * Depleted* - The range is completely used and can not be used anymore.

*) Once a range is depleted, it is not yet deleted. The range has to be deleted seperatly via the delete endpoint to have it  completely deleted.

