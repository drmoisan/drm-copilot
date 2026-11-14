# Preflight Fixes - remediation plan cycle 1 (issue #1114)

Timestamp: 2026-11-07T20-13
Plan: docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/remediation-plan.2026-11-07T20-08.md

## Fix 1 - [P1-T1] diff anchor for a branch-added file

- Defect class: acceptance condition that cannot fail (anchor).
- Finding: the acceptance diff was anchored on `MERGE_BASE`. The test file `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1` was added on this branch, so a diff against the merge base shows every line as added and cannot detect an edited or removed existing row.
- Change: the anchor is the cycle-start `HEAD`, with the diff run before the task commit (`git diff HEAD -- <test file>`), keeping the assertion "added lines only, no removed content line".

## Checks with no defect

- Validator (`plan` subcommand, Python CLI): passed.
- Scope diff `MERGE_BASE..HEAD` over `.claude/hooks`, `.claude/lib`, `.codex/config.toml`, `.codex/hooks/hook-target-worktree.ps1`: empty, so the [P2-T1] boundary assertion is satisfiable.
- Asserting tests: only `feature-review-coverage-target.Tests.ps1` and `validate-feature-review-coverage.Coverage.Tests.ps1` reference the changed function or its reason codes; dispositions in the plan match the tree.
- Fail-before expectation: the six named rows fail and the two-audits guard row passes under the current extractor (traced against the current `$tokenPattern` and `$shapePattern`).
