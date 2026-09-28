# Codex Surface Untouched and Still Green (P5-T10)

Timestamp: 2026-08-28T11-36

Task: [P5-T10]
Issue: #573
Acceptance criterion discharged: AC-13
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command:
1. Confirmation read from the [P5-T4] run record (`artifacts/pester/pester-junit.xml`, written 12:08): `grep -o 'testsuite name="[^"]*epic-execution-gates.Tests.ps1" tests="[0-9]*" errors="[0-9]*" failures="[0-9]*"' artifacts/pester/pester-junit.xml`
2. `git diff --name-only c7133fe75ce1ea1737843330b2232c175a689e37 | grep -i codex`

EXIT_CODE: 0

## The codex gate suite reports zero failures

Verbatim from the [P5-T4] run record:

```
testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a691c7afb3cd3aa84\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1" tests="40" errors="0" failures="0"
```

| Metric | Baseline ([P0-T4]) | Post-change ([P5-T4]) |
| --- | --- | --- |
| Tests | 40 | 40 |
| Errors | 0 | 0 |
| **Failures** | **0** | **0** |

`tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` passes unmodified with **zero failures**, and its test count is unchanged at 40. That suite asserts the `EPIC_WORKTREE_REMOVAL_BLOCKED` token against the codex gate, which this change leaves alone, so its continued green result is the positive evidence that the codex behaviour is unaffected.

## No codex hook file and no codex bundle file was edited

`git diff --name-only` against the merge base `c7133fe75ce1ea1737843330b2232c175a689e37`, filtered case-insensitively for `codex`, produced **no output** and exited 1 (no match). Neither of the two paths named as out of scope appears in the diff:

- `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` — not in the diff.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` — not in the diff.

No other path under the codex hook tree, the codex bundle tree, or the `.agents` surface appears either. This is re-checked from the authoritative whole-change enumeration at [P5-T11].

## Why the codex copies were left alone

The exclusion is a settled decision, recorded in the plan and the spec, not an omission:

- The codex runtime has no parallel surface at all — no `enforce-parallel-*` hook, no parallel orchestrator agent, no parallel skill, and no parallel hook registered in its configuration. A parallel branch there would be unexercisable.
- The codex gate is a materially different implementation from the `.claude` gate, using a silent-allow protocol, absolute-path resolution against the payload working directory, and no shared payload module. A branch added there would be new logic rather than a mirrored edit, creating a second implementation of the allow rule that can drift.
- The landed convention is decisive: when the parallel surface added an allow-branch to the epic **merge** gate, it added it to the `.claude` copy only. This gate follows that convention.

Output Summary: PASS (AC-13). The codex gate suite `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` reports 40 tests with **zero failures** and zero errors in the [P5-T4] run, unchanged from the [P0-T4] baseline of 40/0, and it passes unmodified. A case-insensitive filter for `codex` over the merge-base-anchored `git diff --name-only` produced no output and exited 1, so no codex hook file, no codex bundle file, and no `.agents` file was edited by this change.
