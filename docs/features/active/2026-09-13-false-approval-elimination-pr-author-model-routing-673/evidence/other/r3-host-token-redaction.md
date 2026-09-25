# Host-Token Redaction Log (issue #673)

Timestamp: 2026-09-19T17-43

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-redact.ps1` (route `a`), with the sixteen repository-relative target paths supplied as a semicolon-separated list; then `pwsh -NoProfile -File <SCRATCHPAD>/r3-host-tokens.ps1` over the whole feature folder to verify; then a decision-token comparison of the two control-pair artifacts against `git show HEAD:<path>`.

EXIT_CODE: 0

## Scope

The redaction set is the sixteen files `[P0-T16]` listed with a non-zero count, less the three superseded plans the plan of record excludes by name: `plan.2026-09-13T20-48.md`, `plan.2026-09-18T13-30.md`, and `plan.2026-09-18T16-00.md`. Two of those three had non-zero counts and are excluded here; the third had a zero count. None of the three is edited.

## Replacement order

Values were computed at run time and were never written. The order is fixed so that a narrower rule cannot consume a wider one, and each literal is applied in all three spellings that occur on this platform — both separator forms and the POSIX-shell drive spelling:

1. each of the 74 registered worktree roots, longest first, so a root that is a prefix of another cannot win → `<WORKTREE_ROOT>`
2. the user profile directory → `<HOME>`
3. a program-files prefix → `<PROGRAM_FILES>`
4. remaining occurrences of the account name → `<USER>`
5. any remaining match of the three `[P0-T16]` path regexes, consumed up to the next whitespace, quote, or backtick → `<HOST_PATH>`

## Per-file replacement counts

No matched token is reproduced, per binding rule 6.

| File | `<WORKTREE_ROOT>` | `<HOME>` | `<PROGRAM_FILES>` | `<USER>` | `<HOST_PATH>` |
| --- | --- | --- | --- | --- | --- |
| `evidence/baseline/execution-route.md` | 3 | 10 | 1 | 10 | 0 |
| `evidence/baseline/phase0-base-ref.md` | 2 | 0 | 0 | 0 | 0 |
| `evidence/baseline/phase0-mirror-gate.md` | 1 | 0 | 0 | 0 | 0 |
| `evidence/baseline/phase0-pester-coverage.md` | 4 | 1 | 1 | 1 | 0 |
| `evidence/baseline/phase0-poshqc-analyze.md` | 3 | 1 | 1 | 1 | 0 |
| `evidence/baseline/phase0-poshqc-format.md` | 3 | 0 | 0 | 0 | 0 |
| `evidence/baseline/phase0-python-free-guard.md` | 3 | 1 | 0 | 1 | 0 |
| `evidence/baseline/phase0-worktree-status.md` | 1 | 0 | 0 | 0 | 0 |
| `evidence/baseline/repro-3-2-control-pair.md` | 1 | 4 | 1 | 4 | 0 |
| `evidence/baseline/repro-3-4-control-pair.md` | 1 | 3 | 1 | 3 | 0 |
| `evidence/baseline/repro-fixture-manifest.md` | 0 | 3 | 1 | 3 | 0 |
| `evidence/other/f1-manifest-registration.md` | 3 | 1 | 0 | 1 | 0 |
| `evidence/other/payload-derivability-results.md` | 2 | 0 | 0 | 0 | 0 |
| `evidence/other/payload-sample-inventory.md` | 1 | 0 | 0 | 0 | 0 |
| `evidence/other/phase1-evidence-commit.md` | 1 | 2 | 0 | 2 | 0 |
| `research/2026-09-13T22-10-false-approval-elimination-research.md` | 1 | 0 | 0 | 0 | 1 |

All paths are relative to `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/`.

FILES_REDACTED: 16

The single `<HOST_PATH>` replacement, in the research record, is a residual path that matched a `[P0-T16]` regex after all four literal rules had run; that is the case rule 5 exists for, and it confirms the residual matcher is not dead code.

## Verification 1 — the counters now return zero for every redacted file

Re-running the `[P0-T16]` scan over the whole feature folder after redaction:

```
FILES_SCANNED: 50
MATCHER_TOTALS: m1=3 m2=3 m3=1 m4=1
```

Only two files are still reported, and both are excluded superseded plans:

| File | Lines matching any matcher | m1 | m2 | m3 | m4 |
| --- | --- | --- | --- | --- | --- |
| `plan.2026-09-13T20-48.md` | 2 | 1 | 1 | 1 | 1 |
| `plan.2026-09-18T13-30.md` | 4 | 2 | 2 | 0 | 0 |

Every one of the sixteen redacted files now returns 0 under all four matchers, which is this task's first acceptance condition. The pre-redaction totals were `m1=54 m2=13 m3=56 m4=55`; the residue is exactly the two excluded plans' contribution. The scanned-file count rose from 46 to 50 because four `r3-` artifacts were written between the two scans; all four return 0.

## Verification 2 — permission decisions and reason codes are unchanged

Compared against `git show HEAD:<path>` for both control-pair artifacts:

| Artifact | Token | Count before | Count after |
| --- | --- | --- | --- |
| `evidence/baseline/repro-3-2-control-pair.md` | `permissionDecision":"allow` | 2 | 2 |
| `evidence/baseline/repro-3-2-control-pair.md` | `permissionDecision":"deny` | 2 | 2 |
| `evidence/baseline/repro-3-4-control-pair.md` | `permissionDecision":"allow` | 2 | 2 |
| `evidence/baseline/repro-3-4-control-pair.md` | `permissionDecision":"deny` | 2 | 2 |
| `evidence/baseline/repro-3-4-control-pair.md` | `MODEL_ROUTING_RECEIPT_BLOCKED` | 2 | 2 |

Neither artifact carried a target-resolution reason code before or after, which is correct: both were recorded pre-#687, when no such code existed on the decision path.

Output Summary: Sixteen files redacted. Both acceptance conditions hold. Re-running the `[P0-T16]` matchers over the redacted files returns 0 for each; the only remaining host tokens in the feature folder are in the two excluded superseded plans, and their counts are unchanged from the pre-redaction inventory. Every `permissionDecision` value and every reason-code token in the two control-pair artifacts is unchanged against `git show HEAD:<path>`, so the archived AC-1 and AC-2 evidence retains its evidential content while losing its host data. No matched token is reproduced in this log.
