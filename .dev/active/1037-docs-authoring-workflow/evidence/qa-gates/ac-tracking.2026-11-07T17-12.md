# Acceptance Criteria Tracking (P7-T9)

Timestamp: 2026-11-07T17-12
Command: Evaluation of `## Acceptance Criteria` in `spec.md` and `user-story.md` against the evidence of this feature folder; checkbox changes only (`- [ ]` to `- [x]`), no criterion text edited
EXIT_CODE: 0
Output Summary: spec.md: 17 items, 12 checked, 5 unchecked (AC 9 and 11 for N4, AC 13 for the classification gap, AC 16 for the owner-directed shuffle waiver, AC 17 pending CI). user-story.md: 11 items, 9 checked, 2 unchecked (AC 7 for N4, AC 11 pending CI).

Owner directive 2026-11-07: parallel test gates only

Work mode `full-feature`; sources `spec.md` and `user-story.md`. "Gate" below means the structural-suite gate (`evidence/regression-testing/structural-suites.2026-11-07T16-50.md`) and the final gate (`evidence/qa-gates/pester-coverage.2026-11-07T17-06.md`), in both of which the named suites passed.

## spec.md `## Acceptance Criteria`

| # | Criterion (abbreviated) | Status | Evidence |
|---|---|---|---|
| 1 | Native tool lists of the four roles; no path-scoped entry, `disallowedTools` or `memory:`; asserted on all hosts | PASS, checked | `docs-authoring-roles.Allowlist.Tests.ps1` (`excludes Write-class and Bash tools from the read-only roles` and the per-role rows) in the gate |
| 2 | MCP tool lists equal the role table; `update_docs_ledger` only in `docs-reconciler`; every docs tool held | PASS, checked | Allowlist suite (`holds update_docs_ledger only in docs-reconciler`, `gives every docs MCP tool to at least one role`) in the gate |
| 3 | Write-scope deny and allow rules, reasons naming the rule | PASS, checked | `evidence/regression-testing/enforce-docs-role-write-scope.2026-11-07T16-30.md` |
| 4 | Absent or unparseable profile keeps rules 4 and 6; dependency failure denies | PASS, checked | same artifact |
| 5 | SubagentStop blocks each missing token with exit 2 and allows a complete output | PASS, checked | `evidence/regression-testing/validate-docs-role-output.2026-11-07T16-30.md` (24 token rows, 4 valid rows) |
| 6 | SubagentStop value rules, non-docs pass-through, `StopHookActive`, fail-closed paths | PASS, checked | `validate-docs-role-output` and `docs-role-contract` artifacts of 2026-11-07T16-30 |
| 7 | Skills reference only docs MCP tools and dispatch-table subcommands | PASS, checked | `docs-authoring-roles.Skills.Tests.ps1` (`references only docs MCP tools defined by 1036`, `references only dispatch-table subcommands and options`) in the gate |
| 8 | `.agents` and `.github` skill copies carry no `.claude/` text and state the prerequisite | PASS, checked | Skills suite host-copy rows in the gate |
| 9 | Mirror and push-down parity; existing contract tests pass "without modification" | UNCHECKED (N4) | Parity holds (`docs-authoring-roles.Mirrors.Tests.ps1`, `evidence/regression-testing/contract-tests.2026-11-07T16-37.md`), but the clause "pass without modification" is false: [P2-T5] and [P2-T6] added rows to `hook-dependency-failure.Claude.Tests.ps1` and `subagentstop-uncaught-error.Tests.ps1`, and `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` gained one exemption row. Orchestrator decision (option b): leave unchecked. |
| 10 | Eight templates with the five front-matter fields and the mode mapping | PASS, checked | `docs-authoring-roles.Templates.Tests.ps1` (48 template rows) in the gate |
| 11 | Settings entries, byte-identical bundle copy; `hook-dependency-failure.Claude.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1` pass without modification | UNCHECKED (N4) | Entries and parity hold (`docs-authoring-roles.Registration.Tests.ps1`); `hook-dependency-failure.Claude.Tests.ps1` was modified by [P2-T5]. Orchestrator decision (option b): leave unchecked. |
| 12 | `docs_operations` block, held tools, three byte-identical routing copies, pre-existing blocks unchanged, parity tests pass | PASS, checked | `evidence/other/routing-copy-hashes.2026-11-07T16-35.md`; Registration suite; `test_orchestration_routing_config_parity.py` and `test_codex_topology_policy_config_parity.py` in `contract-tests.2026-11-07T16-37.md` |
| 13 | No Python or TypeScript change, `.codex/config.toml` unchanged; the classification table lists every created or edited file | UNCHECKED (gap) | First clause holds (`evidence/qa-gates/scope-check.*.md`: 0 code-extension paths, 0 `.codex/config.toml`); second clause fails for one file, `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`, which no classification row lists (`evidence/qa-gates/classification-check.*.md`). |
| 14 | No new suite creates a temporary file | PASS, checked | `evidence/qa-gates/scope-check.*.md`: 0 hits for the five temporary-file tokens in the nine new test files |
| 15 | Line coverage at least 85% for each new hook file, no production file excluded | PASS, checked | `evidence/qa-gates/pester-coverage.*.md` |
| 16 | New suites pass in seeded shuffled runs and in a fresh single-process run | UNCHECKED (waived) | Owner directive 2026-11-07: parallel test gates only. No seeded-shuffle or single-process run was made; the suites pass in the parallel gates (`evidence/regression-testing/pester-shuffle.*.md` records the waiver). |
| 17 | (CI-dependent) PoshQC and quality-checks7 jobs pass on the PR head | UNCHECKED (pending-CI) | `evidence/qa-gates/ci-pending.*.md` |

