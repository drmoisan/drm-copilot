# Policy Compliance Audit: npm-audit-gate-and-dependabot

- Feature: npm-audit-gate-and-dependabot (no associated GitHub issue number)
- Date: 2026-06-20T00-43
- Base branch: main
- Merge-base SHA: b70045e02d0d3b6290e9ed9799d0dec5ed09425b
- Feature head SHA: 948b03ee31e8375a7a20ee328ca4949b06afdfb2
- Work Mode: minor-audit
- Reviewer: feature-review agent

## Executive Summary

This change adds CI infrastructure only: a reusable `npm audit` gate workflow, a thin caller workflow, and a Dependabot configuration. No production source files (`.ts`, `.py`, `.ps1`, `.cs`) were modified. The branch diff consists of five files: three GitHub Actions / Dependabot configuration files and two feature-folder documentation files.

Independent verification confirmed: all three YAML files parse, `actionlint` exits 0 on both workflows, and `npm audit --audit-level=moderate` exits 0 for all three manifests against the current committed lockfiles.

Overall verdict: PARTIAL. One Blocking policy finding is present: the `modified-workflow-needs-green-run` rule fires because the diff modifies `.github/workflows/**`, and no green workflow run against the branch head is currently observable. The remaining policy categories are PASS or N/A. The Blocking finding is expected to clear through the PR's own CI (the caller's `pull_request` path filter includes the gate workflow files, so the PR self-triggers the gate) and is verified by the orchestrator's S9 CI-green gate prior to merge.

### Scope of Changed Files

| File | Change | Category |
|---|---|---|
| .github/workflows/_npm-audit-gate.yml | +54/-0 | CI workflow (reusable callee) |
| .github/workflows/npm-audit-gate.yml | +21/-0 | CI workflow (caller) |
| .github/dependabot.yml | +67/-0 | Dependabot config |
| docs/features/active/npm-audit-gate-and-dependabot/issue.md | +71/-0 | Documentation |
| docs/features/active/npm-audit-gate-and-dependabot/plan.2026-06-19T20-37.md | +53/-0 | Documentation |

### Coverage Applicability Determination

Deterministic check for changed source files:
`git diff --name-only b70045e02d0d3b6290e9ed9799d0dec5ed09425b..948b03ee31e8375a7a20ee328ca4949b06afdfb2 | grep -E '\.(ts|tsx|py|ps1|psm1|cs)$'`
Result: no matches. No source files in any of the four measured languages were changed. Coverage is legitimately N/A for all four languages. This is not a scope narrowing; it is the deterministic outcome of a documentation-and-CI-config-only branch.

## 1. General Unit Test Policy Compliance

Verdict: N/A

No production source files changed, so no unit tests were required or added by this change. The general unit test policy (`.claude/rules/general-unit-test.md`) governs test code accompanying source changes; there are no source changes in this branch. The three configuration files are not executable application code and are validated by `actionlint` and YAML parsing rather than by unit tests.

### 1.1 Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript source files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript source files changed on the branch
- PowerShell baseline coverage artifact: N/A - no PowerShell source files changed on the branch
- PowerShell post-change coverage artifact: N/A - no PowerShell source files changed on the branch
- Per-language comparison summary: N/A - no source files changed in any measured language on the branch; coverage measurement is not triggered

### 1.2 Coverage Metrics Table

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|---------------|-------|-------------|-------------------|----------------------|-------------------|
| TypeScript | 0 | N/A | N/A | N/A | N/A | N/A |
| Python | 0 | N/A | N/A | N/A | N/A | N/A |
| PowerShell | 0 | N/A | N/A | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

No per-language comparison bullets are required: every coverage row records N/A for Baseline, Post-Change, and New Code because no source files changed in any measured language. Coverage measurement is not triggered for a CI-config-and-documentation-only branch.

## 2. General Code Change Policy Compliance

Verdict: PASS

The general code change policy (`.claude/rules/general-code-change.md`) applies to the configuration artifacts as authored content. Assessment:

