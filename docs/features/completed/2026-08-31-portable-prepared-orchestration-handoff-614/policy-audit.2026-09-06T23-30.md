# Policy Audit: Portable Prepared Orchestration Handoff (Issue #614)

**Audit Date:** 2026-09-06
**Auditor:** feature-review
**Feature Folder:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614`
**Base Branch:** `main`, resolved to `origin/main @ 0542c92a7c589cfe952a0dfd480223960fd1eb33`
**Head Branch:** `feature/portable-prepared-orchestration-handoff-614 @ a7b80f2df6d849aa65de416655fa58beb4412998`
**Merge Base:** `1ed0964045febbb4d92f1cb92661d4b945153a40` (2026-09-02T19:09:17-05:00)
**Audit Scope:** Full branch diff against the resolved base branch (233 files, +25165 / -518)

**Code Under Test:** 21 TypeScript production modules under `extensions/drm-copilot/src/`, 16 TypeScript test and support modules under `extensions/drm-copilot/test/`, 5 Python production modules under `scripts/dev_tools/`, 14 Python test and support modules under `tests/scripts/dev_tools/`, 2 PowerShell production hooks (`.codex/hooks/enforce-epic-planning-only.ps1` and its published copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/`), 4 PowerShell test files under `tests/scripts/codex-hooks/`, 15 JSON schema, registry, and fixture files, one pair of `.gitattributes` entries, and 155 Markdown documents.

**Template source:** The three review artifacts in this cycle were shaped from the bundled template assets that `mcp__drm-copilot__resolve_policy_audit_template_asset` returns for the selectors `template`, `code-review-template`, and `feature-audit-template`. `extensions/drm-copilot/src/policy-audit-template-assets.ts` lines 39-60 resolve every selector to `<extensionRoot>/resources/templates/policy_audit/<fileName>`. The reviewer's tool surface carries no MCP transport, so the byte-identical bundled files at `extensions/drm-copilot/resources/templates/policy_audit/` were read directly from that same authoritative location. The template instruction blocks were removed as the templates require.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 37 files | 2966 tests | ✅ 2966 pass, 0 fail | 96.78% lines, 90.28% branches | 96.82% lines, 90.37% branches | 98.04% |
| Python | 19 files | 4384 tests | ✅ 4384 pass, 0 fail | 92.8608% lines, 85.4181% branches | 92.8608% lines, 85.4181% branches | 96.84% |
| PowerShell | 6 files | 3931 tests | ✅ 3931 pass, 0 fail | 94.7630% lines, no branch metric | 94.7697% lines, no branch metric | 87.10% |
| JSON | 15 files | N/A | ✅ schema and registry parity assertions pass | N/A (config and fixture data) | N/A (config and fixture data) | N/A |

