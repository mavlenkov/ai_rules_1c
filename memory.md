# Memory

This file is the working project memory for AI agents.

Eligibility, routing between this file and `1c-templates-mcp` (`remember` / `recall`),
fallback when the MCP server is unavailable — see `AGENTS.md → Project memory`.
There are no permanent entries yet.

Entry format (one entry = one self-contained rule). Use English for narrative,
preserve original 1C identifiers (objects, modules, attributes) as-is:

<!--
## YYYY-MM-DD — <short rule title>

- **Scope:** module / subsystem / object where the rule applies (e.g. `Документ.РеализацияТоваровУслуг`).
- **Rule:** what must / must not be done.
- **Why:** consequence of violation (production breakage / data loss / regulatory / data leak).
- **Source:** user request, incident, or external document that established the rule.
-->
## Captured during work (no remember available)

<!-- Populated only when `1c-templates-mcp` is offline; migrate to `remember` once it is back. -->

### 2026-08-07 — Preserve MCP endpoint addresses during rules updates

- Mass deployment of 1c-rules must preserve each project's existing MCP server URLs and hosts. The managed MCP host for the nine deployed projects is `mcp-host` (`MCP_HOST=mcp-host`). Do not regenerate MCP configs from catalog defaults (`localhost`) unless the user explicitly requests it; verify the existing per-project addresses before updating.

### 2026-09-03 — Keep modernization stages in separate workspaces

- **Scope:** Repository modernization roadmap.
- **Rule:** Update `ai_rules_1c` first; modernize MCP in its own Workspace; then add minimal DSH support here. Pilot DSH on a real 1C task only in a separate Workspace bound to that specific 1C project. Do not build a new dispatcher or heavy agent-bus architecture.
- **Why:** Keeps infrastructure changes isolated from production project work and prevents the research prototype from expanding before a real pilot validates it.
- **Source:** Direct user clarification during the foundation refresh.
