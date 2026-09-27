# Policy Compliance Audit: Codex Gates 4 and 5 Epic Scope (#707)

---

**Audit Date:** 2026-09-27
**Timestamp:** 2026-09-27T07-56
**Branch:** `bug/codex-gates-4-5-lack-epic-scope-707` @ `ff73b905fb832a34db63ccd4e9eda144fc58d732`
**Base:** merge-base `daae7f796ebbd87e2170df3c86a9901ce11a4b68` (equal to `git merge-base HEAD origin/main`; `origin/main` is at `736a5007`, and the 14 commits it gained since the merge-base touch none of the files this branch changes). The reviewer regenerated `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` against the same merge-base (range `daae7f79..ff73b905`); both were absent before this review.
**Work mode:** `full-bug` (from `issue.md`); AC source `spec.md` `## Acceptance Criteria` (AC-1 to AC-26).
**Code Under Test:**
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (MODIFIED, 487 lines)
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (NEW, 189 lines)
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` (NEW, 493 lines)
- The three bundle copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` (byte copies; SHA-256 recomputed by the reviewer and equal)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (MODIFIED, +2 entries)
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundle copy (MODIFIED, +3 lines each, identical)
- Tests (NEW): `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` (480 lines), `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1` (445 lines), `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1` (151 lines)
- Tests (MODIFIED, mock registration only, D10): `codex-preimplementation-gate-absolute-paths.Tests.ps1`, `codex-pretooluse-transport.Tests.ps1`, `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1` (+2 or +3 lines each)
- 55 Markdown files under `docs/features/active/codex-gates-4-5-lack-epic-scope-707/` (issue, spec, research, plan, evidence)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 production hooks (+3 bundle copies), 2 settings files, 8 test files | 107 new tests (48 + 53 + 6); 5425 JUnit tests in the full run | PASS: 5416 passed, 0 failed, 9 skipped | 98.80% lines for the gate (164/166); the two siblings did not exist at base | 100.00% gate (164/164); 100.00% epic-scope (44/44); 93.20% epic-resolution (137/147) | 94.92% (187 of 197 changed executable lines across the three files) |

No Python, TypeScript, C#, or Bash file changed on the branch, so no coverage verdict is required for those languages. `core.json` is a manifest and the Markdown files are documentation; neither carries a coverage obligation.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - zero TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/baseline/p0-pester-coverage.md` (gate 98.80%, covered 164, missed 2; overall command coverage 95.24%; self-hosted PoshQC run at 2026-09-27T06-32)
- PowerShell post-change coverage artifact: `docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/final-pester-coverage.md` (self-hosted PoshQC run 2026-09-27T07-28 to 07-32, read from `artifacts/pester/powershell-coverage.xml` written at 07-31); the on-disk `artifacts/pester/powershell-coverage.xml` was later rewritten at 07-39 by the MCP test run and was re-read by the reviewer (repo-wide 95.86% lines, gate 100.00%)
- Per-language comparison summary: Section 1.2.1 of this audit; `docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/final-coverage-delta.md`

---

## Rejected Scope Narrowing

No scope narrowing was applied. The reviewer assessed the caller instructions against the Scope Invariant:

- Caller text: "Diff base: use the literal SHA daae7f796ebbd87e2170df3c86a9901ce11a4b68 (the merge base with origin/main; the local `main` ref in this worktree is stale, so do not use `main`)." Justification: this names the authoritative merge-base; the reviewer confirmed `git merge-base HEAD origin/main` returns the same SHA. All 72 changed files were evaluated.
- Caller text: "Operator approval (operator-supplied, 2026-09-26): all spec decisions D1-D17 and planner decisions are approved; review compliance against them, not their merit." Justification: this constrains design-merit commentary, not file or language scope. Compliance with D1-D17 was reviewed, and findings that arise from an approved decision are still reported with an explicit note (code review CR-1).
- Caller text: "AC-16 intentionally unchecked pending the Linux CI Pester run per plan RS-6." Justification: this concerns an acceptance criterion that cannot be observed locally. It narrows no coverage or toolchain check; the PowerShell coverage verdict below is an explicit PASS.

---

## Evidence Location Compliance

