# Policy Compliance Audit: Structural command-invocation matcher (#824, bundles #742 and #733; epic #852 child C1a)

---

**Audit Date:** 2026-10-09
**Code Under Test:** Branch `bug/promotion-hook-raw-containment-false-positive-deny-exec-824` (local `c1a-824-resume`, head `6ecc591c8b488def89f023c6223d41478ba92c58`) against `origin/epic/enforcement-hook-precision-integration` (merge base `991aae0a180a09d504b59bc9460ec4b00b85d11b`). 143 changed files: 19 PowerShell production hook files (11 under `.claude/hooks/`, 8 under `.codex/hooks/`), their 19 byte-identical bundled mirrors under `extensions/drm-copilot/resources/`, 22 Pester test files, 2 agent/skill Markdown files plus their 2 mirrors, 2 `pack-manifests/core.json` files, and 77 feature-folder documents and evidence artifacts.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 60 files (19 production, 19 bundled mirrors, 22 test files) | 7223 tests (full suite) | 7211 pass, 2 fail (both pre-existing baseline failures, set B_FULL), 10 skipped | 84.33% cmds repo-wide; changed production files 93.33%-100.00% lines | 85.15% cmds repo-wide; changed production files 93.33%-100.00% lines | 100.00% of instrumented changed lines (0 uncovered) |
| JSON | 2 files | N/A | PASS: parsed and validated by the pytest manifest-completeness suites (27 passed) | N/A (config files) | N/A (config files) | N/A |
| Markdown | 81 files (2 agent/skill docs, 2 mirrors, 77 feature docs) | N/A | N/A (documentation) | N/A (no coverage) | N/A (no coverage) | N/A |

Languages with zero changed files on the branch: TypeScript, Python, C#, Bash. No coverage verdict applies to them.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (no TypeScript file changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (no TypeScript file changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/baseline/pester-full-coverage.2026-10-08T17-32.md` (parse of `artifacts/pester/powershell-coverage.xml` from the baseline full run)
- PowerShell post-change coverage artifact: `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/qc-pass-2-pester-full-coverage.2026-10-08T23-19.md`, `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/qc-pass-2-changed-line-coverage.2026-10-08T23-19.md`, `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/coverage-delta.2026-10-08T23-20.md`
- Per-language comparison summary: Section 1.2.1 of this audit and `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/coverage-delta.2026-10-08T23-20.md`

**Coverage artifact binding note.** `artifacts/pester/powershell-coverage.xml` is gitignored and is not present in this review worktree; it was produced in the executor workspace. The coverage evidence of record is the committed parse of that file under `evidence/qa-gates/`. The reviewer bound that evidence to the reviewed head as follows: (1) `git diff --stat f0c55759 HEAD -- .claude .codex extensions tests` shows that no production file changed after commit `f0c55759`, which precedes QC pass 2 (2026-10-08T23:11Z-23:19Z); (2) the SHA-256 of every changed production file at HEAD, recomputed by the reviewer with `Get-FileHash`, equals the value recorded in `qc-pass-2-parity-hashes.2026-10-08T23-24.md`; (3) the blob hashes at HEAD of the six test files edited between QC passes equal the hashes recorded in `qc-pass-2-format.2026-10-08T23-06.md`. Coverage generation was not rerun, per the reviewer contract.

---

## Executive Summary

The branch replaces substring containment on the command-classification path with a structural, payload-aware matcher (`hook-command-payload.ps1`, `hook-command-payload-powershell.ps1`, `hook-command-invocation-operands.ps1`, `hook-command-heredoc.ps1`, revised `hook-command-invocation.ps1` and `hook-command-scanner.ps1`), moves the three worktree-removal gates to per-target authorization through `Resolve-CommandLineInvocationTarget`, narrows the pr-author skill hook's `--body-file` check to a structurally read and normalized value, and adds a per-segment allowlist hook for the `pr-author` agent. Claude, Codex, and bundled copies are byte-identical where required.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- ✅ `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- ✅ `.claude/rules/quality-tiers.md` (`.claude/hooks` and `.codex/hooks` are T3 in `quality-tiers.yml`)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A Bash: no shell file changed
- ✅ JSON: two pack manifests changed; validated by the manifest-completeness suites

Toolchain results (executor QC pass 2, reviewer-confirmed where noted): format drift 0, PSScriptAnalyzer findings 0, full Pester run 7211 passed and 2 failed (both members of the pre-existing baseline set B_FULL), changed-line coverage 0 uncovered, every changed production file at or above 93.33% line coverage. The reviewer independently ran the 22 changed test files plus the four validate-bash suites and the base `enforce-pr-author-skill.Tests.ps1` (1088 tests): 1087 passed and 1 failed, the failure being the pre-existing B_FULL member. The reviewer also reran the four pytest parity and manifest suites (27 passed), recomputed all parity hashes (all groups identical), and ran `validate_evidence_locations` (exit 0).

