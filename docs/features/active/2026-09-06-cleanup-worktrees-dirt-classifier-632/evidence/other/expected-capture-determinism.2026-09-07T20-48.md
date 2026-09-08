# Expected-Output Capture Determinism

Timestamp: 2026-09-07T20-48
Tasks: [P2-T16], with the companion capture of [P2-T17]
Issue: #632

## Correction applied to the plan's capture command, and why it was necessary

The plan's [P2-T16] and [P2-T17] command blocks were authored against a tree that predates the merge of issue #631 into this branch's base commit `4ffe680e`. Run verbatim they would not have produced the reference bytes the whole byte-identity gate compares against. Two defects, both mechanical:

1. **Incomplete source chain.** The plan sources only `cleanup_worktrees_enumerate_lib.sh` and `cleanup_worktrees_lib.sh` for the report capture, and adds `cleanup_worktrees_actions_lib.sh` for the apply capture. After #631, `run_report` calls `run_report_scans` and `classify_all_branches` (defined in `scripts/bash/cleanup_worktrees_report_records_lib.sh`) and `is_detached_candidate` and `report_detached_worktrees` (defined in `scripts/bash/cleanup_worktrees_detached_lib.sh`); `run_apply` calls `is_detached_candidate`, `apply_detached_worktrees`, and `classify_all_branches`. The plan's chain would abort on an undefined function and capture empty or truncated files.

2. **Missing filesystem-scan seam.** `run_report_scans` invokes the scan binary through `cleanup_wt_scan_bin`. With `CLEANUP_WT_SCAN_BIN` unset it falls back to the bundled `cleanup_worktrees_scan_helper.sh`, which reads the machine's real worktree tree. The captured bytes would then vary by machine and by the state of `.claude/worktrees` at capture time, so the byte-identity gate they feed would be non-deterministic rather than a pin. The seam is pointed at the checked-in stub `tests/fixtures/cleanup_worktrees/stub-bin/scan`.

Both corrections are locator and environment repairs to a stale command, not a change to what the task captures.

## Command form actually used (execution amendment EA-1)

The plan's bare-`wsl` form naming the preparation worktree `agent-a3944b95a7d58e712` is forbidden by EA-1 and names the wrong checkout. The capture was run under Git Bash with the working directory set to this worktree root, from the script `capture_report.sh`, whose body is:

```
for s in merged_with_worktree merged_no_worktree unmerged content_neutral \
	residual_on_main residual_unique_doc current_exclusion main_divergence; do
	env CLEANUP_WT_GIT_BIN="$STUB" CLEANUP_WT_SCAN_BIN="$SCAN" \
		CLEANUP_WT_STUB_SCENARIO="$SCEN/$s" \
		bash -c "source $ELIB; source $LIB; source $RLIB; source $DETLIB; run_report" \
		>"tests/fixtures/cleanup_worktrees/expected/report.$s.out" 2>/dev/null || true
done
```

with `ELIB=scripts/bash/cleanup_worktrees_enumerate_lib.sh`, `LIB=scripts/bash/cleanup_worktrees_lib.sh`, `RLIB=scripts/bash/cleanup_worktrees_report_records_lib.sh`, `DETLIB=scripts/bash/cleanup_worktrees_detached_lib.sh`, `STUB=$PWD/tests/fixtures/cleanup_worktrees/stub-bin/git`, `SCAN=$PWD/tests/fixtures/cleanup_worktrees/stub-bin/scan`, `SCEN=$PWD/tests/fixtures/cleanup_worktrees/scenarios`.

EXIT_CODE: 0

## Determinism observation

Command: `sha256sum tests/fixtures/cleanup_worktrees/expected/report.*.out | sha256sum`

First run digest:

```
eaca4562b670b4ac953b51a9cf7467121e002398e5729d15ada7d03eaa634ca5 *-
```

The identical capture command was then re-run and the digest taken again.

Second run digest:

```
eaca4562b670b4ac953b51a9cf7467121e002398e5729d15ada7d03eaa634ca5 *-
```

The two digests are identical, so the capture is reproducible.

## File enumeration

Command: `git status --porcelain -uall -- tests/fixtures/cleanup_worktrees/expected`
EXIT_CODE: 0

```
?? tests/fixtures/cleanup_worktrees/expected/report.content_neutral.out
?? tests/fixtures/cleanup_worktrees/expected/report.current_exclusion.out
?? tests/fixtures/cleanup_worktrees/expected/report.main_divergence.out
?? tests/fixtures/cleanup_worktrees/expected/report.merged_no_worktree.out
?? tests/fixtures/cleanup_worktrees/expected/report.merged_with_worktree.out
?? tests/fixtures/cleanup_worktrees/expected/report.residual_on_main.out
?? tests/fixtures/cleanup_worktrees/expected/report.residual_unique_doc.out
?? tests/fixtures/cleanup_worktrees/expected/report.unmerged.out
```

Exactly eight `??` entries, one per required scenario. The `-uall` flag is required: the default form collapses an entirely untracked directory to a single entry and never names the files. This enumeration was taken before [P2-T17] added its two apply-mode files to the same directory.

## Non-emptiness

Command: `wc -l tests/fixtures/cleanup_worktrees/expected/*.out`

```
  3 report.content_neutral.out
  4 report.current_exclusion.out
  3 report.main_divergence.out
  3 report.merged_no_worktree.out
  4 report.merged_with_worktree.out
  3 report.residual_on_main.out
  4 report.residual_unique_doc.out
  3 report.unmerged.out
 27 total
```

No file is empty.

## Companion apply-mode capture ([P2-T17])

Command form as above with the actions library added to the chain and `run_apply` as the driver. `CLEANUP_WT_CLEAR_DISPOSABLE` was deliberately left unset, because these files record apply-mode behavior without the new flag.

`tests/fixtures/cleanup_worktrees/expected/apply.dirty_worktree.out`:

```
WORKTREE|/repo/main|main|main
WORKTREE|/repo-wt/dirty|feature-dirty|
BRANCH|feature-dirty|MERGED_CLEAN
DIRTY|/repo-wt/dirty|?? untracked-artifact.txt
ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY
BRANCH|main|PROTECTED_CURRENT
```

It contains the exact line `DIRTY|/repo-wt/dirty|?? untracked-artifact.txt` and the exact line `ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY`.

`tests/fixtures/cleanup_worktrees/expected/apply.dirty_worktree_status_error.out`:

```
WORKTREE|/repo/main|main|main
WORKTREE|/repo-wt/dirty|feature-dirty|
```

Command: `grep -c "DIRTFILE\|DIRTSUM" tests/fixtures/cleanup_worktrees/expected/apply.dirty_worktree.out tests/fixtures/cleanup_worktrees/expected/apply.dirty_worktree_status_error.out`

```
apply.dirty_worktree.out:0
apply.dirty_worktree_status_error.out:0
```

Neither file contains the token `DIRTFILE` or the token `DIRTSUM`.

Output Summary: Ten expected-output files were captured against the current unmodified libraries. The report capture is byte-reproducible across two identical runs (digest `eaca4562b670b4ac953b51a9cf7467121e002398e5729d15ada7d03eaa634ca5`), enumerates exactly eight untracked files, and no file is empty. The two apply-mode files carry the required `DIRTY|` and `BLOCKED-DIRTY` lines and contain neither new record token. The plan's capture command required two mechanical corrections, both recorded above, because it predates the merge of issue #631.