- Command: `python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no violations reported.
- Branch-diff scan: `git diff --name-only daae7f79...HEAD` lists no path under `artifacts/`. No file on the branch is under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All evidence is under the canonical `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`.
- The executor recorded `EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/coverage/ replaced with docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/` in `evidence/qa-gates/final-coverage-delta.md`. `evidence/coverage/` is not a canonical kind in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, so the substitution is correct even though spec AC-22 names `evidence/coverage/`.
- Verdict: PASS.

---

## Executive Summary

The branch ports the issue #663 gate-4 epic-scope seam to the Codex preimplementation gate through two dot-sourced siblings, and pins Codex gate-5 behaviour with tests only. The reviewer found no Blocking or Major policy violation.

**Enforcement-hook bypass analysis (priority focus).** The reviewer traced every path through which the new code can change a decision:

- The epic decision is evaluated only after `$requiresReadyCheckpoint` is true and after the declared-checkpoint cross-check (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:398-415`). It can therefore act only on implementation-classified operands that were already subject to the single-feature readiness check. The delegation leg is unaffected: `$command` is initialised to `''` (line 377) and the call is guarded by `$filePath -or $command`.
- An allow requires, in order: a session root that resolves to an absolute worktree root; a parseable object checkpoint at the composed absolute path `<root>/artifacts/orchestration/epic-orchestrator-state.json`; `route_id` equal to `epic` (case-sensitive); a non-empty `integration_branch`; an effective-worktree HEAD equal to `integration_branch` (case-sensitive); every command-leg readiness conjunct; and `MERGE_HEAD` present in the effective worktree's git directory (`epic-resolution.ps1:460-492`, `epic-scope.ps1:123-188`).
- Every failure before scope is established returns `$null`, and the unchanged single-feature path runs (fail-closed). Unparseable, array, and scalar JSON return `$null` without throwing (`epic-resolution.ps1:327-340`). A relative `-C` selector is rejected by `Find-WorktreeResolutionRoot` (`:209`) and yields `selector-unresolved`, which falls through to the single-feature path. An unbalanced command line yields no selector.
- The siblings define functions and `$script:` constants only; they set no StrictMode, preference variable, or location. The reviewer found no function or `$script:` name collision with any other `.codex/hooks` file.
- One inherited precision gap is reported as Minor (code review CR-1): the effective worktree is derived from the first segment's first `git -C` value only. Later segments of a chained command, a repeated `-C`, or a path-leg operand in another worktree are admitted while the probed worktree is in an epic merge. All three required conditions (ready epic checkpoint, HEAD match, merge in progress) still hold for the probed worktree, and the code is identical to the #663 Claude implementation that D2 requires this port to mirror. The gap therefore does not meet the "new bypass" definition in the review brief.

**Parity with #663.** Decision logic, reason codes, conjunct order, deny-reason text, and primitive behaviour match `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`, `EpicScopeReadiness.psm1`, and `WorktreeResolution.psm1`, except for the recorded divergences D1 (placement), D3 (fixed head-match signature), and D13 (apply_patch leg).

**Structure.** Gate 487, epic-scope 189, epic-resolution 493 lines; bundle copies SHA-256 identical; both new files registered in `core.json` and in both `pester.runsettings.psd1` copies.

**Policy documents evaluated:**
- PASS `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- PASS `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- PASS `.claude/rules/quality-tiers.md` (uniform line threshold; `quality-tiers.yml` is absent at the repository root, which is pre-existing and not changed by this branch)

