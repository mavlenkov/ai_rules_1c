# fork-maintenance-baseline Specification

## Purpose
Baseline invariants for maintaining this fork against its upstream: ancestry bridging, documentation/executable parity, and fixture-only validation. Created by archiving change refresh-fork-foundation.

## Requirements
### Requirement: Upstream ancestry bridge preserves the fork tree
The maintenance process SHALL connect the rewritten fork history to the current upstream tip without changing any tracked file content.

#### Scenario: Bridge merge is created
- **WHEN** the fork tip is patch-equivalent to the current upstream tip plus documented fork-only changes
- **THEN** a safeguarded ancestry-only merge records the upstream tip as an ancestor and the tree id before and after the merge is identical

### Requirement: Active fork documentation matches executable behavior
Maintainer-facing documentation SHALL distinguish active fork behavior from historical decisions and SHALL match the supported tools, artifact inventory, validators, and CI policy implemented in the repository.

#### Scenario: Documentation inventory is checked
- **WHEN** the foundation refresh is complete
- **THEN** current documentation reports the executable installer coverage and current source artifact counts without relying on historical counts

### Requirement: Validation does not mutate real target projects
Foundation verification SHALL run only against the source repository and disposable fixture directories.

#### Scenario: Installer smoke tests run
- **WHEN** PowerShell and Bash installation paths are validated
- **THEN** their outputs are created under disposable fixtures with isolated user-scope paths and no registered real 1C project is changed
