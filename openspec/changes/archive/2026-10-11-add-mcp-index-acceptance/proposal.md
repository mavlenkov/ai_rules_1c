## Why

During acceptance of a modernized MCP circuit (2026-10-05/06) vendor indexers skipped whole unit categories of extension layers (pictures, subsystems) and one base form while every indexing phase reported success; another lane started its vector pass early and left a persistent gap. The existing rules (`mcp-deployment.md` and neighbours) cover hosts, ports, mounts and URL preservation, but nothing defines what "the index is complete" must prove before a server is declared ready. The defects were caught only by ad-hoc manual reconciliation, too late for the acceptance window.

## What Changes

- Add an on-demand rule `content/rules/mcp-index-acceptance.md` (category `tooling`) that owns index-completeness acceptance for source-dependent MCP servers:
  - three distinct claims never conflated: deployment/health/phase `completed` ≠ index completeness ≠ operational acceptance;
  - an independent source-to-index reconciliation per layer (base + each extension separately), with the unit-correspondence rule fixed before comparing, the expected side built offline from the file dump, the actual side from a complete paged listing, and misses reported with source evidence;
  - behavioural probes: one known object and one known routine per layer with exact category/name/origin/locator match; fuzzy matches and health codes are not a pass;
  - a verdict matrix with exactly PROVEN / DEFECT / NOT VERIFIED / OUT OF SCOPE, where NOT VERIFIED never silently becomes PASS;
  - paid embedding/LLM probes only with the cost owner's explicit consent for the spend.
- Add one index line to `AGENTS.md → Additional rules` (deployment or reindex of a source-dependent MCP server → `mcp-index-acceptance`).
- Add a single pointer sentence in `content/rules/mcp-deployment.md` to the new rule (no content duplication).

## Capabilities

### New Capabilities
- `mcp-index-acceptance`: Verifiable completeness and behavioural acceptance of source-dependent MCP indexes before any readiness claim.

## Impact

Rules source only: one new rule file, one index line in `AGENTS.md`, one pointer sentence in `mcp-deployment.md`. No installer, adapter, client or target-project changes; no services started; no concrete 1C application metadata or platform API claims authored (repository tooling prose). Real project/extension names from the triggering audits are deliberately not reproduced in this repository.

## Context sources

Read-only precedent analyses from the neighbouring MCP workspace (2026-10-06): `layer-coverage-reconciliation.md` and `denominator-reconciliation.md` — layer reconciliation matrices, the fixed-before-compare unit rule, complete-cursor listings, verdict vocabulary and paid-probe boundaries. Repository conventions: `openspec/changes/README.md`, `content/rules/sdd-integrations.md`, existing `mcp-deployment.md` / `mcp-policy.md` scope split.

## Definition of Done

- DoD-1: Rule content — `content/rules/mcp-index-acceptance.md` follows the on-demand rule canon (frontmatter, category `tooling`, English prose, cross-references resolve); structural validator passes with the new file included, budgets unchanged.
- DoD-2: Wiring — `AGENTS.md → Additional rules` contains exactly one new line for the rule; `mcp-deployment.md` carries one pointer sentence without duplicated content; no other always-on file grows.
- DoD-3: Specification — delta requirements each carry a verification criterion; `openspec validate --strict` passes for the change; final review finds no conflict with `mcp-policy.md`, `multi-contour-search.md` or `verification-gates.md` scope.