**Language-specific policies evaluated:**
- PASS `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- Python: no Python file changed. The four push-down guard suites and the full pytest suite were run as regression checks (17 passed; 5132 passed, 5 skipped).
- TypeScript, C#: no files changed.

**Toolchain.** All stages passed in a recorded single pass (`evidence/qa-gates/final-seven-stage-loop.md`): PoshQC format changed 0 of 538 files; PoshQC analyze reported no findings; full Pester 5416 passed, 0 failed, 9 skipped; Python guards 17 passed; full pytest 5132 passed.

**Template source.** The MCP template-asset tool was unavailable in this reviewer session. This artifact carries the canonical section set enforced by `scripts/dev_tools/validate_policy_audit_artifact.py`.

**Temporary artifacts cleanup:**
- PASS: no temporary scripts were committed. Executor and reviewer scratch scripts are in the session scratchpad, outside the repository.
- PASS: no ongoing tooling scripts were added.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each `It` registers its own seam mocks through `Set-EpicScopeSeam` / `Set-ResolverSeam`; fixtures are rebuilt from a constant JSON string per row. |
| **Isolation** - Each test targets single behavior | PASS | Resolver, predicate, selector, primitive, and gate-decision rows are separated into Contexts; one leg or conjunct per data row. |
| **Fast Execution** - Tests complete quickly | PASS | In-process calls with mocked seams; no child process in the three new suites. |
| **Determinism** - Consistent results | PASS | Every checkpoint, HEAD, root, and `MERGE_HEAD` read is mocked by name; every gate call supplies `-CheckpointRaw`; paths are `/synthetic-worktrees/...` strings. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive templated names; `-Because` on the key assertions; suite headers state scope and the `no-branch-signal` omission (D3). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Gate 98.80% (164/166) at base (`evidence/baseline/p0-pester-coverage.md`). |
| **No Coverage Regression** | PASS | Gate 100.00% post-change (missed 0). The reviewer re-read the current on-disk artifact: the gate `sourcefile` reports `LINE covered=164 missed=0`. |
| **New Code Coverage** (policy: >= 85% line, uniform tier rule) | PASS | Epic-scope 100.00% (44/44); epic-resolution 93.20% (137/147); gate changed lines 6/6 (`evidence/qa-gates/final-coverage-delta.md`). |
| **Comprehensive Coverage** | PASS | 48 resolver/predicate rows, 53 gate rows, 6 gate-5 rows. |
| **Positive Flows** - Valid inputs | PASS | Allow rows for the command, apply_patch, and path legs; selector allow row; ready single-feature allow rows. |
| **Negative Flows** - Invalid inputs | PASS | Merge-not-in-progress deny rows; one deny row per conjunct; single-feature deny rows for four non-scope fixtures. |
| **Edge Cases** - Boundary conditions | PASS (Minor noted) | Detached HEAD, gitdir file versus directory, relative gitdir, array/scalar/unparseable JSON, backslash manifest path. No gate-level row drives a relative or unresolvable `-C` selector (code review CR-2); the resolver rows cover it. |
| **Error Handling** - Error paths | PASS | `ConvertFrom-EpicScopeCheckpointText` non-throw rows; `Resolve-EpicScopeCheckpoint` rows wrapped in `Should -Not -Throw`; `Join-WorktreeResolutionPath` throw row. |
| **Concurrency** - If applicable | N/A | Single-threaded hook decision. |
| **State Transitions** - If applicable | PASS | Merge-in-progress true/false rows through the resolver and through the gate. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 98.80% lines for `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (164/166), overall command coverage 95.24% -> Post-change: 100.00% gate (164/164), 100.00% epic-scope sibling (44/44), 93.20% epic-resolution sibling (137/147); current on-disk artifact repo-wide 95.86% lines (9182/9579). Change: +1.20 percentage points on the gate; two new files enter the denominator above the threshold. New/changed-code coverage: 94.92% (187 of 197 changed executable lines). Disposition: PASS. Evidence: `evidence/baseline/p0-pester-coverage.md`, `evidence/qa-gates/final-pester-coverage.md`, `evidence/qa-gates/final-coverage-delta.md`, `artifacts/pester/powershell-coverage.xml`.

