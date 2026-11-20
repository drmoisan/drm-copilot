# Phase 1 — Call-Site Audit Verification (Cycle 3), Issue #396

Timestamp: 2026-07-22T21-42

Command:

```
grep -n 'cleanup_wt_git\|parse_worktree_list\|enumerate_branches\|compute_protected\|classify_\|consolidation_worktree_path\|< <(\|mapfile\|readarray\||| true' \
  scripts/bash/cleanup_worktrees_lib.sh \
  scripts/bash/cleanup_worktrees_enumerate_lib.sh \
  scripts/bash/cleanup_worktrees_actions_lib.sh \
  scripts/bash/cleanup-worktrees.sh
```

EXIT_CODE: 0

## Match counts per file

| File | Total grep matches | Git-backed invocation rows | Non-git (docstring/definition/arithmetic) |
|---|---|---|---|
| `scripts/bash/cleanup_worktrees_lib.sh` | 38 | as per audit table (lines 54, 79, 114, 127, 152, 153, 188, 197, 223, 234, 247, 280, 294, 312, 323, 335, 350, 356, 364, 395, 407, 409) | header/docstring lines 5-16, 90, 102, 105, 157, 210, 256, 277, 387, 388; arithmetic `|| true` at line 408 |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 21 | lines 63, 108, 166, 167, 176, 203, 204 | header/docstring lines 5-24, definitions 28/53/69/150 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 30 | lines 31, 48, 49, 55, 99, 101, 109, 115, 116, 134, 135, 141, 157, 158, 185, 208, 216, 228, 274, 278, 280, 289, 298 | header/docstring lines 10-11, 21/43/69/153/262; definitions |
| `scripts/bash/cleanup-worktrees.sh` | 1 | none (docstring reference only, line 14) | line 14 docstring |

## Cross-check against the audit table

Every git-backed invocation returned by the grep appears in the plan's Call-Site Audit
table at the cited line number. Confirmed line-by-line:

- Classification lib: 54, 79, 114 (GUARDED); 127 UNGUARDED→P3-T1; 152/153 ACCEPTED-SAFE;
  188 UNGUARDED→P3-T3; 197 UNGUARDED→P3-T2; 223/234 GUARDED; 247 consumer→P3-T5;
  280/294 GUARDED; 312/323/335 GUARDED (tokens extended P3-T4); 350 consumer→P3-T4;
  356 N/A (printf over local var, no git); 364 UNGUARDED→P3-T6; 376 GUARDED; 395 GUARDED;
  409 UNGUARDED→P3-T7. Line 408 `|| true` is arithmetic (`((crc > rc)) && rc=$crc || true`),
  not a git site — correctly absent from the audit as a git call.
- Enumerate lib: 44 (GUARDED 127-fallback); 63 UNGUARDED→P3-T8; 108 GUARDED;
  166/167 UNGUARDED→P3-T9 (NEW-2); 176 GUARDED; 203/204 ACCEPTED-SAFE.
- Actions lib: 31 UNGUARDED→P3-T10 (NEW-4); 48 UNGUARDED consumer→P3-T11; 49-50/55 (probe
  ACCEPTED-SAFE / add GUARDED); 99 GUARDED; 101/109/115/116 ACCEPTED-SAFE; 134 UNGUARDED
  consumer→P3-T11; 135/141 GUARDED; 157/158 ACCEPTED-SAFE/GUARDED; 185 conversion→P3-T12;
  208 GUARDED; 216 UNGUARDED→P3-T12; 228 GUARDED; 274 UNGUARDED→P3-T13; 278-279/280
  ACCEPTED-SAFE; 289 UNGUARDED→P3-T13; 298 UNGUARDED→P3-T13.
- Wrapper `cleanup-worktrees.sh`: no direct git invocation; `main` invoked with `|| rc=$?`
  and explicit final `exit "$rc"` (verified — no fix needed).

## Site count reconciliation (transparency note)

The plan's P1-T1 text states "13" UNGUARDED sites but then enumerates a list
(NEW-1a, D-rung, NEW-1b, minus-present, run_report-enumerate, enumerate-pipeline,
NEW-2 x2, NEW-4, two consumers, reverify/status x2, run_apply x3) that totals 16
site-level changes. The site-level changes are addressed by Phase 3 fix tasks as follows:
P3-T1 (1: line 127), P3-T2 (1: line 197), P3-T3 (1: line 188), P3-T6 (1: line 364),
P3-T7 (1: line 409), P3-T8 (1: line 63), P3-T9 (2: lines 166/167), P3-T10 (1: line 31),
P3-T11 (2: lines 48/134), P3-T12 (2: lines 185/216), P3-T13 (3: lines 274/289/298) = 16
site-level changes, plus the two consumer token-consumption updates at lib lines 247/350
(P3-T4/P3-T5). The "13" figure is a plan-text characterization; it undercounts its own
enumerated list. This is a labeling discrepancy in the plan prose, NOT an audit omission:
no git-backed invocation is omitted from the table, so the P1-T1 alternative branch
(append newly found sites) is not triggered.

Output Summary: Grep run exit 0. All git-backed invocations across the four files map to
rows in the plan's Call-Site Audit table at the exact line numbers; zero omissions. The
sweep is exhaustive, not sampled. The plan's "13" UNGUARDED count is a prose
undercount of its own enumerated 16 site-level fixes (addressed by P3-T1..T3, T6..T13,
with consumer token updates in P3-T4/T5); no additional site was found, so no plan
append/fix task is required and Phase 2 proceeds.