No Blocking finding was identified. Non-blocking findings are listed in Section 8 and in the code review.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed on the branch; executor scripts ran from the session scratchpad (`<SCRATCHPAD>/s-*.sh`) and are recorded by content in `evidence/other/observation-scripts.2026-10-08T17-32.md`.
- ✅ No new ongoing tooling script was added.
- Reviewer probe scripts were written to the session scratchpad only and are not part of the branch.

---

## Rejected Scope Narrowing

No scope narrowing was detected. The caller prompt contained two scoping statements, both consistent with the authoritative sources and neither narrowing the feature-vs-base diff or any language's coverage obligation:

- "Evaluate them as UNVERIFIED pending PR/CI (not FAIL) when the only missing piece is PR/CI evidence" - this concerns acceptance-criteria status for AC-20, AC-21, and AC-24 and matches the acceptance-criteria tracking rules; it does not remove any language or file from the audit.
- "Addendum 2 of #824 (FU-823-1/2/3/5, review notes A/B) is out of scope" - this matches `spec.md` "Out of scope / non-goals" and AC-31; the reviewer still scanned the full diff for addendum-2 paths (none found).

The audit covers the full diff `origin/epic/enforcement-hook-precision-integration...HEAD` (143 files).

---

## Evidence Location Compliance

- Command: `poetry run python -m scripts.dev_tools.validate_evidence_locations --root <worktree>` - exit 0, no reported path.
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `spec.md` names `evidence/coverage/`, `evidence/qa/`, and `evidence/regression/`. The executor recorded `EVIDENCE_LOCATION_OVERRIDE_REJECTED` lines in `evidence/other/evidence-location-overrides.2026-10-08T17-32.md` and wrote to the canonical `evidence/qa-gates/` and `evidence/regression-testing/` kinds. This is compliant with the evidence-location invariant.

