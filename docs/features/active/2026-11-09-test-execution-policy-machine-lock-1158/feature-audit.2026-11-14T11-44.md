# Feature Audit: Test-execution policy and machine test-suite lock (#1158)

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158`
**Base Branch:** `main`
**Head Branch:** `feature/test-execution-policy-machine-lock-1158`
**Work Mode:** `full-feature`
**Audit Type:** First acceptance verification (S7); no pull request yet

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `add7d747886ce893356b63de2941435f2895b345`)
- **Head branch/commit:** `feature/test-execution-policy-machine-lock-1158` (commit `c03f350da362989a3eb4b2153ec9cff5fef45447`)
- **Merge base:** `add7d747886ce893356b63de2941435f2895b345`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 11:35:30 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/**`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml` and `artifacts/python/lcov.info` parsed by the reviewer; a real-process probe of the hook; `check_quality_tiers` at the reviewed head. No CI run exists for the branch.
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

Criteria are identified below by source file and line number; the full text is in the source files and is not rewritten here.

#### From spec.md
- AC1: S298 SKILL.md documents keys, lock, holder, exit codes, prefixes, copies equal; S299 defaults; S300 one case per validation rule; S301 committed config validates and classifies; S302 pytest markers and `--strict-markers` run
- AC2: S306 lock directory and file names; S307 `.codex/hooks` helper discovery; S308 busy lock exits 75; S309 free lock, exit propagation, working directory, cleanup on throw; S310 no worker-reduction tokens; S311 PoshQC lane exclusion; S312 MCP templates; S313 `Invoke-PesterSuite.ps1` argument reach and JUnit without integration files; S314 bats shim; S315 Python and VS Code callers; S316 live Linux two-process proof
- AC3: S320 state-model rows; S321 holder descriptions; S322 driver loop; S323 lane classification; S324 no temporary file or real wait
- AC4: S328 runner deny cases and D25 forms; S329 launcher allowed and lane or worker denials; S330 hidden wrappers; S331 MCP cases; S332 knobs and failure modes; S333 seam override (D33); S334 Codex twin; S335 registration (either D31 branch)
- AC5: S339 wording rows; S340 brief copies; S341 executor tool lists; S342 review-workflow copies; S343 ledger entry and ledger tests
- Definition of Done: S347-S353

#### From user-story.md
- Agent operator: U49 queue timeout 75; U50 worker options unchanged; U51 exit propagation and cleanup; U52 injected clock; U53 hook denials; U54 MCP denials; U55 launcher refusals; U56 brief and executor text
- Repository owner: U60 SKILL.md and mirrors; U61 defaults and validation; U62 committed config; U63 Python and VS Code callers; U64 PoshQC and templates; U65 seams, no temporary files; U66 registration in settings and config; U67 skill wording rows

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S298 | SKILL.md content and copies equal | PASS | SKILL.md copies in the diff; push-down contract tests in the pytest gate (16927 passed) | read of `pytest-suite.2026-11-14T11-27.md` | — |
| S299 | Defaults with no config text | PASS | `test-execution-policy.Tests.ps1` 511 cases, 0 failures | JUnit parse | — |
| S300 | One case per validation rule | PASS | Same suite | JUnit parse | — |
| S301 | Committed config validates and classifies | PASS | `test-execution-policy.RepoConfig.Tests.ps1` 10 cases, 0 failures | JUnit parse | — |
| S302 | Markers registered; `--strict-markers` run | PASS | `pyproject.toml` diff adds both markers; `pytest-suite.2026-11-14T11-20.md` no marker error, exit 0 | evidence read | — |
| S306 | Lock directory and file names | PASS | `test-execution-lock.Tests.ps1` 43 cases, 0 failures | JUnit parse | — |
| S307 | `.codex/hooks` helper discovery | PASS | `Invoke-TestSuite.Tests.ps1` 37 and `PoshQC.McpTemplateLock.Tests.ps1` 24 cases, 0 failures; launcher step 0 code read | JUnit parse; code read | — |
| S308 | Busy lock exits 75 | PASS | `Invoke-TestSuite.Tests.ps1` green | JUnit parse | — |
| S309 | Free lock, exit propagation, cleanup | PASS | Same suite; `finally` removes the record then disposes the stream | JUnit parse; code read | — |
| S310 | No worker-reduction tokens | PASS | `test-execution-policy.Tests.ps1`, `Invoke-PesterSuite.Tests.ps1` 18 cases green; probe denied launcher `-n 2` | JUnit parse; hook probe | — |
| S311 | PoshQC lane exclusion | PASS | `PoshQC.TestingLaneExclusion.Tests.ps1` 10 cases green; `test_poshqc_bundled_parity.py` in pytest gate | JUnit parse | — |
| S312 | MCP templates | PASS | `PoshQC.McpTemplateLock.Tests.ps1` green | JUnit parse | — |
| S313 | Pester suite argument reach; JUnit excludes integration files | PASS | Reviewer JUnit parse: no testsuite from the four integration-named files | scratch JUnit parse | Matches only appear as test names that quote the file names |
| S314 | bats shim | PASS | `bats-suite.2026-11-14T10-59.md` 803 tests, 0 failures | evidence read | — |
| S315 | Python and VS Code callers | PASS | Diffs of the four Python callers and `.vscode/tasks.json`; new tests in the pytest gate | code read; evidence read | — |
| S316 | Live Linux two-process proof | PASS | `lock-two-process-proof.2026-11-11T05-21.md`, B exit 75 naming A; committed before the registration change | `git log` | — |
| S320 | State-model rows | PASS | `test-execution-lock-decision.Tests.ps1` 47 cases green | JUnit parse | — |
| S321 | Holder descriptions | PASS | Same suite | JUnit parse | — |
| S322 | Driver loop | PASS | Same suite | JUnit parse | — |
| S323 | Lane classification | PASS | `test-execution-policy.Tests.ps1`; probe: `-m integration` denied, `-m 'not integration'` allowed | JUnit parse; hook probe | — |
| S324 | No temporary file or real wait | PASS | Self-review AC3 row; leak scan passed (`powershell-static.2026-11-14T11-03.md`) | evidence read | — |
| S328 | Runner deny cases and D25 forms | PASS | Hook suites 376 cases, command-form 327 cases green; probe denied all specified forms | JUnit parse; hook probe | — |
| S329 | Launcher allowed; lane and worker denials | PASS | Probe: launcher allowed; `-n 2`, `_integration.py`, `-m integration` denied | hook probe | — |
| S330 | Hidden wrappers | PASS | Hook suites green | JUnit parse | — |
| S331 | MCP cases | PASS | Hook suites green | JUnit parse | — |
| S332 | Knobs and failure modes | PASS | Hook suites green | JUnit parse | — |
| S333 | Seam override (D33) | PASS | Hook suites green | JUnit parse | — |
| S334 | Codex twin | PASS | `tests/scripts/codex-hooks/enforce-test-execution-policy.Tests.ps1` green | JUnit parse | — |
| S335 | Registration (D31 branch B) | PASS | `test-execution-policy.Registration.Tests.ps1` 19 cases; `hook-dependency-guard-completeness` 792 and `enforcement-hooks-no-python` 43 cases green; Codex dispatcher timeout 720 equals 690 plus 30 | JUnit parse; `git diff` of registries and config | — |
| S339 | Wording rows | PASS | `parallel-gate-wording.Tests.ps1` 88 cases green | JUnit parse | The rows do not cover the stale lines of finding F1 |
| S340 | Brief copies | PASS | `test_execution_environment_brief_contracts.py` in the pytest gate | evidence read | — |
| S341 | Executor tool lists | PASS | `atomic-executor.md` frontmatter lists the launcher; generator `--check` exit 0 (`python-static.2026-11-14T11-27.md`) | `git diff`; evidence read | Prose line 81 is stale (F1) |
| S342 | Review-workflow copies | PASS | `feature-review-workflow` line 118 names the launcher; wording rows green | code read | — |
| S343 | Ledger entry and ledger tests | PASS | `0012-local-lane-exclusion.md` and README row; ledger suites 5 and 15 cases green | JUnit parse | Text names `0011`; P6-T9 authorizes `0012` (Minor wording note) |
| S347-S353 | Definition of Done | PASS for S347, S349-S351, S353; PENDING-CI for S348; N/A for S352 | Final gates; S348 needs Linux CI on the PR head; no logging surface added | evidence read | S348 and S352 stay unchecked |
| U49 | Queue timeout 75 | PASS | As S308 and S316 | — | — |
| U50 | Worker options unchanged | PASS | As S310 | — | — |
| U51 | Exit propagation and cleanup | PASS | As S309 | — | — |
| U52 | Injected clock | PASS | As S322 | — | — |
| U53 | Hook denials (both twins) | PASS | As S328, S330, S334 | — | — |
| U54 | MCP denials | PASS | As S331 | — | — |
| U55 | Launcher refusals | PASS | As S329 and `Invoke-TestSuite.Tests.ps1` | — | — |
| U56 | Brief and executor name the launcher, exit 75 rule and MCP gap | PASS | As S340 and S341 | — | The criterion is met as worded; the stale Python line is finding F1 |
| U60 | SKILL.md and mirrors | PASS | As S298 | — | — |
| U61 | Defaults and validation | PASS | As S299 and S300 | — | — |
| U62 | Committed config | PASS | As S301 | — | — |
| U63 | Python and VS Code callers | PASS | As S315 | — | — |
| U64 | PoshQC and templates | PASS | As S311 and S312 | — | — |
| U65 | Seams, no temporary files | PASS | As S324 | — | — |
| U66 | Registration in settings and config | FAIL | Registration delivered through the dispatcher registries (S335); `.claude/settings.json` and `.codex/config.toml` hold only the dispatcher entries | `git diff` of registries, settings and config | Finding F2: wording not aligned with spec D31 |
| U67 | Skill wording rows | PASS | As S339 | — | — |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 49 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion (U66)
- **PENDING-CI:** 1 Definition of Done item (S348); 1 Definition of Done item N/A (S352)

**Top gaps preventing PASS:**

1. F2: user-story U66 names direct registration in `.claude/settings.json` and `.codex/config.toml`; the delivered registration follows spec D31 branch B.
2. F1 (code review): agent and skill instructions still direct `poetry run pytest` directly, which the delivered hook denies.

**Recommended follow-up verification steps:**

1. After a planner revision aligns U66 with D31, check it off against the existing Registration test evidence.
2. After the F1 text change, rerun the wording, brief, push-down contract, Codex generator `--check` and ledger chain tests and record new evidence.
3. Confirm CI green on the PR head, including `poshqc / PowerShell hook suites (Linux)` and the CI integration lanes, then check off S348 at S9.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, PASS items are checked and FAIL, PENDING-CI and N/A items are left unchecked.

Source-file changes made by this review: none. Every PASS item in `spec.md` and `user-story.md` was already checked by the executor. U66 was already unchecked and stays unchecked (FAIL, finding F2). S348 stays unchecked (PENDING-CI, checked off at S9). S352 stays unchecked (N/A: no telemetry or logging surface was added).

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 57 (spec 34 plus 7 Definition of Done items; user story 16)
- Checked off (delivered): 54
- Remaining (unchecked): 3
- Items remaining: user-story.md U66 (hook registered in the Bash and MCP groups of settings and config); spec.md S348 (behavior matches acceptance criteria in all documented environments, pending CI); spec.md S352 (telemetry or logging, not applicable)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 41 | 39 | 2 | 34 AC plus 7 Definition of Done items; S348 pending CI, S352 N/A |
| `user-story.md` | 16 | 15 | 1 | U66 FAIL (F2) |
