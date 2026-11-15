Timestamp: 2026-11-14T23-04
Plan: docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/plan.2026-11-14T17-45.md

- [P2-T2] Trivial: the task text left step-level run-heavy gating of the three new jobs implicit, while the pinned test `gates every step of <Job> on inputs.run-heavy in <File> (AC-20)` in `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` (extended by P2-T4 to the new job ids) matches step-level `if:` lines. Added the sentence requiring a step-level `inputs.run-heavy` condition on every step of the three new jobs.
