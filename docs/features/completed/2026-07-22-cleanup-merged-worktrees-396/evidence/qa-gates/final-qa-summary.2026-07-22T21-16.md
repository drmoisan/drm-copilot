# Cycle-3 Final QA Summary (P5-T7), Issue #396

Timestamp: 2026-07-22T22-21

## Single-pass QA loop confirmation

The final QA loop completed clean in a single pass, no restarts:

1. P5-T1 `bash scripts/bash/shell-qc.sh format` — EXIT 0, no rewrites.
2. P5-T2 `bash scripts/bash/shell-qc.sh check` — EXIT 0 (shfmt diff-clean, shellcheck 0 findings).
3. P5-T3 coverage test via CI dispatch (`_shell-coverage.yml`, run 29973982957, head a1b39a4d)
   — GREEN, TAP `1..102`, 102 ok / 0 not ok, overall bash line coverage 91.5%.

No stage failed and no stage rewrote files, so the loop was not restarted.

## Phase 5 and referenced artifacts

- P5-T1 format: `evidence/qa-gates/final-shell-format.2026-07-22T21-16.md`
- P5-T2 check: `evidence/qa-gates/final-shell-check.2026-07-22T21-16.md`
- P5-T3 coverage (CI): `evidence/qa-gates/final-shell-coverage-ci.2026-07-22T21-16.md`
- P5-T4 pass-after: `evidence/regression-testing/cycle3-hard-failure.pass-after.2026-07-22T21-16.md`
- P5-T5 coverage delta: `evidence/qa-gates/coverage-delta.2026-07-22T21-16.md`
- P5-T6 file-size caps: `evidence/qa-gates/file-size-caps.2026-07-22T21-16.md`
- P1-T1 call-site audit: `evidence/remediation-baseline/callsite-audit.2026-07-22T21-16.md`
- P2-T11 fail-before exception dossier: `evidence/regression-testing/fail-before-exception.2026-07-22T21-16.md`
- P2-T12 fail-before run: `evidence/regression-testing/cycle3-hard-failure.fail-before.2026-07-22T21-16.md`
- P3-T14 post-fix shell-qc: `evidence/other/fix-shell-qc-check.2026-07-22T21-16.md`

## P4-T1 re-grep (idiom sweep over the three libraries)

Re-run of the P1-T1 grep for `< <(`, `mapfile`, `readarray`, and `|| true`, excluding
comment lines, over the three libraries:

Remaining `< <(` (code, non-comment):
- `cleanup_worktrees_lib.sh:416  done < <(printf '%s\n' "$ce")` — printf over a local
  variable, NOT a git-backed producer.

Remaining `|| true` (code, non-comment):
- `cleanup_worktrees_lib.sh:473  ((crc > rc)) && rc=$crc || true` — arithmetic, not a git command.
- `cleanup_worktrees_actions_lib.sh:140  ... | grep '^stub-git: ' >&2 || true` — grep argv re-surface.
- `cleanup_worktrees_actions_lib.sh:148  cherry-pick --skip ... || true` — accepted best-effort (Decision 9).
- `cleanup_worktrees_actions_lib.sh:155  cherry-pick --abort ... || true` — accepted best-effort (Decision 9).
- `cleanup_worktrees_actions_lib.sh:205  fetch origin main ... || true` — accepted best-effort (Decision 9).
- `cleanup_worktrees_actions_lib.sh:354  vout=$(verify_consolidation_merged) || true` — only the exact
  token MERGED_CLEAN unlocks deletion (Decision 9).

Result: zero `< <(` reads over a git-backed producer and zero `mapfile`/`readarray` over a
git-backed producer remain; zero `|| true` on an authoritative git capture remains. Every
surviving `|| true` is either non-git (arithmetic, grep) or an accepted fail-closed
best-effort site documented in Design Decision 9 and in the actions-lib header.

## Closure statement

All cycle-3 fail-open / rc-losing sites are fixed:

- NEW-1 both sites: `classify_cherry_equivalent` empty-residual diff-tree probe
  (DIFF_TREE_ERROR) and `classify_residual_commit` name-status diff-tree read (RESIDUAL_ERROR).
- NEW-2: `compute_protected` rev-parse --abbrev-ref HEAD / --show-toplevel hard failure is
  fatal, never a weakened protected set.
- NEW-3 both consumers plus the enumerate pipeline: `run_report` and `run_apply` capture
  `enumerate_branches` up front and abort on hard failure; `enumerate_branches` captures
  for-each-ref before sorting so a failure is observed without caller pipefail.
- NEW-4 plus both consumers: `consolidation_worktree_path` fails on a hard failure or empty
  main path (the malformed `-wt/documentationandmemories` derivation is impossible);
  `create_consolidation_worktree` and `cleanup_consolidation_on_abort` guard the capture.
- D-rung ambiguity: the `rev-parse main:<path>` exit-only probe is replaced by a guarded
  `git ls-tree main -- <path>` capture distinguishing a hard failure from an absent path.
- Minus-present re-invocation: the second `git cherry` invocation in `classify_branch` is
  structurally removed; the MINUS_PRESENT token is read from the captured cherry verdict.
- `run_apply` classification rc loss: per-branch `classify_branch` is captured with rc and a
  hard failure propagates a non-zero driver return with no deletion.
- Two consistency conversions: `reverify_delete_eligible` and `remove_worktree_safe` `< <(...)`
  reads over git-backed producers converted to guarded parent-shell captures (fail-closed
  behavior preserved; guards 16 and 17 pin it).

Scope boundaries observed: CR-2 (stub-marker re-emission) and CR-4 (call-graph redundancy)
remain untouched accepted Minors; CR-1 and CR-3 remain resolved and were not reopened.

Output Summary: Single clean QA pass (format 0, check 0, CI green 102/102, coverage 91.5%
>= 90.4% baseline, every measured scripts/bash file >= 85%, all files <= 500 lines). Zero
remaining fail-open idiom instances over authoritative git captures. All named findings and
audit-discovered sites fixed; accepted Minors untouched; resolved findings not reopened.
