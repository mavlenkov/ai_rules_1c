## 1. Rule and wiring

- [x] 1.1 Draft `content/rules/mcp-index-acceptance.md` (category `tooling`, on-demand): three-claims separation, per-layer reconciliation with a unit rule fixed before compare, behavioural probes with exact identity, verdict matrix, paid-probe consent.
- [x] 1.2 Add exactly one line to `AGENTS.md → Additional rules`: deployment or reindex of a source-dependent MCP server → `mcp-index-acceptance`.
- [x] 1.3 Add one pointer sentence in `content/rules/mcp-deployment.md` to the new rule (acceptance of index completeness lives there); no duplicated content.

## 2. Verification and completion

- [x] 2.1 Run the structural validator on the final state; budgets must not grow and all cross-references must resolve (DoD-1).
- [x] 2.2 Review the wiring diff: one index line, one pointer sentence, no other always-on growth (DoD-2).
- [x] 2.3 Validate the change (`openspec validate add-mcp-index-acceptance --strict`) and complete the final scope review against `mcp-policy.md`, `multi-contour-search.md`, `verification-gates.md` (DoD-3).
- [x] 2.4 Reconcile all DoD criteria with current evidence before declaring apply complete.

## Verification evidence

- DoD-1: rule frontmatter and references confirmed; structural validator OK on the wired state (59 rules), budgets unchanged.
- DoD-2: diff contains exactly one new index line in `AGENTS.md` and one pointer sentence in `mcp-deployment.md`; no other always-on content changed by this change.
- DoD-3: `openspec validate add-mcp-index-acceptance --strict` passed; scope review against `mcp-policy.md`, `multi-contour-search.md` and `verification-gates.md` found no overlapping owner or conflict. Live index acceptance remains separate work.

## Notes

- Apply stage only edits the three listed files; no installer, adapter or client changes.
- Real project/extension names from the triggering audits are intentionally absent; keep it that way in any follow-up (public-fork privacy rule).
- Live acceptance of any actual MCP circuit is separate work under the cost/consent rules the new rule itself defines; this change only ships the rule.
