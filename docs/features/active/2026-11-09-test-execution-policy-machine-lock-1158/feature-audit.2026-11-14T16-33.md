# Feature Audit: Test-execution policy and machine test-suite lock (#1158), review at the PR #1184 head

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158`
**Base Branch:** `main`
**Head Branch:** `feature/test-execution-policy-machine-lock-1158`
**Work Mode:** `full-feature`
**Audit Type:** Acceptance re-verification at the live pull-request head after the S9 check-off

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `add7d747886ce893356b63de2941435f2895b345`, fetched during this review and unchanged)
- **Head branch/commit:** `feature/test-execution-policy-machine-lock-1158` (commit `9262895e3b135d1daee942f3239fe9b926a127ef`, PR #1184)
- **Merge base:** `add7d747886ce893356b63de2941435f2895b345`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (refreshed at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/**`
  - Additional evidence: CI run 43613054239 (full run on `171fa263c`, code identical to the reviewed head) and CI run 43615712466 (docs-only run on the reviewed head), read with `gh pr checks 1184` and `gh run view`; `git diff` of the three commits after the previous review; `validate_evidence_locations.py` and `check_quality_tiers` at the reviewed head.
- **Feature folder used:** `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 5 carries `- Work Mode: full-feature`.
- **Scope note:** Full branch diff against the merge base. No scope narrowing was requested by the caller.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/spec.md` — primary source (34 checkbox items under `## Acceptance Criteria`, lines 298-343, plus 7 `## Definition of Done` items, lines 347-353)
- `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/user-story.md` — secondary source (16 checkbox items, lines 49-67)

### Acceptance criteria

Criteria are identified by source file and line number; the full text is in the source files and is not rewritten here. The only AC source change since the previous review is the in-place check-off of spec line 348.

#### From spec.md
- AC1: S298 SKILL.md documents keys, lock, holder, exit codes, prefixes, copies equal; S299 defaults; S300 one case per validation rule; S301 committed config validates and classifies; S302 pytest markers and `--strict-markers` run
- AC2: S306 lock directory and file names; S307 `.codex/hooks` helper discovery; S308 busy lock exits 75; S309 free lock, exit propagation, working directory, cleanup on throw; S310 no worker-reduction tokens; S311 PoshQC lane exclusion; S312 MCP templates; S313 `Invoke-PesterSuite.ps1` argument reach and JUnit without integration files; S314 bats shim; S315 Python and VS Code callers; S316 live Linux two-process proof
- AC3: S320 state-model rows; S321 holder descriptions; S322 driver loop; S323 lane classification; S324 no temporary file or real wait
- AC4: S328 runner deny cases and D25 forms; S329 launcher allowed and lane or worker denials; S330 hidden wrappers; S331 MCP cases; S332 knobs and failure modes; S333 seam override (D33); S334 Codex twin; S335 registration (either D31 branch)
- AC5: S339 wording rows; S340 brief copies; S341 executor tool lists; S342 review-workflow copies; S343 ledger entry `0012` and ledger tests
- Definition of Done: S347-S353

