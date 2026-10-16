# Baseline CI Source (P0-T9)

Timestamp: 2026-10-16T00-57
Command: read of FEATURE/evidence/baseline/branch-state.2026-10-16T00-26.md (P0-T2 B) and FEATURE/evidence/baseline/ci-baseline.2026-10-16T00-11.md (lexicographically greatest `ci-baseline.*.md`, P7-T1)
EXIT_CODE: 0

Output Summary: P0-T2 B = `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`; `ci-baseline.2026-10-16T00-11.md` B = `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`; equal. PASS. This artifact is written before any split and pins the pre-split code state that AC-18's baseline counts describe.

Base SHA B (from P0-T2): `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`

D-BASE selection rule (verbatim from the plan):

> `B` = the output of `git merge-base origin/main HEAD` computed by the orchestrator in P7-T1; P0-T2 records the same command's output. The baseline run `R_base` is the run returned by `gh run list --workflow ci.yml --branch main --event push --commit <B> --status success --limit 1 --json databaseId,headSha`. If that returns no run, `R_base` is the most recent successful `push` run of `ci.yml` on `main` whose `headSha` `X` is an ancestor of `B` and for which `git diff --quiet <X> <B> -- tests scripts .claude .codex config` exits 0. If neither exists, the baseline task records `BLOCKED: no baseline run` and the orchestrator stops for operator input (it does not dispatch a substitute run). Governs P7-T1.

Derivations used by P7-T1: D-JUNIT (row and count derivation) and D-COV (coverage derivation), as defined in the plan's Fixed Derivations section.

Suites whose baseline Passed counts P7-T1 must record:
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`

P7-T1 artifact check: `FEATURE/evidence/baseline/ci-baseline.2026-10-16T00-11.md` exists; R_base = run 38730332356 (headSha `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`); counts 51, 25, 120, 32, 54; baseline line coverage 90.42%.
