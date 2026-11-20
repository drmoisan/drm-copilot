# Pre-Remediation Working-Tree Baseline — Issue #440 F7 Remediation Cycle 1

- **Task:** [P0-T12]
- **Plan of record:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md`

Timestamp: 2026-08-09T00-28

Commands: `git status --porcelain` and `git diff --stat` (both run from the repository root)

EXIT_CODE: 0 (both commands)

## Branch Precondition

`git rev-parse HEAD` reports `c939b5b80c8c297db49febaebdd35dda2c869a3f`, which is the merge base. **This branch has zero commits.** Every path produced by the original plan `plan.2026-08-07T11-10.md` (53/53 tasks complete) is therefore uncommitted working-tree state, not committed state. Consequently **every later scope check in this cycle must be a DELTA against the baseline set recorded below, never an absolute path list**, because an absolute path list would name the original plan's 31 entries and be unsatisfiable.

## Ordering Interaction with [P0-T3] — recorded explicitly

The plan's stated task order places [P0-T3] (`npm run format`, Prettier in **write** mode) before [P0-T12]. Per the plan's authority, the stated order was followed. Two mitigations make the recorded baseline exact rather than approximate:

1. **A pristine capture was taken before any command in this cycle ran and before any file in this cycle was created or modified.** That capture is recorded in the "Pristine capture" section below. It precedes [P0-T1]'s artifact write, [P0-T2]'s `npm ci`, and [P0-T3]'s Prettier write.
2. **[P0-T3] rewrote nothing.** Prettier reported `(unchanged)` for all 341 files in its extension scope and exited 0 (see `ts-format.2026-08-08T23-15.md`). The post-[P0-T3] status set is byte-identical to the pristine capture.

The capture taken at [P0-T12] itself, after [P0-T1] through [P0-T11], is also byte-identical to the pristine capture. All three captures agree, so the interaction had no effect on the baseline. The reason evidence writes do not perturb the entry set is that `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/` is already a single untracked-directory entry (`??`) in the baseline, and the plan file itself is already a single untracked-file entry, so writes inside either add no new porcelain entry.

`npm ci` in both scopes likewise added no entry: both `node_modules` trees are gitignored, confirmed by the post-install count of 31.

## Pristine capture — `git status --porcelain`

Taken before any command in this cycle. **Entry count: 31** (17 modified tracked, 14 untracked).

```
 M .claude/hooks/enforce-epic-invocation-origin.ps1
 M .claude/settings.json
 M .claude/skills/parallel-orchestrate/SKILL.md
 M docs/features/active/2026-08-07-parallel-enforcement-hooks-440/plan.2026-08-07T11-10.md
 M docs/features/active/2026-08-07-parallel-enforcement-hooks-440/spec.md
 M docs/features/active/2026-08-07-parallel-enforcement-hooks-440/user-story.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-invocation-origin.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/settings.json
 M extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
 M extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
 M extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
 M scripts/dev_tools/validate_parallel_orchestrator_state.py
 M scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 M tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1
 M tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
 M tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py
 M tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_structures.py
?? .claude/hooks/enforce-parallel-cohort-barrier.ps1
?? .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/code-review.2026-08-08T23-10.md
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/feature-audit.2026-08-08T23-10.md
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/policy-audit.2026-08-08T23-10.md
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-inputs.2026-08-08T23-10.md
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md
?? extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1
?? extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
?? scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py
?? tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1
?? tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
?? tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py
```

## Capture at [P0-T12] — `git status --porcelain`

**Entry count: 31.** Byte-identical to the pristine capture above; the same 31 lines in the same order. Reproduced here for completeness:

```
 M .claude/hooks/enforce-epic-invocation-origin.ps1
 M .claude/settings.json
 M .claude/skills/parallel-orchestrate/SKILL.md
 M docs/features/active/2026-08-07-parallel-enforcement-hooks-440/plan.2026-08-07T11-10.md
 M docs/features/active/2026-08-07-parallel-enforcement-hooks-440/spec.md
 M docs/features/active/2026-08-07-parallel-enforcement-hooks-440/user-story.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-invocation-origin.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/settings.json
 M extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
 M extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
 M extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
 M scripts/dev_tools/validate_parallel_orchestrator_state.py
 M scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 M tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1
 M tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
 M tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py
 M tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_structures.py
