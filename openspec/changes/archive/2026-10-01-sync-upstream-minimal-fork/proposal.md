## Why

The fork is 65 upstream commits behind its maintenance baseline. Large duplicated deployment commands and a separately implemented installer make updates conflict-prone and obscure new upstream safeguards.

## What Changes

- Integrate upstream `45bacdd` and adopt its lean rule layout and OpenSpec bundle.
- Retain Linux/converter workflows, Koda and per-client model routing as bounded extensions.
- Consolidate converter instructions into one on-demand rule; inherit common deployment checks and UI policy from upstream.
- Replace the duplicate Bash installer engine with a compatibility entry point into the PowerShell installer, preserving the existing CLI options.
- Adopt upstream verification selection and make the extra external critic opt-in.
- Preserve existing client MCP endpoints and user configuration; update only source defaults and instructions, never running services.

## Capabilities

### New Capabilities
- `minimal-fork-integration`: Upstream integration with bounded, tested fork adaptations and configuration preservation.

### Modified Capabilities
- `external-review`: External review becomes explicitly requested instead of automatic.

## Impact

Rule templates, deployment command documentation, installer, Bash entry point, adapters, OpenSpec bundle and maintainer documentation. Bash installation requires PowerShell 7. No real infobases, deployment hosts or target projects are changed. The user accepted a merge commit and archival on 2026-10-01. Git publication and installed project updates remain separate follow-up steps.

## Context sources

Git history and tree comparison against `45bacdd`; existing fork commands, installer and `FORK-TODO.md`. This is repository tooling and documentation work; no concrete application metadata or new platform API claims are authored.

## Definition of Done

- [x] DoD-1: Upstream core and bounded fork adaptations — compare the lean entry point and metadata tools against `45bacdd`; structural validation must pass without increased budgets.
- [x] DoD-2: Shared installer and existing connections — run offline Bash/PowerShell fixtures on Linux with spaced paths, existing authentication, unrelated settings, update/ForcePaths, invalid JSON and missing PowerShell; all assertions must pass.
- [x] DoD-3: Converter safety and explicit external review — review command hooks, the shared converter rule and reviewer policy; no phase bypass or implicit critic/model selection may remain.
- [x] DoD-4: Final parent review and OpenSpec validation — reconcile requirements with current source and test evidence; no unresolved blocking findings, strict validation must pass.

Required environment: Linux, PowerShell 7 and Python 3 for the installer fixtures. No application UI or infobase operation is included. The inherited Windows metadata suite is informational on Linux; its six failures reproduce on unchanged upstream and do not prove Windows support.