#### From user-story.md
- Agent operator: U49 queue timeout 75; U50 worker options unchanged; U51 exit propagation and cleanup; U52 injected clock; U53 hook denials; U54 MCP denials; U55 launcher refusals; U56 brief and executor text
- Repository owner: U60 SKILL.md and mirrors; U61 defaults and validation; U62 committed config; U63 Python and VS Code callers; U64 PoshQC and templates; U65 seams, no temporary files; U66 registration as dispatcher-registry membership; U67 skill wording rows

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S298 | SKILL.md content and copies equal | PASS | Copies byte-identical (previous review `md5sum`; no copy changed since); push-down contract tests green locally and in CI | `git diff --name-only 6a6a85a23..HEAD`; evidence read | — |
| S299 | Defaults with no config text | PASS | `test-execution-policy.Tests.ps1` green locally (26420-test gate) and in CI shards | evidence read; CI run 43613054239 | — |
| S300 | One case per validation rule | PASS | Same suite | evidence read | — |
| S301 | Committed config validates and classifies | PASS | `test-execution-policy.RepoConfig.Tests.ps1` green | evidence read | — |
| S302 | Markers registered; `--strict-markers` run | PASS | pytest gate exit 0; CI pytest on 3.11 to 3.13 success | evidence read; CI | — |
| S306 | Lock directory and file names | PASS | `test-execution-lock.Tests.ps1` green | evidence read | — |
| S307 | `.codex/hooks` helper discovery | PASS | `Invoke-TestSuite.Tests.ps1` and `PoshQC.McpTemplateLock.Tests.ps1` green | evidence read | — |
| S308 | Busy lock exits 75 | PASS | `Invoke-TestSuite.Tests.ps1` green | evidence read | — |
| S309 | Free lock, exit propagation, cleanup | PASS | Same suite | evidence read | — |
| S310 | No worker-reduction tokens | PASS | `Invoke-PesterSuite.Tests.ps1` green | evidence read | — |
| S311 | PoshQC lane exclusion | PASS | `PoshQC.TestingLaneExclusion.Tests.ps1` and `PoshQC.ParallelScoped.Tests.ps1` green | evidence read | — |
| S312 | MCP templates | PASS | `PoshQC.McpTemplateLock.Tests.ps1` green | evidence read | — |
| S313 | Pester suite argument reach; JUnit excludes integration files | PASS | `pester-suite.2026-11-14T15-28.md` | evidence read | — |
| S314 | bats shim | PASS | `bats-suite.2026-11-14T10-59.md`; CI `shell-coverage` success | evidence read; CI | — |
| S315 | Python and VS Code callers | PASS | pytest gate green; CI success | evidence read; CI | — |
| S316 | Live Linux two-process proof | PASS | `lock-two-process-proof.2026-11-11T05-21.md` | evidence read | — |
| S320 | State-model rows | PASS | `test-execution-lock-decision.Tests.ps1` green | evidence read | — |
| S321 | Holder descriptions | PASS | Same suite | evidence read | — |
| S322 | Driver loop | PASS | Same suite | evidence read | — |
| S323 | Lane classification | PASS | `test-execution-policy.Tests.ps1` and the scoped hook rows green | evidence read | — |
| S324 | No temporary file or real wait | PASS | Leak scan 0 failures (`powershell-static.2026-11-14T15-29.md`) | evidence read | — |
| S328 | Runner deny cases and D25 forms | PASS | Hook suites green on Windows locally and on Linux in CI | evidence read; CI job `poshqc / PowerShell hook suites (Linux)` | — |
| S329 | Launcher allowed; lane and worker denials | PASS | Same | evidence read; CI | — |
| S330 | Hidden wrappers | PASS | Same | evidence read; CI | — |
| S331 | MCP cases | PASS | Same | evidence read; CI | — |
| S332 | Knobs and failure modes | PASS | Same | evidence read; CI | — |
| S333 | Seam override (D33) | PASS | Same | evidence read; CI | — |
| S334 | Codex twin | PASS | `tests/scripts/codex-hooks/enforce-test-execution-policy.Tests.ps1` green | evidence read; CI | — |
| S335 | Registration (D31 branch B) | PASS | `test-execution-policy.Registration.Tests.ps1` green; previous review's registry read; registries unchanged since | evidence read | — |
| S339 | Wording rows | PASS | `parallel-gate-wording.Tests.ps1` green | evidence read | — |
| S340 | Brief copies | PASS | Copies unchanged since the previous review's `md5sum`; brief contract test green | evidence read | — |
| S341 | Executor tool lists | PASS | Tool lists and `## Toolchain Commands` name the launcher; generator `--check` exit 0 | evidence read | — |
| S342 | Review-workflow copies | PASS | Wording rows green | evidence read | — |
| S343 | Ledger entry and ledger tests | PASS | `0012-local-lane-exclusion.md` and README row; ledger suites green in CI on `171fa263c`, which contains the `Merge commit:` line correction | `git show 171fa263c`; CI | — |
| S347 | AC documented and mapped | PASS | `spec.md` AC sections and plan mapping | read | Already checked |
| S348 | Behavior matches AC in all documented environments | PASS | CI run 43613054239 on `171fa263c`: 23 jobs success, covering Windows and Linux runners, Python 3.11 to 3.13, the Linux hook suites and the CI integration and golden lanes; the reviewed head differs only in documentation | `gh run view 43613054239 --json jobs`; `git diff --name-only 171fa263c..9262895e3` | Checked off at S9 by the item's orchestrator run (`ci-dependent-ac-checkoff.2026-11-14T16-26.md`) |
| S349 | Tests updated/added | PASS | New suites listed in the policy audit Appendix A | read | Already checked |
| S350 | Edge cases and error handling covered | PASS | See the policy audit section 1.2 | read | Already checked |
| S351 | Docs updated | PASS | Skill, brief, executor and ledger text | read | Already checked |
| S352 | Telemetry/logging (if applicable) | N/A | The item adds no telemetry or logging surface | read | Stays unchecked |
| S353 | Toolchain pass completed (format, lint, type-check, test) | PASS | Final local gates clean (`powershell-static.2026-11-14T15-29.md`, `phase-gate.P2.2026-11-14T15-00.md`, suite records); CI Black, Ruff, Pyright, PSScriptAnalyzer and test jobs success | evidence read; CI | Already checked |
| U49 | Queue timeout 75 | PASS | As S308 and S316 | — | — |
| U50 | Worker options unchanged | PASS | As S310 | — | — |
| U51 | Exit propagation and cleanup | PASS | As S309 | — | — |
| U52 | Injected clock | PASS | As S322 | — | — |
| U53 | Hook denials (both twins) | PASS | As S328, S330, S334 | — | — |
| U54 | MCP denials | PASS | As S331 | — | — |
| U55 | Launcher refusals | PASS | As S329 | — | — |
| U56 | Brief and executor name the launcher, exit 75 rule and MCP gap | PASS | As S340 and S341 | — | — |
| U60 | SKILL.md and mirrors | PASS | As S298 | — | — |
| U61 | Defaults and validation | PASS | As S299 and S300 | — | — |
| U62 | Committed config | PASS | As S301 | — | — |
| U63 | Python and VS Code callers | PASS | As S315 | — | — |
| U64 | PoshQC and templates | PASS | As S311 and S312 | — | — |
| U65 | Seams, no temporary files | PASS | As S324 | — | — |
| U66 | Registration as dispatcher-registry membership | PASS | As S335; `ac4-registration-closure.2026-11-14T15-31.md` | — | — |
| U67 | Skill wording rows | PASS | As S339 | — | — |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 56 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria
- **N/A:** 1 Definition of Done item (S352)

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. If a further commit lands before merge, confirm CI green on that head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, PASS items are checked and N/A items are left unchecked.

Source-file changes made by this review: none. Every PASS item in `spec.md` and `user-story.md` was already checked; S348 was checked off at S9 by the item's orchestrator run in `9262895e3`, and this review verified it as PASS against CI run 43613054239. S352 stays unchecked (N/A: no telemetry or logging surface was added).

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 57 (spec 34 plus 7 Definition of Done items; user story 16)
- Checked off (delivered): 56
- Remaining (unchecked): 1
- Items remaining: spec.md S352 (telemetry or logging, not applicable)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 41 | 40 | 1 | 34 AC plus 7 Definition of Done items; S352 N/A |
| `user-story.md` | 16 | 16 | 0 | All verified PASS |