?? .claude/hooks/enforce-parallel-cohort-barrier.ps1
?? .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/code-review.2026-08-08T23-10.md
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/feature-audit.2026-08-08T23-10.md
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/policy-audit.2026-08-08T23-10.md
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-inputs.2026-08-08T23-10.md
?? docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md
?? extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1
?? extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
?? scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py
?? tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1
?? tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
?? tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py
```

## Capture at [P0-T12] — `git diff --stat`

**Entry count: 17 tracked files changed, 471 insertions, 112 deletions.** Byte-identical to the pristine capture.

```
 .claude/hooks/enforce-epic-invocation-origin.ps1   |  34 +++--
 .claude/settings.json                              |  17 +++
 .claude/skills/parallel-orchestrate/SKILL.md       |  50 ++++++-
 .../plan.2026-08-07T11-10.md                       | 106 +++++++-------
 .../spec.md                                        |  32 ++---
 .../user-story.md                                  |  32 ++---
 .../hooks/enforce-epic-invocation-origin.ps1       |  34 +++--
 .../claude-customizations/.claude/settings.json    |  17 +++
 .../.claude/skills/parallel-orchestrate/SKILL.md   |  50 ++++++-
 .../claude-customizations/pack-manifests/core.json |   2 +
 .../PoshQC/settings/pester.runsettings.psd1        |   7 +
 .../validate_parallel_orchestrator_state.py        |   4 +
 .../PoshQC/settings/pester.runsettings.psd1        |   7 +
 .../enforce-epic-invocation-origin.Tests.ps1       | 154 +++++++++++++++++++++
 .../parallel_orchestrator_surface_expectations.py  |   8 ++
 ...test_parallel_orchestrator_surface_contracts.py |   8 +-
 ...idate_parallel_orchestrator_state_structures.py |  21 ++-
 17 files changed, 471 insertions(+), 112 deletions(-)
```

Note that `git diff --stat` reports only tracked modifications; the 14 untracked entries appear in `git status --porcelain` but not here. That asymmetry is why both outputs are recorded.

## This Baseline Is the Comparison Basis for [P3-T4] and [P4-T12]

**[P3-T4] and [P4-T12] compare against this set.** Both tasks compute the DELTA of their own `git status --porcelain` and `git diff --stat` captures against the 31-entry status set and the 17-file diff set recorded above. Neither may assert an absolute path list.

Facts about the baseline that both tasks depend on:

- **`.claude/skills/parallel-orchestrate/SKILL.md` appears in the baseline set** (as ` M`, and its mirror as ` M` under `extensions/drm-copilot/resources/claude-customizations/`). It is modified by the **original** plan and must be unchanged by this cycle, so the reserved sections `## Mutation Protocol (F6)` and `## Radius Drift Detection (F8)` are untouched. Its presence in the delta as an *additional* change would be a violation; its presence in the *baseline* is expected.
- **`scripts/dev_tools/validate_parallel_orchestrator_state.py` appears in the baseline set** with a 4-line insertion — the original plan's Python F7 seam fill. It is on this cycle's no-touch list, so its diff must remain exactly 4 insertions.
- **`tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_structures.py` appears in the baseline set** with a 21-line change — the Python-side cohort recolour that [P1-T3] mirrors on the TypeScript side. It must not change further in this cycle.
- **`.claude/settings.json`, both `pester.runsettings.psd1` files, `pack-manifests/core.json`, the two parallel hooks and their mirrors, and the Python cohort-barrier helper and its test** are all original-plan baseline entries, not this cycle's delta.

The paths this cycle is expected to ADD to the delta are exactly: `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-cohort-barrier.ts` (new); `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` (newly modified, two added lines); `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-structures.test.ts` (newly modified); `extensions/drm-copilot/jest.config.cjs` (newly modified); `extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts` and `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-cohort-barrier.test.ts` (new); `tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py` (new); `tests/fixtures/parallel_cohort_barrier/` (new corpus); and this feature's own plan and evidence artifacts, which are already covered by existing untracked entries.