**Note:** C# has zero changed files on this branch and is therefore out of scope. Bash has zero changed files on this branch.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/policy-and-scope-baseline.2026-09-02T22-17.md` (P0-T3 record, 96.78% lines and 90.28% branches)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (47738/49304 lines = 96.82%, 6815/7541 branches = 90.37%)
- PowerShell baseline coverage artifact: `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/policy-and-scope-baseline.2026-09-02T22-17.md` (P0-T5 record, 7437/7848 lines = 94.7630%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (7447/7858 lines = 94.7697%)
- Python baseline coverage artifact: `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/python-baseline.2026-09-02T22-17.json` (P0-T4 record, 92.8608% lines and 85.4181% branches)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (14646/15772 lines = 92.86%, 4903/5740 branches = 85.42%)
- Per-language comparison summary: section 1.2.1 of this document, cross-checked against `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/fr-614-005-coverage-comparison.2026-09-03T00-07.md`

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed and new-code coverage when required. Those figures appear above and in section 1.2.1 for all three coverage languages that have changed files.

**Fail-closed rule:** Every required baseline artifact, QA artifact, and coverage-comparison artifact named above was located on disk and parsed. No required artifact is absent.

**Evidence rule:** Every coverage figure in this document was recomputed by the reviewer directly from `extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/lcov.info`, and `artifacts/pester/powershell-coverage.xml` rather than transcribed from the executor's records. Where the reviewer's recomputation and the executor's record agree, that agreement is stated; where they differ, both figures are shown.

---

## Rejected Scope Narrowing

The caller prompt for this review attempted no scope narrowing. It supplied the resolved base branch, the merge base, the PR-context artifact paths, and the work mode, all of which are legitimate scope sources, and it directed verification from existing coverage artifacts, which the workflow itself prescribes. No caller text was rejected.

One narrowing was found inside the evidence this review consumes, and it is rejected here for the record. `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/fr-614-005-coverage-comparison.2026-09-03T00-07.md` states, verbatim:

> ### PowerShell — N/A, with proof
>
> PowerShell changed-code coverage is `N/A` because no PowerShell production file
> changed within the authorized FR-614-005 scope.

and:

> The six PowerShell files that differ from the base
> (`.codex/hooks/enforce-epic-planning-only.ps1`, its published copy, and four
> `tests/scripts/codex-hooks/*.Tests.ps1` files) are prior committed branch work
> from the earlier FR-614 findings, not changes made under FR-614-005.

That reasoning scopes PowerShell coverage to one remediation cycle's task list rather than to the branch diff. The branch diff contains two changed PowerShell production files, so `N/A` is not an acceptable verdict for PowerShell in a feature-versus-base audit. The narrowing is rejected. This audit computes PowerShell changed-line coverage over the full branch diff (27/31 = 87.10%, section 1.2.1) and records an explicit PASS verdict for PowerShell rather than `N/A`.

---

## Evidence Location Compliance

- `git diff --name-only 1ed09640..a7b80f2d | grep -E '^artifacts/(baselines?|qa|qa-gates|evidence|coverage|regression-testing|post-change)/'` returned no matches. No branch file is written to a forbidden `artifacts/` evidence sub-path.
- `python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 and reported no paths.
- All feature evidence resides under `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/{baseline,qa-gates,regression-testing,remediation-baseline,other}/`, which are canonical sub-paths.
- The reviewer received no non-canonical evidence path from the caller, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record was required.

**Status:** ✅ PASS

---

## Executive Summary

The branch adds a versioned, provider-neutral orchestration handoff contract with parallel Python and TypeScript implementations, a shared JSON schema and semantic MCP alias registry, an MCP transition authority, a Codex preparation-gate hook that resolves its allowlist from that registry, and end-to-end TaskMaster issue #469 fixtures in both directions. All seven toolchain stages were exercised and every one passed on the branch head. All three coverage languages exceed the uniform 85% line threshold repo-wide, on changed lines, and per changed file, and the two branch-capable languages exceed the 75% branch threshold.

The compliance gaps that remain are test-completeness gaps rather than behavioral defects. Two are material: the Python destination-projection integrity guard `_validate_projection_facts` has none of its five rejection branches exercised while its TypeScript counterpart is exercised, and the Python failure-precedence tuple carries no parity assertion against `config/orchestration-handoff-registry.json` while the TypeScript list does. Both weaken the cross-runtime parity that AC4, AC5, and AC11 rest on, without contradicting those criteria today. Four further Minor and three Nit gaps are recorded in section 8. No finding blocks the pull request.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (mirrored at `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (mirrored at `.claude/rules/general-unit-test.md`)
- ✅ `quality-tiers.md` (uniform coverage thresholds, Authoritative Decision #2)
- ✅ `tonality.md`

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` and `python-unit-test.instructions.md`
- ✅ `powershell-code-change.instructions.md` and `powershell-unit-test.instructions.md`
- ✅ `typescript-code-change.instructions.md` and `typescript-unit-test.instructions.md`
- N/A `csharp-code-change.instructions.md` and `csharp-unit-test.instructions.md` (zero changed C# files)
- N/A Bash: shfmt, shellcheck, and bats (zero changed Bash files)
- ✅ JSON: schema, registry, and pack-manifest parity assertions

**Temporary artifacts cleanup:**
- ✅ The branch adds no throwaway scripts. Every added `scripts/dev_tools/` module is a tested production module.
- ✅ The reviewer's own parsing scripts were written to the session scratchpad outside the repository and are not part of the diff.
- No scripts were created inside the repository during this review.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The added Python suites build every envelope from module-level constructor helpers such as `_envelope()` in `tests/scripts/dev_tools/test_orchestration_handoff_versions.py`, together with shared fixture JSON under `tests/fixtures/orchestration-handoff/`; no suite mutates shared state. The TypeScript suites inject every boundary through `HandoffMaterializerDependencies`, so no suite depends on another's side effects. Running the seven Python handoff suites in isolation produced 126 passed in 0.69s. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each added test names one behavior, for example `test_legacy_v1_accepts_only_explicit_migration_facts`, `test_completed_phase_replay_has_deterministic_code`, and `it("returns a deterministic dry-run projection without mutation")`. Failure-code assertions are one code per test rather than grouped. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Focused Python handoff suites ran 126 tests in 0.69s. Focused TypeScript handoff suites ran 11 suites and 221 tests in 1.172s. Full-suite figures from the executor records are 4384 Python tests, 2966 TypeScript tests, and 3931 active Pester tests. |
| **Determinism** - Consistent results | ✅ PASS | The materializer takes an injected `HandoffClockBoundary` at `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` lines 80-82 rather than reading wall-clock time. A search for `setTimeout`, `Date.now()`, `Thread.Sleep`, and `time.sleep` across the added handoff test files returned no matches. All hashes are pinned raw-byte SHA-256 values, and the two fixture plan files are exempted from EOL normalization in `.gitattributes` so their digests are stable across platforms. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Python tests carry docstrings such as `"""Installed authority avoids Python and leaves #467/#543 behavior unchanged."""`. TypeScript suites group behavior-named `it` blocks under module-named `describe` blocks. Table-driven negative cases are externalized to `tests/fixtures/orchestration-handoff/contract/invalid-contract-cases.json` and consumed with `it.each`, keeping case data separate from assertion logic. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** TypeScript 96.78% lines and 90.28% branches; Python 92.8608% lines and 85.4181% branches; PowerShell 94.7630% lines.<br>**Commands:** `npm run test:coverage`, `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch`, `mcp__drm-copilot__run_poshqc_test`.<br>**Timestamps:** 2026-09-02 22:17 and 2026-09-06 00:00.<br>**Artifacts:** `evidence/baseline/policy-and-scope-baseline.2026-09-02T22-17.md` and `evidence/baseline/python-baseline.2026-09-02T22-17.json`. |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** TypeScript 96.82% lines and 90.37% branches; Python 92.8608% lines and 85.4181% branches; PowerShell 94.7697% lines.<br>**Change:** TypeScript +0.04% lines and +0.09% branches; Python +0.0000% lines and +0.0000% branches; PowerShell +0.0067% lines.<br>**Status:** No regression in any language. Every figure was recomputed by the reviewer from the post-change lcov and JaCoCo artifacts and agrees with the executor's comparison record. |
| **New Code Coverage >=90%** | ✅ PASS | **New and modified files:** 21 TypeScript `src/**` modules, 5 Python `scripts/dev_tools/` modules, 2 PowerShell hooks.<br>**New and changed executable-line coverage:** TypeScript 3504/3574 = 98.04%; Python 552/570 = 96.84%; PowerShell 27/31 = 87.10%.<br>**Calculation method:** `git diff --unified=0 --no-color 1ed09640 a7b80f2d -- <language paths>` produced the added-line set per file; that set was intersected with the `DA:` records of the lcov artifacts and with the `<line nr= ci=/>` records of the JaCoCo artifact.<br>The PowerShell figure covers modified files, which the tier rule gates at 85% line coverage with no regression rather than at the 90% new-file threshold; 87.10% satisfies it. Both languages that add new files exceed 90%. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | Per-file line coverage for every changed production module is at or above 91% apart from the interface-only module discussed below: `orchestration-handoff-contract.ts` 98.79%, `orchestration-handoff-materializer.ts` 92.48%, `orchestration-handoff-path-boundary.ts` 97.56%, `orchestration-handoff-authority-service.ts` 98.41%, `orchestration_handoff_contract.py` 98.70%, `orchestration_handoff_adapters.py` 96.09%, `orchestration_handoff_contract_support.py` 91.01%.<br>**Untested code:** `scripts/dev_tools/orchestration_handoff_adapters.py` lines 196, 198, 202, 210, and 215 are all five rejection branches of `_validate_projection_facts`, the guard that stops a destination projection from diverging from the validated envelope and that backs AC4 and AC5. `.codex/hooks/enforce-epic-planning-only.ps1` lines 58, 67, 72, and 77 are all four registry-validation `throw` statements in `Get-EpicPlanningRegisteredMcpTool`. `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` lines 143-144, 205-209, 358-363, 392-398, and 411-424 are the workspace-root rejection, the envelope-versus-request source binding rejection, and every post-write recovery branch. `scripts/dev_tools/orchestration_handoff_contract_support.py` line 77 is the already-migrated legacy-input guard. These are the error-handling paths this section requires to be exercised. |
| **Positive Flows** - Valid inputs | ✅ PASS | **Positive scenarios tested:**<br>- `test_orchestration_handoff_contract.py` validates both positive fixtures, `valid-ordinary-claude-to-codex.json` and `valid-parallel-codex-to-claude.json`<br>- `it("returns a deterministic dry-run projection without mutation")` covers the dry-run success path<br>- `it("atomically replaces the canonical checkpoint after candidate validation")` covers the materialization success path<br>- `It 'allows both registered MCP server spellings identically for <Operation>'` covers four operations across two transport spellings<br>- `test_orchestration_handoff_taskmaster_469.py` covers both #469 fixture directions end to end<br>**Total tests in the focused handoff subsets:** 126 Python and 221 TypeScript |
| **Negative Flows** - Invalid inputs | ⚠️ PARTIAL | **Negative scenarios tested:**<br>- `it.each(invalidEnvelopeCases)("rejects $id")` drives the externalized invalid-contract case table<br>- `test_unknown_major_version_has_deterministic_code`, `test_unknown_vocabulary_has_deterministic_code`, `test_unknown_capability_has_deterministic_code`, `test_invalid_transition_has_deterministic_code`, and `test_completed_phase_replay_has_deterministic_code`<br>- `test_invalid_plan_path_blocks_before_write`, `test_plan_directory_rediscovery_blocks_before_write`, `test_shared_traversal_fixture_blocks_before_write`, `test_wrong_binding_blocks_before_write`, and `test_stale_plan_hash_blocks_before_write`<br>- `It 'denies <Label> exactly without changing checkpoint bytes'` covers a malformed MCP id, an unrelated MCP server, an unregistered operation, an approximate operation, a shell edit, and a production patch<br>**Gap:** the five `_validate_projection_facts` rejections and the four hook registry-validation rejections have no negative test. See section 8, gaps G1 and G4. |
| **Edge Cases** - Boundary conditions | ✅ PASS | **Edge cases tested:**<br>- `test_supported_newer_minor_version_is_accepted` covers schema version 2.99.0 at the supported-major boundary<br>- `it("walks missing ancestors to the nearest canonical directory")` covers creatable paths whose parents do not yet exist<br>- `it("rejects root-prefix collisions after canonical resolution")` covers a sibling directory whose name is a string prefix of the workspace root<br>- `it("accepts an in-root link only after resolving its canonical target")` and `it("rejects existing and creatable reparse targets outside the root")` cover symlink and reparse escape<br>- `it("rejects non-normal separators and applies configured case semantics")` covers separator and case-folding boundaries |
| **Error Handling** - Error paths | ⚠️ PARTIAL | **Error scenarios tested:**<br>- `it("blocks with an unavailable observation rather than trusting the envelope")` covers checkout-observation failure<br>- `it.each(supportFailureCases)` and `it("normalizes malformed JSON to a contract error")` cover contract-support failures<br>- `test_orchestration_handoff_paths.py` proves each rejection blocks before any write by installing write-denying boundaries<br>**Gap:** `OrchestrationHandoffMaterializer.stageMaterialization` has exactly one success-path test and no test for any of its five recovery branches, so the AC10 clause "any failure leaves the source checkpoint intact and records no completed transition" is verified by code inspection alone for post-write failures. See section 8, gap G3. |
| **Concurrency** - If applicable | N/A | The handoff transition is a single-writer, single-process operation. The one concurrency-adjacent behavior, an existing archive or candidate file left by a prior attempt, is handled by exclusive-create plus digest comparison at `orchestration-handoff-materializer.ts` lines 340-398 rather than by locking. Those branches are untested and are recorded under gap G3 rather than as a concurrency requirement. |
| **State Transitions** - If applicable | ✅ PASS | `REGISTERED_TRANSITIONS` at `scripts/dev_tools/orchestration_handoff_contract.py` lines 57-65 enumerates each transition with its permitted source states, and `test_invalid_transition_has_deterministic_code` plus `test_completed_phase_replay_has_deterministic_code` assert that an unregistered transition and a replayed completed phase both yield `HANDOFF_TRANSITION_NOT_ALLOWED`. History status transitions are constrained by `HISTORY_STATUSES` and asserted in `test_orchestration_handoff_provenance.py`. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.78% lines -> Post-change: 96.82% lines. Change: +0.04% lines and +0.09% branches, from 90.28% to 90.37%. New/changed-code coverage: 98.04% over 3504 of 3574 changed executable lines. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` and `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/fr-614-005-typescript-unit-coverage.2026-09-03T00-07.md`.
- Python: Baseline: 92.8608% lines -> Post-change: 92.8608% lines. Change: +0.0000% lines and +0.0000% branches, holding at 85.4181%. New/changed-code coverage: 96.84% over 552 of 570 changed executable lines. Disposition: PASS. Evidence: `artifacts/python/lcov.info` and `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/fr-614-005-python-unit-coverage.2026-09-03T00-07.md`.
- PowerShell: Baseline: 94.7630% lines -> Post-change: 94.7697% lines. Change: +0.0067% lines, with no branch figure because Pester measures command and line coverage only. New/changed-code coverage: 87.10% over 27 of 31 changed instrumented lines. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` and `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/fr-614-005-powershell-unit-coverage.2026-09-03T00-07.md`.

Two measurement notes belong with these figures.

First, `extensions/drm-copilot/src/repo-automation-service-contract.ts` reports 0 of 198 lines covered. The file consists only of `interface` declarations and re-exported `type` aliases; the branch adds five type imports and three optional method signatures to it and no executable statement. The v8 provider emits an `(empty-report)` placeholder with one zero-hit `DA:` record per source line for such a file. `.claude/rules/general-unit-test.md` states that interface-only files with no executable behavior legitimately report 0% executable coverage, and `extensions/drm-copilot/jest.config.cjs` lines 170-177 and 261-266 record the same reasoning for this exact file. The module remains inside `collectCoverageFrom` and no coverage exclusion was added for it; excluding it would itself be a prohibited exclusion, and it is not excluded. With this module included, TypeScript changed-line coverage is 98.04%; excluding it the figure would be 98.48%.

Second, the published hook copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` is a changed PowerShell production payload that lies outside the PoshQC coverage scope, which spans `.claude/hooks`, `.claude/lib/*`, `.codex/hooks`, `scripts/dev-tools`, and `scripts/powershell`. That scope boundary predates this branch and was not changed by it. The canonical source of the same script is measured at 91.82% line coverage, and byte parity between the two copies is asserted by `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`, so the payload's behavior is covered through its canonical source. This is recorded as an observation and not as a coverage exclusion, because no `exclude` entry was added anywhere in the diff.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Contract failures carry a field name and a reason through `HandoffContractError`, whose constructor composes `${field}: ${message}` at `extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract-support.ts` lines 125-134, and whose Python twin does the same. Hook denials return a fixed reason string that the Pester cases assert verbatim, for example `"MCP tool 'mcp__other__resolve_provider_routing' is outside the registered preparation lifecycle and semantic allowlist."` Parameterized suites use `$id` and `<Label>` interpolation so a failing case names itself. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | The Pester deny cases arrange a payload and capture the checkpoint bytes, act through `Invoke-EpicPlanningDecisionProcess`, then assert both the decision and that the checkpoint bytes are unchanged. The TypeScript materializer suites arrange an injected dependency set, act through `transition`, and assert on the returned result together with the recorded boundary calls. Python suites build an envelope, call `_validate`, and assert one failure code. |
| **Document Intent** | ✅ PASS | Python tests carry docstrings; TypeScript suites nest behavior-named `it` blocks under module-named `describe` blocks; Pester uses `Describe` and `It` with behavioral sentences. Test names state the expected outcome rather than the method under test, for example `test_stale_plan_hash_blocks_before_write`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No added test contacts a network, database, or remote API. Git is reached only through the injected `HandoffGitBoundary` seam in TypeScript. The Pester hook tests invoke the hook as a child process against a repository-local checkpoint file, which is the established process-contract pattern for this hook family rather than an external service. |
| **Use Mocks/Stubs** | ✅ PASS | `HandoffFileSystemBoundary`, `HandoffGitBoundary`, `HandoffTopologyBoundary`, `HandoffRoutingBoundary`, `HandoffValidatorBoundary`, and `HandoffClockBoundary` are the six injected seams at `orchestration-handoff-materializer.ts` lines 30-91; `orchestration-handoff-materializer-test-support.ts` supplies the fakes. Python path tests install write-denying boundaries through the `deny_write_boundaries` fixture, so a rejection that failed to block would surface as an attempted write. |
| **Environment Stability** | ✅ PASS | A search for `tmpdir`, `mkdtemp`, `os.tmpdir`, `TemporaryDirectory`, `tmp_path`, and `NamedTemporaryFile` across the added handoff test files returned no matches, so the prohibition on temporary files in tests is satisfied. Test data is committed under `tests/fixtures/orchestration-handoff/`. The two fixture plan files are pinned to raw bytes by `.gitattributes` entries that disable EOL normalization, which removes the platform-dependent digest that would otherwise make the hash assertions environment-sensitive. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required pre-submission policy review for the branch. The outstanding review items are the nine gaps enumerated in section 8 and carried into `remediation-inputs.2026-09-06T23-30.md`. None is classified blocking. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Policy reading order followed** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-08-31T07-58.md` records the ordered reads from `Policy Order: 1` through `Policy Order: 8`, covering the standing instructions, the general code-change and unit-test policy, the Python, TypeScript, and PowerShell rules, the atomic-plan contract, and the evidence conventions. |
| **Baseline captured before change** | ✅ PASS | `evidence/baseline/policy-and-scope-baseline.2026-09-02T22-17.md` and `evidence/baseline/python-baseline.2026-09-02T22-17.json` record pre-change coverage and test counts for all three languages with `Timestamp:`, `Command:`, and `EXIT_CODE:` fields. |
| **Target surface mapped** | ✅ PASS | `evidence/baseline/target-surface-map.2026-08-31T07-58.md` enumerates the implementation, test, MCP dispatch, hook, provider-skill, bundle, pack, and installed-consumer paths, and records that the #467 and #543 surfaces were deliberately excluded. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | `OrchestrationHandoffMaterializer.transition` is a three-line dispatcher over `prepare` and `stageMaterialization`, with the branch on `request.mode === "dry_run"` expressed once. Failure results are constructed through a single `blockedResult` helper rather than assembled by hand at each of the eighteen rejection sites. |
| **Reusability** | ⚠️ PARTIAL | Shared behavior is factored well within each runtime: `orchestration-handoff-contract-support.ts` and `orchestration_handoff_contract_support.py` hold the validators, patterns, and error type used by their respective contracts, and `orchestration-handoff-materializer-support.ts` and `-request.ts` hold the hashing, porcelain parsing, and result-shaping helpers. Across runtimes the contract vocabulary is deliberately duplicated in Python and TypeScript, which the feature requires. The single source of truth for that duplication is `config/orchestration-handoff-registry.json`, and TypeScript asserts agreement with it at `orchestration-handoff-contract.test.ts` line 267 while Python does not. See section 8, gap G2. |
| **Extensibility** | ✅ PASS | Every public entry point takes one readonly options object rather than positional parameters, for example `TransitionPreparedOrchestrationRequest` and `PortableHandoffReferenceRequest`. The materializer composes six injected interfaces rather than inheriting from a base class. `pathBoundary` is optional with a syntactic default, so a caller may substitute a stricter boundary without a signature change. The three new service methods on `RepoAutomationService` are declared optional, so existing implementors are not broken. |
| **Separation of concerns** | ✅ PASS | Pure contract validation lives in `orchestration_handoff_contract.py` and `orchestration-handoff-contract.ts` with no I/O. Projection is a pure transform in `orchestration-handoff-provider-adapters.ts`. All disk, Git, and authority access is confined to the injected boundaries, with the concrete Node implementations isolated in `orchestration-handoff-materializer-production.ts`. The MCP dispatch layer in `orchestration-handoff-handlers.ts` performs argument shaping only. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **500-line file limit** | ✅ PASS | The largest changed source files are `scripts/dev_tools/orchestration_handoff_contract.py` at 498 lines, `extensions/drm-copilot/src/repo-automation-service.ts` at 498 lines, and `extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract.ts` at 497 lines. A line-count sweep over every changed `.ts`, `.py`, and `.ps1` file returned no file above 500 lines. |
| **Test file location** | ✅ PASS | Python tests mirror production under `tests/scripts/dev_tools/`. PowerShell tests mirror under `tests/scripts/codex-hooks/`. TypeScript tests live under `extensions/drm-copilot/test/lib/validate/` and `extensions/drm-copilot/test/mcp-handlers/`, mirroring `extensions/drm-copilot/src/lib/validate/` and `extensions/drm-copilot/src/mcp-handlers/`. No test file was placed inside a production source tree, so the colocation prohibition holds. The directory is named `test/` rather than `tests/` for this extension, which is the pre-existing convention shared by all 214 suites and is not a change introduced by this branch. |
| **Module decomposition** | ✅ PASS | The handoff surface is split into thirteen focused TypeScript modules and three Python modules by responsibility (contract, contract support, validation, path boundary, provider adapters, materializer, materializer request, materializer support, materializer production, authority service, checkout context, semantic identity, handlers) rather than concentrated in one file. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Names state intent: `resolveExistingTarget` versus `resolveCreatableTarget`, `projectDestinationCheckpoint`, `porcelainAffectedPaths`, `validate_bounded_scheduler_return`, and `Get-EpicPlanningRegisteredMcpTool`. Failure codes are self-describing, for example `HANDOFF_BRANCH_LINEAGE_MISMATCH`. |
| **Language conventions** | ✅ PASS | Python uses `snake_case` functions and `PascalCase` dataclasses; TypeScript uses `camelCase` locals and `PascalCase` types and interfaces; PowerShell uses approved verb-noun form in `Get-EpicPlanningRegisteredMcpTool`, `Get-EpicPlanningDenyDecision`, and `Invoke-EpicPlanningOnlyDecision`. |
| **Documentation comments** | ✅ PASS | Every new TypeScript module carries a header block stating purpose, responsibilities, invariants, and side effects, and every exported interface carries a one-line doc comment. Python modules and public functions carry docstrings, for example `"""Accept legacy bytes only when every portable migration fact is explicit."""`. |
| **Comment quality** | ✅ PASS | Comments explain rationale rather than restating code, for example the note at `orchestration-handoff-materializer.ts` line 417 recording why a failed candidate removal is tolerated, and the two jest configuration comments recording why the interface-only module carries no threshold entry. |

### 2.5 After Making Changes - Toolchain Execution

The seven-stage loop was re-run by the reviewer against the branch head in check-only mode. Every stage passed in a single pass with no auto-fix, so no restart was required.

| Stage | Command | Exit Code | Result |
|-------|---------|-----------|--------|
| 1. Formatting | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` from `extensions/drm-copilot` | 0 | ✅ PASS — "All matched files use Prettier code style!" |
| 1. Formatting | `poetry run black --check .` | 0 | ✅ PASS — 473 files would be left unchanged |
| 1. Formatting | `mcp__drm-copilot__run_poshqc_format` (executor record) | 0 | ✅ PASS — the formatter rewrote no PowerShell file |
| 2. Linting | `npm run lint` (eslint over `src test`) | 0 | ✅ PASS — zero violations |
| 2. Linting | `poetry run ruff check .` | 0 | ✅ PASS — "All checks passed!" |
| 2. Linting | `mcp__drm-copilot__run_poshqc_analyze` (executor record) | 0 | ✅ PASS — zero new diagnostics |
| 3. Type checking | `npm run typecheck` (`tsc -p ./ --noEmit`) | 0 | ✅ PASS — zero errors |
| 3. Type checking | `poetry run pyright` | 0 | ✅ PASS — 0 errors, 0 warnings, 0 informations |
| 3. Type checking | Not applicable to PowerShell | N/A | Skipped per policy |
| 4. Architecture boundary | Consumer import-boundary scan recorded in `evidence/qa-gates/architecture-consumer-import-boundary.2026-08-31T07-58.md`, re-asserted by `test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged` | 0 | ✅ PASS — no `scripts.dev_tools` or `scripts/dev_tools` import reaches the shipped TypeScript authority |
| 5. Unit tests | `poetry run pytest` over the seven handoff suites | 0 | ✅ PASS — 126 passed in 0.69s |
| 5. Unit tests | `poetry run pytest` over the four push-down and validator suites | 0 | ✅ PASS — 46 passed in 0.30s |
| 5. Unit tests | `node run-jest.cjs --testPathPattern "orchestration-handoff\|semantic-mcp-identity"` | 0 | ✅ PASS — 11 suites and 221 tests in 1.172s |
| 5. Unit tests | Full suites per the executor records | 0 | ✅ PASS — 4384 Python passed and 5 skipped; 2966 TypeScript passed across 214 suites; 3931 Pester active passed and 9 skipped |
| 6. Contract / schema | `evidence/qa-gates/fr-614-005-contract-schema.2026-09-03T00-07.md`; registry-to-implementation parity asserted at `orchestration-handoff-contract.test.ts` line 267; fixture digests recomputed by the reviewer | 0 | ✅ PASS — all four fixture digests match both the pinned values and the committed blobs |
| 7. Integration | `evidence/qa-gates/fr-614-005-integration-parity.2026-09-03T00-07.md`; installed-consumer parity through `test_push_down_codex_and_agents_customizations.py` | 0 | ✅ PASS |

Property-based and mutation tests are not required here: the changed modules are dev tooling and orchestration scaffolding classified T4 under `quality-tiers.yml`, for which the property-test density and mutation-score gates are `none`.

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Change documented** | ✅ PASS | `spec.md` (413 added lines), `user-story.md`, and `issue.md` describe the contract, the failure vocabulary, the adapters, and the risks. `research/20260831-portable-prepared-orchestration-handoff-implementation-research.md` records the implementation research. |
| **Commit messages descriptive** | ✅ PASS | Eight commits, each scoped and conventionally prefixed, for example `feat(orchestration): add portable prepared-state handoff contract` and `fix(orchestration): enforce canonical handoff path containment`. |
| **Public API changes called out** | ✅ PASS | The three added `RepoAutomationService` methods are declared optional at `repo-automation-service-contract.ts` lines 165-174, so no existing implementor breaks. The three new tool names are added to `repo-automation-tool-names.ts` and surfaced through `mcp-repo-automation-tool-definitions-handoff.ts`, with the definition inventory asserted by `mcp-repo-automation-tool-definitions.test.ts`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black formatting** | ✅ PASS | `poetry run black --check .` exited 0 with 473 files unchanged. |
| **Ruff linting** | ✅ PASS | `poetry run ruff check .` exited 0 with "All checks passed!". |
| **Pyright type checking** | ✅ PASS | `poetry run pyright` exited 0 with 0 errors, 0 warnings, 0 informations. |
| **Full type annotations** | ✅ PASS | Every added function is annotated, including return types. `from __future__ import annotations` is used, and `TYPE_CHECKING` guards the `collections.abc.Iterable` import so no runtime import is added for a typing-only need. |
| **Typed containers over untyped dictionaries** | ⚠️ PARTIAL | The contract uses frozen dataclasses for `HandoffEnvelope` and its components, which is the correct choice. `Bindings = dict[str, object]` at `orchestration_handoff_contract.py` line 37 and the `dict[str, object]` parameter of `validate_bounded_scheduler_return` keep the scheduler-binding payload untyped by design, because bindings vary by scheduler kind. The values are validated by equality against `expected_bindings` rather than by shape, so no unchecked attribute access occurs, but the payload shape is not expressible to the type checker. This is a design trade-off rather than a violation. |
| **No broad exception handling** | ✅ PASS | The added Python modules raise `HandoffContractError` with a field and a reason rather than catching broadly. No bare `except:` or `except Exception:` appears in the added modules. |
| **Fail fast on invariant violation** | ✅ PASS | `_require` raises immediately on any failed invariant, and `read_legacy_v1` raises before returning bytes when the source provider or any migration fact is absent, at lines 78-83. |
| **Dependencies unchanged** | ✅ PASS | No dependency was added; the modules use only `json`, `re`, `hashlib`, `dataclasses`, and `typing` from the standard library. |
| **I/O isolated** | ✅ PASS | `orchestration_handoff_contract.py` performs no file I/O. File reads are confined to `raw_file_sha256` and `resolve_pinned_plan_path` in the support module, keeping the validation core testable without a filesystem. |

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Invoke-Formatter clean** | ✅ PASS | `mcp__drm-copilot__run_poshqc_format` returned `ok: true` and rewrote no file, per `evidence/qa-gates/fr-614-005-powershell-format.2026-09-03T00-07.md`. |
| **PSScriptAnalyzer clean** | ✅ PASS | `mcp__drm-copilot__run_poshqc_analyze` exited 0 with zero new diagnostics, per `evidence/qa-gates/fr-614-005-powershell-analyze.2026-09-03T00-07.md`. |
| **Advanced function form** | ✅ PASS | `Get-EpicPlanningRegisteredMcpTool` declares `[CmdletBinding()]`, `[OutputType([string[]])]`, and `[Parameter(Mandatory)]` on both parameters. |
| **Approved verb naming** | ✅ PASS | `Get-EpicPlanningRegisteredMcpTool` uses the approved `Get` verb with a namespaced noun consistent with the file's existing `Get-EpicPlanningDenyDecision` and `Invoke-EpicPlanningOnlyDecision`. |
| **Literal path usage** | ✅ PASS | Every path operation uses `-LiteralPath`, including `Test-Path -LiteralPath` and `Get-Content -Raw -LiteralPath`, so a bracket in a path cannot be interpreted as a wildcard. |
| **Explicit failure behavior** | ⚠️ PARTIAL | The registry resolution at lines 85-88 executes at script scope, above both the dot-source guard at line 315 and the `try` block at line 319. A missing or malformed `config/orchestration-handoff-registry.json` therefore raises an unhandled terminating error instead of the hook's deterministic `exit 2` with a stderr reason, and it also prevents the file from being dot-sourced for testing. `config/orchestration-handoff-registry.json` is delivered to consumers through `pack-manifests/core.json` and `push_down_codex_and_agents_customizations.py` line 70, so the condition is unlikely in a correctly installed checkout, but the failure mode is not the contracted one. See section 8, gap G4. |
| **Regex construction safety** | ✅ PASS | The transport-alias pattern escapes the interpolated operation with `[regex]::Escape($operation)` before embedding it, and anchors both ends with `^` and a backtick-escaped `$`. |
| **Branch-coverage gate** | N/A | Pester measures command and line coverage only, so no branch threshold applies to PowerShell per `.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md`. The absent branch figure is not a failure. |

### Section 3C: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Prettier formatting** | ✅ PASS | `npx prettier --check` exited 0 across `src`, `test`, `*.json`, and `*.cjs`. |
| **ESLint clean** | ✅ PASS | `npm run lint` exited 0 with zero violations. |
| **tsc --noEmit clean** | ✅ PASS | `npm run typecheck` exited 0 with zero errors. |
| **No untyped escape hatches** | ⚠️ PARTIAL | A search for `: any`, `<any>`, and `as any` across the added handoff production modules returned no matches. One unchecked assertion remains at `orchestration-handoff-materializer.ts` lines 271-276, where a caught error is narrowed only by `error instanceof Error && "code" in error` and its `code` property is then asserted to `HandoffFailureCode`. Any `Error` carrying a `code` property, including a Node `ErrnoException`, satisfies that guard and would place an unvalidated string into the result contract. The practical exposure is low because the guarded call is a pure projection over an already-validated envelope, but `error instanceof HandoffContractError` would make the narrowing sound. See section 8, gap G5. |
| **Readonly and immutable contracts** | ✅ PASS | Every exported interface property is `readonly`, and array-valued properties use `ReadonlyArray` or `readonly T[]`, so contract objects cannot be mutated by a consumer. |
| **Explicit error handling** | ⚠️ PARTIAL | Every failure path returns a structured `blockedResult` with a deterministic failure code rather than propagating an exception, which satisfies the fail-explicitly requirement. However, eleven `catch` blocks discard the caught error entirely with no logging, and `HANDOFF_VALIDATOR_UNAVAILABLE` is reused as the outcome for at least six distinct causes: source or envelope read failure, UTF-8 decode failure, destination-projection validation failure, Git porcelain read failure, candidate write or re-read failure, and atomic replace failure. An operator receiving that code cannot distinguish a permissions error from a validator defect. See section 8, gap G6. |
| **Suppressions** | ✅ PASS | No `eslint-disable`, `@ts-ignore`, or `@ts-expect-error` directive appears in the added production modules. |
| **Boundary injection** | ✅ PASS | Six interfaces isolate every side effect, and the concrete Node implementations are confined to `orchestration-handoff-materializer-production.ts`. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Schema validity** | ✅ PASS | `config/orchestration-handoff.schema.json` declares Draft 2020-12 and is exercised by `test_orchestration_handoff_schema.py` across 8 tests. |
| **Registry as single source** | ⚠️ PARTIAL | `config/orchestration-handoff-registry.json` defines `semantic_tools`, `capabilities.supported`, and `failure_precedence`. TypeScript asserts its `HANDOFF_FAILURE_PRECEDENCE` equals `registry["failure_precedence"]`; the PowerShell hook reads `semantic_tools` at runtime; Python reads `capabilities.supported` in tests but restates `failure_precedence` as a literal at `orchestration_handoff_contract.py` lines 67-76 with no parity assertion. See section 8, gap G2. |
| **Bundled copy parity** | ✅ PASS | `extensions/drm-copilot/resources/config/orchestration-handoff-registry.json` and the matching schema file are added alongside the canonical files, `pack-manifests/core.json` lists both, and `test_push_down_codex_and_agents_customizations.py` asserts the installed registry exposes the expected `semantic_tools`. |
| **Fixture integrity** | ✅ PASS | The reviewer recomputed all four pinned digests. `claude-to-codex/source-checkpoint.json` is `558de827d94b8f51fc135227a7f70a0933807e2c558f7c0f40a8bff1181e0fdd`, `codex-to-claude/source-checkpoint.json` is `ed0724168078356d789d503e629e5de0a2e2ac099ac2aba8bd5ca60299404669`, and both `plan.2026-08-29T12-22.md` files are `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`. Each value matches the corresponding `fixture.json` field and the committed git blob content at `a7b80f2d`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest structure** | ✅ PASS | Seven handoff suites plus four push-down and validator suites, all under `tests/scripts/dev_tools/`, named `test_*.py` with `test_*` functions. |
| **No temporary files** | ✅ PASS | No `tmp_path`, `TemporaryDirectory`, or `NamedTemporaryFile` usage appears in the added suites; fixture data is committed under `tests/fixtures/orchestration-handoff/`. |
| **Table-driven negative cases** | ✅ PASS | `tests/fixtures/orchestration-handoff/contract/invalid-contract-cases.json` externalizes the invalid-envelope corpus and is consumed by both the Python and TypeScript suites, so the two runtimes assert against the same cases. |
| **Shared support module extracted** | ✅ PASS | `orchestration_handoff_taskmaster_469_test_support.py`, `push_down_handoff_test_support.py`, and `validate_orchestrator_state_test_support.py` hold shared builders, keeping each test file under the 500-line cap. |
| **Error-path coverage** | ⚠️ PARTIAL | The five `_validate_projection_facts` rejection branches and the already-migrated legacy guard have no test. See section 8, gaps G1 and G7. |
| **Coverage thresholds** | ✅ PASS | Repo-wide 92.86% lines and 85.42% branches; changed-line 96.84%; the lowest per-file changed module is 91.01% lines and 81.58% branches. All exceed the 85% and 75% uniform thresholds. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester structure** | ✅ PASS | Four modified suites under `tests/scripts/codex-hooks/` using `Describe`, `Context`, and `It` with `-ForEach` data-driven cases. |
| **Process-contract assertions** | ✅ PASS | `Invoke-EpicPlanningDecisionProcess` runs the hook as a child process and the assertions cover exit code, stdout, and stderr together, which is the correct granularity for a PreToolUse hook contract. |
| **Non-mutation assertions** | ✅ PASS | Each deny case captures the checkpoint bytes as base64 before acting and asserts they are unchanged afterwards, proving the hook is read-only with respect to the checkpoint. |
| **Alias-normalization coverage** | ✅ PASS | `It 'allows both registered MCP server spellings identically for <Operation>'` covers all four registered operations across the hyphenated and underscored transports and asserts the two results are identical rather than merely both permitted. |
| **Rejection coverage** | ✅ PASS | A malformed identifier, an unrelated server, an unregistered operation, an approximate operation, a shell edit, and a production patch are each denied with an exact asserted reason string. |
| **Error-path coverage** | ⚠️ PARTIAL | The four registry-validation `throw` statements added to `Get-EpicPlanningRegisteredMcpTool` are the only uncovered changed PowerShell lines: 58, 67, 72, and 77. See section 8, gap G4. |
| **Coverage thresholds** | ✅ PASS | Repo-wide 94.77% lines against the 85% threshold; the changed hook file at 91.82% lines; changed-line coverage 87.10%. No branch threshold applies to Pester. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Jest structure** | ✅ PASS | Eleven added or modified suites named `*.test.ts` under `extensions/drm-copilot/test/`, mirroring the `src/` layout. |
| **Dependency injection over module mocking** | ✅ PASS | The materializer suites construct explicit fake boundaries rather than using `jest.mock`, so the tests exercise the real coordination logic against controlled seams. |
| **Deterministic time** | ✅ PASS | `HandoffClockBoundary` is injected; no suite calls `Date.now()` or `setTimeout`. |
| **Registry parity assertion** | ✅ PASS | `orchestration-handoff-contract.test.ts` line 267 asserts `HANDOFF_FAILURE_PRECEDENCE` equals the registry array, which is the parity gate Python lacks. |
| **Error-path coverage** | ⚠️ PARTIAL | `stageMaterialization` has one success-path test and no test for any of its five recovery branches. See section 8, gap G3. |
| **Coverage thresholds** | ✅ PASS | Repo-wide 96.82% lines and 90.37% branches; changed-line 98.04%; the lowest per-file changed module with executable code is `orchestration-handoff-materializer.ts` at 92.48% lines and 89.04% branches. All exceed the 85% and 75% uniform thresholds. |
| **Per-file threshold registration** | ⚠️ PARTIAL | `extensions/drm-copilot/jest.config.cjs` carries no `global` key, so the per-file `coverageThreshold` map is the only enforcement mechanism. The branch adds fifteen `src/**` production modules and registers none of them in that map; the config file is unmodified on this branch. Measured coverage passes today, but no gate would catch a future regression in these modules. See section 8, gap G8. |

---

## 5. Test Coverage Detail

### Portable handoff contract (`orchestration_handoff_contract.py`, `orchestration-handoff-contract.ts`) (13 Python tests, 13 TypeScript tests)

- Positive validation of both committed envelope fixtures, ordinary Claude-to-Codex and parallel Codex-to-Claude.
- Deterministic failure-code selection for unknown major version, unknown vocabulary, unknown capability, invalid transition, and completed-phase replay.
- Table-driven invalid-envelope corpus shared with the TypeScript suite through `invalid-contract-cases.json`.
- Malformed-JSON normalization to a contract error.
- Registry `failure_precedence` parity assertion on the TypeScript side.
- Python line coverage 98.70% and branch 94.57%. TypeScript line coverage 98.79% and branch 90.79%. Uncovered TypeScript lines 443-448 are a single version-branch pair not reachable from the current fixtures.

### Plan and path identity (`orchestration-handoff-path-boundary.ts`, `test_orchestration_handoff_paths.py`) (5 Python tests, 8 TypeScript tests)

- Absolute-path, `..`, and non-normal-separator rejection.
- Symlink and reparse-point escape rejection for both existing and creatable targets.
- Root-prefix collision rejection after canonical resolution.
- Missing-ancestor walk for creatable paths.
- Directory rediscovery and stale plan hash both blocked before any write, proven with write-denying boundaries.
- Line coverage 97.56% and branch 81.13%. Uncovered lines 141-142, 167-168, and 189 are platform-specific reparse branches.

### Materialization (`orchestration-handoff-materializer.ts` with its production, request, and support modules) (13 TypeScript tests)

- Dry-run projection produces a deterministic result and performs no mutation.
- Materialization writes the archive, writes and re-validates the candidate, and atomically replaces the destination.
- Independent-context mismatches block every transition, which is the FR-614-005 remediation set.
- Checkout observation is routed through the injected command runner and blocks rather than trusting the envelope when the observation is unavailable.
- The path boundary is shared with authority resolution.
- Coordinator line coverage 92.48% and branch 89.04%; the production, request, and support modules are at 100% lines each.
- Untested: the five recovery branches at lines 143-144, 205-209, 358-363, 392-398, and 411-424.

### Provider adapters (`orchestration-handoff-provider-adapters.ts`, `orchestration_handoff_adapters.py`) (7 Python tests, 2 TypeScript tests)

- Claude-to-Codex and Codex-to-Claude projection with provider-specific evidence retained only in the expression that produced it.
- Destination-evidence gating so receipts begin only at the first new destination delegation.
- TypeScript line coverage 99.27% and branch 95.65%. Python line coverage 96.09% and branch 77.27%.
- Untested: all five `_validate_projection_facts` rejection branches on the Python side.

### Semantic MCP identity (`semantic-mcp-identity.ts`, hook allowlist) (8 TypeScript tests, 2 Pester test groups)

- Both transport spellings resolve to one semantic operation, asserted for all four registered operations.
- Malformed identifiers, unrelated servers, unregistered operations, and approximate operations are each rejected with an exact reason string.
- The alias-case corpus is externalized to `semantic-mcp-alias-cases.json`.
- TypeScript line and branch coverage are both 100%.

### TaskMaster #469 end-to-end fixtures (`test_orchestration_handoff_taskmaster_469.py`) (10 Python tests)

- The Claude-prepared checkpoint reaches Codex execution readiness with pinned source and plan digests.
- Symmetric Codex-to-Claude continuation.
- No completed-phase replay and no historical-receipt fabrication.
- `HANDOFF_DIRTY_WORKTREE` is selected only after every earlier contract and authority check passes, with the unrelated `.csproj` paths reported and left unmodified.

### Provenance and history (`test_orchestration_handoff_provenance.py`) (7 Python tests)

- Source bytes archived by content digest before canonical replacement.
- Prior provider receipts remain opaque and unchanged.
- Handoff history is monotonic and digest-linked.

### Consumer publishing and scope ownership (`test_push_down_codex_and_agents_customizations.py`) (4 relevant tests)

- The installed consumer registry exposes the required `semantic_tools`.
- The shipped TypeScript authority contains no `scripts.dev_tools` or `scripts/dev_tools` import.
- The Codex-native parallel skill and agent files remain absent, keeping #467 the owner of that scope.
- The epic-planner ready gate still calls `validate_epic_planner_child_launch_bindings(features)`, keeping #543 the owner of that defect.

---

## 6. Test Execution Metrics

| Metric | TypeScript | Python | PowerShell |
|--------|-----------|--------|------------|
| Suites or files | 214 suites | 11 changed suites of 473 formatted files | 4 changed suites |
| Tests passed (full suite) | 2966 | 4384 | 3931 active |
| Tests skipped | 0 | 5 | 9 |
| Tests failed | 0 | 0 | 0 |
| Focused handoff subset | 11 suites and 221 tests in 1.172s | 126 tests in 0.69s | covered within `epic-execution-gates.Tests.ps1` |
| Push-down and validator subset | included above | 46 tests in 0.30s | covered within the four changed suites |
| Repo-wide line coverage | 96.82% (47738/49304) | 92.86% (14646/15772) | 94.77% (7447/7858) |
| Repo-wide branch coverage | 90.37% (6815/7541) | 85.42% (4903/5740) | not measured by Pester |
| Changed-line coverage | 98.04% (3504/3574) | 96.84% (552/570) | 87.10% (27/31) |

Reproduction commands are listed in Appendix B.

---

## 7. Code Quality Checks

| Check | Status | Evidence |
|-------|--------|----------|
| No secrets in code | ✅ PASS | The added modules contain no credential, token, or key material. The only embedded constants are schema URIs, regular expressions, failure codes, and SHA-256 digests of committed test fixtures. |
| No unsafe subprocess or command construction | ✅ PASS | The hook's only external invocation is `git -C $repositoryRoot diff --cached --name-only --diff-filter=ACMR` with a bound variable and no string-built command line. The TypeScript layer reaches Git only through the injected `HandoffGitBoundary`, and the production implementation routes through an injected command runner rather than a shell string. |
| Input validation at boundaries | ✅ PASS | Every envelope field is validated against an anchored pattern before use: `SHA256_PATTERN`, `GIT_SHA_PATTERN`, `SCHEMA_VERSION_PATTERN`, `HANDOFF_ID_PATTERN`, and `PLAN_CONTRACT`. The transition request is re-validated inside `prepare` before any write. Vocabulary values are checked against frozen sets rather than accepted as free strings. |
| Error handling remains explicit | ⚠️ PARTIAL | Failures are always surfaced as a structured result with a deterministic code and are never silently ignored, which satisfies the fail-explicitly rule. The weakness is diagnostic rather than behavioral: eleven `catch` blocks discard the caught error with no logging, and one failure code stands for at least six distinct causes. See gap G6. |
| Configuration and path handling is safe | ✅ PASS | `HandoffPathBoundary` canonicalizes the workspace root and every target, rejects absolute inputs, `..` segments, non-normal separators, root-prefix collisions, and symlink or reparse escape, and distinguishes existing from creatable targets. The archive path is confined to the `artifacts/orchestration/handoffs/sources/sha256/` prefix. `resolve_pinned_plan_path` accepts only the pinned normalized repository-relative path with a verified raw-byte hash, so directory rediscovery cannot substitute a different plan. |
| Atomic write discipline | ✅ PASS | The destination candidate is written in the destination's own directory, re-read and re-validated, and only then moved over the canonical path, so a partially written file can never become the canonical checkpoint. Archive and candidate writes use exclusive create with a digest comparison on collision. |
| Non-mutation of unrelated state | ✅ PASS | The clean-worktree preflight reads `git status --porcelain` and reports affected paths without staging, stashing, resetting, or modifying them, and the Pester deny cases assert the checkpoint bytes are unchanged after every denial. |

---

## 8. Gaps and Exceptions

### Identified Gaps

| ID | Severity | Location | Gap | Required correction |
|----|----------|----------|-----|---------------------|
| G1 | Major | `scripts/dev_tools/orchestration_handoff_adapters.py` lines 191-216 | All five rejection branches of `_validate_projection_facts` are unexercised; the uncovered lines are 196, 198, 202, 210, and 215. This guard prevents a destination projection from diverging from the validated envelope in plan, lifecycle, scheduler context, digest format, or history linkage, and it backs AC4 and AC5. Its TypeScript counterpart is exercised. | Add five negative tests in `tests/scripts/dev_tools/test_orchestration_handoff_adapters.py`, one per rejection, each asserting the raised `HandoffContractError` field name. |
| G2 | Major | `scripts/dev_tools/orchestration_handoff_contract.py` lines 67-76 | `FAILURE_PRECEDENCE` restates the registry's `failure_precedence` as a literal with no parity assertion. TypeScript asserts equality at `orchestration-handoff-contract.test.ts` line 267; Python reads the registry only for `capabilities.supported`. AC11 requires all four runtimes to select the same primary failure by the same order, and nothing prevents the Python list from drifting. | Add a Python test asserting `orchestration_handoff_contract.FAILURE_PRECEDENCE == tuple(REGISTRY["failure_precedence"])`, mirroring the existing TypeScript assertion. |
| G3 | Minor | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` lines 340-434 | `stageMaterialization` has one success-path test and no test for any recovery branch: pre-existing archive with matching or mismatched digest, pre-existing candidate with matching or mismatched digest, candidate re-read or re-validation failure, and atomic-replace failure. The uncovered lines are 358-363, 392-398, and 411-424. The AC10 clause "any failure leaves the source checkpoint intact and records no completed transition" is therefore verified by inspection alone for post-write failures. | Add tests driving each recovery branch through the injected `HandoffFileSystemBoundary`, asserting the returned failure code, the reported `affectedPaths`, and that `status` is never `materialized`. |
| G4 | Minor | `.codex/hooks/enforce-epic-planning-only.ps1` lines 57-78 and 85-88 | The registry resolution runs at script scope above both the dot-source guard at line 315 and the top-level `try` at line 319, so a missing or malformed registry raises an unhandled terminating error rather than the contracted `exit 2` with a stderr reason, and also breaks dot-sourcing for tests. All four validation `throw` statements at lines 58, 67, 72, and 77 are the only uncovered changed PowerShell lines. | Move the resolution inside the `try` block or wrap it in its own `try`/`catch` that emits the contracted `exit 2` output, and add Pester cases for a missing registry, an unregistered semantic id, a mismatched operation, and a malformed transport alias. |
| G5 | Minor | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` lines 271-276 | A caught error is narrowed by `error instanceof Error && "code" in error` and its `code` is then asserted to `HandoffFailureCode`. Any `Error` carrying a `code` property, including a Node `ErrnoException`, satisfies that guard, so an unvalidated string can enter the result contract that callers route on. | Narrow with `error instanceof HandoffContractError` so the `code` property is typed at its source, and fall back to `HANDOFF_VALIDATOR_UNAVAILABLE` otherwise. |
| G6 | Minor | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`, eleven `catch` blocks | Every caught error is discarded with no logging, and `HANDOFF_VALIDATOR_UNAVAILABLE` is returned for at least six distinct causes: source or envelope read failure, UTF-8 decode failure, destination-projection validation failure, Git porcelain read failure, candidate write or re-read failure, and atomic replace failure. `.claude/rules/general-code-change.md` permits a catch-all only when it propagates with added context; the structured result adds a code but discards the cause. | Either log the caught cause at `warning` through the project's logging pattern, or carry a `diagnostic` string alongside the failure code so an operator can distinguish a permissions error from a validator defect. |
| G7 | Nit | `scripts/dev_tools/orchestration_handoff_contract_support.py` line 77 | The guard rejecting a non-dictionary or already-migrated legacy input is uncovered. | Add one test passing an object that already carries `schema_version`. |
| G8 | Nit | `extensions/drm-copilot/jest.config.cjs` | The config carries no `global` key, so the per-file `coverageThreshold` map is the only gate. Fifteen `src/**` modules added by this branch have no entry, and the file is unmodified on this branch. Coverage passes today at 92.48% to 100% per file, so nothing is currently failing, but no gate would catch a future regression. | Add a `coverageThreshold` entry at `lines: 85, branches: 75` for each new `src/**` module, following the existing per-file convention. |
| G9 | Nit | `scripts/dev_tools/orchestration_handoff_contract.py` lines 43-46 and 67-76 | `PHASE_ORDER` and `FAILURE_PRECEDENCE` are built by calling `.split()` on implicitly concatenated multi-line string literals. A dropped trailing space during a future edit would silently merge two contract tokens into one rather than raising. | Replace with explicit tuples of quoted strings, one token per line. |

### Approved Exceptions

| Exception | Justification | Authority |
|-----------|---------------|-----------|
| `extensions/drm-copilot/src/repo-automation-service-contract.ts` reports 0% line coverage | The file is interface-and-type-only with no executable statement; the v8 provider emits an `(empty-report)` placeholder with one zero-hit record per source line. The module remains inside `collectCoverageFrom` and is not excluded from measurement. | `.claude/rules/general-unit-test.md`, "Type-only / interface-only modules with no executable behavior may be omitted from coverage measurement", and the recorded rationale at `extensions/drm-copilot/jest.config.cjs` lines 170-177 and 261-266 |
| No branch-coverage figure for PowerShell | Pester measures command and line coverage only; no branch percentage exists to evaluate. | `.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md`, uniform gate matrix |
| No property-based or mutation tests | The changed modules are dev tooling and orchestration scaffolding classified T4, for which the property-test density and mutation-score gates are `none`. | `.claude/rules/quality-tiers.md`, tier-dependent gate matrix |
| Contract vocabulary duplicated across Python and TypeScript | The feature's purpose is provider-neutral parity across two runtimes that cannot share a module; `config/orchestration-handoff-registry.json` is the single source of truth for the shared vocabulary. | `spec.md` behavior section. The duplication is acceptable; the incomplete Python parity assertion is recorded separately as gap G2. |

### Removed/Skipped Tests

`tests/scripts/dev_tools/test_validate_orchestrator_state.py` shows +39/-349 lines. The removed content was not deleted: it was extracted into `tests/scripts/dev_tools/validate_orchestrator_state_test_support.py` (+225) and `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py` (+130) to keep each file under the 500-line cap. The combined suites pass 46 tests and no assertion was dropped. The 5 skipped Python tests and 9 skipped Pester tests are pre-existing platform-conditional skips unrelated to this branch.

---

## 9. Summary of Changes

### Commits in This PR/Branch

| SHA | Message |
|-----|---------|
| `376fe8f9` | feat(orchestration): add portable prepared-state handoff contract |
| `763d70fc` | feat(orchestration): add portable handoff runtime authority |
| `ca33e000` | feat(orchestration): add portable handoff consumer parity |
| `6ffc5985` | test(orchestration): close portable handoff QA gaps |
| `5910838c` | docs(orchestration): record portable handoff execution checkpoint |
| `6026cf3a` | fix(orchestration): enforce canonical handoff path containment |
| `8defb1df` | fix(orchestration): preserve handoff fixture byte identity |
| `a7b80f2d` | fix(orchestration): require independent expected context for handoff FR-614-005 |

### Files Modified

**TypeScript production (21 files, 15 added):** `lib/validate/orchestration-handoff-authority-service.ts`, `-checkout-context.ts`, `-contract.ts`, `-contract-support.ts`, `-materializer.ts`, `-materializer-production.ts`, `-materializer-request.ts`, `-materializer-support.ts`, `-path-boundary.ts`, `-provider-adapters.ts`, `-validation.ts`, `lib/validate/semantic-mcp-identity.ts`, `mcp-handlers/orchestration-handoff-handlers.ts`, and `mcp-repo-automation-tool-definitions-handoff.ts`, plus modifications to `lib/validate/orchestration-artifacts.ts`, `mcp-repo-automation-tool-definitions.ts`, `mcp-tool-definitions.ts`, `mcp-tools.ts`, `repo-automation-service.ts`, `repo-automation-service-contract.ts`, and `repo-automation-tool-names.ts`.

**TypeScript tests (16 files):** eleven suites and two support modules under `extensions/drm-copilot/test/`, plus modifications to `mcp-repo-automation-tool-definitions.test.ts`, `mcp-server.test.ts`, and `repo-automation-orchestration-validation.test.ts`.

**Python production (5 files, 3 added):** `scripts/dev_tools/orchestration_handoff_contract.py`, `orchestration_handoff_contract_support.py`, and `orchestration_handoff_adapters.py`, plus modifications to `push_down_codex_and_agents_customizations.py` and `validate_orchestrator_state.py`.

**Python tests (14 files, 9 added):** seven handoff suites, three support modules, and a completion suite under `tests/scripts/dev_tools/`, plus modifications to the two push-down suites and the orchestrator-state suite.

**PowerShell (6 files):** `.codex/hooks/enforce-epic-planning-only.ps1` and its published copy, plus four suites under `tests/scripts/codex-hooks/`.

**Configuration and fixtures (16 files):** `config/orchestration-handoff.schema.json`, `config/orchestration-handoff-registry.json`, their two published copies, `pack-manifests/core.json`, ten fixture files under `tests/fixtures/orchestration-handoff/`, and two `.gitattributes` entries pinning the fixture plan bytes.

**Documentation (155 files):** feature scoping documents, research, three prior review cycles, three remediation plans, and the evidence tree.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Every mandatory gate passes. All seven toolchain stages are green on the branch head, all three coverage languages exceed the uniform 85% line and, where applicable, 75% branch thresholds repo-wide, on changed lines, and per changed file, and no evidence-location, file-size, coverage-exclusion, or workflow-modification violation exists. The partial status is driven entirely by scenario-completeness gaps under `.claude/rules/general-unit-test.md`: nine identified error-handling and negative-flow paths across three languages are implemented but unexercised, and two of them weaken the cross-runtime parity guarantees on which AC4, AC5, and AC11 rest.

### Policy-by-Policy Summary

| Policy | Verdict | Notes |
|--------|---------|-------|
| General unit test policy | ⚠️ PARTIAL | Core principles, structure, dependencies, and all coverage thresholds pass. Scenario completeness is partial: negative flows and error-handling paths are unexercised at nine identified locations, gaps G1, G3, G4, and G7. |
| General code change policy | ✅ PASS | Design principles, module structure, the 500-line limit, naming, documentation, and the full seven-stage toolchain loop all pass. Reusability is noted partial only for the deliberate cross-runtime contract duplication, whose parity gate is incomplete on the Python side, gap G2. |
| Quality tiers (uniform coverage) | ✅ PASS | Line coverage at or above 85% and branch coverage at or above 75% are satisfied for every language with changed files, repo-wide and on changed lines. No tier-specific lower threshold was applied. |
| Coverage exclusion policy | ✅ PASS | No `exclude` entry matching a production source path was added anywhere in the diff. The one module reporting 0% is interface-only and remains inside `collectCoverageFrom`. |
| Evidence location conventions | ✅ PASS | The validator exits 0 and no forbidden `artifacts/` evidence sub-path appears in the diff. |
| Python code change and unit test | ⚠️ PARTIAL | The toolchain is clean and coverage is above threshold; the `_validate_projection_facts` rejections and the legacy-input guard are untested, gaps G1 and G7. |
| TypeScript code change and unit test | ⚠️ PARTIAL | The toolchain is clean and coverage is above threshold; the materializer recovery branches are untested (G3), one error narrowing is unsound (G5), one failure code is overloaded with discarded causes (G6), and fifteen new modules are unregistered in the per-file threshold map (G8). |
| PowerShell code change and unit test | ⚠️ PARTIAL | The formatter and analyzer are clean and coverage is above threshold; the registry resolution sits outside the hook's error contract and its four validation paths are untested, gap G4. |
| JSON configuration | ⚠️ PARTIAL | Schema, registry, bundled parity, and fixture integrity are all verified; the Python side does not assert registry parity for `failure_precedence`, gap G2. |
| Tonality policy | ✅ PASS | This audit and the accompanying review artifacts use neutral, evidence-matched wording with no hyperbole, humor, or decorative metaphor. |
| Modified-workflow-needs-green-run rule | N/A | The branch diff touches no path under `.github/workflows/`, `.github/actions/`, or `scripts/benchmarks/`, so the rule does not fire and no green-run evidence is required. |

### Metrics Summary

| Metric | Value | Threshold | Result |
|--------|-------|-----------|--------|
| TypeScript repo-wide line coverage | 96.82% | at least 85% | ✅ PASS |
| TypeScript repo-wide branch coverage | 90.37% | at least 75% | ✅ PASS |
| TypeScript changed-line coverage | 98.04% | at least 90% new, 85% modified | ✅ PASS |
| Python repo-wide line coverage | 92.86% | at least 85% | ✅ PASS |
| Python repo-wide branch coverage | 85.42% | at least 75% | ✅ PASS |
| Python changed-line coverage | 96.84% | at least 90% new, 85% modified | ✅ PASS |
| PowerShell repo-wide line coverage | 94.77% | at least 85% | ✅ PASS |
| PowerShell changed-line coverage | 87.10% | at least 85% modified, no regression | ✅ PASS |
| Format errors | 0 | 0 | ✅ PASS |
| Lint errors | 0 | 0 | ✅ PASS |
| Type errors | 0 | 0 | ✅ PASS |
| Architecture violations | 0 | 0 | ✅ PASS |
| Test failures | 0 | 0 | ✅ PASS |
| Files above 500 lines | 0 | 0 | ✅ PASS |
| Prohibited coverage exclusions | 0 | 0 | ✅ PASS |
| Forbidden evidence paths | 0 | 0 | ✅ PASS |
| Blocking findings | 0 | 0 | ✅ PASS |
| Major findings | 2 | advisory | ⚠️ remediation recommended |
| Minor findings | 4 | advisory | ⚠️ remediation recommended |

### Recommendation

Proceed to pull request. No finding blocks the merge: the implementation is behaviorally complete against the acceptance criteria, every mandatory gate is green, and the residual gaps are test-completeness items on error paths that are correct by inspection. Address gaps G1 and G2 before or immediately after merge, because those two are what let the Python and TypeScript runtimes drift apart silently, which is the specific risk this feature exists to eliminate. Gaps G3 through G9 are suitable for a follow-up cycle. The enumerated remediation inputs are recorded in `remediation-inputs.2026-09-06T23-30.md`.

---

## Appendix A: Test Inventory

### Complete Test List

**Python, added under `tests/scripts/dev_tools/`**

| File | Tests | Scope |
|------|-------|-------|
| `test_orchestration_handoff_contract.py` | 3 | Positive fixture validation and the shared invalid-case corpus |
| `test_orchestration_handoff_schema.py` | 8 | Draft 2020-12 schema identity and required-field enforcement |
| `test_orchestration_handoff_versions.py` | 7 | Version, vocabulary, capability, transition, and phase-replay codes, plus legacy-v1 migration facts |
| `test_orchestration_handoff_paths.py` | 5 | Plan path and hash identity, with every rejection proven to block before write |
| `test_orchestration_handoff_adapters.py` | 7 | Claude-to-Codex and Codex-to-Claude projection semantics |
| `test_orchestration_handoff_provenance.py` | 7 | Source archival, receipt opacity, and monotonic digest-linked history |
| `test_orchestration_handoff_taskmaster_469.py` | 10 | Both #469 fixture directions end to end |
| `orchestration_handoff_taskmaster_469_test_support.py` | support | Shared #469 fixture builders |
| `push_down_handoff_test_support.py` | support | Shared consumer-parity assertions |
| `validate_orchestrator_state_test_support.py` | support | Extracted orchestrator-state builders |
| `test_validate_orchestrator_state_completion.py` | extracted | Completion-gate cases split out of the oversized suite |

**TypeScript, added under `extensions/drm-copilot/test/`**

| File | Tests | Scope |
|------|-------|-------|
| `lib/validate/orchestration-handoff-contract.test.ts` | 10 | Envelope validation and registry `failure_precedence` parity |
| `lib/validate/orchestration-handoff-contract-negative-coverage.test.ts` | 3 | Table-driven invalid envelopes, support failures, and malformed JSON |
| `lib/validate/orchestration-handoff-authority-service.test.ts` | 17 | Workspace-explicit validation, topology, and routing authority |
| `lib/validate/orchestration-handoff-checkout-context.test.ts` | 11 | Independent checkout observation |
| `lib/validate/orchestration-handoff-path-boundary.test.ts` | 8 | Canonical path containment plus symlink and reparse escape |
| `lib/validate/orchestration-handoff-materializer.test.ts` | 4 | Dry-run, atomic replacement, and independent-context mismatches |
| `lib/validate/orchestration-handoff-materializer-production.test.ts` | 7 | Node boundary delegation and the shared path boundary |
| `lib/validate/orchestration-handoff-materializer-path-boundary.test.ts` | 2 | End-to-end materialization through canonical paths |
| `lib/validate/orchestration-handoff-provider-adapters.test.ts` | 2 | Projection and destination-evidence gating |
| `lib/validate/semantic-mcp-identity.test.ts` | 8 | Transport-spelling normalization and rejection |
| `mcp-handlers/orchestration-handoff-handlers.test.ts` | 5 | MCP dispatch for the three handoff tools |
| `mcp-server-test-service.ts` | support | Shared MCP server test service |
| `lib/validate/orchestration-handoff-materializer-test-support.ts` | support | Injected boundary fakes |

**PowerShell, modified under `tests/scripts/codex-hooks/`**

| File | Scope |
|------|-------|
| `epic-execution-gates.Tests.ps1` | Dual transport spellings across four operations; malformed, unrelated, unregistered, and approximate rejections; shell-edit and patch denials; checkpoint byte immutability |
| `codex-pretooluse-integration.Tests.ps1` | End-to-end PreToolUse dispatch including a normalized MCP identifier |
| `codex-pretooluse-transport.Tests.ps1` | Transport-layer identifier handling |
| `legacy-codex-hook-contracts.Tests.ps1` | Backward-compatible hook contract preservation |

**Fixtures under `tests/fixtures/orchestration-handoff/`**

| File | Scope |
|------|-------|
| `contract/valid-ordinary-claude-to-codex.json` | Positive ordinary envelope |
| `contract/valid-parallel-codex-to-claude.json` | Positive parallel-child envelope |
| `contract/invalid-contract-cases.json` | Shared negative corpus consumed by both runtimes |
| `contract/semantic-mcp-alias-cases.json` | Alias normalization corpus |
| `taskmaster-469/claude-to-codex/` | Claude-prepared to Codex-execution-ready end-to-end fixture with pinned source and plan digests |
| `taskmaster-469/codex-to-claude/` | Symmetric Codex-to-Claude fixture |

---

## Appendix B: Toolchain Commands Reference

All commands were run from the workspace root `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29` unless a working directory is stated.

**Base and scope resolution**

```
git rev-parse HEAD
git log --oneline 1ed0964045febbb4d92f1cb92661d4b945153a40..a7b80f2df6d849aa65de416655fa58beb4412998
git diff --stat 1ed0964045febbb4d92f1cb92661d4b945153a40..a7b80f2df6d849aa65de416655fa58beb4412998
git diff --name-status 1ed0964045febbb4d92f1cb92661d4b945153a40..a7b80f2df6d849aa65de416655fa58beb4412998
git status --porcelain
```

**Stage 1, formatting, check-only**

```
cd extensions/drm-copilot && npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"
poetry run black --check .
```

**Stage 2, linting**

```
cd extensions/drm-copilot && npm run lint
poetry run ruff check .
```

**Stage 3, type checking**

```
cd extensions/drm-copilot && npm run typecheck
poetry run pyright
```

**Stage 4, architecture boundary**

```
poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py -q
```

**Stage 5, unit tests**

```
poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_contract.py tests/scripts/dev_tools/test_orchestration_handoff_adapters.py tests/scripts/dev_tools/test_orchestration_handoff_paths.py tests/scripts/dev_tools/test_orchestration_handoff_provenance.py tests/scripts/dev_tools/test_orchestration_handoff_schema.py tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py tests/scripts/dev_tools/test_orchestration_handoff_versions.py -q
poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py -q
cd extensions/drm-copilot && node run-jest.cjs --testPathPattern "orchestration-handoff|semantic-mcp-identity"
```

**Coverage generation, run by the executor and inspected rather than re-run by the reviewer**

```
cd extensions/drm-copilot && npm run test:coverage
poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing
mcp__drm-copilot__run_poshqc_test
```

**Coverage verification by the reviewer, read-only over the existing artifacts**

```
python <scratchpad>/cov.py         # repo-wide totals from extensions/drm-copilot/coverage/lcov.info and artifacts/python/lcov.info
python <scratchpad>/perfile.py     # per-changed-file line and branch coverage
python <scratchpad>/changed.py     # changed-line coverage: git diff --unified=0 intersected with lcov DA: records
python <scratchpad>/pschanged.py   # PowerShell changed-line coverage from the JaCoCo <line nr= ci=/> records
python <scratchpad>/unc.py <file> <lcov>   # uncovered line numbers for a single file
```

The reviewer's parsing scripts were written to the session scratchpad outside the repository and are not part of the diff.

**Stage 6, contract and fixture integrity**

```
sha256sum tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/source-checkpoint.json
sha256sum tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/source-checkpoint.json
sha256sum tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md
sha256sum tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md
git cat-file -p a7b80f2d:<fixture-path> | sha256sum
```

**Policy and evidence gates**

```
python scripts/dev_tools/validate_evidence_locations.py --root .
git diff --name-only 1ed09640..a7b80f2d | grep -E '^artifacts/(baselines?|qa|qa-gates|evidence|coverage|regression-testing|post-change)/'
git diff --name-only 1ed09640..a7b80f2d | grep -E '^(\.github/workflows/|scripts/benchmarks/|\.github/actions/)'
```

**Artifact validation**

```
mcp__drm-copilot__validate_orchestration_artifacts --artifact_type policy-audit  --artifact_path docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-06T23-30.md
mcp__drm-copilot__validate_orchestration_artifacts --artifact_type code-review   --artifact_path docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/code-review.2026-09-06T23-30.md
mcp__drm-copilot__validate_orchestration_artifacts --artifact_type feature-audit --artifact_path docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/feature-audit.2026-09-06T23-30.md
```

The MCP transport is not present on this reviewer's tool surface. The three artifacts were instead validated against the same rule sets by executing the repository's own validator implementations directly: `validatePolicyAuditText` from `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts`, and the corresponding code-review and feature-audit rule sets routed through `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`. Results are recorded in `evidence/qa-gates/review-artifact-validation.2026-09-06T23-30.md`.
