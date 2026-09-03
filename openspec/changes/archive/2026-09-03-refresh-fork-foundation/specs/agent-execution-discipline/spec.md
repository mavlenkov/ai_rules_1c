## ADDED Requirements

### Requirement: Repeated work requires changed information
An agent SHALL NOT repeat an unchanged tool request, reread context already carried in a valid handoff, or poll a background subagent when the runtime provides completion notifications. A retry SHALL address a changed input, changed state, or a materially different query.

#### Scenario: Background subagent is running
- **WHEN** a background subagent will emit a completion notification and independent work remains
- **THEN** the parent continues independent work without polling the subagent status

#### Scenario: Tool request fails
- **WHEN** a tool call fails and neither its inputs nor the relevant state have changed
- **THEN** the agent surfaces or diagnoses the failure instead of issuing the same call again

### Requirement: Tool failures remain visible in the final verdict
An agent SHALL NOT report overall success when a required tool, validator, or implementation step failed or remained unverified. The final report SHALL distinguish completed work, failed checks, and residual blockers.

#### Scenario: Required validator fails
- **WHEN** a required validator has no clean confirming result on the final artifact state
- **THEN** the final verdict identifies the affected artifact as unverified and does not describe the task as fully successful

### Requirement: Exploration and application remain separate
Read-only exploration SHALL NOT mutate files or silently transition into implementation. An apply phase SHALL require an approved plan or direct implementation authorization and an explicit write scope.

#### Scenario: Explorer finds a likely fix
- **WHEN** a read-only exploration identifies a concrete change
- **THEN** it reports the finding and proposed write scope without applying the change

### Requirement: User interaction is decision-focused
The agent SHALL ask the user only for material choices or information that cannot be discovered safely, and SHALL avoid presenting routine implementation details as mandatory decisions.

#### Scenario: Low-risk ambiguity exists
- **WHEN** repository patterns provide a reversible default for a low-risk detail
- **THEN** the agent states the assumption and proceeds without adding a user prompt
