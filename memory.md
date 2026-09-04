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

- Mass deployment of 1c-rules must preserve each project's existing MCP server URLs, hosts, ports, transports, and authentication settings. Values in `content/mcp-servers.json` are installer placeholders/defaults, not evidence of production endpoints. For MCP modernization, deployed Workspace configuration is authoritative evidence of the current connectivity baseline; use the catalog only for server identities, expected capabilities, and config shape. Never replace working endpoints with catalog values merely because the catalog is newer. This does not freeze the MCP implementation or architecture: each MCP repository evolves independently and its upstream/fork divergence must be audited. A server may be substantially redesigned or replaced when justified by evidence and covered by an approved compatibility, migration, validation, and rollback plan.

### 2026-09-03 — Keep modernization stages in separate workspaces

- **Scope:** Repository modernization roadmap.
- **Rule:** Update `ai_rules_1c` first; modernize MCP in its own Workspace; then add minimal DSH support here. Pilot DSH on a real 1C task only in a separate Workspace bound to that specific 1C project. Do not build a new dispatcher or heavy agent-bus architecture.
- **Why:** Keeps infrastructure changes isolated from production project work and prevents the research prototype from expanding before a real pilot validates it.
- **Source:** Direct user clarification during the foundation refresh.
- **State (2026-09-04):** Stage 1 is complete and published: local `main` and `mavlenkov/main` both point to `3d8e965`; the OpenSpec change is archived. The next active stage is the MCP modernization in a separate Workspace.

### 2026-09-04 — Evaluate vendor deployment and project ownership for MCP

- **Scope:** MCP modernization in the separate MCP Workspace.
- **Rule:** Inspect and use the agent deployment instruction shipped inside the Workspace archive `MCP_Distr.zip`, adapting it to the actual MCP project rather than applying it blindly. Treat the archive as a vendor deployment source alongside current runtime evidence and each repository's upstream history. Explicitly compare maintaining the existing custom project/fork with migrating fully to the vendor's scheme; do not assume either outcome. The decision must cover required capabilities, retained local value, update and security burden, deployment/operations, compatibility, migration cost, validation, rollout, and rollback.
- **Why:** The vendor deployment model may make custom maintenance unnecessary, while project-specific capabilities may still justify a fork or a smaller compatibility layer.
- **Source:** Direct user clarification before starting the MCP audit.
