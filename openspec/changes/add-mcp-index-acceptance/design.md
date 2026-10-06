# Design — mcp-index-acceptance

## Why a new on-demand rule, not an extension of mcp-deployment.md

`mcp-deployment.md` answers "where do containers run and how do clients reach them" and is loaded for installation/diagnostics. Index acceptance is a different reader at a different moment (post-deployment/reindex verification), with its own budget: keeping it separate keeps the deployment rule lean and lets the acceptance rule load alone on its trigger. One pointer sentence from `mcp-deployment.md` provides routing without duplication.

## Key decisions

1. **Claims ladder.** Deployment state → completeness → acceptance. Precedent: phases green while whole extension categories were absent from the index; health 200 proved nothing about content. The rule forbids deriving the later claims from the earlier evidence.
2. **Denominator discipline.** The unit-correspondence rule is fixed *before* comparing because the indexer's unit is legitimately broader than a dump-directory rule (extras from `Configuration.xml` and nested declarations). Expected side is built offline from the dump per layer; actual side requires cursor-to-end listings with de-duplication. Per-layer attribution limits of real listings contracts are handled honestly (NOT VERIFIED, not assumption).
3. **Probes complement, never replace.** Exact identity (category/name/origin/locator) per layer; fuzzy is not a pass; contested multi-layer objects stay attributed or reported as contested, and effective extension order remains an infobase claim.
4. **Verdict vocabulary.** Exactly four verdicts so matrices from different runs are comparable; NOT VERIFIED is non-promotable without new evidence. Stability of counts across runs proves stability, not completeness against current sources.
5. **Paid probes.** Embedding/LLM verification spends money and is gated on recorded cost-owner consent; free structural checks are the default acceptance path. This matches how the precedent audits ran (structural probes only, vector lanes out of scope).
6. **Privacy.** The triggering audits name real projects and extensions; the rule and this change cite the precedent documents as external read-only sources and reproduce no real names (public-fork privacy rule in `FORK-TODO.md`).

## Alternatives considered

- Extend `verification-gates.md`: wrong scope — that file owns artifact verification (BSL/XML), not service acceptance.
- Fold into `mcp-policy.md`: that file owns tool selection/availability per session, not post-deployment acceptance evidence.
- A checklist command instead of a rule: the knowledge is needed at decision time in any session, not only when a slash command is remembered; the index line in `AGENTS.md` is the canonical router.