## user-story.md `## Acceptance Criteria`

| # | Criterion (abbreviated) | Status | Evidence |
|---|---|---|---|
| 1 | Role tool exclusions on Claude, Copilot and Codex copies | PASS, checked | Allowlist suite in the gate |
| 2 | `update_docs_ledger` only in `docs-reconciler`; MCP sets equal the role table | PASS, checked | Allowlist suite in the gate |
| 3 | Write-scope hook cases | PASS, checked | `enforce-docs-role-write-scope.2026-11-07T16-30.md` |
| 4 | SubagentStop cases | PASS, checked | `validate-docs-role-output.2026-11-07T16-30.md` |
| 5 | Skills reference only defined tools and subcommands | PASS, checked | Skills suite in the gate |
| 6 | Codex and Copilot skill copies: no `.claude/` path, prerequisite stated | PASS, checked | Skills suite in the gate |
| 7 | Mirror parity; existing contract tests pass "without modification" | UNCHECKED (N4) | As spec AC 9. |
| 8 | Template front matter and mode mapping | PASS, checked | Templates suite in the gate |
| 9 | Hook registration and the three routing copies | PASS, checked | Registration suite; `routing-copy-hashes.2026-11-07T16-35.md` |
| 10 | No Python or TypeScript change, `.codex/config.toml` unchanged, no temporary file | PASS, checked | `scope-check.*.md` |
| 11 | (CI-dependent) PoshQC jobs pass on the PR head | UNCHECKED (pending-CI) | `ci-pending.*.md` |

## N5 deviation

The surface-delta finding code differs between the 1034 spec and the epic (`DOCS_SURFACE_DELTA_UNLEDGERED`). The skills name no surface-delta finding code: `docs-review-coverage` names only the `surface-delta` subcommand with its dispatch-row options (`-Base`, `-Profile`, from `upstream-contracts.2026-11-07T15-59.md`), the evidence artifact `docs-surface-delta.<timestamp>.md`, and the review finding `surface-change-without-ledger-change` owned by 1034 and raised by `feature-review`.
