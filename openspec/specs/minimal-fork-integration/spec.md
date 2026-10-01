# minimal-fork-integration Specification

## Purpose
Maintain a bounded fork on the upstream core, with one installer engine, preserved configured connections and shared converter safety gates.

## Requirements
### Requirement: Upstream core and bounded fork adaptations
The ruleset SHALL adopt the selected upstream core and OpenSpec bundle, retaining converter, Koda and per-client routing through focused extensions.

**Definition of Done:** DoD-1: Compare adopted core and metadata tooling with the selected upstream tree; run the structural validator with unchanged budgets. Expected: adopted sources match and validation passes.

#### Scenario: Core synchronization
- **WHEN** the selected upstream revision is integrated
- **THEN** its lean entry point and generated bundle are retained without historical fork duplication
- **AND** retained capabilities have explicit source hooks and validation evidence

### Requirement: Shared installer engine
The Bash entry point SHALL invoke the PowerShell installer with argument boundaries preserved and SHALL fail before target writes when PowerShell is unavailable.

**Definition of Done:** DoD-2: Execute the offline installer fixtures with spaced paths and a missing PowerShell runtime. Expected: exact arguments reach the common engine, and missing runtime causes no target writes.

#### Scenario: Bash installation with spaced paths
- **WHEN** installation uses a target path containing spaces and explicit client options
- **THEN** the common installer receives the exact arguments and installs the requested adapters

### Requirement: Existing connections are preserved
Installation and update SHALL preserve existing per-server endpoints, authentication, non-managed servers and sibling client settings.

**Definition of Done:** DoD-2: Execute JSON/TOML preservation fixtures through init, update and ForcePaths, including malformed JSON. Expected: existing connections and sibling settings survive; malformed JSON remains untouched.

#### Scenario: Custom endpoint update
- **WHEN** an existing managed server has a custom URL and authentication and another user server is configured
- **THEN** both connections and their settings survive the update unchanged

### Requirement: Converter integration retains common safety gates
Converter workflows SHALL inherit the upstream source-selection and load/check/apply sequence and SHALL fall back to the common deployment route if the converter cannot separate these phases.

**Definition of Done:** DoD-3: Review all converter command hooks and the shared load/check/apply rule. Expected: unsupported split phases select the common route, and no automatic apply bypass is allowed.

#### Scenario: Converter cannot separate load from apply
- **WHEN** the selected script cannot load without applying an extension
- **THEN** the workflow uses the common deployment route rather than bypassing applicability checks
