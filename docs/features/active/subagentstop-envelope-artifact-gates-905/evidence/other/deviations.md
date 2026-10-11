# Deviations (issue #905, E3)

Timestamp: 2026-10-11T14-41

## Execution-context substitutions (orchestrator directive)

- [P0-T2], [P0-T4], rule 8 (every R-COMMIT push), [P12-T1], [P12-T20], [P12-T22]: branch substitution. Trigger: the prepared branch `bug/subagentstop-envelope-artifact-gates-905` is locked in another worktree. Action: the execution branch is `bug/subagentstop-envelope-artifact-gates-exec-905` (created from `origin/epic/subagentstop-envelope-integration` at f11f1814b); every push is `git push origin HEAD:bug/subagentstop-envelope-artifact-gates-exec-905`; merge messages name the execution branch. Record: `evidence/other/branch-substitution.2026-10-11T17-05.md`.
- [P0-T4]: the merge was expected to report "Already up to date"; observed: the integration tip had advanced to 1011d98d7 (one docs commit to `docs/features/epics/subagentstop-envelope/epic-status.md`), so a no-ff merge commit c0cfec94d was created. No E3 file changed ([P0-T5]).
- [P0-T13]: corpus commit operator rule. At orchestration start `git merge-base origin/main HEAD` and `git rev-parse origin/main` were both 2ef8d361e978ca8b7733a545d76a87e8418005ce. If ORIGIN-MAIN-TIP differs from CORPUS_SHA at [P0-T13], each validator's after-change corpus additionally runs against the origin/main tip with zero false positives required, recorded in the same corpus evidence file.
- Execution-context item 5: a bundled-copy parity pytest failure caused by gitignored state (issue 510) is tolerated locally only when it matches the baseline failure set; it is verified on PR CI.

## Plan-authorized deviations

- [P0-T6]: R-ROUTE option (a) (PowerShell tool) is not exposed to this executor session; option (b) (`sh <SCRATCHPAD>/route.sh`) is used for every fresh-process run. Scratchpad wrappers `rl.sh` (runs one scratchpad script through `pwsh -NoProfile -File` and captures its output) and `asm.sh` (writes the captured output into an evidence file with host paths replaced) are thin shells over the same route.
- [P0-T22]: the first R-SCOPED invocation bound the first path positionally to `-ExcludeTag` and ran 4 tests. Action: the scratchpad runner was corrected in its I/O only (`[CmdletBinding(PositionalBinding = $false)]`) and re-run; the corrected run is the recorded baseline.
- [P0-T24] to [P0-T29]: [P0-T26] to [P0-T29] (read-only captures: pytest, static scan, sizes, mirror hashes) were executed while the [P0-T24] R-FULL process ran in the background. Trigger: R-FULL takes about ten minutes. Action: no shared state exists between those commands and R-FULL (none reads `artifacts/pester/`); the tasks were checked off in plan order after [P0-T24] and [P0-T25] completed.
- Evidence timestamps: several Phase 0 evidence file names initially carried a timestamp later than their actual write time. Action: each such file was renamed to its file-system write time (`yyyy-MM-ddTHH-mm`) and its `Timestamp:` line was updated to match before the Phase 0 commit.
