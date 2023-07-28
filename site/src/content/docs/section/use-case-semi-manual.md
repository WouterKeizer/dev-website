---
section: Use-Case
title: API booking with manual price/service selection
description: A use case that describes to a customer how to use the shipment API, where price & service are selected manually. 
---

In the following use-case we describe how to setup a two-step system where the Shipment API is used to provide the shipment data and a user can make a carrier selection within the Viya UI. 

The steps required for this are as follows

1. [ Setting up the Authentication (M2M Token) and webhook](#setting-up-the-authentication-m2m-token-and-webhook)
1. [Create a new shipment using the Shipment API](#create-a-new-shipment-using-the-shipment-api)
2. [User select carrier in UI(based on Price/Services)](#user-select-carrier-in-uibased-on-priceservices)
3. [Return shipment details to WMS/ERP using a webhook](#return-shipment-details-to-wmserp-using-a-webhook)

Below is an interaction diagram of the full process for creating and ordering a shipment.


## Interaction Diagram 

``` mermaid
sequenceDiagram
    autonumber
    actor U as Shipper User

    participant S as Shipper ERP/WMS
    participant V as Viya
    link V: API-documentation @ https://viya.me/docs/api-shipping
    link V: Webhook-documentation @ https://viya.me/docs/api-shipping

    participant C as Carrier

    U ->> S: Ready for carrier selection
    Note right of S: Triggered through SAP

    S ->> V: [Post] Create a new shipment (see example)
    V ->> S: Response Shipment Created
    U -->> V: Navigate to Checkout URL
    U -->> V: Select Price & Service
    V ->> C: Order Shipment 
    C ->> V: Order Response
    V ->> S: Webhook: Shipment:Ordered
    S ->> V: [GET] Get a single shipment by shipmentReference (see example)
    U -->> V: Navigate to Shipment
    U -->> V: Download shipping labels from browser
    U -->> U: Print shipping label on local printer
    
```

## Setting up the Authentication (M2M Token) and webhook

### M2M token
In order to get started with our shipment API a M2M token needs to be requested for the oAuth flow. 

T.B.D.

### Webhook setup

In order to receive shipment status updates during the process a set of webhooks can be used.

- Shipment:Created
- Shipment:CheckoutCompleted
- Shipment:Ordered
- Shipment:Confirmed
- Shipment:Executed

You can find more information on our shipment states [here](#TODO).  

## Create a new shipment using the Shipment API

Using the `Post:` [Create a new shipment](https://viya.me/api-shipping/#tag/Shipment/paths/~1api~1v1~1shipments/post) a new shipment can be created, depending on the shipping scenario and different fields are required. In the examples below we've already selected some common scenarios that you might wish to implement.

<details>
  <summary>Examples</summary>

##### Domestic Shipment (single package)

```json
{
    "reference": "string",
    "addresses": {
      "sender": {
        "companyName": "Sender Company",
        "addressLine1": "Sender Address Line 1",
        "addressLine2": "Sender Address Line 2",
        "streetNumber": "2",
        "city": "Amsterdam",
        "stateCode": "",
        "postCode": "1012WP",
        "countryCode": "AD",
        "vat": "VAT12345678",
        "eori": "NL12345677",
        "contactName": "Sender contact name",
        "contactPhone": "06123456789",
        "contactEmail": "user@example.com",
        "carrierAccountReference": "Sender account number"
      },
      "receiver": {
        "companyName": "Receiver Company",
        "addressLine1": "Receiver Address Line 1",
        "addressLine2": "Receiver Address line 2",
        "streetNumber": "4",
        "city": "Rotterdam",
        "stateCode": "",
        "postCode": "3068JW",
        "countryCode": "NL",
        "vat": "NL234567889",
        "eori": "NL12345677",
        "contactName": "Receiver contact name",
        "contactPhone": "06123456789",
        "contactEmail": "user@example.com",
        "carrierAccountReference": "Receiver account number"
      }
    },
    "lengthUnit": "CMT",
    "weightUnit": "KGM",
    "description": "Some test examples",
    "declaredValue": {
      "value": 10,
      "currencyCode": "EUR"
    },
    "timeWindows": {
      "pickup": {
        "planned": {
          "start": "2023-08-24T14:15:22Z",
          "end": "2023-08-24T16:15:22Z"
        },
        "requested": {
          "start": "2023-08-24T14:15:22Z",
          "end": "2023-08-24T16:15:22Z"
        }
      },
      "delivery": {
        "planned": {
          "start": "2023-08-25T14:15:22Z",
          "end": "2023-08-25T16:15:22Z"
        },
        "requested": {
          "start": "2023-08-25T14:15:22Z",
          "end": "2023-08-25T16:15:22Z"
        }
    },
    "incoterms": {
      "scope": "DoorToDoor",
      "incoterm": "DAP",
      "place": "Amsterdam",
      "version": "2020"
    },
    "carrier": {
      "code": "DHL",
      "name": "DHL Express",
      "customerAssignedValue": "DHL"
    },
    "trackingReference": "",    
    "inbound": false,
    "serviceLevel": {
      "code": "Express",
      "description": "Express service",
      "customerAssignedValue": "Express"
    },
    "references": {
      "shipmentNumber": "12345678"

    },
    "handlingUnits": [
      {
        "sequence": 1,
        "weight": 10,
        "length": 15,
        "width": 25,
        "height": 30,
        "packageTypeCode": "BOX",
        "description": "test examples",
        "reference": "123-456",
        "isStackable": true
      }
    ]
  }
}
```

##### Domestic Shipment (multi package)

multi-package.json


##### International Dutiable Shipment

export-json

##### Saturday delivery

saturday-delivery.json

</details>

After the following Post has been created a response is given back;

``` json
{
    "id": "string",
    "shipmentCode": "string",
    "reference": "string",
    "urls":{
      "checkout":"https://{shipper-name}.viya.me/shipment/{shipment-reference}/checkout",
      "change":"https://{shipper-name}.viya.me/shipment/{shipment-reference}/edit",
    }
}
```

which can be used in the further process for the shipment.

## User select carrier in UI(based on Price/Services)

After the shipment is created, users can go to Viya platform to make a carrier and price selection. The following URL can be used


## Return shipment details to WMS/ERP using a webhook

After the carrier selection has been made a webhook response will be returned on shipment:ordered

Following the GET /shipment request can be made to collect the shipment details 

<details>
  <summary>Examples</summary>

  ```json
    TODO: Example get shipment without price
  ```

  
  ```json
    TODO: Example get shipment with price
  ```
<details>
- Response of webhook for the GET /shipment
