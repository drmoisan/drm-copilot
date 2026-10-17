# Acceptance-Criteria Ledger (P9-T11)

Timestamp: 2026-10-16T12-12
Command: git grep -n -F -e "which serves a merge queue on" -- .github/workflows/README.md; git grep -c -F -e "- [x] AC-<n>:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md (for each LOCAL-PASS AC)
EXIT_CODE: 0
Output Summary: AC source spec.md `## Acceptance Criteria` (AC-1 to AC-28). LOCAL-PASS and checked off by the executor in Phase 9: AC-3, AC-4, AC-16 to AC-20, AC-24 to AC-26 (10). PASS via ORCH-2, checked off by the orchestrator: AC-21 to AC-23 (3). PENDING-ORCH: AC-1, AC-2, AC-5 to AC-15, AC-27 (14). PENDING-CI: AC-28 (1).

Source: `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` `## Acceptance Criteria` (Work Mode full-bug; `user-story.md` is intentionally absent).

AC-4 re-run (P9-T2), verbatim output, one line containing `merge_group`:
```
.github/workflows/README.md:15:- `merge_group` (`types: [checks_requested]`, no branch or path filter), which serves a merge queue on `main`: when a queue is enabled, every required check is produced by a `merge_group` run of `ci.yml` (issue #952).
```