- Simplicity first: PASS. The reusable callee declares a three-entry matrix and two steps (npm ci, npm audit). The caller is a thin wrapper that wires triggers and references the callee. No unnecessary indirection.
- Reusability: PASS. The audit logic is factored into a single reusable workflow (`_npm-audit-gate.yml`) consumed by the caller via `uses: ./.github/workflows/_npm-audit-gate.yml`, following the repository reusable-workflow convention (callee `_<name>.yml` declares `workflow_call` + `workflow_dispatch`).
- Extensibility: PASS. `audit-level` is exposed as a `workflow_call` and `workflow_dispatch` input with a `moderate` default, allowing tightening to `low` without editing the callee body.
- Separation of concerns: PASS. Trigger wiring (caller) is separated from audit execution (callee).
- File size limit: PASS. All files are well under 500 lines (54, 21, and 67 lines).
- Fail fast: PASS. The gate relies on `npm audit` returning a non-zero exit code at or above the configured severity, which fails the step explicitly. `npm ci` precedes the audit and fails the step if the lockfile and manifest are out of sync.

### 2.1 CI Workflow Authoring Rule (`.claude/rules/ci-workflows.md`)

Verdict: N/A (rule does not apply)

The deliberately-failing nested command / exit-code propagation rule applies only to workflow steps whose `run:` block uses `shell: pwsh` and intentionally invokes a failing nested command followed by success logic. The audit step in `_npm-audit-gate.yml` runs under the ubuntu-latest default shell (bash), not pwsh, and the `npm audit` non-zero exit is the step's primary and intended terminal signal — there is no subsequent success path whose exit code could be masked. The exit-code-leak hazard described by the rule is therefore not present. No pwsh steps with deliberately-failing nested commands exist in this diff.

### 2.2 Benchmark Baseline Provenance (`.claude/rules/benchmark-baselines.md`)

Verdict: N/A. No benchmark baseline files are added or modified. No path under `scripts/benchmarks/**` is touched.

## 3. Language-Specific Code Change Policy Compliance

Verdict: N/A

No Python, PowerShell, TypeScript, or C# source files were changed. Language-specific code change rules (`.claude/rules/python.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, `.claude/rules/csharp.md`) are scoped by file path to those source extensions and are not activated by this diff. The only language-relevant policy is the GitHub Actions workflow policy (`.github/instructions/github-actions.instructions.md`), assessed in Section 7.

## 4. Language-Specific Unit Test Policy Compliance

Verdict: N/A

No source files changed in any measured language; no language-specific unit tests were required. See Section 1 and the coverage applicability determination.

## 5. Test Coverage Detail

Verdict: N/A

