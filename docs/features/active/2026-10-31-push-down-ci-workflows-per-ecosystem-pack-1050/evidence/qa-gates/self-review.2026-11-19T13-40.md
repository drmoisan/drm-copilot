# Self-Review (advisory-fix plan, P2-T5)

Timestamp: 2026-11-19T13-40
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against the branch diff from the merge base of origin/epic/shared-agent-harness-layer-integration and HEAD, focused on the eight files this plan changed (advisory-scope-check.2026-11-19T13-40.md)
EXIT_CODE: 0
Output Summary: No FAIL row. The three Minor findings of code-review.2026-11-19T11-55.md are closed, each by named tests. Every other applicable item is PASS; items with nothing in scope are N/A with the reason. The earlier self-review (self-review.2026-11-19T11-49.md) still covers the rest of the branch, which this plan did not change.

## Minor Findings of code-review.2026-11-19T11-55.md

| Finding | Status | Change | Closing test |
| --- | --- | --- | --- |
| Ruleset list not paginated (`Set-CiRequiredChecks.ps1` and bundle copy) | PASS | `gh api repos/<repo>/rulesets --paginate --slurp`; pages flattened before the same-name filter | `finds a same-name ruleset on the second page and issues no write` (failed before the change, task-check.P1-T1); `lists the rulesets with --paginate and --slurp` |
| gh standard error merged into parsed output (`Invoke-GhExe`) | PASS | `Output` holds standard output only; `ErrorOutput` holds the error-stream text; failure messages name the gh call and `ErrorOutput`; non-JSON list output fails with a message that names the call | `returns standard output only when the command writes a warning to standard error`; `names the gh call and its error output when listing fails`; `names the gh call when the ruleset list is not JSON` |
| Copy mode assumes a top-level `tests` directory (`harness-powershell.yml` and bundle copy, README) | PASS | Copy-mode Pester step fails with `Copy mode requires a top-level tests directory.` and `exit 1`; README bullet in `## Push-Down CI Workflows` | `harness workflows are destination-generic` (new negative case expecting `powershell: copy-mode Pester step does not fail when tests is absent`) |

## A. Policy Audit Template

| Item | Status | Evidence |
| --- | --- | --- |
| 1.1 Independence / isolation | PASS | New Pester cases set script-scope fixtures in the `BeforeEach` or use a local mock; the second-page case uses its own `Mock` inside the `It`; the parallel gates passed (8 Pester shards, Jest workers). |
| 1.1 Fast / deterministic | PASS | 30 tests run in about 1.1s (shard log); no clock, network, process, or temporary file (forbidden-token search count 0). |
| 1.1 Readability | PASS | Case names state the behavior; AAA layout. |
| 1.2 Baseline coverage documented | PASS | advisory-baseline-reference.2026-11-19T12-16.md names baseline-pester and baseline-jest. |
| 1.2 No coverage regression | PASS | final-pester: repo-wide 96.77% (47244/48820) vs baseline 96.77%; `Set-CiRequiredChecks.ps1` 98.36% vs prior 98.08%. final-jest: lines 97.44%, branches 94.66% vs baseline 97.42% / 94.63%. |
| 1.2 Changed files meet thresholds | PASS | `Set-CiRequiredChecks.ps1` 98.36% line (threshold 85%). The TypeScript files changed are test files outside the coverage population. |
| 1.2 New code coverage | PASS | Every added line executes in a named test; the only missed line is the pre-existing `-DataFilePath` default expression. |
| 1.2 Positive / negative / edge / error flows | PASS | Positive: second-page match; negative: list failure, non-JSON output, missing guard (Jest); edge: warning on standard error with exit 0; error: messages name the call. |
| 1.2 Concurrency / state transitions | N/A | No concurrent path or state machine in the changed code. |
| 1.4 No external dependencies / mocks | PASS | `Invoke-GhExe` mocked with production parameter names; `-GhCommand` test doubles; no executable mocked. |
| 2.2 Simplicity / reuse | PASS | One parse of one JSON document; no new function; no new workflow input (plan `## Decisions`). |
| 2.3 File size | PASS | Script 209 lines; suite 279; contract helper 421; contract test 259; workflow 101; all below 500. |
| 2.5 Toolchain loop | PASS | phase-gate.P1.2026-11-19T13-22 and final-pwsh-static, final-yaml-static, final-ts-static (2026-11-19T13-34), final-pester (13-38), final-jest (13-39): one clean pass each. |
| 3A Python | N/A | No Python file changed. |
| 3B PowerShell formatting / analyzer | PASS | 0 format differences, 0 PSScriptAnalyzer findings (final-pwsh-static). |
| 3B PowerShell design | PASS | `[CmdletBinding()]` unchanged; `throw` on every failure path; no global state; `ShouldProcess` around the single POST unchanged. |
| 3C Bash | N/A | No bash file. |
| TypeScript (rule file) | PASS | Prettier, ESLint, tsc clean; no `any` and no suppression added. |
| GitHub Actions (rule file) | PASS | actionlint 1.7.12 clean on both copies; the guard is an intended failure path (`exit 1`), not a deliberately-failing nested command, so the exit-code reset pattern of `.claude/rules/ci-workflows.md` does not apply; same `Write-Error -ErrorAction Continue` plus `exit 1` shape as the existing input guard step. |
| 4B Pester style / mocking | PASS | Wrapper mocked, signature parity; test doubles accept remaining arguments. |
| Mirror parity | PASS | advisory-scope-check: script pair acac0fbb..., workflow pair 2fcf236c...; Jest `CI bundle is complete and copies match` passed. |
| Execution-environment brief | N/A | No CI job, required context, tool route, or batch-budget rule changed. |

## B. Code Review Template

| Check | Status | Evidence |
| --- | --- | --- |
| No secrets in code | PASS | No token or credential added. |
| No unsafe command construction | PASS | `gh` called with argument arrays; no `--jq` filter, so the ruleset name is never interpolated into an expression; no `Invoke-Expression`. |
| Input validation at boundaries | PASS | Non-JSON list output is rejected before any write (test asserts zero POST calls). |
| Error handling explicit | PASS | Each failure throws with the gh argument text and error output. |
| Findings | PASS | No new Blocker, Major, Minor, or Warning finding. |

Info (not a defect): the copy-mode guard runs only on a GitHub runner; its presence is pinned by the contract helper, and runtime proof remains the S17 dispatched run that the code review records as pending (orchestrator-owned).

## C. Feature Audit Template

| Item | Status | Evidence |
| --- | --- | --- |
| Acceptance criteria affected | N/A | The plan changes no spec or user-story criterion; S14 (`Set-CiRequiredChecks.ps1` suite) and S11 (contract tests) remain PASS with 30 and 44 selection tests passing. |
| AC check-off changes | N/A | No AC item changes state; S17 and U4 stay unchecked (CI-dependent, orchestrator-owned). |
