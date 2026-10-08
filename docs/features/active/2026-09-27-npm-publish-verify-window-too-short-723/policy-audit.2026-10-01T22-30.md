# Policy Audit (Issue #723, minor-audit) - Reaudit after remediation cycle 1

- Base: origin/main; head 4285f410; scope: full branch diff (`git diff origin/main...HEAD --name-only`, 30 files).
- Work mode: minor-audit (AC source: `issue.md` `## Acceptance Criteria`).
- Supersedes: `policy-audit.2026-10-01T18-00.md`. Re-evaluated finding: R1.

## Rejected Scope Narrowing

None. The caller prompt requested the full feature-vs-base audit.

## Changed-file scope

Product/test/doc files: `.github/workflows/publish-mcp-npm.yml`, `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`, `docs/engineering/missed-npm-publish.runbook.md`. All other changed files are under the feature folder (`evidence/`, `research/`, `issue.md`, `plan`, `remediation-*`, prior review artifacts). The remediation cycle added only feature-folder evidence and documents (`evidence/qa-gates/final-powershell-coverage.md`, `evidence/remediation-baseline/*`, `remediation-plan.*`). No file under `scripts/`, `extensions/`, `packages/` changed. The only changed `.ps1` file is the Pester test file. PASS.

## Verdicts

| Policy | Verdict | Evidence |
|---|---|---|
| Out-of-scope files untouched | PASS | Name-only diff lists the three expected product/test/doc files plus feature-folder documents. |
| File size limit (500 lines) | PASS | Workflow 135, Pester test 227, runbook 226 (Markdown exempt). Unchanged since the prior audit. |
| Forbidden tokens (`NPM_TOKEN`, `NODE_AUTH_TOKEN`) | PASS | `final-forbidden-token-scan-workflow.md` and `final-token-guard-pytest.md` (17 passed). |
| Tonality | PASS | Runbook text and error message are factual and match evidence strength. |
| Test location | PASS | Test remains under `tests/scripts/workflows/`. |
| Test purity / determinism | PASS | Tests parse workflow text only; no temp files, clock, network, or executed sleeps. |
| Evidence location compliance | PASS | The new coverage artifact is at `<feature>/evidence/qa-gates/final-powershell-coverage.md`, a canonical path. The branch diff contains no file under `artifacts/baselines|qa|evidence|coverage`. |
| Toolchain: format | PASS | `final-format-pester-file.md`. |
| Toolchain: lint | PASS | `final-analyze-pester-file.md` (MCP ok plus CI step success; see non-blocking N2). |
| Toolchain: actionlint | PASS | `final-actionlint-publish-mcp-npm.md`, exit 0. |
| Toolchain: unit tests (Pester) | PASS | CI-sourced (accepted D1-D4): 6084/0 baseline, 6085/3 fail-before, 6088/0 pass-after. Counts reconcile. |
| Type check / architecture / integration | PASS | No production source changed; `final-no-source-change-check.md`. |

## Evidence Location Compliance

No violations. No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` appears in the branch diff. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose.

## Coverage verification (R1 re-evaluation)

| Language | Changed files | Artifact | Result | Verdict |
|---|---|---|---|---|
| PowerShell | `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` (test file only; no production `.ps1` changed) | `evidence/qa-gates/final-powershell-coverage.md` (CI poshqc run 36927150048, `powershell-coverage.xml` LINE counter) | Repo-wide line 11353 / 11783 = 96.35 percent (threshold 85 percent); recomputed by the reviewer and consistent. No branch metric exists for Pester; no branch gate applies. | PASS |
| TypeScript / Python / C# | none | n/a | zero changed files | n/a (zero changed files) |

Rationale: the prior FAIL was procedural (artifact absent in the review worktree). The remediation attached the CI-produced report-level counter from the job that ran against the pass-after head. No production PowerShell file changed, so no new-file threshold or changed-line regression applies; the changed test file is outside the coverage denominator. Limitation: the raw XML is not stored in the worktree, and the figures are the orchestrator's extraction recorded in the evidence file. The recorded run, job id, and counters are specific and verifiable via the cited run URL. Run head 9a6e0aa7 precedes current HEAD 4285f410; the intervening commits are limited to feature-folder documentation (confirmed by the name-only diff), so the figure remains applicable.

R1 status: RESOLVED.

## Plan Deviations D1-D8

D1-D5 (CI-sourced Pester, MCP analyze) are operator-approved (Option A) and accepted. D6-D8 were not material to any verdict.

## Counts

- FAIL: 0.
- Blocking PARTIAL: 0.
