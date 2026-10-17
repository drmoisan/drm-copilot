# Policy Audit (Issue #723, minor-audit)

- Base: origin/main; head a4a681c9; scope: full branch diff (`git diff origin/main...HEAD --name-only`, 22 files).
- Work mode: minor-audit (AC source: `issue.md` `## Acceptance Criteria`).

## Rejected Scope Narrowing

None. The caller prompt requested the full feature-vs-base audit.

## Changed-file scope

Product/test/doc files: `.github/workflows/publish-mcp-npm.yml`, `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`, `docs/engineering/missed-npm-publish.runbook.md`. All other changed files are under the feature folder (`evidence/`, `research/`, `issue.md`, `plan.*.md`). No file under `scripts/`, `extensions/`, `packages/` changed. PASS.

## Verdicts

| Policy | Verdict | Evidence |
|---|---|---|
| Out-of-scope files untouched | PASS | Name-only diff lists only the three expected files plus feature-folder docs. |
| File size limit (500 lines) | PASS | Workflow 135, Pester test 227, runbook 226 (Markdown exempt anyway). |
| Forbidden tokens (`NPM_TOKEN`, `NODE_AUTH_TOKEN`) | PASS | Grep of the workflow returned 0 matches; `final-token-guard-pytest.md` records 17 passed. |
| Tonality (runbook text, error message) | PASS | Runbook section "Red verify step after a green publish step" is factual and neutral; the error message is factual and uses "probably published", matching the evidence strength. |
| Test location | PASS | Test remains at `tests/scripts/workflows/` mirroring `.github/workflows` layout already in use. |
| Test purity (no temp files, no sleeps) | PASS | New tests parse workflow text only; the sleep cmdlet name is built from two fragments as a search token, never executed. |
| Determinism | PASS | Tests use static text and arithmetic; no clock or network. |
| Evidence location compliance | PASS | All evidence is under `<feature>/evidence/{baseline,regression-testing,qa-gates,other}`. `validate_evidence_locations.py --root .` exited 0. No files under `artifacts/baselines|qa|evidence|coverage`. |
| Toolchain: format | PASS | `final-format-pester-file.md`: hash and status identical before and after (PoshQC MCP). |
| Toolchain: lint (PSScriptAnalyzer) | PASS | `final-analyze-pester-file.md`: MCP ok:true plus CI "Analyze PowerShell" step success (finding detail unavailable; see non-blocking N2). |
| Toolchain: actionlint | PASS | Empty output, exit 0 (actionlint 1.7.11, independently observed by orchestrator). |
| Toolchain: unit tests (Pester) | PASS | CI-sourced (accepted D1-D4): baseline run 36925501558 6084 passed/0 failed; fail-before run 36926301667 6085 passed/3 failed; pass-after run 36927150048 6088 passed/0 failed. Arithmetic is consistent: 6084+1 (fourth test passes pre-change) = 6085; 6084+4 = 6088. |
| Evidence artifact consistency | PASS | The three failing test names in the fail-before artifact match the three new tests whose assertions depend on the workflow change; baseline, fail-before, and pass-after counts reconcile. |
| Type check / architecture / integration | PASS | Not applicable to a YAML, Pester, and Markdown change with no production source change; `final-no-source-change-check.md` confirms no source under `scripts`, `extensions`, `packages`. Token-guard pytest passes. |

## Coverage verification

| Language | Changed files | Artifact | Verdict |
|---|---|---|---|
| PowerShell | `PublishMcpNpmWorkflow.Tests.ps1` (test file only; no production `.ps1` changed) | `artifacts/pester/powershell-coverage.xml` absent in the review worktree | FAIL (procedural) |
| TypeScript / Python / C# | none | n/a | zero changed files |

Rationale: the policy requires FAIL when the artifact is absent for a language with changed files. The changed PowerShell file is a test file, which is excluded from the coverage denominator, so no production coverage numerator or denominator changed. The FAIL reflects missing verifiable evidence, not measured under-coverage. CI run 36927150048 completed its poshqc job successfully; attaching that job's coverage output under `evidence/qa-gates/` would resolve it (R1).

## Plan Deviations D1-D8

D1-D5 (CI-sourced Pester, MCP analyze) are operator-approved (Option A) and accepted. The evidence artifacts record each deviation and its limitation (CI logs print only failures). D6-D8 were not independently material to any verdict above.

## Counts

- FAIL: 1 (coverage artifact absent, PowerShell; procedural, resolvable with evidence only).
- Blocking PARTIAL: 0.
