## Context

The fork tree already contains the current upstream changes, but a privacy rewrite severed all shared ancestry. Direct tree comparison therefore shows the complete fork delta while normal ahead/behind and merge-base operations fail. The repository also has drift between executable installers and maintainer documentation, and OpenSpec 1.4 rejects the comment-only `openspec/config.yaml` as a non-object.

Cross-client research identified recurring operational failures: long sessions, repeated context, polling, unchanged retries after errors, success reports that hide tool failures, exploration/apply confusion, and excessive orchestration. Existing rules cover several of these, so the change must audit before adding text.

## Goals / Non-Goals

**Goals:**

- Restore a durable upstream ancestry baseline without changing the fork tree.
- Make active fork documentation describe current executable behavior.
- Keep rule additions minimal and non-duplicative.
- Verify both installer channels only in disposable fixtures.

**Non-Goals:**

- MCP workspace modernization.
- DSH adapter or profile implementation.
- Plugin installation or changes to `$DSH_HOME`.
- Updates to real target projects or a real 1C pilot.
- Refactoring the large fork deployment commands in the same change.

## Decisions

1. **Use an ancestry-only merge after safeguards.** Create a backup branch and tag, then merge current `origin/main` with the `ours` strategy and `--allow-unrelated-histories`. Compare tree ids before and after. This records that the already patch-equivalent upstream tip is incorporated without replaying or replacing fork content. Rebase/replay was rejected because it would rewrite the public fork again and make rollback harder.

2. **Treat direct tree diff as the fork delta.** After the bridge merge, future comparisons use the new merge base. Before it, patch-id equivalence and `origin/main..main` tree comparison are the evidence.

3. **Separate active debt from history.** `FORK-TODO.md` keeps a short active section first; resolved and superseded entries remain explicitly historical rather than acting as current instructions.

4. **Audit execution discipline before editing rules.** Map every reported failure to an existing normative rule. Add language only where no clear SHALL-style behavior exists, preferring focused workflow rules over enlarging `AGENTS.md`, which is already near its byte ceiling.

5. **Keep routine orchestration single-model.** The experimental Sol/GLM/Kimi/Terra/Luna hypothesis is not made a default. Multiple senior-model opinions are reserved for material, explicit decision forks; routine work uses one suitable tier and normal validator evidence.

6. **Validate through disposable fixtures.** Run repository validation and both installers against temporary directories with isolated HOME where needed. Do not run update against any registered real project.

## Risks / Trade-offs

- **An `ours` merge could accidentally accompany tree changes** → capture and compare tree ids and abort if they differ.
- **Historical notes may still be read as current policy** → add explicit active/history structure and superseded labels.
- **More rules could worsen context cost** → modify focused on-demand files only and measure `AGENTS.md` bytes.
- **Installer smoke tests may write user-scope Codex paths** → use an isolated temporary HOME.
- **Large deployment-command drift remains** → keep it as named active debt for a separate OpenSpec change.

## Migration Plan

1. Preserve the pre-change tip with branch and tag.
2. Create and validate this OpenSpec change.
3. Record the ancestry-only merge and verify unchanged tree id.
4. Apply documentation and minimal rule corrections in focused commits.
5. Run structural validation and disposable installer smoke tests.
6. Roll back by resetting the maintenance branch to the backup reference; the original `main` remains untouched until explicit integration.

## Open Questions

None for this change. DSH model assignments and MCP modernization remain decisions for later workspaces/stages.
