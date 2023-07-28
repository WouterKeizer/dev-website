---
section: Shipping
title: Collection Windows
description: A description of our collection windows

---


During Stitch Enrichment ('Carrier Configuration'), a list of Collection Windows ('opening/closing times') may be enriched:

```yaml
rules:
    - condition: Shipment.Carrier?.Code == "DUM"
      patch:
        Integration:
            Path: examples/dummy/booking/booking
            Key: ENC[AES256_GCM,data:XU+Ovu9gO8jokL0=,iv:++3Q1E54VbzUHSD7bB+AX+aymr5hnMdngoXbwIdscnY=,tag:uAHnCsovsPAf9sbdeM6GiQ==,type:str]
        Collection:
            Windows:
                - Day: Monday
                  Open: "08:00"
                  Close: "17:00"
                - Day: Tuesday
                  Open: "09:00"
                  Close: "12:00"
            Exclusions:
                - Name: Christmas
                  Start: 2022-12-25T13:25:12
                  End: 2022-12-26T20:01:02
                - Name: New Year
                  Start: 2022-12-31T00:00:00
                  End: 2023-01-01T23:59:59
            IncreaseWindowToMinimal: "00:30"
            PlannedStartToWindowOpen: true
        Metadata:
            DUMMY_LABEL: "N"
```

From the `Shipping` -> `Shipment` input model, the customer can specify a Pickup Requested time window, containing an `Start` and `End` DateTime:

```json
{
    //...
    "timeWindows": {
        "pickup": {
            "planned": {
                //...
            },
            "requested": {
                "start": "2022-11-24T13:00:00Z",
                "end": "2022-11-24T18:00:00Z"
            }
        },
        "delivery": {
           //...
        }
    },
}
```
Together, the Stitch Enrichment `Collection` and Shipping `Pickup Requested` time window map to Shipping `Pickup Planned` time window (and, identically, `EarliestTimeReady` and `LatestTimeReady` derived fields).

The following scenarios illustrate the mapping logic.

**NOTES**: 
- the light-blue rectangles illustrate `Collection` windows from the Stitch Enrichment
- The vertical blue lines illustrate the `Pickup.Requested.Start` and `Pickup.Requested.End` from the Shipment input
- The Green and Red arrows illustrate the derived values of `Pickup.Planned.Start` and `Pickup.Planned.End` (and of `EarliestTimeReady` and `LatestTimeReady` in the Stitch model)

## Scenario 1: No `Pickup Requested` window present, no Collection Windows present
If no `Pickup Requested` window present in the Shipment and no Collection Windows present in the enrichment, `Planned Start` and `Planned End` both map to `DateTime.Now`.

![scenario_1.png](~/assets/doc/collection-window/scenario_1.png)

## Scenario 2: No `Pickup Requested` window present, one or more Collection Windows present
If no `Pickup Requested` window is present in the Shipment, but there are one or more Collection Windows present in the enrichment, the `Planned Start` and `Planned End` map to the Open and Close of the chronologically next window.

![scenario_2.png](~/assets/doc/collection-window/scenario_2.png)

## Scenario 3: No `Collection` windows configured
When there are no `Collection` windows present in Stitch Enrichment, the `Pickup Requested` window maps directly to the `Pickup Planned` window.

If this is the case and `Requested Start` and `Requested End` fall on different dates, `Planned Start` and `Planned End` will also be on different dates. This is the _only scenario in which this will ever happen_.

![scenario_3.png](~/assets/doc/collection-window/scenario_3.png)

## Scenario 4: window overlaps with `Requested Start`
When a window exists that overlaps with `Requested Start`, `Planned Start` will be equal to `Requested Start`, while `Planned End` will be equal to end of the overlapping window.

![scenario_4.png](~/assets/doc/collection-window/scenario_4.png)

## Scenario 5: window overlaps with `Requested End`
When the first window after `Requested Start` overlaps with `Requested End`, the start of the window will map to `Planned Start`, while `Requested End` maps to `Planned End`.

![scenario_5.png](~/assets/doc/collection-window/scenario_5.png)

## Scenario 6: Two adjacent windows spanning over multiple days
When two adjacent windows together span over multiple days, The first window overlapping with or after the `Requested Start` will determine the `Planned Start` and `Planned End`.

The `Planned Start` and `Planned End` will always fall on the same date, _unless there are no windows at all and scenario 1 applies_.

![scenario_6.png](~/assets/doc/collection-window/scenario_6.png)

## Scenario 7: window overlapping `Requested Start` and `Requested End`
When a single window overlaps with both `Requested Start` and `Requested End`, those DateTimes map directly to `Planned Start` and `Planned End`.

![scenario_7.png](~/assets/doc/collection-window/scenario_7.png)

## Scenario 8: No windows overlapping with or falling in between `Pickup Start` and `Pickup End`
When no windows overlap with or fall in between `Pickup.Requested.Start` and `Pickup.Requested.End`, the chronologically first next window present will map to `EarliestTimeReady` and `LatestTimeReady`.

![scenario_8.png](~/assets/doc/collection-window/scenario_8.png)

## Scenario 9: Single window on day of `Requested Start` but completely before it
When a single window is present that is on the same day as `Requested Start` but ends before it, that same window but than a week later will be mapped to `Planned Start` and `Planned End`.

![scenario_9.png](~/assets/doc/collection-window/scenario_9.png)

## Scenario 10: Remaining window time less than `IncreaseWindowTominimal`
When a window overlaps with `Requested Start` but ends less than the time specified in Stitch Enrichment `IncreaseWindowTominimal` after the `Requested Start`, the window is 'stretched' to result in at least this minimal window time between `Planned Start` and `Planned End`.

![scenario_10.png](~/assets/doc/collection-window/scenario_10.png)

## Scenario 11: `PlannedStartToWindowOpen` is `true`
When a window overlaps with `Requested Start` and `PlannedStartToWindowOpen` is equal to `true`, `Planned Start` will map to Window Open time instead of `Requested Start`.

![scenario_11.png](~/assets/doc/collection-window/scenario_11.png)

## Scenario 12: `Exclusion` range overlaps with `Requested start`
When there is an `Exclusion` range that overlaps with `Requested Start`, the end of the exclusion range will be used as new reference datetime to determine the window (instead of the `Requested Start`).

![scenario_12.png](~/assets/doc/collection-window/scenario_12.png)

## Scenario 13: Multiple `Exclusion` ranges
When there are multiple exclusion ranges present and at least one overlaps with the `Requested Start`, the first (partial) pickup window that does not overlap with an `Exclusion` range will determine the `Planned Start` and `Planned End`.

![scenario_13.png](~/assets/doc/collection-window/scenario_13.png)

![scenario_13a.png](~/assets/doc/collection-window/scenario_13a.png)

## Scenario 14: `Exclusion` range results in window smaller than `IncreaseWindowToMinimal`
When an `Exclusion` range limits the resulting window to me smaller than `IncreaseWindowToMinimal`, the system ignores that part of the `Exclusion` range and lengthens the window to be at least `IncreaseWindowToMinimal`. **Note**: this is the only situation in which a `Planned End` can fall within an `Exclusion` range.

![scenario_14.png](~/assets/doc/collection-window/scenario_14.png)

![scenario_14a.png](~/assets/doc/collection-window/scenario_14a.png)

## Still to implement
- Start time default in now SERVER time (not user time)