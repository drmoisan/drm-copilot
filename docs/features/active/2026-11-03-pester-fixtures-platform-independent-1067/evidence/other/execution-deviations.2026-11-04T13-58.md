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

## Adjusted evaluation of P6-T14 (porcelain expectation)

- Plan expectation: the porcelain status lists only the three P6-T1 to P6-T3 test files and paths under `<FEATURE>/evidence/`, so any other path is a file written by a test run.
- Adjusted evaluation: after the recovery commit, the Phase 6 test changes are in `git diff --name-only MB HEAD`, not in porcelain. P6-T14 is evaluated as (a) `git status --porcelain --untracked-files=all` taken after the P6-T13 test run lists only paths under `<FEATURE>/evidence/`, plus plan.md and spec.md (task check-offs); any other path is a file written by a test run and fails the task; and (b) `git diff --name-only MB HEAD` outside `docs/features/` lists only the 5 production files and the 17 suites.

## Adjusted evaluation of P6-T19 (HEAD~1 expectation)

- Plan expectation: `git diff --name-only HEAD~1 HEAD` lists `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`.
- Adjusted evaluation: the file is committed in the recovery commit, so the final P6-T19 commit carries only evidence, the self-review, plan.md, and spec.md. P6-T19 is evaluated as `git diff --name-only MB HEAD` listing `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` (and the other two isolation-fix files), `git status --porcelain` empty, and `HEAD` equal to its upstream.
