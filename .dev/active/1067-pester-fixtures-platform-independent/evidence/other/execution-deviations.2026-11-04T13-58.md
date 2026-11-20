# Execution Deviations (Phase 6 resume)

Timestamp: 2026-11-04T13-58
Plan: docs/features/active/2026-11-03-pester-fixtures-platform-independent-1067/plan.2026-11-03T17-43.md

## Context

A Codespace restart stopped the previous executor after P6-T12. The working copy held the checked P6-T1 to P6-T12 boxes, spec.md with AC1 and AC9 checked, ten modified test files, and untracked Phase 6 evidence. The adopted state was re-verified by one 17-suite run (`evidence/regression-testing/linux-17-suites.2026-11-04T13-58.md`, Failed=0) before any commit.

## Deviation 1: recovery commit before P6-T19

- Plan rule: `### Phase 6` states that nothing in the phase is committed before P6-T19.
- Deviation: on owner instruction to commit in recoverable steps, the adopted tracked changes and the existing Phase 6 evidence are committed and pushed as a recovery commit before P6-T13.
- Effect on the change set: none. The same files are committed; only the commit boundary moves.

## Deviation 2: the ten modified test files are wider than the three P6-T1 to P6-T3 files

- P6-T14 and P6-T19 name only the three isolation-fix files as the Phase 6 test changes. The working copy also carries loop fixes made during P6-T4 to P6-T12 in seven further suites (HostBootstrap, SideloadedExtensionPublish.Invoke, activate, post-codex-worktree-session, publish-sideloaded-extension, PoshQC.ScanFolders, PoshQC.TestingCommands). All seven are among the 17 suites of the change set, so the scope rule of P6-T16 is unaffected.

## Restart rule applied on resume

- File modification times show that `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` and `PoshQC.TestingCommands.Tests.ps1` were last changed at 2026-11-04T04-49 UTC, after every existing P6-T4 to P6-T12 artifact (latest 2026-11-04T04-30). Under the `### Phase 6` restart rule (a change during P6-T4 to P6-T14 restarts from P6-T4), P6-T4 to P6-T12 are re-run after the recovery commit and each writes a new evidence file with a later stamp. Their boxes stay checked from the earlier pass; each re-run's evidence supersedes the earlier file as the lexicographically greatest match.

## Second restart: P6-T13 failure and loop fix

- P6-T13 (concurrent-shard run, 2026-11-04T14-30) failed one test in each of `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` (`Invoke-PoshQCTest scan-folder support` / `overrides run paths and preserves configured coverage paths when scan folders are supplied`) and `tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1` (`Invoke-PoshQCTest` / `preserves a custom KoverageOutputPath when ScanFolders narrow Run.Path and preserve coverage paths`), with `IOException: Permission denied` from the real `New-Item` creating `/repo/artifacts`.
- Mechanism, reproduced with SCRATCH harnesses: the default `-InvokePester` trampoline of `Invoke-PoshQCTest` (`PoshQC.Testing.psm1`) invokes an unbound script block from inside the module, so under a PoshQC-hosted run the test bodies execute in the host PoshQC module's session state (a diagnostic test reported `$ExecutionContext.SessionState.Module` as PoshQC). A `Mock -ModuleName PoshQC` created from that session state is not honored inside the re-imported instance, even when the call goes through that instance. A plain Invoke-Pester run and a run with a script-scope seam do not show this, which is why P6-T6 to P6-T12 passed.
- Fix (test code only, inside the change set): each of the two `It` bodies runs inside `InModuleScope PoshQC`, with `Mock -CommandName New-Item` and `Should -Invoke -CommandName New-Item` without `-ModuleName`, the same form `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` already uses for the same branch. Every assertion, count, and ParameterFilter is unchanged. Verified with 30 of 30 passing under the default trampoline, a script-scope seam, and a plain run.
- Open finding (not fixed, outside the change set): the trampoline comment in `PoshQC.Testing.psm1` states that the Pester run is hosted in the global session state; the observation above shows that test code runs in the PoshQC module session state. On Windows CI the same mock miss would let these tests create `C:\repo\artifacts` for real before this fix. Changing the trampoline would add a sixth production file and its bundle mirror, which the P6-T16 scope rule excludes.
- The loop restarted from P6-T4 after the fix.

## Adjusted evaluation of P6-T14 (porcelain expectation)

- Plan expectation: the porcelain status lists only the three P6-T1 to P6-T3 test files and paths under `<FEATURE>/evidence/`, so any other path is a file written by a test run.
- Adjusted evaluation: after the recovery commit, the Phase 6 test changes are in `git diff --name-only MB HEAD`, not in porcelain. P6-T14 is evaluated as (a) `git status --porcelain --untracked-files=all` taken after the P6-T13 test run lists only paths under `<FEATURE>/evidence/`, plus plan.md and spec.md (task check-offs); any other path is a file written by a test run and fails the task; and (b) `git diff --name-only MB HEAD` outside `docs/features/` lists only the 5 production files and the 17 suites.

## Adjusted evaluation of P6-T19 (HEAD~1 expectation)

- Plan expectation: `git diff --name-only HEAD~1 HEAD` lists `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`.
- Adjusted evaluation: the file is committed in the recovery commit, so the final P6-T19 commit carries only evidence, the self-review, plan.md, and spec.md. P6-T19 is evaluated as `git diff --name-only MB HEAD` listing `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` (and the other two isolation-fix files), `git status --porcelain` empty, and `HEAD` equal to its upstream.