No source files changed in any of the four measured languages (TypeScript, Python, PowerShell, C#). Coverage measurement is not triggered. The coverage table in Section 1.2 records N/A for all languages with a documented deterministic basis. Per the repository coverage-applicability rule, N/A is the correct verdict for a language with zero changed source files on the branch.

As a regression guard appropriate to this change type, `npm audit --audit-level=moderate` was executed against all three manifests; each exited 0. `npm ci` lockfile-sync behavior is exercised by the gate at runtime on the CI runner.

## 6. Test Execution Metrics

Verdict: N/A

No unit test suites were in scope for this change. The verification performed is configuration validation rather than test execution:

| Check | Target | Result |
|---|---|---|
| YAML parse | _npm-audit-gate.yml, npm-audit-gate.yml, dependabot.yml | PASS (all three parse) |
| actionlint | _npm-audit-gate.yml, npm-audit-gate.yml | PASS (exit 0) |
| npm audit --audit-level=moderate | root, extensions/drm-copilot, packages/mcp-server | PASS (exit 0 for all three) |
| evidence-location validator | repository root | PASS (exit 0) |

## 7. Code Quality Checks

Verdict: PASS (with one Blocking process finding tracked in Section 8)

GitHub Actions workflow policy (`.github/instructions/github-actions.instructions.md`):

- Workflows must pass `actionlint`: PASS. `actionlint .github/workflows/_npm-audit-gate.yml .github/workflows/npm-audit-gate.yml` exits 0 (independently confirmed).
- Preserve `on:` triggers and permissions unless intentional: PASS. Both workflows are new files; triggers are intentional and documented in issue.md.
- Jobs small and focused: PASS. The callee has one job (npm-audit) with a clear single responsibility; the caller has one job that delegates.
- Expression syntax accurate: PASS. `${{ matrix.manifest }}` and `${{ inputs.audit-level }}` are used correctly. The audit step reads the input through the `AUDIT_LEVEL` environment variable rather than direct expression interpolation in the `run:` body, which is the safer pattern.
- Prefer reusable actions over inlined bash: PASS. The audit logic is a reusable workflow; the only inline commands are `npm ci` and `npm audit`, which are minimal.

Dependabot configuration (`.github/dependabot.yml`):

- Schema version 2 with valid structure: PASS (YAML parses; structure matches Dependabot v2 schema).
- Four ecosystems configured: three npm directories (`/`, `/extensions/drm-copilot`, `/packages/mcp-server`) and github-actions, each weekly with grouped updates and `open-pull-requests-limit: 5`. Matches the stated implementation intent.

## 8. Gaps and Exceptions

### 8.1 Blocking: modified-workflow-needs-green-run

The branch diff modifies paths matching `.github/workflows/**` (`_npm-audit-gate.yml`, `npm-audit-gate.yml`). The `modified-workflow-needs-green-run` policy rule (`.claude/skills/feature-review-workflow/SKILL.md`) therefore requires evidence of a green workflow run against the branch head (SHA 948b03ee31e8375a7a20ee328ca4949b06afdfb2) before merge.

Current state: no qualifying green-run evidence is present. `gh run list --workflow=npm-audit-gate.yml` returns HTTP 404 (the workflow does not yet exist on the default branch), no PR exists for the branch yet, and no remediation-inputs file currently records a green `workflow_dispatch` or PR-context run against the branch head.

Disposition: Blocking. Routed to remediation inputs. The rule is satisfiable without code change: the caller `npm-audit-gate.yml` has a `pull_request` path filter that includes the gate workflow files (`.github/workflows/npm-audit-gate.yml`, `.github/workflows/_npm-audit-gate.yml`), so the PR that introduces this change self-triggers the gate. The resulting green run against the branch head provides the required evidence, verified by the orchestrator's S9 CI-green gate prior to merge. This is the documented mitigation for the chicken-and-egg case in which a feature must land its CI gate before the gate can run in PR context.

Note: the supporting validator referenced by the rule, `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1`, is not present on disk in this worktree. The rule's trigger-path and evidence-presence logic was applied textually: trigger path matched (`.github/workflows/**`), evidence absent, therefore Blocking.

### 8.2 Acceptance criterion AC-7 not yet satisfiable at review time

Issue.md AC-7 ("A green run of the new gate is observed on the PR") is the same end-state evidence as the Blocking finding above. It remains `[ ]` because the green run is produced by the PR's own CI, which has not run at review time. This is expected for a gate that lands before it can run in PR context.

## 9. Summary of Changes

This change introduces an automated npm vulnerability gate and a Dependabot dependency-update mechanism, as a follow-up to PR #209 which remediated 25 npm vulnerabilities across three independently installed manifests:

- `_npm-audit-gate.yml`: reusable callee declaring `workflow_call` and `workflow_dispatch` with an `audit-level` input (default `moderate`); runs `npm ci` then `npm audit` across a three-manifest matrix (`.`, `extensions/drm-copilot`, `packages/mcp-server`) with `fail-fast: false`.
- `npm-audit-gate.yml`: thin caller wiring `schedule` (weekly Monday 07:00 UTC), path-filtered `pull_request` (on `**/package.json`, `**/package-lock.json`, and the two gate workflow files), and `workflow_dispatch`; calls the callee with `audit-level: moderate`.
- `dependabot.yml`: weekly grouped updates for the three npm directories plus github-actions, each capped at five open PRs.
- Two feature-folder documentation files (issue.md, plan).

## 10. Compliance Verdict

Overall: PARTIAL — one Blocking finding (`modified-workflow-needs-green-run`), remediation routed.

| Section | Verdict |
|---|---|
| 1. General Unit Test Policy | N/A |
| 2. General Code Change Policy | PASS |
| 2.1 CI Workflow Authoring (pwsh exit-code) | N/A (rule not triggered) |
| 2.2 Benchmark Baseline Provenance | N/A (rule not triggered) |
| 3. Language-Specific Code Change | N/A |
| 4. Language-Specific Unit Test | N/A |
| 5. Test Coverage Detail | N/A |
| 6. Test Execution Metrics | N/A |
| 7. Code Quality Checks | PASS |
| 8. Gaps and Exceptions | 1 Blocking (green-run), 1 expected pending AC |

Go/no-go: NO-GO until the green-run evidence is produced and verified by the orchestrator's S9 CI-green gate. All other policy categories are clear. The Blocking finding is the only obstacle and is satisfiable through the PR's own CI without code change.

## Rejected Scope Narrowing

No scope-narrowing instructions were detected in the caller prompt. The caller correctly delegated scope determination to this agent's scope invariant and described the full branch diff. The caller's note that "no production source files were modified" is a factual statement consistent with the independent deterministic check (Section: Coverage Applicability Determination), not an attempt to narrow scope. No verbatim narrowing text is recorded because none was supplied.

## Evidence Location Compliance

Scan of the branch diff for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`:
`git diff --name-only b70045e02d0d3b6290e9ed9799d0dec5ed09425b..948b03ee31e8375a7a20ee328ca4949b06afdfb2 | grep -E 'artifacts/(baselines|qa|evidence|coverage)/'`
Result: no matches (no violations). `python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0. No EVIDENCE_LOCATION_OVERRIDE_REJECTED conditions occurred; no delegation specified a non-canonical evidence path. Verdict: PASS.

## Appendix A: Test Inventory

No unit test files were added or modified by this change. There is no test inventory to report. Configuration validation was performed in lieu of test execution; results are summarized in Section 6.

## Appendix B: Toolchain Commands Reference

Commands executed during this review (check-only, no mutation):

- Changed-file enumeration:
  `git diff --name-only b70045e02d0d3b6290e9ed9799d0dec5ed09425b..948b03ee31e8375a7a20ee328ca4949b06afdfb2`
- Source-change coverage trigger check:
  `git diff --name-only b70045e02d0d3b6290e9ed9799d0dec5ed09425b..948b03ee31e8375a7a20ee328ca4949b06afdfb2 | grep -E '\.(ts|tsx|py|ps1|psm1|cs)$'`
- YAML parse:
  `python -c "import yaml; [yaml.safe_load(open(f)) for f in ['.github/workflows/_npm-audit-gate.yml','.github/workflows/npm-audit-gate.yml','.github/dependabot.yml']]"`
- Workflow lint:
  `actionlint .github/workflows/_npm-audit-gate.yml .github/workflows/npm-audit-gate.yml`
- Dependency audit (per manifest):
  `npm audit --audit-level=moderate` run in `.`, `extensions/drm-copilot`, and `packages/mcp-server`
- Evidence-location scan:
  `git diff --name-only b70045e02d0d3b6290e9ed9799d0dec5ed09425b..948b03ee31e8375a7a20ee328ca4949b06afdfb2 | grep -E 'artifacts/(baselines|qa|evidence|coverage)/'`
- Evidence-location validator:
  `python scripts/dev_tools/validate_evidence_locations.py --root .`
- Green-run evidence probe:
  `gh run list --workflow=npm-audit-gate.yml --limit 5`
