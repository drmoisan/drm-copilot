# Preparation Halt After Preflight Round Two

Timestamp: 2026-11-23T06-38
Plan: .dev/active/1219-docs-prose-markdown-lint/plan.2026-11-23T00-38.md
Status: preparation halted, blocked_reason validator_failed

## Decision

Preflight round one returned five substantive defects; one planner revision resolved all five. Preflight round two returned three new substantive defects. The single-pass preflight rule of the atomic-plan-contract skill permits one return to the planner, and a second substantive result halts the run. The autonomous-mode directive governs decisions between options; it does not override this process gate, so the run halts instead of opening a third round.

## Remaining Defects (round two)

1. P2-T2, Vale install match path: `It 'installs Vale 3.25.1 and throws VALE_SHA256_MISMATCH before tar'` must also assert that the hash line contains `.Hash.ToLowerInvariant()` and that the `-cne` comparison reads `$env:VALE_SHA256`. Without it, an uppercase `Get-FileHash` result fails every consumer run and no test detects it.
2. P2-T2, Vale run across roots: `It 'runs Vale with the estate configuration and exits with its exit code'` must also assert one call of `$env:RUNNER_TEMP/vale/vale` that receives all non-empty root lines, no `foreach` or `ForEach-Object` around it, and the empty-line filter on `$env:DOCS_LINT_ROOTS`.
3. P1-T3, coverage integration: `It 'reports placeholder counts for pages that contain the token'` must assert concrete `placeholders.token`, `placeholders.total`, and per-page `page_path` and `count` values, and the placeholder text lines between the existing report lines and the `coverage: exit=` summary line.

Each defect is one added assertion in an existing task; no task is added and the file set does not change.

## Resume

One planner revision carrying the three defects above, followed by one preflight, clears the plan if the revision is correct. That extra round requires coordinator authority, for example an owner directive of class `extra_planner_revision` recorded by the coordinator.

## Evidence

- Round-one fix record: .dev/active/1219-docs-prose-markdown-lint/evidence/other/preflight-fixes.2026-11-23T06-23.md
- Round-two fix record: .dev/active/1219-docs-prose-markdown-lint/evidence/other/preflight-fixes.2026-11-23T06-36.md
