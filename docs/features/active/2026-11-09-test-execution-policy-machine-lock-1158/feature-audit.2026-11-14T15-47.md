# Feature Audit: Test-execution policy and machine test-suite lock (#1158), re-audit after remediation cycle 1

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158`
**Base Branch:** `main`
**Head Branch:** `feature/test-execution-policy-machine-lock-1158`
**Work Mode:** `full-feature`
**Audit Type:** Acceptance re-verification at the exit of remediation cycle 1; no pull request yet

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `add7d747886ce893356b63de2941435f2895b345`, fetched during this review and unchanged)
- **Head branch/commit:** `feature/test-execution-policy-machine-lock-1158` (commit `6a6a85a23701f4413349fad33f59663e09314757`)
- **Merge base:** `add7d747886ce893356b63de2941435f2895b345`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 15:37:41 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/**`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` parsed by the reviewer; reads of the four dispatcher registries, both `settings.json` and both `config.toml` copies; a real-process probe of the scoped resolver; `check_quality_tiers` and `validate_evidence_locations.py` at the reviewed head. No CI run exists for the branch.
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

Criteria are identified below by source file and line number; the full text is in the source files and is not rewritten here. Cycle 1 replaced text in place (no line added or removed) in spec lines 192 (D30) and 343 (AC5) and in user-story line 66 (AC4), so line numbers match the first review.

#### From spec.md
- AC1: S298 SKILL.md documents keys, lock, holder, exit codes, prefixes, copies equal; S299 defaults; S300 one case per validation rule; S301 committed config validates and classifies; S302 pytest markers and `--strict-markers` run
- AC2: S306 lock directory and file names; S307 `.codex/hooks` helper discovery; S308 busy lock exits 75; S309 free lock, exit propagation, working directory, cleanup on throw; S310 no worker-reduction tokens; S311 PoshQC lane exclusion; S312 MCP templates; S313 `Invoke-PesterSuite.ps1` argument reach and JUnit without integration files; S314 bats shim; S315 Python and VS Code callers; S316 live Linux two-process proof
- AC3: S320 state-model rows; S321 holder descriptions; S322 driver loop; S323 lane classification; S324 no temporary file or real wait
- AC4: S328 runner deny cases and D25 forms; S329 launcher allowed and lane or worker denials; S330 hidden wrappers; S331 MCP cases; S332 knobs and failure modes; S333 seam override (D33); S334 Codex twin; S335 registration (either D31 branch)
- AC5: S339 wording rows; S340 brief copies; S341 executor tool lists; S342 review-workflow copies; S343 ledger entry `0012` and ledger tests
- Definition of Done: S347-S353

#### From user-story.md
- Agent operator: U49 queue timeout 75; U50 worker options unchanged; U51 exit propagation and cleanup; U52 injected clock; U53 hook denials; U54 MCP denials; U55 launcher refusals; U56 brief and executor text
- Repository owner: U60 SKILL.md and mirrors; U61 defaults and validation; U62 committed config; U63 Python and VS Code callers; U64 PoshQC and templates; U65 seams, no temporary files; U66 registration as dispatcher-registry membership (rewritten in cycle 1 to spec D31 branch B); U67 skill wording rows

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S298 | SKILL.md content and copies equal | PASS | Six test-execution-policy copies byte-identical (reviewer `md5sum`); push-down contract tests in the pytest gate (16927 passed) | `md5sum`; read of `pytest-suite.2026-11-14T15-28.md` | Cycle 1 added `### Scoped Pester runs` to every copy |
| S299 | Defaults with no config text | PASS | `test-execution-policy.Tests.ps1` green in the 26420-test Pester gate | evidence read | — |
| S300 | One case per validation rule | PASS | Same suite | evidence read | — |
| S301 | Committed config validates and classifies | PASS | `test-execution-policy.RepoConfig.Tests.ps1` green | evidence read | — |
| S302 | Markers registered; `--strict-markers` run | PASS | Unchanged since the first review; pytest gate exit 0 | evidence read | — |
| S306 | Lock directory and file names | PASS | `test-execution-lock.Tests.ps1` green | evidence read | — |
| S307 | `.codex/hooks` helper discovery | PASS | `Invoke-TestSuite.Tests.ps1` and `PoshQC.McpTemplateLock.Tests.ps1` green | evidence read | — |
| S308 | Busy lock exits 75 | PASS | `Invoke-TestSuite.Tests.ps1` green | evidence read | — |
| S309 | Free lock, exit propagation, cleanup | PASS | Same suite | evidence read | — |
| S310 | No worker-reduction tokens | PASS | `Invoke-PesterSuite.Tests.ps1` green, including the new `TestPath` case with no `WorkerCount` key | evidence read; test read | — |
| S311 | PoshQC lane exclusion | PASS | `PoshQC.TestingLaneExclusion.Tests.ps1` green; `PoshQC.ParallelScoped.Tests.ps1` PS12 applies the same rule on the scoped route | evidence read | — |
| S312 | MCP templates | PASS | `PoshQC.McpTemplateLock.Tests.ps1` green | evidence read | — |
| S313 | Pester suite argument reach; JUnit excludes integration files | PASS | `pester-suite.2026-11-14T15-28.md`: none of the four integration-named files in the merged JUnit | evidence read | — |
| S314 | bats shim | PASS | `bats-suite.2026-11-14T10-59.md` 803 tests, 0 failures; no shell file changed afterwards | evidence read; `git diff --stat` | — |
| S315 | Python and VS Code callers | PASS | Unchanged since the first review; pytest gate green | evidence read | — |
| S316 | Live Linux two-process proof | PASS | `lock-two-process-proof.2026-11-11T05-21.md` | `git log` | — |
| S320 | State-model rows | PASS | `test-execution-lock-decision.Tests.ps1` green | evidence read | — |
| S321 | Holder descriptions | PASS | Same suite | evidence read | — |
| S322 | Driver loop | PASS | Same suite | evidence read | — |
| S323 | Lane classification | PASS | `test-execution-policy.Tests.ps1` green; new hook row denies a lane path after `-TestPath` | evidence read; test read | — |
| S324 | No temporary file or real wait | PASS | Leak scan 0 failures (`powershell-static.2026-11-14T15-29.md`); the scoped suite uses seams and module-scope mocks | evidence read; test read | — |
| S328 | Runner deny cases and D25 forms | PASS | Hook suites green; no hook code changed in cycle 1 | evidence read; `git diff --stat` | — |
| S329 | Launcher allowed; lane and worker denials | PASS | Hook suites green, including the new scoped allow and deny rows | evidence read | — |
| S330 | Hidden wrappers | PASS | Hook suites green | evidence read | — |
| S331 | MCP cases | PASS | Hook suites green | evidence read | — |
| S332 | Knobs and failure modes | PASS | Hook suites green | evidence read | — |
| S333 | Seam override (D33) | PASS | Hook suites green | evidence read | — |
| S334 | Codex twin | PASS | `tests/scripts/codex-hooks/enforce-test-execution-policy.Tests.ps1` green | evidence read | — |
| S335 | Registration (D31 branch B) | PASS | `test-execution-policy.Registration.Tests.ps1` 18 cases, 16 passed, 2 skipped by their Codex-only condition; reviewer read of the four registries | evidence read; registry read | — |
| S339 | Wording rows | PASS | `parallel-gate-wording.Tests.ps1` 108 cases green, including 14 `PGW-LAUNCHER-*` and 6 `PGW-SCOPED-*` rows | evidence read | The rows now cover the F1 lines |
| S340 | Brief copies | PASS | Six brief copies byte-identical (reviewer `md5sum`); `test_execution_environment_brief_contracts.py` in the pytest gate | `md5sum`; evidence read | — |
| S341 | Executor tool lists | PASS | Tool lists and the `## Toolchain Commands` prose name the launcher; generator `--check` exit 0 (`phase-gate.P2.2026-11-14T15-00.md`) | `git diff`; evidence read | F1 resolved |
| S342 | Review-workflow copies | PASS | Unchanged since the first review; wording rows green | evidence read | — |
| S343 | Ledger entry and ledger tests | PASS | `0012-local-lane-exclusion.md` and README row; ledger suites 5 and 15 cases green in the final Pester gate | evidence read | Criterion text now names `0012` |
| S347-S353 | Definition of Done | PASS for S347, S349-S351, S353; PENDING-CI for S348; N/A for S352 | Final gates; S348 needs CI (including Linux hook suites) on the pull-request head; no logging surface added | evidence read | S348 and S352 stay unchecked |
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
| U66 | Registration as dispatcher-registry membership | PASS | Reviewer read: `.claude/hooks/pretooluse-dispatch.json` and its bundle copy hold one group with matcher `Bash\|mcp__drm-copilot__run_poshqc_test\|mcp__drm-copilot__run_poshqc_suite`; the Codex registries and bundle copy hold the anchored form with member `timeout` 30; neither `settings.json` nor `config.toml` copy carries a direct hook entry; `ac4-registration-closure.2026-11-14T15-31.md` records the Registration, guard-completeness (792), no-Python (43) and pack-manifest tests passing | registry read; evidence read | F2 resolved; text change authorized by ORCH-D7 |
| U67 | Skill wording rows | PASS | As S339 | — | — |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 50 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria
- **PENDING-CI:** 1 Definition of Done item (S348); 1 Definition of Done item N/A (S352)

**Top gaps preventing PASS:**

1. None among the acceptance criteria. S348 depends on CI on the pull-request head, which does not exist yet.

**Recommended follow-up verification steps:**

1. Open the pull request and confirm CI green on its head, including `poshqc / PowerShell hook suites (Linux)` and the CI integration lanes.
2. Check off S348 at S9 after the CI green gate.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, PASS items are checked and PENDING-CI and N/A items are left unchecked.

Source-file changes made by this review: none. Every PASS item in `spec.md` and `user-story.md` was already checked; U66 was checked off by the executor in cycle 1 (task P3-T6), and this review verified it as PASS. S348 stays unchecked (PENDING-CI, checked off at S9). S352 stays unchecked (N/A: no telemetry or logging surface was added).

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 57 (spec 34 plus 7 Definition of Done items; user story 16)
- Checked off (delivered): 55
- Remaining (unchecked): 2
- Items remaining: spec.md S348 (behavior matches acceptance criteria in all documented environments, pending CI); spec.md S352 (telemetry or logging, not applicable)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 41 | 39 | 2 | 34 AC plus 7 Definition of Done items; S348 pending CI, S352 N/A |
| `user-story.md` | 16 | 16 | 0 | U66 checked in cycle 1 and verified PASS |
