## Context

The common ancestor is `4aef5ca`; the chosen upstream tip is `45bacdd`. The trial merge reports 63 conflicting paths, including 38 OpenSpec bundle paths. The untracked `content/rules/system-safety.md` belongs to prior work and must remain byte-identical.

## Goals / Non-Goals

Goals: upstream-owned core files, one installer engine, one converter canon, retained client-specific routing and Koda, preserved configured endpoints.
Non-goals: real deployments, network MCP mutations, Git publication, or user-scope installation outside disposable fixtures.

## Decisions

1. Resolve common core conflicts from upstream, then reapply only documented fork capabilities. Restore the upstream OpenSpec bundle and refresh scripts without retaining historical generated edits.
2. Replace the 816-line Bash/Python installer with an argument-safe wrapper invoking PowerShell 7. Preserve target/tools/host/publish-url options; use init or update according to the target manifest. This trades a runtime prerequisite for one maintained implementation.
3. Keep per-client model overrides in the installer and document their precedence. Keep Koda registration instructions and canonical adapter locations.
4. Put converter mapping and Linux invocation guidance in `linux-converter.md`; command hooks inherit upstream source-selection, safety, retry and verification requirements. Converter load and apply must be separate where applicability checks are required; do not bypass those checks with automatic apply.
5. Adopt upstream verification depth policy. Make the extra external critic opt-in and respect upstream reviewer model selection; it never changes the selected validator set.
6. Existing per-server client endpoints and authentication remain authoritative, including custom managed endpoints. Retain non-managed entries and sibling configuration. Host/publish-url options supply defaults for missing connections, not replacements for configured connections.
7. Source defaults remain portable. Runtime-specific host/port/beta deployment details stay outside the published rules catalog.

## Risks / Trade-offs

- PowerShell 7 is required by the Bash wrapper: report an absent executable before writes; document the dependency.
- A textual merge can preserve obsolete fork hooks: compare modified common files with upstream and run structural validation.
- Converter scripts are external: carry existing documented mappings, require capabilities to be checked at execution time, and fall back to the upstream deployment route when split load/check/apply is unavailable.
- Installation can write Codex user-scope files: isolate user home and XDG paths in every fixture.

## Migration Plan

Use the dedicated branch and the external pre-change snapshot. Resolve the merge without committing, implement adaptations, and validate in temporary projects. Rollback consists of discarding this branch's changes after preserving the user's untracked file. Real project updates require a separate requested operation.

## Open Questions

None. The user accepted the assessed upstream integration and bounded adaptation strategy.

## Context sources

Git tree comparison, installer/adapters, current converter commands, upstream verification and MCP deployment rules. No application metadata or newly invented platform API is involved.
