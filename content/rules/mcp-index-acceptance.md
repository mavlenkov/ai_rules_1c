---
description: Acceptance of MCP index completeness after deployment or reindexing — layer reconciliation against sources, behavioural probes, verdict matrix, paid-probe consent. Load before declaring a source-dependent MCP server ready.
alwaysApply: false
category: tooling
---

# MCP index acceptance — completeness before readiness

**When to load this file:** a source-dependent MCP server (code-metadata, graph, help, templates and similar index builders over a configuration dump) has just been deployed, restarted after a source change, or reindexed, and someone proposes to declare it ready — for a pilot, a client switch, or an acceptance report. This rule owns what "ready" must prove; `content/rules/mcp-deployment.md` owns deployment plumbing (hosts, ports, mounts, URLs), and `content/rules/mcp-policy.md` owns tool availability. A deployment that passed its plumbing checks is not an accepted index.

## Three distinct claims — never conflated

1. **Deployment state** — containers started, endpoints answer, health/ready returns 200, an indexing phase reports `completed`. This is a claim about the process, not the content.
2. **Index completeness** — the index actually contains the units its sources define, per layer, verified independently of the indexer's own success flags.
3. **Operational acceptance** — completeness plus behavioural probes plus a recorded verdict matrix (below). Only this authorizes "ready" for consumers.

A green deployment with an incomplete index is a defect caught late; vendor indexers have skipped whole extension layers (pictures, subsystems) while every phase reported success. Health 200 and a completed phase prove neither completeness nor acceptance.

## Independent source-to-index reconciliation

For every affected server, before any readiness claim:

1. **Fix the unit rule first.** Decide and write down, before comparing, what counts as one indexable unit (for example: a depth-1 object directory in a dump section; a module; a routine). The indexer's unit may legitimately be broader (objects declared inside `Configuration.xml` or other objects appear as extras); extras are a superset, not a completeness defect, but the mapping must be stated, not improvised after the diff.
2. **Build the expected side offline** from the file dump itself, per layer — the base configuration and **each extension separately** — never from the index, the deployment manifest, or a previous count. Record the list hash and per-section counts.
3. **Build the actual side from a complete server listing** — page every cursor to its end, de-duplicate, and check the returned total against items actually seen. A sampled or first-page listing is not an actual side. Where the server exposes no per-layer filter, per-layer attribution may be reconstructed from source paths of returned entries; if the contract cannot attribute layers at all, record that row as NOT VERIFIED rather than assuming.
4. **Compare per layer and report every miss** with its source evidence (directory plus XML present, entry absent). A systematic pattern (an entire category missing from one layer) is a defect even when the percentage looks small.

## Behavioural probes

On top of the reconciliation, probe per layer:

- **One known object** and **one known routine** that verifiably exist in that layer's sources: exact category, name, origin/layer attribution and locator (file and line range) must match the source. Fuzzy or approximate hits are not a pass.
- Probes complement the denominator, never replace it: a handful of proven rows does not close a missing-completeness row.
- Contested objects present in several layers must attribute to a verified layer (or honestly report the contest); effective application order of extensions belongs to the infobase claim, not the index claim.

## Verdict matrix

Report the acceptance as a matrix with exactly these verdicts: **PROVEN**, **DEFECT**, **NOT VERIFIED**, **OUT OF SCOPE** — one row per server, layer and check (object probe, routine probe, layer completeness, extras mapping, vector lanes). Rules:

- **NOT VERIFIED never silently becomes PASS.** It may be narrowed only by running the missing check, with evidence.
- A single unreconciled DEFECT (missing units, wrong attribution) blocks the readiness claim for that server/layer; it does not block reporting.
- Every verdict names its evidence source (listing capture, probe output, list hashes) so the matrix can be re-audited.
- Aggregate counts matching a previous run prove stability, not completeness against current sources.

## Paid probes

Any check that invokes provider embeddings or LLM calls (semantic/vector search probes, description regeneration, recompute runs) costs money: run it only with the cost owner's explicit consent for that spend, state the consent in the matrix row, and keep such rows OUT OF SCOPE when consent is absent. Free structural checks (listings, exact-match probes, stats) are the default path.

Acceptance results bind to the pair "rules revision + deployed images + source snapshot/index generation" (`content/rules/multi-contour-search.md`); a later source change or reindex invalidates them.