Result: PASS. No FAIL-level evidence-location finding.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New suites dot-source the hook under test in `BeforeAll` and drive pure decision functions with string inputs. Gate rows inject checkpoint content through existing read seams (`Get-EpicWorktreeGateCheckpointContent`, `Resolve-*RunTarget`, `Get-PrAuthorReceiptContent`, `Get-PrBodyFileBytes`) via `Mock`, scoped per `It`/`Context`. No shared mutable state between rows was found. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Rows are ID-tagged by unit (PY payload iterator, IV invocation, OP operands, PM promotion, EW/PW/CW gates, PA pr-author skill, AL allowlist, CN consumers, REG named reproductions). Each `It` asserts one decision or one record property. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer run: 1088 tests across 27 files in 29 s (about 27 ms per test). Full suite: 293.41 s for 7223 tests. |
| **Determinism** - Consistent results | ✅ PASS | The matcher is pure string logic. No `Start-Sleep`, `Get-Date`, temporary path, or `TestDrive` usage in the new or changed test files (reviewer `Grep` over the Issue824, allowlist, operands, and payload suites; the single `Out-File` hit is a command-text fixture string, not a call). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row names state the command and the expected decision, for example `AL-33 registers the hook in the pr-author frontmatter and keeps the SubagentStop entry`. Suites carry a `.SYNOPSIS`/`.DESCRIPTION` header with the determinism statement. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** 84.33% commands repo-wide (21,894 commands in 174 files); per-file line coverage for the 10 pre-existing changed production files 93.33%-100.00%; 9 new files recorded NEW_FILE.<br>**Command:** `Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .` (via `sh <SCRATCHPAD>/s-full-run.sh`) and `sh <SCRATCHPAD>/s-full-parse.sh baseline`<br>**Timestamp:** 2026-10-08 17:32<br>**Artifacts:** `evidence/baseline/pester-full-run.2026-10-08T17-32.md`, `evidence/baseline/pester-full-coverage.2026-10-08T17-32.md` |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 85.15% commands repo-wide (23,254 commands in 183 files).<br>**Change:** +0.82 percentage points repo-wide; no modified file decreased (invocation 99.19 to 100.00 Claude and 97.58 to 100.00 Codex; epic gate 95.41 to 96.40; parallel gate 93.46 to 94.50; pr-author helpers 97.00 to 97.39; Codex epic gate 98.53 to 98.61; promotion and scanner unchanged).<br>**Status:** No regression (`evidence/qa-gates/coverage-delta.2026-10-08T23-20.md`). |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** 9 new production files (payload, payload-powershell, operands, heredoc on each surface, plus the allowlist hook) and 10 modified production files.<br>**New code coverage:** every new file 100.00%; changed-line coverage 0 uncovered of 1,016 instrumented changed lines across 19 files.<br>**Calculation method:** executor intersected the merge-base diff line set with the JaCoCo LINE entries of `powershell-coverage.xml` (`qc-pass-2-changed-line-coverage.2026-10-08T23-19.md`). |
| **Comprehensive Coverage** | ✅ PASS | All new public functions have unit rows: `Read-CommandLineInvocationSegment` (PY rows), `Get-CommandLineInvocation` and `Resolve-CommandLineInvocation` (IV rows), `Resolve-CommandLineInvocationTarget` (OP rows), `Test-CommandLineWordPresent` (PY-22/PY-23), `Get-CommandLinePowerShellPayload` and the encoded-command decoder (payload suite), `Get-PrAuthorBodyFileValue` (PA rows), `Get-PrAuthorCommandAllowlistReason` and the entry point (AL rows). Untested: none reported; changed-line coverage is complete. |
| **Positive Flows** - Valid inputs | ✅ PASS | Allow rows: R-824-MAIN (REG-01, PM-01), R-824-ADD1 (EW-01, PW-01, CW-01), `git --version` (REG-03/05/07/08), inert sinks (PM-14/15, IV-06 with 18 sink executions), canonical body-file spellings (PA-06..PA-15), allowlist single segments (AL-07, AL-08, REG-19..REG-21), authorized removals (EW/PW/CW-08..12). |
| **Negative Flows** - Invalid inputs | ✅ PASS | Deny rows: six `gh issue create/new` spellings on both surfaces (PM-02..PM-13), unauthorized removals (EW/PW/CW-03..07), non-canonical body paths (PA-11..PA-15, PA-21), inline `--body` and no-body (PA-16..PA-19), allowlist chain and non-allowed forms (REG-18, AL-11..AL-31). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Depth limit, `-EncodedCommand` decode failure, PowerShell parse error, backslash-newline continuation, `/usr/bin/gh` and `gh.exe` leaf normalization, `--exec-path` versus `--exec-path=<value>`, `{}` xargs placeholder, multi-target removals (EW/PW/CW-13..20), and the prior-run corpus (B1-B5, X/Y/W rows; `evidence/other/prior-run-corpus-coverage.2026-10-08T22-48.md`). |
| **Error Handling** - Error paths | ✅ PASS | Indeterminate deny text keeps the gate prefix plus `TARGET_WORKTREE_NOT_DERIVABLE` (EW/PW/CW-21..28); allowlist payload-anomaly deny (AL rows over `Invoke-PrAuthorCommandAllowlistEntryPoint`); Unbalanced fail-closed in each consumer (PM-19, EW-21, PW-21, CW-21, AL-25). |
| **Concurrency** - If applicable | N/A | The hooks are single-invocation, stateless string classifiers; no shared state or concurrency surface exists. |
| **State Transitions** - If applicable | N/A | No stateful component was added; checkpoint authorization reads existing checkpoint state through seams without mutation. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 84.33% commands repo-wide (changed production files 93.33%-100.00% lines) -> Post-change: 85.15% commands repo-wide (changed production files 93.33%-100.00% lines). Change: +0.82 percentage points repo-wide; no per-file decrease; nine new files at 100.00%. New/changed-code coverage: 100.00% of 1,016 instrumented changed lines (0 uncovered). Disposition: PASS. Evidence: `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/baseline/pester-full-coverage.2026-10-08T17-32.md`, `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/qc-pass-2-pester-full-coverage.2026-10-08T23-19.md`, `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/qc-pass-2-changed-line-coverage.2026-10-08T23-19.md`, `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/coverage-delta.2026-10-08T23-20.md`.

