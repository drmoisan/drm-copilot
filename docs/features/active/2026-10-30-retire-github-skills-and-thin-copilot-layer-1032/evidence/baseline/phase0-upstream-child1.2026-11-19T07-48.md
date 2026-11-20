# Phase 0 Upstream Check: Child 1 (#1025) ([P0-T3])

Timestamp: 2026-11-19T07-48
Plan: plan.2026-10-30T18-39.md
Command: sh SCRATCH/issue-1032-ps.sh issue-1032-matrix.ps1 (ConvertFrom-Json over config/harness-parity-matrix.json; Compare-Object against .github/skills folders and .github/agents files); ls C1/evidence/other/; grep over C1/survey/difference-approval.md and C1/survey/batch-c-integration.md
EXIT_CODE: 0
Output Summary: UA-C1a, UA-C1b, UA-C1c and UA-C1d hold; E3, E4 and E6 are deferred in `## Owner Overrides` (no result files); E6Result: deferred. No `blocked: premise_falsified`.

`C1` = `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025` (merged into the integration branch by PR #1199).

## Assumptions

| ID | Result | Observation |
| --- | --- | --- |
| UA-C1a | holds | `config/harness-parity-matrix.json` (656 features), `config/harness-parity-matrix.schema.json` and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` exist. The schema defines `disposition`, `reason`, `decision_ref` and `decision_status`, requires `reason` and `decision_ref` for `dropped`, and accepts `decision_status: provisional` (requiring `decision_ref` with it). |
| UA-C1b | holds | `copilot:skill:*` entries: 43, one per `RETIRED-SKILL-FOLDERS` member (Compare-Object difference empty). `copilot:skill-frontmatter-field:*`: 2 (`description`, `name`; both `native`, `provisional`). `copilot:agent:*`: 50, one per `.github/agents/` file (the spaced file `Powershell DI Unit Test Engineer.agent.md` is encoded `Powershell%20DI%20Unit%20Test%20Engineer`; ids are opaque). `copilot:handoff:*`: 20. |
| UA-C1c | holds | No E3, E4 or E6 result file exists under `C1/evidence/other/` (only `e5-claude-hooks-subagent-permissions-documentation.2026-11-16T01-23.md`); `C1/survey/difference-approval.md` `## Owner Overrides` records E3, E4 and E6 as `deferred: owner-run runbook not executed in the autonomous run`. |
| UA-C1d | holds | `Approval-Status: approved-with-overrides`. Classifications read below. |

## Entry Count per `copilot:` Kind

agent 50; handoff 20; hook-registration 4; instructions 1; path-scoped-rule 18; prompt 29; skill 43; skill-frontmatter-field 2; subagent-frontmatter-field 7.

## U1, U2, U3, U5 Diff IDs and Approved Classes

| U | Section | Diff IDs | Approved class | Source |
| --- | --- | --- | --- | --- |
| U1 | `feature-promotion-lifecycle` `## MCP-First Execution Rule` | D-feature-promotion-lifecycle-08, -09 | negative (Owner-Decision A: shared body omits the fallback section) | `## Disputed Cases` |
| U2 | `feature-promotion-lifecycle` `## Canonical Fallback Command Sequence`; `## Canonical Fallback Short-Path Sequence (Minor Audit Mode)` | D-feature-promotion-lifecycle-10, -11; -12, -13 | negative (Owner-Decision A) | `## Disputed Cases` |
| U3 | `feature-review-workflow` `## File Size Advisory` | D-feature-review-workflow-07, -08 | mechanism-only, port none | `## Bulk Approval Set`; `batch-c-integration.md` |
| U5 | `feature-review-workflow` `## Documentation Surface Check` | D-feature-review-workflow-09, -10 | mechanism-only, port none | `## Bulk Approval Set`; `batch-c-integration.md` |

No `## Owner Overrides` row overrides U1 or U2.

E6Result: deferred (`#1025:survey/difference-approval.md#owner-overrides`, row E6)
