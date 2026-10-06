# Delta for mcp-index-acceptance

## ADDED Requirements

### Requirement: Readiness claims separate deployment, completeness and acceptance
A readiness claim for a source-dependent MCP server SHALL distinguish deployment state (containers, endpoints, health codes, phase `completed`) from index completeness and from operational acceptance, and SHALL NOT derive readiness from deployment state alone.
#### Scenario: Green deployment with incomplete index
- **WHEN** every container is running, health/ready answers 200 and all indexing phases report `completed`, but a layer reconciliation or probe has not been run
- **THEN** the server is reported as deployed-but-not-accepted and no consumer switch or pilot readiness is claimed
- **DoD verification:** rule text review — the three-claims section forbids the conflation and names health/phase flags as non-proof; criterion DoD-1.

### Requirement: Independent per-layer source-to-index reconciliation
Before any readiness claim, the accepting agent SHALL reconcile each layer (base configuration and each extension separately) between an expected side built offline from the file dump and an actual side built from a complete paged listing of the server, with the unit-correspondence rule fixed before the comparison.
#### Scenario: Extension category systematically missing
- **WHEN** the expected side contains units of a category in an extension layer and the complete server listing contains none of them
- **THEN** the row is reported as DEFECT with source evidence, and readiness for that server/layer is blocked
#### Scenario: Unit rule fixed before comparing
- **WHEN** the indexer returns extra units beyond the offline definition (objects declared inside `Configuration.xml` or other objects)
- **THEN** the extras are classified by the pre-fixed unit rule as a superset, the mapping is stated explicitly, and unattributed extras remain NOT VERIFIED instead of being silently accepted
- **DoD verification:** rule text review — the reconciliation section prescribes offline expected side, cursor-to-end actual side, per-layer comparison and recorded list hashes; criterion DoD-1.

### Requirement: Behavioural probes with exact identity
The acceptance SHALL include, per layer, a probe of one known object and one known routine with exact category, name, origin/layer attribution and locator match against the sources; approximate or fuzzy matches SHALL NOT count as a pass.
#### Scenario: Fuzzy hit on a same-named object
- **WHEN** a probe returns an entry whose category or layer differs from the probed source unit
- **THEN** the probe is not a pass and the discrepancy is recorded for follow-up
- **DoD verification:** rule text review — probes complement and never replace the denominator; criterion DoD-1.

### Requirement: Verdict matrix with non-promotable NOT VERIFIED
The acceptance result SHALL be recorded as a matrix over server, layer and check with exactly the verdicts PROVEN, DEFECT, NOT VERIFIED and OUT OF SCOPE, each row naming its evidence source; a NOT VERIFIED verdict SHALL NOT be silently converted into a pass.
#### Scenario: Missing tool or window
- **WHEN** a check cannot be executed in the available window or the server contract cannot attribute a layer
- **THEN** the corresponding row stays NOT VERIFIED with the reason, and the overall verdict states it is not PASS
- **DoD verification:** rule text review and final review of the verdict vocabulary; criteria DoD-1, DoD-3.

### Requirement: Paid probes require explicit cost consent
Any acceptance check that invokes provider embeddings or LLM calls SHALL run only after the cost owner's explicit consent to that spend, recorded in the matrix row; absent consent the row SHALL be marked OUT OF SCOPE while free structural checks proceed.
#### Scenario: Vector-lane probe without consent
- **WHEN** semantic or vector verification would call a paid provider and no consent for the spend exists
- **THEN** the row is recorded as OUT OF SCOPE with the consent gap and the acceptance proceeds on free structural checks
- **DoD verification:** rule text review — the paid-probes section ties spend to recorded consent; criterion DoD-1.

### Requirement: Rule is discoverable on its trigger
The rule SHALL be reachable through `AGENTS.md → Additional rules` for its trigger (deployment or reindex of a source-dependent MCP server) and referenced from `content/rules/mcp-deployment.md` by a single pointer without content duplication.
#### Scenario: Agent prepares an acceptance
- **WHEN** an agent is asked to declare such a server ready after deployment or reindexing
- **THEN** the index line routes it to `mcp-index-acceptance` before any readiness wording is produced
- **DoD verification:** diff review of `AGENTS.md` (exactly one new line) and `mcp-deployment.md` (one pointer sentence); criterion DoD-2.
