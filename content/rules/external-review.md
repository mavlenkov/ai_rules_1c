---
description: Explicitly requested external critic; Codex route, selected reviewer-model fallback and focused review context
alwaysApply: false
category: quality
---

# External Review — on explicit request

Load only when the user explicitly requests an external critic. Routine changes follow `verification-policy.md`, `verification-gates.md` and the parent review in `verification-delivery.md`; no extra model starts automatically.

Prefer an available authorized Codex CLI/plugin route. Pass the final diff, `anti-patterns.md` and the `coding-standards.md` index, resolving installed paths. Keep the review scoped and obey the session's time budget. Confirm invocation capabilities through the installed integration rather than assuming a plugin agent name.

If Codex is unavailable, use `1c-code-reviewer` only when its model is explicitly selected and the host exposes that subagent (`subagents.md`). Per-client model routing applies. Never choose a fallback model silently. If no route is available, report the requested review as unavailable; do not claim it passed.

Run once on the final change state. Fix critical/major findings and refresh evidence affected by behavioural edits. The critic does not replace or enlarge the validator set selected by `verification-policy.md` and does not waive parent review or completion evidence.
