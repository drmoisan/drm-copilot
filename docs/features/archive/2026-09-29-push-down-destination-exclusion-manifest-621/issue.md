# Push-down reintroduces reference-repo governance content already excluded by a prior repo-specific decision (#621)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Active
- Source issue: #621 (filed directly on GitHub; this entry is authored from the issue body after the fact)
- Epic: push-down-payload-correctness (#770)

- Work Mode: full-feature

## Problem / Why

The Claude push-down does not preserve a destination repository's prior, repository-specific exclusion decisions. Content that a destination explicitly opted out of during an earlier sync is reintroduced by a later push-down, and nothing records that the exclusion decision existed or that it should be respected.

Concrete instance (TaskMaster). In 2026-06, TaskMaster's `.claude/` governance was synced from a reference repository under the directive "keep current policy, adapt mechanism" (TaskMaster issue #178, PR #179). That sync deliberately excluded the reference repository's coverage model: `.claude/rules/quality-tiers.md`, the 85% line / 75% branch coverage floor, and the T1-T4 `quality-tiers.yml` tier-classification system. TaskMaster kept its own 80% line / 90% new-module policy. As of 2026-09, `.claude/rules/quality-tiers.md` is present in TaskMaster again. It asserts the 85%/75% floor and requires a `quality-tiers.yml` at the repository root, which TaskMaster does not have.

Impact:

- Two conflicting coverage floors are simultaneously presented as authoritative in the destination (`CLAUDE.md`: 80%/90%; `quality-tiers.md`: 85%/75%), with no signal to an agent about which one governs.
- The reintroduction is not visible at push-down time. The push-down does not check a destination's prior exclusion decisions before writing `.claude/rules/**`.
- Any destination that has made a deliberate, documented divergence from the bundled defaults can have that divergence reverted by the next push-down.

Evidence: found during the `bugs-638-644-647` parallel-orchestration run in TaskMaster (2026-09-01), reported independently by two execution children as a repository-level finding unrelated to their own item work.

## Proposed Behavior

- A destination repository carries a durable, destination-side manifest of paths it has deliberately excluded from push-down.
- The manifest lives at a location that the push-down itself never writes, merges, or deletes, so the record survives every subsequent push-down.
- Both push-down implementations (TypeScript `extensions/drm-copilot/src/lib/push-down/*` and Python `scripts/dev_tools/push_down_claude_customizations.py`) read the manifest before the write and merge step.
- A payload path that matches a manifest entry is skipped. The skip is reported in the push-down result (CLI output, MCP result, extension UI), and the push-down never overwrites an excluded path silently.
- Exclusion applies ahead of merged paths (for example `config/orchestration-routing.json` and `config/blast-radius.json`); the interaction with merges and with derived artifacts such as the blast-radius configuration is defined explicitly.
- When the manifest is absent, push-down behavior is identical to today.

## Acceptance Criteria

- [ ] A documented manifest format, location, and path/glob semantics exist, and the location is never written by a push-down.
- [ ] Both implementations skip every payload path matched by the manifest and report each skipped path.
- [ ] A payload path that matches the manifest while the destination file exists is never overwritten; a conflict is reported instead of silently resolved.
- [ ] Absent-manifest behavior is byte-for-byte identical to the current behavior in both implementations.
- [ ] The Python/TypeScript parity test covers exclusion semantics and fails on any divergence.
- [ ] A malformed manifest fails fast with a specific error rather than being ignored.

## Constraints & Risks

- Depends on #507 (Python publishes `config/` and merges `config/orchestration-routing.json`; parity test over roots and merged paths) and #508 (generalized merged-path set, blast-radius merge). The exclusion filter sits ahead of that pipeline.
- Pushed-down enforcement hooks must not gain Python legs.
- No production file may exceed 500 lines; `push_down_claude_customizations.py` is already about 400 lines, so new logic likely needs its own module.
- Glob semantics must be identical in Python and TypeScript; divergent matcher libraries are a parity risk.
- Excluding a path that other pushed-down content references (for example a rule referenced by an agent) can leave dangling references; the design must state whether this is reported.
- Issue #769 files (`.claude/hooks/enforce-powershell-batch-budget.ps1` and its tests) are out of scope.

## Test Conditions to Consider

- [ ] Unit coverage: manifest parsing (valid, empty, malformed, comments), glob matching (exact file, directory prefix, wildcard), filter application ahead of writes and merges.
- [ ] Integration scenarios: push-down into a destination with an exclusion for `.claude/rules/quality-tiers.md`, with and without the file present; exclusion of a merged path.
- [ ] Parity: identical skip sets and reports from Python and TypeScript for a shared fixture.
- [ ] CLI/API examples: Python CLI output and MCP push-down result listing excluded paths.

## Next Step

- [x] GitHub issue already exists (#621); no promotion call is made.
- [ ] Create `docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/` from the template