Derivation notes:
- The ten uncovered lines of the epic-resolution sibling are 61, 111, 153, 168, 183, 239, 252, 395, 404, and 453. The reviewer inspected each. They are defensive `return` statements (blank normalised path, null first line, null gitdir target, null level, null relative path, null property input, null git directory, empty branch), the `Directory` branch of the real filesystem probe, and the `(Get-Location).ProviderPath` parameter default. None is a decision branch that can turn a deny into an allow.
- The current `artifacts/pester/powershell-coverage.xml` (written 07-39) comes from the later MCP PoshQC test run, which resolves the installed-extension settings. It contains the gate but not the two new siblings. The sibling figures are therefore taken from the self-hosted run recorded in `evidence/qa-gates/final-pester-coverage.md`, which lists per-file covered and missed counts and the uncovered line numbers. The reviewer did not rerun coverage generation (agent contract). This provenance gap is reported as code review CR-3 (Minor).
- Pester measures line coverage only; no branch threshold applies to PowerShell (`.claude/rules/powershell.md`).
- Both new siblings are in `CodeCoverage.Path` in both runsettings copies; no `exclude` entry was added.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `-Because` on allow/deny and reason assertions; the fail-before run (`evidence/regression-testing/fail-before-b2-gate.md`) shows the named failing rows. |
| **Arrange-Act-Assert Pattern** | PASS (Minor noted) | Explicit `# Arrange` / `# Act` / `# Assert` in the two gate-4 suites. The gate-5 suite separates the three phases with blank lines but without labels (code review CR-4). |
| **Document Intent** | PASS | Suite headers document seams, hermeticity, and the D3, D12, D15, and D16 decisions. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | Reviewer search of the three new suites for `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `origin/main`, `Set-Location`, `Push-Location`, drive-letter roots, and `Get-Content` of the checkpoint returned no match. |
| **Use Mocks/Stubs** | PASS | Named-seam mocks; the D10 `Mock Get-EpicScopeCheckpointText { $null }` sits in the Describe-level `BeforeAll` of the five exposed suites (one Describe per file, verified). |
| **Environment Stability** | PASS | No temporary files; no directory change; `$PSScriptRoot`-relative repository paths; Linux-shaped synthetic paths only. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Principle | Status | Evidence |
|-----------|--------|----------|
| **Simplicity First** | PASS | One guarded call inserted in the gate; the resolver is a linear sequence of early returns. |
| **Reusability** | PASS | Reuses the helpers-file parser for the selector and the gate's allow and block constructors. The primitives duplicate `.claude/lib` code by approved decision D1. |
| **Extensibility** | PASS | Named parameters with defaults; result object shape identical to #663. |
| **Separation of Concerns** | PASS | Filesystem contact is limited to two seams (`Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`); pure normalisation helpers are separate. |

### 2.2 Code Quality Standards

| Standard | Status | Evidence |
|----------|--------|----------|
| **File Size Limit (500 lines)** | PASS | 487 / 189 / 493 production; 480 / 445 / 151 test. The epic-resolution sibling has 7 lines of headroom (code review CR-5, Informational). |
| **Error Handling** | PASS | Fail-closed `$null` scope on every resolver failure; parse errors are logged with `Write-Debug` and not rethrown, matching #663; the hook entry point still exits 2 on an unexpected exception. |
| **Naming Conventions** | PASS | Approved verbs; seam names identical to D2. |
| **Documentation** | PASS | Comment-based help on public seams; headers declare authority and dependencies. |

### 2.3 Dependencies and Compatibility

| Requirement | Status | Evidence |
|-------------|--------|----------|
| **No New Dependencies** | PASS | No module import; dot-source only. |
| **API Compatibility** | PASS | Relocated `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` keep their names and bodies; the `mode-routing` and `mode-resolution` suites are unchanged and passing. |
| **I/O Isolation** | PASS | See 2.1. |

---

## 3. Language-Specific Code Change Policy Compliance

### PowerShell (`.claude/rules/powershell.md`)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **PowerShell 7+ compatibility** | PASS | PSScriptAnalyzer with repository settings reported no findings. |
| **Advanced functions / CmdletBinding** | PASS | Public seams use `[CmdletBinding()]` and `[OutputType()]`; small pure helpers are plain functions, as in the #663 source. |
| **Mandatory parameters and validation** | PASS | `Mandatory`, `AllowNull`, `AllowEmptyString`, `ValidateRange(0, 4096)`. |
| **ShouldProcess for state changes** | N/A | No state-changing function; `New-EpicScopeResult` carries a justified suppression. |
| **Avoid global/mutable script state** | PASS | `$script:` values are constants assigned once at load. |
| **No Invoke-Expression / secrets / hard-coded paths** | PASS | None present. |
| **Batch cap (3 production + 3 test per batch)** | PASS | Batches B1 to B4 are recorded in `evidence/qa-gates/b1..b4-*` within the cap. |
| **Bundle byte identity** | PASS | Reviewer SHA-256 comparison: one distinct hash per pair for the gate, both siblings, helpers, and modes. |

---

## 4. Language-Specific Unit Test Policy Compliance

### PowerShell (Pester 5)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester v5, `*.Tests.ps1`, mirrored layout** | PASS | `tests/scripts/codex-hooks/` mirrors `.codex/hooks/`. |
| **Describe/Context/It, one behaviour per It** | PASS | Data-driven `-ForEach` rows. |
| **No executable mocking** | PASS | No `git` process call exists or is mocked; wrapper seams are mocked. |
| **Deterministic (no PATH/cwd/profile dependence)** | PASS | The new suites never read the working directory's git state; D10 closes the local-epic-state exposure in five existing suites. |
| **Line coverage >= 85% on changed files** | PASS | Section 1.2.1. |
| **No assertion weakening in existing suites** | PASS | `git diff -U0` of the nine pre-existing gate suites shows 0 removed lines and 0 added `Should` lines (reviewer run). |

---

## 5. Test Coverage Detail

| File | Baseline | Post-change | Changed-line coverage | Verdict |
|------|----------|-------------|-----------------------|---------|
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 98.80% | 100.00% | 6/6 | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | new file | 100.00% | 44/44 | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | new file | 93.20% | 137/147 | PASS |

---

## 6. Test Execution Metrics

| Run | Result | Evidence |
|-----|--------|----------|
| Full Pester (self-hosted PoshQC, repository runsettings) | 5416 passed, 0 failed, 9 skipped; JUnit 5425, 0 failures, 0 errors | `evidence/qa-gates/final-pester-coverage.md` |
| New suites | 48/48, 53/53, 6/6 passed | same |
| Fail-before (gate suite before the gate edit) | 10 expected failures, 43 passed | `evidence/regression-testing/fail-before-b2-gate.md` |
| Fail-before (resolution suite) | recorded | `evidence/regression-testing/fail-before-b1-resolution.md` |
| Gate-5 pin (no production change) | 6/6 on unchanged files; exception dossier recorded | `evidence/regression-testing/gate5-pin-pass.md`, `fail-before-exception.2026-09-27T07-13.md` |
| Python guard suites | 17 passed | `evidence/qa-gates/final-pytest-guards.md` |
| Full pytest | 5132 passed, 5 skipped | `evidence/qa-gates/final-pytest-full.md` |
| MCP PoshQC format/analyze/test | ok flags true; 16 hashes unchanged | `evidence/qa-gates/final-mcp-poshqc.md` |
| Linux CI Pester run | pending (no PR exists yet) | AC-16 |

---

## 7. Code Quality Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Formatting (Invoke-Formatter) | PASS | 0 formatted of 538 (`final-poshqc-format.md`) |
| Linting (PSScriptAnalyzer) | PASS | no findings (`final-poshqc-analyze.md`) |
| Type checking | N/A | PowerShell has no type-check stage; no Python changed |
| Architecture-boundary tests | N/A | none exist for PowerShell hooks |
| Contract checks | PASS | push-down contracts, manifest completeness, core closure, bundled parity; bundle hook probe 3/3 |
| No-Python invocation | PASS | the parser-based detector reports 0 findings in the three files and their bundle copies; the siblings contain neither token |

---

## 8. Gaps and Exceptions

- AC-16 (Linux CI Pester run) is pending by plan RS-6 and is left unchecked. Local proxy evidence is recorded. This is not a policy violation.
- The on-disk coverage artifact no longer contains the two new siblings (see 1.2.1); the verdict relies on the recorded self-hosted run (code review CR-3, Minor).
- `quality-tiers.yml` is absent at the repository root; this is pre-existing and outside this branch.
- The plan's `[P7-T29]` check-off is intentionally left uncommitted by the plan's own acceptance text.

---

## 9. Summary of Changes

- Codex gate 4 now consults the session-root epic checkpoint on the command, apply_patch, and path legs before the mode block. In epic scope it allows implementation operands only while a merge is in progress, and otherwise denies with the epic checkpoint path and the failed conjunct.
- Two read seams were relocated verbatim from the gate to the epic-scope sibling.
- Gate 5 is unchanged; six pinning rows were added.
- The two new files are registered in the manifest and in coverage; five existing suites gain a hermetic epic-read mock.

---

## 10. Compliance Verdict

**PASS.** No Blocking or Major policy finding. PowerShell coverage: PASS (the only language with changed code files). Minor items are listed in the code review.

---

## Appendix A: Test Inventory

| Suite | Tests | Status |
|-------|-------|--------|
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1` (new) | 48 | passed |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` (new) | 53 | passed |
| `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1` (new) | 6 | passed |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` (D10) | 35 | passed |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` (D10) | 56 | passed |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (D10) | 119 | passed |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` (D10) | 23 | passed |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (D10) | 43 | passed |
| `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` | 3 | passed |

## Appendix B: Toolchain Commands Reference

- Executor, fresh PowerShell 7 process: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1`, then `Invoke-PoshQCFormat` and `Invoke-PoshQCAnalyze -Root <worktree>`, then `Invoke-PoshQCTest -Root <worktree> -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- Executor, supplementary: `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`
- Executor: `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`
- Reviewer: `git diff --stat` and `--name-status` over `daae7f79...HEAD`; SHA-256 comparison of the five hook pairs; `python scripts/dev_tools/validate_evidence_locations.py --root .`; JaCoCo parse of `artifacts/pester/powershell-coverage.xml`; `poetry run python -m scripts.dev_tools.pr_context.collector --base daae7f796ebbd87e2170df3c86a9901ce11a4b68`
