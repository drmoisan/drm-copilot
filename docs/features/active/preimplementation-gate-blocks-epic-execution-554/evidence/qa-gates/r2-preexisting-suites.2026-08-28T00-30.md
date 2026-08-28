# Remediation Cycle 2 — The Six Pre-Existing Suites Are Unmodified and Passing

Timestamp: 2026-08-28T02-15
Task: [P3-T9]
Command: `git diff --name-only HEAD`, plus `git diff --name-only 9fed8b9074354ac91b35dc6756fcf4935cfc1c89` (the cycle-inclusive listing, see the note below), plus `git status --porcelain`, plus an ElementTree read of `artifacts/pester/pester-junit.xml` produced by the [P3-T4] run
EXIT_CODE: 0

## The six pre-existing suites (prohibition 3)

1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`
2. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`
4. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
5. `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`
6. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`

---

## Check 1 — the name-listing diffs name none of the six

### `git diff --name-only HEAD`

```
docs/features/active/preimplementation-gate-blocks-epic-execution-554/remediation-plan.2026-08-28T00-30.md
```

One path. **None of the six appears.**

### Cycle-inclusive listing: `git diff --name-only 9fed8b9074354ac91b35dc6756fcf4935cfc1c89`

**Why this second listing is recorded.** The plan's acceptance condition was written on the
assumption that no task stages or commits, in which case `git diff --name-only HEAD` observes every
tracked change this cycle made. The calling directive instead requires a commit and push at the end
of each phase, so at this point in Phase 3 the Phase 1 and Phase 2 edits are already committed and a
two-dot diff against `HEAD` can no longer observe them. `9fed8b9074354ac91b35dc6756fcf4935cfc1c89` is
the branch head at the moment this cycle began, recorded at [P0-T3]; a diff against it observes the
whole cycle. Both listings are recorded so the assertion is made against the complete set rather than
against a residue.

```
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-batch-budget-reset.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-claude-classifier-line-count.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-claude-classifier-suite-run.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-codex-suite-line-count.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-codex-suite-run.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-codex-gate-uncovered.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-instructions-read.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-analyze.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-format.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-test-coverage.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-requirements-sources.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-revision-anchors.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-test-suite-line-counts.2026-08-28T00-30.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/remediation-plan.2026-08-28T00-30.md
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
```

Eighteen paths. The only two `.ps1` paths are the two **branch-created** suites this plan is
authorized to edit. **None of the six pre-existing suites appears.**

---

## Check 2 — the porcelain companion names none of the six

**Why the porcelain companion is required.** A name-listing diff enumerates tracked changes only and
can never report an untracked path, so a suite removed and recreated as an untracked file would be
invisible to the diff alone.

`git status --porcelain`, with each line's **three-character status-and-separator prefix** stripped
before the path is read — the two-character `XY` status field at positions 0 and 1 followed by a
single separator space at position 2, with the path beginning at position 3:

| Raw prefix | Path after the three-character strip |
| --- | --- |
| `` ` M ` `` | `docs/features/…/remediation-plan.2026-08-28T00-30.md` |
| `?? ` | `docs/features/…/evidence/qa-gates/coverage-delta.2026-08-28T00-30.md` |
| `?? ` | `docs/features/…/evidence/qa-gates/r2-codex-gate-coverage-probe.2026-08-28T00-30.md` |
| `?? ` | `docs/features/…/evidence/qa-gates/r2-false-claim-corrections.2026-08-28T00-30.md` |
| `?? ` | `docs/features/…/evidence/qa-gates/r2-final-poshqc-analyze.2026-08-28T00-30.md` |
| `?? ` | `docs/features/…/evidence/qa-gates/r2-final-poshqc-format.2026-08-28T00-30.md` |
| `?? ` | `docs/features/…/evidence/qa-gates/r2-final-poshqc-test-coverage.2026-08-28T00-30.md` |
| `?? ` | `docs/features/…/evidence/qa-gates/r2-final-single-pass-confirmation.2026-08-28T00-30.md` |
| `?? ` | `docs/features/…/evidence/qa-gates/r2-final-typecheck-not-applicable.2026-08-28T00-30.md` |

Nine paths, all under the feature evidence tree. **None of the six pre-existing suites appears**, and
no `?? tests/…` line is present.

**The prefix is three characters, not two.** Stripping only two would leave a leading space on every
path, which would make each equality test against a path fail and would let a deleted-and-recreated
suite appearing as an untracked `?? tests/…` line pass this check unnoticed.

---

## Check 3 — the [P3-T4] run reports zero failures in all six

Read from `artifacts/pester/pester-junit.xml`, the JUnit result the [P3-T4] run wrote.

Run root element: `tests="3827" errors="0" failures="0" disabled="9" time="115.609"`.

| Suite | Present in the run | Tests | Failures | Errors |
| --- | --- | --- | --- | --- |
| `enforce-orchestration-preimplementation-gate.Tests.ps1` | FOUND | 35 | **0** | 0 |
| `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | FOUND | 58 | **0** | 0 |
| `enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | FOUND | 33 | **0** | 0 |
| `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | FOUND | 58 | **0** | 0 |
| `PreToolUseSchema.Contract.Tests.ps1` | FOUND | 15 | **0** | 0 |
| `legacy-codex-hook-contracts.Tests.ps1` | FOUND | 43 | **0** | 0 |

All six were executed by the [P3-T4] run and all six report **zero failures and zero errors**.

The sixth suite, `legacy-codex-hook-contracts.Tests.ps1`, is the one that would break if
`Test-PreparationModeDelegation` were deleted from the production copies. Its 43 passing cases
confirm the production-side alternative was correctly not taken (prohibition 7).

---

Output Summary: **All six pre-existing suites are unmodified and passing.** Neither name-listing
diff names any of the six, the porcelain companion (three-character prefix stripped) names none of
the six and shows no untracked `tests/` path, and the [P3-T4] JUnit result records all six as present
with **0 failures and 0 errors** across 242 cases. EXIT_CODE 0.
