The Pingwire API can be used by all our customers. Reach out to get your credentials.

 <a href="mailto:sales@pingwire.io">Become a customer</a>


# Introduction
## Dictionary

- `ENTITY`: An entity is a subject for investigation e.g an individual, a company, or an asset.
- `REQUEST`: A request is an enquiry to the system by the user to investigate one or several entities. Initiated manually or through API.
- `RULE`: Each request triggers a set of user defined rules. Rules can also be executed at regular intervals by the system for continuous monitoring.
- `PING`: For each rule broken the system creates a Ping. A Ping identifies a unit of suspicious information that needs to be followed up. A Ping can be <em>Confirmed</em>, <em>Resolved</em> or <em>Ignored</em> by the user.

- `CASE`: Provides the main user interface. A Case collects sets of Pings and related Entities and provides means to investigate and report suspicious activities in bulk.
- `SEGMENT`: Custom grouping corresponding to a self-defined group structure, e.g. product usage. In addition, segments also correspond to a baseline probability of criminal activity.
- `RISK CLASS`: Classes partitioned by the probability of an entity committing a crime using self-defined probability intervals.

## Unique Identifier
The Pingwire system strives to ensure the unicity of entities that are inserted in the system in order to help our customers detect complex financial patterns. To do so it is using some fields labeled as "Unique identifiers".

The system prevents the insertion of duplicated unique identifiers by reusing existing entities as much as possible. Creating a new entity can result on updating an existing one if the payload for the create endpoint contains a unique identifier already present in an existing entity.

Similarly when inserting a new entity in the system at least one of the unique identifier must be present in the payload so that it can be matched to existing or future entities. An entity without unique identifier would be useless in the system as it would never be able to be matched to past or future activity/behaviour/information.

## Sequence Diagram

<img src="assets/seq-diagram.svg"  />

## Request flowchart
The following flowchart illustrates a typical request process.

<img src="assets/Request_flowchart.png" width="60%" style="margin-left: 15%" />

# Test objects

The Pingwire system provides two rules which can be used for test purposes: "Test Review" and "Test Block". When these rules are published for a specific process, they will trigger for every requests sent on that process which has a targetted entity in the list of test objects bellow. These rules can therefore be used to test the integration for a specific recommendation or even a specific signal (if signals are used on the test rules). 

|   | Environment | Identification | Entity type  | Recommendation | Create ping |
|---|------------|--------------------------------|--------------|----------------|-------------|
| 1 |   staging  |          Ssn <span>&#8594;</span>  201912072392          |  Individual  |      block     |     true    |
| 2 |   staging  |          Ssn <span>&#8594;</span> 201912302385          |  Individual  |     review     |     true    |
| 3 |   staging  |          Org. nr. <span>&#8594;</span> 5599887766          |  Business  |      block     |     true    |
| 4 |   staging  |          Org. nr. <span>&#8594;</span> 5566778899          |  Business  |     review     |     true    |
| 5 |   staging  |          Reg. nr. <span>&#8594;</span> AAA111          |  Car  |      block     |     true    |
| 6 |   staging  |          Reg. nr. <span>&#8594;</span> ABC123          |  Car  |     review     |     true    |