AC-20 re-runs (P3-T15 and P4-T6 acceptance commands, run during P9-T7): `enforce-epic-merge-gate-command.ps1` count 1 in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; count 1 in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`; `Invoke-MergeConfirmationParser.ps1` count 1 in the Claude `core.json`. The 13 mirror pairs were re-hashed against HEAD 1f822aff0 during P9-T7 and equal the hashes recorded in `final-mirror-hashes.2026-10-16T11-53.md`.

## Ledger

| AC | Status | Evidence | Owner |
|---|---|---|---|
| AC-1 | PENDING-ORCH | ORCH-4 named row (a), `evidence/regression-testing/ciworkflow-after.2026-10-16T10-43.md` (local disposition only) | ORCH-4 on `R_final`, job `poshqc / PowerShell QC`; checked off in ORCH-6 |
| AC-2 | PENDING-ORCH | ORCH-4 named row (b), `evidence/regression-testing/ciworkflow-after.2026-10-16T10-43.md` (local disposition only) | ORCH-4 on `R_final`, job `poshqc / PowerShell QC`; checked off in ORCH-6 |
| AC-3 | LOCAL-PASS (checked off, P9-T1) | `evidence/other/required-context-map.2026-10-16T10-44.md` (`UNMAPPED=0`, `CI_TRIGGERS_MERGE_GROUP=true`) | executor |
| AC-4 | LOCAL-PASS (checked off, P9-T2) | README search re-run above (one line, `merge_group`, line 15) | executor |
| AC-5 | PENDING-ORCH | static part: `evidence/qa-gates/final-scope-boundary.2026-10-16T12-09.md` (`hook-command-invocation.ps1` absent); Pester part `hook-dependency-guard-completeness.Tests.ps1`: `evidence/qa-gates/final-ps-test-t-claude-runtime.2026-10-16T11-52.md` (local disposition only) | ORCH-4 on `R_final`, job `poshqc / PowerShell QC`; checked off in ORCH-6 |
| AC-6 | PENDING-ORCH | `evidence/regression-testing/claude-merge-gate-after.2026-10-16T11-13.md` (local disposition only) | ORCH-4 and ORCH-5, jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` of `R_final` |
| AC-7 | PENDING-ORCH | `evidence/regression-testing/claude-merge-gate-after.2026-10-16T11-13.md` (local disposition only) | ORCH-4 and ORCH-5 |
| AC-8 | PENDING-ORCH | `evidence/regression-testing/claude-merge-gate-after.2026-10-16T11-13.md` (local disposition only) | ORCH-4 and ORCH-5 |
| AC-9 | PENDING-ORCH | `evidence/regression-testing/codex-merge-gate-after.2026-10-16T11-13.md` (local disposition only) | ORCH-4 and ORCH-5 |
| AC-10 | PENDING-ORCH | ORCH-4 named rows (c), (e), (f); `claude-merge-gate-after.2026-10-16T11-13.md`, `codex-merge-gate-after.2026-10-16T11-13.md` (local disposition only) | ORCH-4 and ORCH-5 |
| AC-11 | PENDING-ORCH | ORCH-4 named rows (d), (e), (f); same local artifacts | ORCH-4 and ORCH-5 |
| AC-12 | PENDING-ORCH | `evidence/regression-testing/parser-after.2026-10-16T11-19.md` (local disposition only) | ORCH-4 on `R_final`, job `poshqc / PowerShell QC` |
| AC-13 | PENDING-ORCH | `evidence/regression-testing/parser-after.2026-10-16T11-19.md`, `evidence/regression-testing/pushdown-after-parser.2026-10-16T11-19.md` | ORCH-4 on `R_final`, job `poshqc / PowerShell QC` |
| AC-14 | PENDING-ORCH | `evidence/regression-testing/release-flow-after.2026-10-16T11-24.md` (local disposition only) | ORCH-4 on `R_final`, job `poshqc / PowerShell QC` |
| AC-15 | PENDING-ORCH | `evidence/regression-testing/release-flow-after.2026-10-16T11-24.md` (local disposition only) | ORCH-4 on `R_final`, job `poshqc / PowerShell QC` |
| AC-16 | LOCAL-PASS (checked off, P9-T3) | `evidence/regression-testing/procedure-pins-after.2026-10-16T11-33.md` (`50 passed`), `evidence/qa-gates/final-python-contract-suites.2026-10-16T11-52.md` (`786 passed`) | executor |
| AC-17 | LOCAL-PASS (checked off, P9-T4) | same two artifacts (`claude-orchestrate-s9`, `claude-orchestrate-pr-gate` pins) | executor |
| AC-18 | LOCAL-PASS (checked off, P9-T5) | same two artifacts (four epic pins), `evidence/regression-testing/frozen-digest-before.2026-10-16T11-31.md` (`2 failed`), `evidence/regression-testing/frozen-digest-after.2026-10-16T11-31.md` (`2 passed`) | executor |
| AC-19 | LOCAL-PASS (checked off, P9-T6) | same two artifacts (`agents-epic-orchestrate`, `codex-epic-orchestrator-agent` pins) | executor |
| AC-20 | LOCAL-PASS (checked off, P9-T7) | `evidence/qa-gates/final-mirror-hashes.2026-10-16T11-53.md` (`PAIRS_EQUAL=13/13`), `evidence/qa-gates/final-python-contract-suites.2026-10-16T11-52.md`, manifest token re-runs above | executor |
| AC-21 | PASS via ORCH-2 (orchestrator-checked) | `evidence/qa-gates/ruleset-compare.2026-10-16T12-00.md` (`RULESET-COMPARE AllOk=True`; run as a Python port of Appendix O.1) | orchestrator (ORCH-2); not an executor check-off |
| AC-22 | PASS via ORCH-2 (orchestrator-checked) | `evidence/qa-gates/ruleset-compare.2026-10-16T12-00.md` | orchestrator (ORCH-2); not an executor check-off |
| AC-23 | PASS via ORCH-2 (orchestrator-checked) | `evidence/qa-gates/ruleset-compare.2026-10-16T12-00.md` | orchestrator (ORCH-2); not an executor check-off |
| AC-24 | LOCAL-PASS (checked off, P9-T8) | `evidence/qa-gates/runbook-sections.2026-10-16T11-35.md` (`TOKENS_FOUND=16/16`) | executor |
| AC-25 | LOCAL-PASS (checked off, P9-T9) | `evidence/qa-gates/final-scope-boundary.2026-10-16T12-09.md` (`SCOPE_BOUNDARY=PASS`, `OUTSIDE_PATHS=48`) | executor |
| AC-26 | LOCAL-PASS (checked off, P9-T10) | `evidence/qa-gates/final-line-counts.2026-10-16T11-53.md` (maximum 469), `evidence/qa-gates/final-temp-file-scan.2026-10-16T11-53.md` (no match) | executor |
| AC-27 | PENDING-ORCH | Python part LOCAL-PASS: `final-python-black.2026-10-16T11-52.md`, `final-python-ruff.2026-10-16T11-52.md`, `final-python-pyright.2026-10-16T11-52.md`, `final-python-contract-suites.2026-10-16T11-52.md`; PowerShell loop `final-loop-status.2026-10-16T11-52.md`; coverage `coverage-status.2026-10-16T11-53.md` (`POWERSHELL: PENDING-ORCH`) | ORCH-6 on `R_final`, job `poshqc / PowerShell QC` |
| AC-28 | PENDING-CI | none locally (needs the `pull_request` run on the PR head) | ORCH-3 at S9 (the single CI-dependent criterion under `.claude/skills/orchestrate/SKILL.md:361`); checked off in ORCH-7 |

Every `PENDING-ORCH` AC is verified and checked off by the orchestrator before feature review. No `PENDING-ORCH` or `PENDING-CI` AC was checked off by the executor. AC-21 to AC-23 were checked off by the orchestrator in ORCH-2 and are left checked.

## Related in-item fixes (not acceptance criteria)

- D10(a) queue-aware cleanup skill: `evidence/regression-testing/procedure-pins-before.2026-10-16T11-26.md` (P6-T3, `12 failed, 38 passed`, including the `claude-cleanup-merged-worktrees` pin) and `evidence/regression-testing/procedure-pins-after.2026-10-16T11-33.md` (P6-T32, `50 passed`).
- D10(b) epic-orchestrator `pwsh` grants: `evidence/regression-testing/epic-permission-before.2026-10-16T11-30.md` (P6-T19, `1 failed`) and `evidence/regression-testing/epic-permission-after.2026-10-16T11-30.md` (P6-T22, `1 passed`).
- R4 policy follow-up record: `evidence/other/policy-followups-check.2026-10-16T11-36.md` (P7-T6).
- R5 runbook operator statements: `evidence/qa-gates/runbook-sections.2026-10-16T11-35.md` (P7-T5).