PowerShell branch coverage: Pester does not measure branch coverage; no branch threshold applies (`.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`). Thresholds applied: line >= 85% for each new and modified file and repo-wide, and no regression on changed lines. All are met.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions use `Should -BeExactly`/`-Be` on decision fields and deny-reason prefixes, with `-Because` naming the command span where rows iterate (for example AL-34 and AL-35). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Rows build the command text or JSON envelope, call one decision function, and assert the decision; table-driven rows use `-ForEach` with named cases. |
| **Document Intent** | ✅ PASS | Row IDs map to the plan's test matrix and to the AC ledger (`evidence/other/ac-checkoff-ledger.2026-10-08T23-24.md`); suites are tagged `Issue824`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The matcher performs no disk, process, or network I/O. Static rows AL-33..AL-35 read two tracked repository documents (`.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`), which is a read of committed source, not an external dependency. |
| **Use Mocks/Stubs** | ✅ PASS | Checkpoint, receipt, and body-file reads are mocked through the existing seams; `Get-PrAuthorBodyFileRoot` is a new single seam for the session root. The negative-control rows (AC-14) use a test-local stub that reinstates substring classification. |
| **Environment Stability** | ✅ PASS | No temporary files are created (reviewer search). Two pre-existing full-suite failures read ambient orchestration state (B_FULL); they are not introduced by this branch (see Section 7 notes). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the S6 policy audit for the branch. Outstanding PR-stage items: AC-20 live smoke, AC-21 PR comment, AC-24 CI parity results (feature audit). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` (#824 with addendum 1, bundled #742 and #733) and `spec.md` Root Cause Analysis. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md`; research `research/research.2026-10-08T14-00.md` covers the prior `wt-824` run. |
| **Document the plan** | ✅ PASS | `plan.2026-10-08T13-53.md` with a phase-by-phase checklist; all execution phases checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One iterator (`Read-CommandLineInvocationSegment`) feeds one classifier (`Get-CommandLineInvocation`); consumers read results rather than re-implementing matching. The classifier's rule order is documented in its docblock. |
| **Reusability** | ✅ PASS | The worktree gates share `Resolve-CommandLineInvocationTarget`; the allowlist hook reuses the iterator; existing public signatures are preserved for other consumers. |
| **Extensibility** | ✅ PASS | Option tables (`WithArgument`, `Standalone`, `Terminal`) and the sink allowlist are script-scoped data; the record shape is documented for C1b and C3. |
| **Separation of concerns** | ✅ PASS | POSIX payload extraction, PowerShell AST adaptation, operand/target reading, and heredoc parsing are in separate files; hooks keep I/O (payload acquisition, checkpoint reads) at their entry points. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Each new module has a single stated responsibility in its header. |
| **Under 500 lines** | ✅ PASS | Reviewer recount at HEAD: maximum 497 (`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`); largest production files `hook-command-payload.ps1` 484 and `hook-command-invocation.ps1` 482. Matches `evidence/qa-gates/qc-pass-2-lines.2026-10-08T23-22.md`. |
| **Public vs internal** | ✅ PASS | Spec-defined public API: `Read-CommandLineInvocationSegment`, `Get-CommandLineInvocation`, `Resolve-CommandLineInvocationTarget`, `Test-CommandLineWordPresent`, plus preserved signatures. Other functions are internal helpers. |
| **No circular dependencies** | ✅ PASS | Load order: scanner -> heredoc; invocation -> scanner, payload, payload-powershell, operands. Payload and operands call invocation-defined functions at call time only. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `<Verb>-CommandLine<Noun>` naming per spec; approved verbs (`Get`, `Test`, `Resolve`, `Read`, `ConvertTo`, `ConvertFrom`, `Add`, `Split`, `Skip`, `Invoke`). |
| **Docs/docstrings** | ✅ PASS | Every new function has comment-based help; outputs and record properties are documented. |
| **Comment why, not what** | ✅ PASS | Comments explain rationale, for example why `{}` is quoted before segmenting and why the entry point writes the decision before `exit`. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` plus read-only drift check `sh <SCRATCHPAD>/s-fmtcheck.sh writeset`<br>**Result:** FORMAT_DRIFT_COUNT 0 over 60 write-set `.ps1` files; no file rewritten (`qc-pass-2-format.2026-10-08T23-06.md`). |
| **2. Linting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze` plus `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** PSSA_FINDING_COUNT 0 (`qc-pass-2-analyze.2026-10-08T23-07.md`). |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .`<br>**Result:** 7211 passed, 2 failed (both B_FULL pre-existing), 10 skipped (`qc-pass-2-pester-full-run.2026-10-08T23-19.md`). |
| **Full toolchain loop** | ✅ PASS | Pass 1 failed changed-line coverage (20 uncovered lines); nine covering rows were added; pass 2 completed every gate in a single pass (`qc-loop-summary.2026-10-08T23-25.md`). |
| **Explicit reporting** | ✅ PASS | Each gate has a timestamped artifact with command, exit code, and summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages per phase (Section 9); the PR body is produced at the PR stage. |
| **Design choices explained** | ✅ PASS | `spec.md` Proposed Fix and orchestrator decisions D1-D4, D10; research §8. |
| **Update supporting documents** | ✅ PASS | `.claude/agents/pr-author.md` and `.claude/skills/pr-author/SKILL.md` name the receipt commands; `evidence/other/receipt-procedure-surfaces.2026-10-08T22-46.md` records that `.github` and `.codex` pr-author surfaces do not name the procedure. |
| **Provide next steps** | ✅ PASS | PR-stage items AC-20, AC-21, AC-24 are recorded as PENDING-ORCHESTRATOR in `evidence/other/ac-checkoff-ledger.2026-10-08T23-24.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` (MCP) and drift check<br>**Result:** 0 drift; baseline `evidence/baseline/format-check.2026-10-08T17-32.md` also 0. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze` (MCP) and direct `Invoke-ScriptAnalyzer`<br>**Result:** 0 findings; baseline `evidence/baseline/pssa.2026-10-08T17-32.md`. |
| **Fix all findings** | ✅ PASS | No finding remained in pass 2. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The spec scopes the hooks to PowerShell 7+ (`[System.IO.Path]::GetRelativePath`, `Parser.ParseInput`); hooks are registered as `pwsh -NoProfile -File`. Windows PowerShell 5.1 is not a supported host for these hooks (spec Assumptions). |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | New functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `[Parameter(Mandatory)]`, `[AllowEmptyString()]`, `[ValidateNotNullOrEmpty()]`, `[ValidateRange(0, 64)]` on `MaxDepth`. |
| **Avoid global state** | ✅ PASS | Only `$script:` constants (option tables, sink allowlist, deny prefix); no mutable global state. |
| **Error handling** | ✅ PASS | Parse errors, decode failures, and depth limit produce Indeterminate records instead of exceptions; `ConvertFrom-CommandLineEncodedCommand` catches only `System.FormatException`; payload anomalies in the allowlist hook deny fail-closed. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | See Section 2.3. |
| **Approved verbs** | ✅ PASS | All new function verbs are approved PowerShell verbs; PSScriptAnalyzer `PSUseApprovedVerbs` reported nothing. |
| **Comment why** | ✅ PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Pass 2: 0 drift. |
| **Step 2: Analyze** | ✅ PASS | Pass 2: 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Pass 2: failures limited to B_FULL; Issue824 rows 689 passed, 0 failed (`qc-pass-2-issue824.2026-10-08T23-21.md`). |
| **Rerun loop if needed** | ✅ PASS | Two passes; pass 2 clean. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | The two manifest edits insert array entries in the existing two-space style; no reformatting of other lines (diff inspection). |
| **Schema validation** | ✅ PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_push_down_*_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_*_resource_contracts.py`<br>**Result:** 27 passed (reviewer rerun and executor `qc-pass-2-pytest-parity.2026-10-08T23-22.md`). |
| **Required $schema** | N/A | The pack manifests are not schema-governed files under `validate_json`; no `$schema` change was made. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Both files parse in the pytest suites. |
| **Deterministic key order** | ✅ PASS | No object key was added; only array string entries. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Suites declare `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` and use `BeforeAll`, `Describe`/`Context`/`It`, `-ForEach`, and `Should`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and coverage population `config/poshqc-coverage.json`; no configuration change on the branch. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Suites declare `#Requires -Version 7.0`, consistent with the hooks' PowerShell 7 host. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One decision or one record property per row. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert allow/deny decisions, deny-reason prefixes, and documented record properties rather than private helper calls. |
| **Mocking Used Sparingly** | ✅ PASS | Mocks only replace checkpoint, receipt, body-file, and session-root read seams. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-hooks/*.Tests.ps1`, `tests/scripts/codex-hooks/*.Tests.ps1`<br>**Code files:** `.claude/hooks/*.ps1`, `.codex/hooks/*.ps1`<br>Layout follows the established repository mirror (`claude-hooks` for `.claude/hooks`, `codex-hooks` for `.codex/hooks`). |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All 22 test files end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Each suite has one `Describe` per unit with `Context` groups by behavior. |
| **Logical Grouping** | ✅ PASS | Issue-specific rows are in `*.Issue824.Tests.ps1` files beside the existing suites. |
| **Docstrings/Comments** | ✅ PASS | Suite headers document scope and determinism. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** see Section 6. |
| **No Alternative Test Runners** | ✅ PASS | Pester only. The reviewer's confirmation run used `Invoke-Pester` with an explicit path list and no coverage, which is the same runner. |

---

## 5. Test Coverage Detail

### Matcher modules (`hook-command-payload.ps1`, `hook-command-payload-powershell.ps1`, `hook-command-invocation.ps1`, `hook-command-invocation-operands.ps1`, `hook-command-heredoc.ps1`, `hook-command-scanner.ps1`; both surfaces)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| PY-01..PY-27 (`hook-command-payload.Tests.ps1`) | Positive / Edge Case / Error Handling | payload iterator, wrapper extraction, decode, depth limit, inert proof | ✅ |
| IV-01..IV-24 (`hook-command-invocation.Issue824.Tests.ps1`) | Positive / Negative / Edge Case | classifier rules, terminal options, leaf normalization, signatures | ✅ |
| OP-01..OP-16 (`hook-command-invocation-operands.Tests.ps1`) | Positive / Negative | operand and flag readers, target resolver | ✅ |
| Scanner Issue824 rows (`hook-command-scanner.Issue824.Tests.ps1`) | Edge Case | Delimiter values, backslash-newline, heredoc module | ✅ |
| Regression corpus (`hook-command-invocation.Issue824Regression.Tests.ps1`) | Negative / Edge Case | B/X/Y/W corpus and prior-run fixtures | ✅ |

**Coverage:** 100.00% of each matcher module on both surfaces (scanner 149/0, heredoc 42/0, payload 186/0, payload-powershell 71/0, invocation 147/0, operands 40/0).

**Not covered:** None.

---

### Consumer hooks (promotion, worktree gates, pr-author helpers, allowlist)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| PM-01..PM-30 (`enforce-promotion-mcp-only.Issue824.Tests.ps1`) | Positive / Negative | gh issue create/new detection | ✅ |
| EW-, PW-, CW-01..40 (three Issue824 gate suites) | Positive / Negative / Error Handling | per-target authorization, Indeterminate deny | ✅ |
| PA-01..PA-24 (`enforce-pr-author-skill.Issue824.Tests.ps1`) | Positive / Negative | Check 1 normalization, bypass fallback | ✅ |
| AL-01..AL-38 (`enforce-pr-author-command-allowlist.Tests.ps1`) | Positive / Negative / Static | allowlist forms, entry point, frontmatter | ✅ |
| CN-01..CN-10 (`hook-command-consumers.Issue824.Tests.ps1`) | Negative | unchanged consumers still detect governed invocations | ✅ |

**Coverage:** promotion 93.33% (Claude) and 100.00% (Codex); epic gate 96.40% (Claude) and 98.61% (Codex); parallel gate 94.50%; pr-author helpers 97.39%; allowlist 100.00%. Every changed line is covered.

**Not covered:** Pre-existing uncovered lines outside the changed set (promotion 4, epic gate 4, parallel gate 6, helpers 3, Codex epic gate 1); none is a changed line.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 7223 (JUnit, full suite) | ✅ |
| Tests Passed | 7211 (99.83%) | ✅ |
| Tests Failed | 2 (both pre-existing, B_FULL) | ✅ |
| Execution Time | 293.41s total | ✅ Fast |
| Average Time per Test | about 41ms | ✅ Fast |
| Discovery Time | not reported separately by PoshQC | ✅ |
| Functions/Classes Tested | all new public functions | ✅ |
| Test File Size | maximum 497 lines | ✅ Maintainable |
| Code Coverage (if applicable) | 85.15% commands repo-wide; changed production files 93.33%-100.00% lines; branch coverage not measured by Pester | ✅ |

Reviewer confirmation run (2026-10-09, HEAD `6ecc591c`): 27 files, 1088 tests, 1087 passed, 1 failed (`enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, a B_FULL member), 29 s.

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` (MCP, scoped to hook and test folders) | 0 drift | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` (MCP) and `Invoke-ScriptAnalyzer` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 7211 passed, 2 failed (B_FULL) | ✅ |

**Notes:**
- Pre-existing failure 1 (B_FULL): `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. Recorded failing at baseline (`evidence/baseline/pester-full-coverage.2026-10-08T17-32.md`). Reviewer probe at HEAD: the deny reason is `TARGET_WORKTREE_NOT_DERIVABLE: the call carries neither a canonical issue number line nor a branch signal ...`, produced by checkpoint target resolution (issue #690 logic), not by the body-file check changed on this branch. Not a regression.
- Pre-existing failure 2 (B_FULL): `Every registered Codex PreToolUse handler accepts every tool name its matcher admits`. Recorded failing at baseline; the executor attributes it to the Codex `enforce-epic-wave-barrier.ps1` handler reading the live epic checkpoint (`EPIC_WAVE_BARRIER_BLOCKED` for item 824). No file on this branch touches that handler. Not a regression.
- Python and TypeScript toolchains: no Python or TypeScript source changed. The pytest and jest parity suites were run as parity checks (27 and 42 passed respectively).

---

## 8. Gaps and Exceptions

### Identified Gaps

All gaps below are Non-blocking.

- PR-stage acceptance evidence: AC-20 (live pr-author delegation smoke), AC-21 (#742 PR comment posting), and AC-24 (parity tests in CI) cannot be produced before the pull request exists. Static and local parts were verified (feature audit).
- Coverage XML locality: `artifacts/pester/powershell-coverage.xml` is gitignored and absent from this review worktree; coverage is taken from the committed parse bound to HEAD by hash (header note). Recommendation: no action for this branch.
- Evidence inconsistency: `evidence/qa-gates/qc-pass-2-parity-hashes.2026-10-08T23-24.md` states "16 groups" but lists 15 group lines. Reviewer recomputation at HEAD found the same 15 groups, each with one distinct hash. The stated count is an evidence text error, not a parity failure.
- Spec boundary wording: `spec.md` lists the promotion adjacency regex as unchanged. The regex is unchanged, but its input moved from `ScanText` to `MaskedText` (`enforce-promotion-mcp-only.ps1` adjacency loop). This change is required for AC-9 (`pwsh -c 'Write-Output "gh issue create"'` must be allowed), and wrapped invocations remain covered by the structural check (PM-02..PM-13; reviewer probes for heredoc-fed `bash`, `sh -o pipefail -c`, and unquoted `$(...)` all deny).

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** Existing rows that pinned the removed substring behavior (`hook-command-invocation.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`, gate trigger-scoping suites) were updated to the new contract as `spec.md` Backward-compatibility expectations require; no row was deleted without replacement.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **d4df97c3** - docs(824): substitute execution branch name in plan (orchestrator decision D5)
2. **13d1bce9** - docs(824): record phase 0 baseline evidence
3. **fee4f572** - test(824): add named regression rows (fail-before)
4. **992f656a** - feat(824): scanner delimiter capture and heredoc module
5. **9ed1d4e8** - feat(824): payload extraction and PowerShell adapter
6. **5abb5568** - feat(824): structural invocation matcher and operand target resolver
7. **0c4a2f31** - docs(824): record phase 4 completion in plan checklist
8. **32cef1ec** - feat(824): promotion and worktree gates consume the structural matcher
9. **2da00286** - feat(824): pr-author body-file matching and per-segment allowlist hook
10. **f0c55759** - chore(824): bundle mirrors and pack-manifest entries
11. **8c1b4892** - docs(824): record phase 7 completion in plan checklist
12. **378ce9ee** - docs(824): record pass-after regression evidence
13. **1f1098fa** - docs(824): record dispositions and handoff artifacts
14. **5b17560e** - docs(824): final QC evidence and AC check-off
15. **6ecc591c** - docs(824): record phase 10 completion in plan checklist

### Files Modified

1. **`.claude/hooks/hook-command-payload.ps1`, `.codex/hooks/hook-command-payload.ps1`** (NEW)
   - Payload-aware iterator, wrapper payload extraction, whole-token presence, inert proof.
2. **`.claude/hooks/hook-command-payload-powershell.ps1`, Codex copy** (NEW)
   - PowerShell host-flag parsing, `-EncodedCommand` decode, AST adapter.
3. **`.claude/hooks/hook-command-invocation-operands.ps1`, Codex copy** (NEW)
   - Moved operand and flag readers; `Resolve-CommandLineInvocationTarget`.
4. **`.claude/hooks/hook-command-heredoc.ps1`, Codex copy** (NEW)
   - Heredoc header and body readers moved out of the scanner.
5. **`.claude/hooks/hook-command-invocation.ps1`, `.claude/hooks/hook-command-scanner.ps1`, Codex copies** (MODIFIED)
   - Structural classifier with `Status`, Terminal options, leaf normalization; scanner `Delimiter` and `TokenText` fields; `Test-CommandLineRawContainment` removed.
6. **`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`** (MODIFIED)
   - Per-target authorization; Indeterminate denies with `TARGET_WORKTREE_NOT_DERIVABLE`.
7. **`.claude/hooks/enforce-promotion-mcp-only.ps1`, Codex copy** (MODIFIED)
   - Adjacency regex reads masked text; structural check covers wrapped forms.
8. **`.claude/hooks/enforce-pr-author-skill-helpers.ps1`** (MODIFIED)
   - Structural `--body-file` read with normalization through `Get-PrAuthorBodyFileRoot`; raw fallback limited to Indeterminate matches.
9. **`.claude/hooks/enforce-pr-author-command-allowlist.ps1`** (NEW)
   - Per-segment allowlist hook for the pr-author agent.
10. **`.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`** (MODIFIED)
    - Frontmatter `hooks.PreToolUse` registration; `Bash(sha256sum *)` and `Bash(date *)` tool entries; receipt procedure names the two single-segment commands.
11. **Bundled mirrors and `pack-manifests/core.json` (both surfaces)** (MODIFIED/NEW)
    - Byte-identical copies; manifest entries for the four new shared modules and the allowlist hook.
12. **22 test files under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`** (NEW/MODIFIED)
    - Issue824 rows, named regression rows, negative controls, `SharedModuleNames` extension.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

Every applicable policy requirement is met for the full feature-vs-base diff. Numeric baseline and post-change PowerShell coverage, changed-line coverage, and the per-language comparison are present. The two full-suite failures are pre-existing baseline failures with root causes outside the changed files. Remaining items are PR-stage acceptance evidence (AC-20, AC-21, AC-24), which are tracked in the feature audit and are not policy failures.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is absent. All required artifacts for this branch are present.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: issue, spec, research, and plan present.
- ✅ Design Principles: single iterator and classifier; consumers reuse the API.
- ✅ Module & File Structure: maximum 497 lines; cohesive modules.
- ✅ Naming, Docs, Comments: approved verbs; comment-based help on new functions.
- ✅ Toolchain Execution: QC pass 2 clean.
- ✅ Summarize & Document: commits per phase; agent and skill docs updated.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: 0 drift, 0 analyzer findings at baseline and after.
- ✅ PowerShell Design & Safety: advanced functions, validated parameters, fail-closed error handling.
- ✅ Structure & Naming: under 500 lines; approved verbs.
- ✅ Toolchain: two passes, pass 2 clean.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: pure-string, seam-mocked, deterministic rows.
- ✅ Coverage & Scenarios: 100% changed-line coverage; positive, negative, edge, and error rows.
- ✅ Test Structure: AAA with ID-tagged names.
- ✅ External Dependencies: none; no temporary files.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC.
- ✅ Test Style & Structure: behavior-focused; mocks limited to read seams.
- ✅ Naming & Readability: `*.Tests.ps1`, Describe/Context/It.
- ✅ Toolchain: full run with coverage recorded.

---

### Metrics Summary

- ✅ 7211/7223 tests passing (99.83%); the 2 failures are pre-existing baseline failures
- ✅ All new public functions tested
- ✅ 85.15% repo-wide PowerShell command coverage; changed production files 93.33%-100.00% lines; 0 uncovered changed lines
- ✅ Proper file organization: tests under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`
- ✅ All code quality checks passing
- ✅ Test execution time: 293.41 seconds for the full suite (fast per test)

---

### Recommendation

**Ready for merge** after the PR-stage items complete: run the AC-20 live pr-author delegation smoke, post the #742 comment from `evidence/issue-updates/issue-742.2026-10-08T22-50.md` (AC-21), and confirm the parity and manifest suites in CI (AC-24). No policy remediation is required.

---

## Appendix A: Test Inventory

### Complete Test List

Changed or added suites (row IDs per the plan test matrix):

1. `tests/scripts/claude-hooks/hook-command-payload.Tests.ps1` › PY-01..PY-27
2. `tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1` › IV-01..IV-24
3. `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` › REG-01..REG-21 and corpus rows
4. `tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1` › OP-01..OP-16
5. `tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1` › scanner Delimiter and continuation rows
6. `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` › CN-01..CN-10
7. `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1` › PM-01..PM-30 (Claude and Codex)
8. `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1` › EW-01..EW-40
9. `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1` › PW-01..PW-40
10. `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1` › CW-01..CW-40
11. `tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1` › PA-01..PA-24
12. `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1` › AL-01..AL-38
13. Updated existing suites: `hook-command-invocation.Tests.ps1` (Claude, Codex), `hook-command-parser.AcceptanceCases.Tests.ps1`, `enforce-epic-worktree-removal-gate.Tests.ps1`, `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`, `enforce-parallel-worktree-removal-gate.Tests.ps1`, `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1`, `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`, `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands (check-only):**
```bash
git diff --stat=200 origin/epic/enforcement-hook-precision-integration...HEAD
git log --oneline origin/epic/enforcement-hook-precision-integration..HEAD
git diff --stat f0c55759 HEAD -- .claude .codex extensions tests
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/enforcement-hook-precision-integration --head HEAD
poetry run python -m scripts.dev_tools.validate_evidence_locations --root <worktree>
poetry run pytest -q tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
sh <SCRATCHPAD>/hash.sh      # Get-FileHash parity groups and line counts at HEAD
sh <SCRATCHPAD>/run-tests.sh # Invoke-Pester over the 22 changed test files, four validate-bash suites, and enforce-pr-author-skill.Tests.ps1
sh <SCRATCHPAD>/probe.sh     # matcher, allowlist, and target-resolver probes at HEAD
```

**For PowerShell (executor toolchain):**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

**Parity (executor):**
```bash
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts test/lib/push-down/claude-customizations.test.ts test/lib/push-down/codex-agents-customizations.test.ts
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-10-09
**Policy Version:** Current (as of audit date)
