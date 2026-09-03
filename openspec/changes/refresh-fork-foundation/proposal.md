## Why

The fork contains the current upstream content but its rewritten history has no common ancestor with `comol/ai_rules_1c`, so ordinary divergence checks and future merges are unsafe. Maintainer documentation also contradicts the implemented installers and current artifact inventory, while several cross-client execution failures identified during research need to be checked against the existing rules before DSH work begins.

## What Changes

- Re-establish a non-destructive Git ancestry link to the current upstream tip while preserving the fork tree exactly.
- Separate active fork debt from historical notes and update maintainer-facing documentation to match the implemented installers, validators, CI policy, and artifact inventory.
- Repair baseline structural defects that prevent current OpenSpec tooling or repository checks from passing.
- Audit the rules for bounded sessions and delegation, no polling, no unchanged retries after tool errors, explicit failure propagation, exploration/apply separation, and low-noise user interaction; add only missing behavioral constraints.
- Verify the PowerShell and Bash installation channels in temporary projects without updating real target projects.
- Keep MCP modernization, DSH integration, plugin installation, and real 1C pilot work outside this change.

## Capabilities

### New Capabilities

- `fork-maintenance-baseline`: Maintainers can establish and verify an upstream-connected, internally consistent fork baseline before subsequent feature work.
- `agent-execution-discipline`: Rules explicitly prevent repeated context/tool work, hidden tool failures, polling loops, exploration/apply confusion, and unjustified multi-model orchestration where existing guidance is insufficient.

### Modified Capabilities

- `subagent-model-routing`: Clarify that expensive joint evaluation is reserved for material decisions and that routine work uses one appropriate tier/model.

## Impact

Affected areas include Git maintenance history, `FORK-TODO.md`, repository and installer documentation, shared execution/delegation rules, OpenSpec configuration and artifacts, and temporary installer smoke-test procedures. No MCP workspace, DSH runtime/profile, installed plugin, real target project, or 1C source tree is changed.
