## 1. Upstream integration

- [x] 1.1 Resolve upstream integration with the upstream core and OpenSpec bundle
- [x] 1.2 Consolidate converter guidance and wire retained command hooks
- [x] 1.3 Adopt upstream verification policy and make external critic opt-in

## 2. Shared installation

- [x] 2.1 Retain Koda and per-client model routing in the common installer
- [x] 2.2 Preserve existing MCP connections and client settings
- [x] 2.3 Replace duplicate Bash implementation with the compatibility wrapper

## 3. Verification and delivery

- [x] 3.1 Update maintainer documentation and active fork debt
- [x] 3.2 Run structural, metadata and relevant installer regression checks
- [x] 3.3 Verify Bash and PowerShell fixtures, configuration preservation and user-file integrity
- [x] 3.4 Validate OpenSpec artifacts and complete the parent review and reconcile DoD

## Verification evidence

- DoD-1: passed; adopted AGENTS.md and metadata tooling match upstream `45bacdd`; structural validator passed with unchanged budgets. See `docs/upstream-sync-2026-09-30.md`.
- DoD-2: passed; `fork-install-regression.py` exercises eight real client adapters through the shared engine; preservation, spaced paths, invalid JSON and missing runtime assertions passed. Adapter suite: 9/9; portable installer-path scenarios passed. See the same report for environment limits.
- DoD-3: passed; final parent review covered converter hooks, split load/check/apply fallback and explicit critic/model selection. Required branches are documented; no real converter or external reviewer was invoked.
- DoD-4: passed; final parent review found no blocking issue in the retained adaptations. Strict OpenSpec and structural validation passed. Unchanged upstream Windows-suite failures on Linux remain an explicit platform verification limit.

## Follow-up priority

User instruction, 2026-10-01: Koda is experimental and rarely used in real work. Further Koda improvements and related PRs are last priority. Complete synchronization and the selected real-project pilot first; MCP modernization remains a separate step.
