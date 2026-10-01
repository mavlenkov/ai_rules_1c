## MODIFIED Requirements

### Requirement: Автоматический внешний критик в quality gate
The ruleset SHALL run an extra external critic only when explicitly requested. The selected upstream validator policy SHALL remain authoritative and SHALL NOT be replaced by the critic.

**Definition of Done:** DoD-3: Review external-review.md and verification-delivery.md. Expected: the extra critic requires an explicit request and retains the selected validators.

#### Scenario: Routine change does not start an extra critic
- **WHEN** an agent completes a change without an explicit external review request
- **THEN** the applicable upstream gates run without starting the extra critic

#### Scenario: Explicit review request
- **WHEN** the user explicitly requests an external review
- **THEN** the focused critic workflow runs after the selected validators

### Requirement: Предпочтение Codex с graceful fallback
The explicitly requested external review SHALL prefer an available Codex invocation. A reviewer subagent fallback SHALL respect the explicitly selected reviewer model and host availability; missing routes SHALL be reported without silently selecting another model.

**Definition of Done:** DoD-3: Review the external review routing policy. Expected: fallback requires a selected model and available host route; unavailable review is reported without a silent alternative.

#### Scenario: Codex available
- **WHEN** an explicit external review request has an available Codex route
- **THEN** Codex performs the review

#### Scenario: Codex unavailable with a selected fallback model
- **WHEN** Codex is unavailable and a reviewer model and subagent route are explicitly selected
- **THEN** the reviewer subagent performs the review on that model

#### Scenario: No review route available
- **WHEN** no permitted external review route is available
- **THEN** the requested review is reported as unavailable and is not claimed complete

## Context sources

Existing external-review specification and upstream reviewer selection policy. No application-specific 1C facts.
