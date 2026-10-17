# Bug: untouched-files coverage verification (#884)

- Work Mode: minor-audit
- Issue: #884
- Type: bug

## Problem / Why

Issue #884 (source PA-7 of the #824 policy audit, severity Medium) reported two production files below the uniform 85% line-coverage floor:

- `.claude/lib/bash/compute-concurrency-batches.sh` at 81.82% (kcov, CI run 38057811190).
- `.codex/hooks/validate-feature-review-coverage.ps1` at 7.30%, 10 of 137 lines (Pester, CI run 38022356096).

Both files have since been raised. The bash file was raised by the bats tests added in PR #917. The Codex hook was raised by the #786 coverage suite and by epic #904 E4 / #896. This item therefore makes no code change. It verifies the current per-file coverage on main, records the evidence, and closes #884.

Research: `research/research.2026-10-15T07-50.md` (determination EVIDENCE-ONLY). CI per-file figures: `evidence/other/ci-per-file-coverage.2026-10-15T11-47.md`.

## Implementation Intent

Evidence-only. No production or test file is changed. Verification evidence is recorded under the `evidence/` tree of this feature folder.

## Acceptance Criteria

- [x] AC1: `.claude/lib/bash/compute-concurrency-batches.sh` per-file line coverage on main CI run 38683717593 (head f6915d429, kcov artifact `shell-coverage`) is recorded as 100.00% (44/44), at or above the 85% floor, in an evidence artifact under the feature folder `evidence/` tree.
- [x] AC2: `.codex/hooks/validate-feature-review-coverage.ps1` per-file line coverage on main CI run 38683717593 (Pester artifact `poshqc-test-results`) is recorded as 100.00% (146/146), at or above the 85% floor, in an evidence artifact under the feature folder `evidence/` tree.
- [x] AC3: A verification evidence artifact cites the corroborating committed records with file and line references: the #917 kcov record (81.82% to 100.00%), the #896 Pester records (99.29% to 100.00%), and the statement that the 7.30% figure is superseded.
- [x] AC4: No file outside `docs/features/active/untouched-files-coverage-verification-884/` differs from `origin/main` on this branch, so neither production file is modified.
- [x] AC5: An issue-update mirror under `evidence/issue-updates/` records the closing comment text for #884 citing CI run 38683717593 and the evidence artifacts.

## Dependencies / Risks

- No blocking dependencies.
- The CI per-file numbers were read by the orchestrator through `gh`; the executor has no `gh` access and relies on the recorded evidence artifact.
- A future change that lowers coverage on either file is out of scope.

## Verification Steps

1. Confirm the evidence artifact records 44/44 (100.00%) for `.claude/lib/bash/compute-concurrency-batches.sh` on CI run 38683717593 (AC1).
2. Confirm the evidence artifact records 146/146 (100.00%) for `.codex/hooks/validate-feature-review-coverage.ps1` on CI run 38683717593 (AC2).
3. Confirm the verification artifact cites the #917 and #896 records with file and line references and states that 7.30% is superseded (AC3).
4. Run `git diff --name-only origin/main` and confirm every path is under `docs/features/active/untouched-files-coverage-verification-884/` (AC4).
5. Confirm the closing comment mirror exists under `evidence/issue-updates/` and cites the CI run and evidence artifacts (AC5).

## Evidence Checklist

- [x] baseline
- [x] targeted verification
- [x] end-state

## Follow-ups

None for this item. #847 (aggregate PowerShell coverage) is separate and pre-existing.
