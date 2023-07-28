---
section: Shipping
title: Business Rules 
description: Business rules

---

The shipping process can be fine-tuned based on the different requirements of each carrier and changing external factors.
Once the shipping API is established, using the business rules, minor changes in the process flow can be accomplished without the need of adjusting the integration with the WMS/ERP/etc...

## Implementation

At its core, the [RuleEngine](https://github.com/shipitsmarter/ruleengine) is used to define condition(s) for modifying objects.

The shipping process currently allows to apply business rules at the following steps in the process:

- At shipment creation: `This step is not yet implemented`
- At booking the shipment:
  - `PreBooking` -> used to enrich the shipment before it is booked;
    - At this moment the carrier does not yet have to be known, then the business rules should have an outcome that will set the carrier.
    - The object being enriched is the core shipment: that is the version directly collected from the database.
    - This enrichment contains customizations that are carrier specific like: account number(s), specific sender / collection addresses, defaulting specific service options.
    - The enriched information is **stored** against the shipment if the booking step is successful.
  - `CarrierBooking` -> used to enrich the communication model for booking with the carrier. 
    - At this moment the carrier is known.
    - The object that is being enriched is the shipment AFTER the `PreBooking` enrichment.
    - This enrichment typically contains what integration method is used to book with the carrier, the metadata belonging to that integration method like API keys/credentials/notification settings,pickup window information etc...
    - The enriched information is **NOT stored** against the shipment, only used to provide all information required for the booking process.
      - One exception: The Planned Pickup Window is stored against the shipment when stitch booking is successful. See [Planned pickup window  / Opening/closing times](#planned-pickup-window---openingclosing-times)


> _NOTE_:
> At this moment the rules can only be maintained by adjusting a YAML file inside the shipping application. In the future this is expected to be possible through an API & User interface by the customer.


## Planned pickup window  / Opening/closing times 

The shipment can contain a `requested pickup window` but when communicating with the carrier, a `planned pickup window` is used.
The conversion from `requested` to `planned` is handled via the opening/closing times enrichment in the `CarrierBooking` business rules.

This gives the shipper the opportunity to specify time windows when carriers can collect the shipments and manage their shipping days per week including holidays.

Details on how the pickup window is determined can be found in [To be moved Wiki: Collection Window](https://dev.azure.com/shipitsmarterdev/CurrentPlatform/_wiki/wikis/ShipitSmarter-wiki/1203/CollectionWindow)