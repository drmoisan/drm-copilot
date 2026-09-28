# Decision A — report-mode exit code on a hard status read

Timestamp: 2026-09-08T05-45

Task: [P1-T1] of `remediation-plan.2026-09-08T05-00.md`
Finding: R6a (code review F5; policy audit P22)

Decision: RETAIN

## Observed behaviour

The behaviour was driven against both trees under the checked-in scenario
`tests/fixtures/cleanup_worktrees/scenarios/dirty_worktree_status_error`, whose
`status._repo-wt_dirty.rc` is `128`. The two figures are taken from
`code-review.2026-09-08T05-00.md` finding F5, which recorded them from a direct run against
each tree:

- HEAD report-mode exit code = 128
- BASE report-mode exit code = 0

Report mode therefore exits 128 on this checkout where the pre-change tree exited 0 and
produced a complete report.

## Code locations

1. `scripts/bash/cleanup_worktrees_dirt_lib.sh:342-344` — `classify_worktree_dirt` captures
   the `status --porcelain` read in the parent shell and returns the version-control tool's
   exit code unchanged when it is non-zero, before emitting any record.
2. `scripts/bash/cleanup_worktrees_lib.sh:485-487` — `run_report` calls
   `classify_worktree_dirt "$wpath" || rc=$?` for each candidate registration, so the
   classifier's non-zero return becomes `run_report`'s return.
3. The wrapper `scripts/bash/cleanup-worktrees.sh` propagates `run_report`'s return as the
   process exit status.

## Why the propagation is intended

Report mode is the read-only diagnostic pass that feeds the Dirty Worktree Triage
Procedure. A worktree whose status read failed produces no `DIRTFILE|` record and no
`DIRTSUM|` record at all. A report that also exited 0 would therefore be indistinguishable
from a report about a clean worktree, and an operator would make a deletion decision on
silently incomplete data. The non-zero exit is the only channel that carries the
incompleteness to a wrapping script.

## Rejected alternative

Suppress the propagation and emit a `WARN|` record instead. Rejected for two reasons. It
would require adding a record type to the published Report Line Contract, which every
downstream consumer of the contract would then have to handle. And it would leave the exit
code unable to signal the incompleteness at all: a wrapping script that reads only the exit
status would still treat the run as complete.

## Precedent

`.claude/skills/cleanup-merged-worktrees/SKILL.md:197-200` already documents an analogous
apply-mode exit-status change introduced by issue 631: a blocked detached removal sets a
non-zero exit status, so a checkout holding dirty or locked detached worktrees exits
non-zero from `--apply` where it previously exited 0. This decision mirrors that treatment
for report mode.

## Work items this decision entails

1. A `SKILL.md` note in `## Report Line Contract` recording the report-mode exit-status
   behaviour, applied to the canonical file and mirrored byte-identically into the bundle
   copy (plan tasks P7-T1 and P7-T3).
2. A new acceptance criterion in `spec.md`, AC-43 (plan task P1-T6).
3. A test pinning report-mode exit 128 for the `dirty_worktree_status_error` scenario,
   asserting no `DIRTFILE|` and no `DIRTSUM|` record is emitted for that worktree, with the
   `WORKTREE|` record as its positive control (plan task P7-T4).

No code change is made. The behaviour is documented and pinned, not altered.
