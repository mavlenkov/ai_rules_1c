---
description: Automatic external critic (Codex) at the verification gate — trigger, per-client detection, graceful fallback to 1c-code-reviewer, rule context for Codex
alwaysApply: false
category: quality
---

# External Review — automatic critic at the verification gate

**When to load this file:** at the verification gate of any **non-trivial** code change, right after the hard validators pass and before declaring the change "done". Referenced as a soft gate from `verification-checklist.md`. Companion files: `verification-checklist.md` (the gate this plugs into), `subagents.md` (the `1c-code-reviewer` fallback), `anti-patterns.md` (the review rubric passed to Codex).

This rule adds an **automatic external critic** as a second opinion on top of the mandatory in-toolchain validators. It does not replace them.

## Where the critic sits

The verification gate for non-trivial code has two layers:

```
verification gate (non-trivial code):
  ① mandatory hard validators (verification-checklist.md):
       syntaxcheck → check_1c_code → review_1c_code (1С:Напарник)
  ② external critic (automatic, this rule):
       try   → Codex   (rules context + diff)
       catch → 1c-code-reviewer @ <current client's model>
```

Layer ① is never skipped or replaced — `review_1c_code` (1С:Напарник) is a **mandatory** validator, not part of the fallback. Layer ② is an extra "fresh eyes" pass: a different model that did not write the code reviews it against the project's 1C rubric.

## Trigger — when the critic runs automatically

- **Run automatically** for **non-trivial** changes — the same boundary that separates full-cycle from quick-fix in Triage (`AGENTS.md → Development Procedure`). No user request is required; this is the automatic upgrade of the former "user-explicit code review" (soft gate C) for non-trivial code.
- **Skip** for quick-fix and docs-fix changes — the launch cost is not justified, and layers ① already cover the routine bar.
- The critic runs **once** per change at the gate, on the final diff, not after every intermediate edit.

## Per-client detection — "is a way to call Codex available?"

Detection is declarative: *is a working way to invoke Codex available for the current client?* Concrete per-client checks:

- **Claude Code** — the Codex integration (the `codex:codex-rescue` agent / `codex` CLI sharing the same runtime). Readiness signal: `codex` resolvable in `PATH` (`command -v codex`).
- **OpenCode** — direct `codex exec` via shell. Readiness signal: `command -v codex`.

Codex is considered **unavailable** on any of: binary not found, launch error, or timeout. Treat the user's global Codex time-control policy as binding — a Codex run that does not return within the configured budget counts as unavailable and triggers the fallback (do not hang the gate waiting on Codex).

## Fallback chain — never block on Codex

1. **Codex available** → Codex performs the review (with the rules context below). Address its critical / major findings before delivery; summarize minor ones.
2. **Codex unavailable** → the `1c-code-reviewer` subagent performs the review **on the current client's model** (resolved per-client per `subagents.md → Model-tier routing`: Claude Code → `coding` tier model e.g. `sonnet`; OpenCode → e.g. `glm-5.2`). This is the one sanctioned automatic use of `1c-code-reviewer` — it does **not** contradict the `subagents.md` ban on auto-triggering the reviewer, which targets quick-fix / non-requested tasks.

Codex unavailability MUST NOT block task completion — degrade to the subagent and proceed. If both Codex and the subagent are unavailable, note it under **Risks** in the delivery summary and rely on layer ① only.

## Rules context for Codex — close the AGENTS.md-only gap

Codex natively reads only the root `AGENTS.md`; it does **not** auto-load the on-demand rules under `content/rules/*` (they are `alwaysApply: false` for every client). The review rubric lives in `anti-patterns.md` ("code-review scoring rubric"), so without help Codex would review without the 1C rubric.

Therefore, when invoking Codex, the parent agent MUST attach:

1. **`anti-patterns.md`** — the code-review scoring rubric (critical anti-patterns, severities).
2. **`coding-standards.md`** — the index of detail rules (so Codex can reference the standards' shape).
3. **The diff / changed files** — the actual change under review.

Keep the prompt focused on one goal (review this diff against this rubric) — do not bundle large unrelated context (PDF + long spec + diff at once), per the user's Codex time-control policy; that is a known hang trigger.

## Anti-patterns

- **Treating Codex as mandatory** — if Codex is not configured, the gate still completes via the `1c-code-reviewer` fallback. Blocking on Codex is forbidden.
- **Dropping layer ①** — running Codex does not let you skip `syntaxcheck` / `check_1c_code` / `review_1c_code`. The hard validators are always mandatory.
- **Calling Codex without the rubric** — Codex reviewing on `AGENTS.md` alone misses the 1C anti-pattern rubric; always attach `anti-patterns.md` + the `coding-standards.md` index + the diff.
- **Running the critic on quick-fix / docs-fix** — wasted budget; the trigger is non-trivial code only.
- **Hanging on a stalled Codex run** — enforce the time budget; a non-returning Codex run is "unavailable" → fall back, do not wait indefinitely.
