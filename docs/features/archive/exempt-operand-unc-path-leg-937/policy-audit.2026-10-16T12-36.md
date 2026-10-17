# Policy Compliance Audit: Exempt-operand UNC path-leg fix (#937)

---

**Audit Date:** 2026-10-16
**Audit Type:** Re-audit after remediation cycle 2 (full branch diff against the resolved base)
**Branch:** `bug/exempt-operand-unc-path-leg-937` (HEAD `e8bdc75e61c7785e5163940b90781d893c073120`, pushed)
**Base:** `origin/main` (tip `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`; merge base `c415af626c292f38b910e3a27e70ab3e1903b31a`)
**Work Mode:** `full-bug` (AC source: `spec.md` AC-1 to AC-20)
**Code Under Test:** 143 changed files (9324 insertions, 0 deletions). Non-documentation code: 4 production PowerShell files (the canonical `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` and three byte-identical copies under `.codex/hooks/` and the two `extensions/drm-copilot/resources/` bundles), each +9/-0; 3 Pester test files: the new `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1` (+134/-0) and two gate suites (+54/-0 each). The original targets suite `enforce-orchestration-preimplementation-gate-targets.Tests.ps1` has no net change against the merge base. The remaining 136 files are feature-folder documentation and evidence.

**Total blocking findings: 0.**

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 7 files (4 production incl. 2 bundle mirrors, 3 test) | 10507 testcases local full suite (MCP); 10507 Windows testcases (CI run 38898218767); 6374 Linux hook-suite testcases (CI) | PASS: 0 failed, 10 disabled (local and Windows CI); 6374 with 0 failed (Linux CI) | CI report 90.44% lines (c2 baseline run 38885695856); targets copies 99.40%; local canonical 94.58% | Canonical `artifacts/pester/powershell-coverage.xml` (local full-suite run): 94.58% lines repo-wide (11629/12296). CI run 38898218767: 90.44% repo-wide (16432/18169); targets copies 99.40% each | 100% of changed executable lines (3/3 per measured copy: lines 41, 230, 231) |
| Python | 0 files | N/A | N/A (push-down contract tests run for AC-12: 23 passed) | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

PowerShell coverage verdict: **PASS**. The canonical artifact `artifacts/pester/powershell-coverage.xml` comes from a full-suite local run (10507 testcases, 0 failed) and reports 94.58% repo-wide line coverage, above the 85% floor (default; the root `CLAUDE.md` states no threshold). That artifact does not contain the targets file, because the MCP runner resolves its Pester runsettings from the installed extension (127 source files locally against 204 in CI). Per-file coverage of the modified files is therefore taken from the full-suite CI artifact of run 38898218767, as recorded by the `OrchestratorDecision:` lines in the evidence. That run executed the repository's own coverage configuration on `725545096`; the only later commit, `e8bdc75e6`, changes only feature-folder paths. This reviewer downloaded that artifact independently and re-parsed it: both measured targets copies are at 99.40% (165/166, uncovered line 173 only), changed lines 41, 230, and 231 have `ci` 1, 1, 2 in both copies, and the report reads 90.44%. Pester measures line coverage only; no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript file changed on the branch)
- TypeScript post-change coverage artifact: N/A (no TypeScript file changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/coverage-ci-baseline-c2.2026-10-16T10-33.md` (CI run 38885695856) and `evidence/remediation-baseline/coverage-local-baseline-c2.2026-10-16T10-04.md`
- PowerShell post-change coverage artifact: `docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-final-c2.2026-10-16T12-28.md` (CI run 38898218767) and `evidence/qa-gates/coverage-canonical-c2.2026-10-16T11-57.md` (canonical local artifact)
- Per-language comparison summary: `docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-delta-c2.2026-10-16T12-29.md` and section 1.2.1 of this audit
- Reviewer re-verification: this reviewer re-parsed the local `artifacts/pester/powershell-coverage.xml` (report LINE 11629 covered / 667 missed, 94.58%, 127 source files; file written 2026-10-16T11-54 UTC) and read the `testsuites` element of the local `artifacts/pester/pester-junit.xml` (`tests="10507" errors="0" failures="0" disabled="10"`). The reviewer downloaded the `poshqc-test-results` artifact of CI run 38898218767 to the session scratchpad and re-parsed it with a standard-library script: report 16432/1737 (90.44%), 204 source files; `.claude/hooks` and `.codex/hooks` targets copies 165 covered, 1 missed (line 173), lines 41/230/231 covered. The CI junit reads `tests="10507" errors="0" failures="0" disabled="10"`. All values match the executor's evidence.
- PowerShell canonical coverage artifact `artifacts/pester/powershell-coverage.xml` (gitignored, local): present; full-suite run started 2026-10-16T11-42 UTC, file written 11-54 UTC. Report LINE counter 11629/667 = 94.58%. Verdict on this artifact: PASS.

---

## Executive Summary

The branch fixes #937. In the R1 path-leg loop of `Get-OrchestrationCommandTarget`, a raw path-leg input now returns an unresolved `path-not-local` result when it has a UNC, extended-length, device, or NT-object prefix (either separator style), is drive-relative, has leading or trailing whitespace, begins with a URI scheme of two or more characters followed by a colon, begins with `~`, or is a single-backslash root-relative path. Previously such input resolved to the session root. The production change is two additions (one module-scope pattern of two physical lines with a three-line comment, and one three-line guard), applied byte-identically to four copies (`git hash-object` `f8e8e9a1a...`, 433 lines, LF, no line over 120 characters).

Remediation cycle 2 resolved both items in scope:

- RI-7 (code-review CR-1, URI schemes other than `file:`): resolved. The `file:` alternative was replaced by `[A-Za-z][A-Za-z0-9+.-]+:`. Four U27 rows (`http-uri`, `smb-uri`, `vscode-remote-uri`, `scheme-plus-uri`), the U32 keep-behavior row (`scripts/a:b.ps1`), and six `(issue #937 RI-7)` gate rows were added. Fail-before: CI run 38892084649 on `96b20936d`, conclusion `failure` (reviewer `gh run view`), with exactly the 14 expected testcases failing. Pass-after: CI run 38898218767 on `725545096`, conclusion `success` (reviewer `gh run view`), 17/17 jobs. AC-20 was added and checked off.
- RI-8 (code-review CR-2 / policy-audit PA-3, test file at 496 lines): resolved. U27 to U31 were moved unchanged into the sibling suite `enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1` with an identical `Describe` name and surface `-ForEach`, so testcase names are unchanged. The source suite is back to 399 lines (no net change against the merge base); the new suite is 134 lines.

The dispositions of PA-1/CR-5, CR-7, and PA-4/CR-4 as unrelated are carried forward and not re-raised.

No blocking finding remains. Related non-blocking items: PA-2 (branch 133 commits behind `origin/main`; trial merge clean; the orchestrator merges before the PR) and PA-5 (AC-15 pending PR CI). Code-review CR-1 records an informational consequence of the generalized scheme alternative.

**Policy documents evaluated:**
- PASS `CLAUDE.md` (tone, policy order)
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` exists at the repository root)

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (PowerShell code change and unit test)
- N/A Python, TypeScript, C#, Bash: no changed files.

**Temporary artifacts cleanup:**
- PASS: no temporary script is committed. Executor helper scripts lived under the session scratchpad and are not in the branch diff.
- This reviewer wrote two parsing scripts and one downloaded CI artifact to the session scratchpad only. The tracked files this reviewer wrote are the three review artifacts. The untracked `artifacts/pr_context.*.txt` were regenerated.

---

## Rejected Scope Narrowing

None. The caller prompt did not narrow the audit scope. It named the base (`main`), the worktree, the remediation context, the CI runs, and the coverage sources, and it directed AC-15 to be evaluated as pending CI, which the AC-tracking protocol for CI-dependent criteria also requires. The reviewer audited the full `git diff origin/main...HEAD`.

## Evidence Location Compliance

- `poetry run python -I scripts/dev_tools/validate_evidence_locations.py --root .` (run by this reviewer at `e8bdc75e6`): exit 0.
- `git diff --name-only origin/main...HEAD -- artifacts config scripts .claude/lib` lists no path. The branch adds nothing under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All evidence files sit under `docs/features/active/exempt-operand-unc-path-leg-937/evidence/<kind>/` with kinds `baseline`, `remediation-baseline`, `regression-testing`, `qa-gates`, `other`.
- Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entry was needed.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | U27 to U32 are pure calls with data-row literals; gate rows reuse the existing per-row seam arrangement. |
| **Isolation** - Each test targets single behavior | PASS | One spelling per U27/U28 row; U29 to U32 each test one rule interaction. |
| **Fast Execution** - Tests complete quickly | PASS | Pure string logic; the Linux hook-suite job runs 6374 testcases with 0 failed. |
| **Determinism** - Consistent results | PASS | No clock, randomness, sleep, network, process, or filesystem use in the added rows. The new suite header states that it creates no file and starts no process. |
| **Readability & Maintainability** - Clear structure | PASS | Row keys U27 to U32 and gate-row names ending in `(issue #937)`, `(issue #937 RI-4)`, `(issue #937 RI-5)`, or `(issue #937 RI-7)`; every assertion carries `-Because`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-development, cycle 2):** CI report 90.44%; each targets copy 99.40% (CI run 38885695856). Local canonical baseline 94.58%.<br>**Timestamp:** 2026-10-16T10-33 (`remediation-baseline/coverage-ci-baseline-c2.2026-10-16T10-33.md`) |
| **No Coverage Regression** | PASS | **Post-change coverage:** CI report 90.44%; targets copies 99.40% each (CI run 38898218767).<br>**Status:** No changed line regressed (3/3 changed executable lines covered on both measured copies). |
| **Repo-wide PowerShell line coverage, canonical artifact** | PASS | `artifacts/pester/powershell-coverage.xml` reports 94.58% (11629 / 12296 lines) from a full-suite local run; CI full-suite 90.44%. Both are at or above 85%. |
| **New Code Coverage >=85% (uniform tier rule)** | PASS | No new production file. Both measured modified files are at 99.40%. Changed-line coverage is 100%. |
| **Comprehensive Coverage** | PASS | The pattern assignment (line 41), the guard (line 230), and the `return` (line 231) are covered on both surfaces. Line 42 (pattern continuation) and line 40 (comment) are not instrumented. The only uncovered line in each copy is line 173, which is pre-existing and not a changed line. |
| **Positive Flows** - Valid inputs | PASS | U28 (bare drive roots stay resolved to `C:/`); U32 (relative path with a later colon stays on the session root); U01 to U05 unchanged and passing. |
| **Negative Flows** - Invalid inputs | PASS | U27 (27 non-local spellings), U31 (marker path), and 18 gate deny rows (9 per surface). |
| **Edge Cases** - Boundary conditions | PASS | Bare `\\` and `//`, mixed separators, bare `C:`, leading and trailing whitespace, `\\server\share\..\x` (U30), scheme with `+` (`git+ssh:`), colon after a separator (U32). |
| **Error Handling** - Error paths | PASS | Unresolved-result shape (`Resolved`, empty `Targets`, `ReasonCode`, exact `Detail`) is asserted in U27, U29, and U30. |
| **Concurrency** - If applicable | N/A | No concurrent code path changed. |
| **State Transitions** - If applicable | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.44% lines repo-wide in CI (run 38885695856) -> Post-change: 90.44% (run 38898218767, 16432 covered / 1737 missed). Change: 0.00 points. Targets copies 99.40% -> 99.40%. New/changed-code coverage: 100% (lines 41, 230, 231 on both measured copies). Canonical local artifact: 94.58% repo-wide from a full-suite run (baseline 94.58%). Disposition: PASS (repo-wide, modified-file, and changed-line conditions met). Evidence: `evidence/qa-gates/coverage-canonical-c2.2026-10-16T11-57.md`, `evidence/qa-gates/coverage-final-c2.2026-10-16T12-28.md`, `evidence/qa-gates/coverage-delta-c2.2026-10-16T12-29.md`, plus this reviewer's independent re-parse of the CI artifact and of the local artifact.
- Sufficiency of the two-source evidence (OrchestratorDecision). The canonical local artifact satisfies the repo-wide check on its own. It cannot carry per-file values for the targets copies, because the installed extension's runsettings omit that file (`jacoco_targets.py` prints `NO_MATCH`). The modified-file and changed-line checks therefore rely on the CI artifact. The reviewer accepts that source because (1) it is a pre-existing coverage artifact, which the verification model allows; (2) it was produced by the repository's own coverage configuration over the full suite (204 source files, 10507 testcases, 0 failed); (3) its head `725545096` carries production and test files byte-identical to HEAD, since `git diff --name-only 725545096 HEAD` lists only feature-folder paths; and (4) the reviewer re-parsed it independently with matching results. No coverage configuration was edited and no XML was copied into `artifacts/pester/`. The local 94.58% figure is computed over a narrower population (127 files) than the CI figure (204 files), so the CI 90.44% is the representative repo-wide value. Both exceed the floor.
- Bundle mirrors: the two `extensions/drm-copilot/resources/...` copies are outside the coverage population defined by `config/poshqc-coverage.json`, which this branch does not change. They are byte-identical to the measured canonical copy (reviewer SHA-256 `ebe9dce17c9779a4...` for all four; Parity suite passes in CI).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Every new assertion uses `-Because`; cycle 2 fail-before MESSAGE lines name the actual value (8 contain `but got $true`, 6 contain `'allow'`). |
| **Arrange-Act-Assert Pattern** | PASS | U27 to U32 carry `# Arrange`, `# Act`, `# Assert` markers; gate rows reuse the existing AAA body. |
| **Document Intent** | PASS | The new suite header states its origin (RI-8) and its constraints; each `It` and gate row references issue #937 and, for remediation rows, the RI number. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No UNC share, URI, device path, or network is touched; all inputs are string literals. |
| **Use Mocks/Stubs** | PASS | Gate rows use the existing filesystem seams (`Set-TargetSeam`, `Set-CodexTargetSeam`). The new suite dot-sources the production scripts only. |
| **Environment Stability** | PASS | No temporary files; the session root is a synthetic literal. Windows and Linux CI legs are both green. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit. Outstanding non-blocking items: AC-15 pending PR CI at S9 (PA-5); merge of `origin/main` before the PR (PA-2). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `spec.md` Context, Root Cause Analysis, Proposed Fix (fail closed), and the cycle 2 test-file-split note; `remediation-inputs.2026-10-16T08-40.md`. |
| **Read existing change plans** | PASS | `evidence/remediation-baseline/phase0-instructions-read-c2.2026-10-16T09-43.md`, `evidence/remediation-baseline/inputs-read-c2.2026-10-16T09-44.md`. |
| **Document the plan** | PASS | `remediation-plan.2026-10-16T08-40.md`: all task checkboxes checked (the one unchecked `- [ ]` line is the verbatim AC-20 text quoted inside task P2-T3, not a task). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The cycle 2 production change replaces one alternative (`file:`) with one generalized alternative and updates the matching comment. No new function. |
| **Reusability** | PASS | Reuses `New-OrchestrationTargetResult` and the existing `target-unresolvable` reason code and deny text. |
| **Extensibility** | PASS | Function signature and result shape are unchanged. |
| **Separation of concerns** | PASS | Pure string logic stays in the targets module; no I/O was added. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The change sits in the R1 path-leg loop it fixes. The new test suite holds only the #937 path-not-local rows. |
| **Under 500 lines** | PASS | Reviewer `wc -l`: targets copies 433; source targets suite 399; new PathNotLocal suite 134; Claude EpicScopeTargets suite 203; Codex epic-scope-targets suite 208. RI-8 resolved. |
| **Public vs internal** | PASS | `$script:` scope for the pattern, matching its sibling patterns. |
| **No circular dependencies** | PASS | No new dot-source in production code; the new test suite dot-sources the same three scripts as the source suite. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `OrchestrationTargetNonLocalPattern`; rule token `path-not-local`; suite name suffix `PathNotLocal`. |
| **Docs/docstrings** | PASS | The comment above the pattern now says "a URI scheme" instead of "a file: URI", matching the generalized alternative. |
| **Comment why, not what** | PASS | The comment states that the test runs on the raw value before normalization. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` over six folders: ok; eight in-scope hashes identical before and after (`evidence/qa-gates/poshqc-format-final-c2.2026-10-16T11-56.md`). |
| **2. Linting** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`: ok (`poshqc-analyze-final-c2.2026-10-16T11-56.md`); the MCP result carries no diagnostic count, so CI `poshqc / PowerShell QC` (success, run 38898218767) is the analyzer verdict of record. |
| **3. Type checking** | N/A | Not applicable to PowerShell. |
| **4. Architecture-boundary tests** | N/A | No architecture-boundary suite is defined for PowerShell hooks; no new dependency was introduced. |
| **5. Testing** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` full suite: ok (`poshqc-test-final-c2.2026-10-16T11-56.md`), local junit 10507 / 0 failed; CI Windows 10507 / 0 failed; CI Linux 6374 / 0 failed. |
| **6. Contract checks** | PASS | Push-down resource contract tests: 23 passed (`python-contract-final-c2.2026-10-16T11-56.md`). |
| **7. Integration tests** | PASS | End-to-end gate rows on the Claude (Write) and Codex (`apply_patch`) surfaces pass in CI. |
| **Full toolchain loop** | PASS | `evidence/qa-gates/qa-loop-pass-c2.2026-10-16T11-56.md`: one pass, no rewrite. |
| **Explicit reporting** | PASS | Every stage has a timestamped evidence artifact with `Command:` and `EXIT_CODE:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages and `evidence/other/ac-evidence-map-c2.2026-10-16T12-29.md`. |
| **Design choices explained** | PASS | `spec.md` Proposed Fix (fail closed), the RI-8 test-file-split note, and AC-20. |
| **Update supporting documents** | PASS | All four copies updated byte-identically; AC-20 added to `spec.md` with AC-1 to AC-19 text unchanged; the spec records where U27 to U31 now live. |
| **Provide next steps** | PASS | `spec.md` Rollout section; AC-15 check-off at S9. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Command:** `run_poshqc_format` and CI `poshqc / PowerShell QC`<br>**Result:** no change; CI success. |
| **Linting with PSScriptAnalyzer** | PASS | **Command:** `run_poshqc_analyze` and CI<br>**Result:** ok; CI success. |
| **Fix all findings** | PASS | No suppression was added. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | Only `-match` and a .NET regex with character classes, lookaheads, and `\s` are used; all are available in 5.1 and 7.x. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | No function was added; the edited function keeps `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | PASS | Unchanged. |
| **Avoid global state** | PASS | The pattern is a `$script:` constant. |
| **Error handling** | PASS | Fail closed via the existing unresolved-result factory; no silent catch. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 433 lines per copy; every line at or below 120 characters (`targets-size-check-c2.2026-10-16T11-30.md`; Parity suite; reviewer `awk` over added lines finds only the two `+++ b/extensions/...` diff header lines over 120 characters, which are not file content). |
| **Approved verbs** | PASS | No new function; analyzer clean. |
| **Comment why** | PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | `poshqc-format-final-c2.2026-10-16T11-56.md`; CI success. |
| **Step 2: Analyze** | PASS | `poshqc-analyze-final-c2.2026-10-16T11-56.md`; CI success. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | `poshqc-test-final-c2.2026-10-16T11-56.md`; CI run 38898218767. |
| **Rerun loop if needed** | PASS | One loop pass with no rewrite. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | The new suite declares `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` and uses `-ForEach` data rows inside a surface-parameterized `Describe`. |
| **Use PoshQC Configuration** | PASS | **Command:** `run_poshqc_test` and CI<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged by the branch). |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | Suites pass on the Windows and Linux CI legs. The new suite declares `#Requires -Version 7.0`, matching the source suite it was split from. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | One spelling or one rule interaction per row. |
| **Test Behavior Over Implementation** | PASS | Rows assert the result contract and gate outcome codes, not regex text. |
| **Mocking Used Sparingly** | PASS | Only the existing gate seams are used. |
| **Organization** | PASS | **Test file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1`<br>**Code file:** `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and `.codex/hooks` via the surface `-ForEach`). Location follows the existing sibling-suite convention in `tests/scripts/claude-hooks/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | The new file ends in `.Tests.ps1` and follows the `<module>.<Aspect>.Tests.ps1` pattern used by `...targets.Parity.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | The `Describe` name equals the source suite's, so JUnit testcase names are unchanged (move proof: passed FM name set `cmp` against the c2 baseline exits 0). |
| **Logical Grouping** | PASS | All #937 path-not-local unit rows live in one suite; gate rows extend the two deny tables. |
| **Docstrings/Comments** | PASS | Header comment and Arrange comments reference #937. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | **Command:** `run_poshqc_test`<br>**Result:** ok; per-row results from CI junit (`ci-pass-after-c2.2026-10-16T12-27.md`: F1 84/84, F2 14/14, FM 64/64, FNEW 67/67, FINV 27 with 0 failed, 6374 total with 0 failed). |
| **No Alternative Test Runners** | PASS | Pester through PoshQC and CI only. |

---

## 5. Test Coverage Detail

### `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and `.codex/hooks` copy)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| U27 gives path-not-local for `<Label>` (27 rows) | Negative / Edge Case | 41, 230, 231 | PASS |
| U28 keeps a bare drive root path-leg input (2 rows) | Positive | 230 (no match), 233 onward | PASS |
| U29 denies a non-local input with a valid sibling | Negative | 230, 231 | PASS |
| U30 path-not-local before path-dot-segment | Edge Case | 230, 231 | PASS |
| U31 non-local apply_patch marker path | Negative | marker extraction, 230, 231 | PASS |
| U32 relative path with a later colon stays on the session root | Positive / Edge Case | 230 (no match), relative fallback | PASS |

**Coverage:** 99.40% (165 covered, 1 missed) per copy; cycle 2 baseline 99.40%.

**Not covered:** line 173 (pre-existing, not a changed line).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Pester 10507 (local full suite and Windows CI); 6374 (Linux hook suites) | PASS |
| Tests Passed | 10497 + 10 disabled (local and Windows); 6374 with 0 failed (Linux) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | Pester Windows 865.6s (CI junit); local 698.9s | PASS |
| Average Time per Test | About 82ms on Windows CI (all suites) | PASS |
| Discovery Time | Not separately reported | N/A |
| Functions/Classes Tested | `Get-OrchestrationCommandTarget` (R1 path-leg loop), `Get-OrchestrationPatchMarkerPath`, epic-scope gate decisions on both surfaces | PASS |
| Test File Size | 134, 399, 203, 208 lines (all at or under 500) | PASS |
| Code Coverage (if applicable) | Canonical artifact 94.58% repo-wide; CI 90.44%; targets copies 99.40% | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `run_poshqc_format` / CI | ok / no change | PASS |
| PSScriptAnalyzer | `run_poshqc_analyze` / CI | ok / success | PASS |
| Pester Tests | `run_poshqc_test` / CI | 0 failed | PASS |

**Notes:**
CI run 38898218767 is a `workflow_dispatch` run on `725545096` with all 17 jobs at `success` (reviewer `gh run view`: `conclusion: success`). The later commit `e8bdc75e6` changes only feature-folder documents and evidence. No PR exists yet for the branch (the regenerated PR context reports "no PR exists yet for this branch"). AC-15 names the PR head and is checked off by the orchestrator at S9.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **RI-7 (cycle 2): resolved.** See the Executive Summary and AC-20 in the feature audit.
- **RI-8 / PA-3 (cycle 2): resolved.** Every test file is at or below 500 lines; the source targets suite has no net change against the merge base.
- **PA-1 (cycle 0, Non-blocking; unrelated): accepted by the orchestrator** (report-row attribution variance in the unchanged `WorktreeTargetResolution.psm1`). The cycle 2 CI report row is 90.44 at both baseline and post-change. Not re-raised.
- **PA-2 (Non-blocking; related): branch behind `origin/main` by 133 commits.** `git merge-tree --write-tree --name-only origin/main HEAD` completes without conflict (tree `1e55a0ef2...`). The orchestrator merges `origin/main` before the PR, so that the PR diff and the S9 CI run reflect current `main`.
- **PA-4 (Non-blocking; unrelated to the #937 change surface): local canonical coverage population narrower than CI** (127 measured source files locally against 204 in CI; the targets file is not instrumented locally). Tooling-environment matter of the installed extension, outside the branch diff. Not re-raised as a defect of this item.
- **PA-5 (Non-blocking; related): AC-15 pending PR CI** at S9 (CI-dependent by design).

### Approved Exceptions

- None required. The pre-existing uncovered line 173 in each targets copy is unchanged by this branch.

### Removed/Skipped Tests

- No test was removed or skipped. U27 to U31 were moved, not removed: the move proof shows FOLD (rows remaining in the source suite) at 109 = 165 - 56 with 0 failed and the passed moved-row name set identical to the c2 baseline. The 10 disabled testcases are pre-existing platform skips.

---

## 9. Summary of Changes

1. **e137102c1 / f7191869f / f8fa81273 / 2312a56b7 / f7f35287a / c7f4ce8c6** - feature folder, research, spec, plan, and plan revisions
2. **2fe046995 / 1a2b7ed66 / 01fdeaf6a / 62f42c659 / 553433761 / fd138e1ca / d8ad225b2 / 0baf84bf4** - cycle 0 baseline, expect-fail rows, fix, QA, and review artifacts
3. **316857900, 2677047c1** - merges of `origin/main`
4. **4294ddbca ... 5d34fe436, a9dcc8c1a** - cycle 1 remediation (RI-1 to RI-6) and cycle 1 reaudit
5. **90ab138c2 / 1d0912206 / 87bcfed3e** - cycle 2 remediation plan and baseline evidence
6. **caa66b50f** - test: move U27 to U31 to the sibling PathNotLocal suite (RI-8)
7. **96b20936d / bdd9d3052** - cycle 2 expect-fail rows (four U27 URI rows, U32, six gate rows), AC-20, and fail-before evidence
8. **d9ce4757e** - fix: deny every URI-scheme path-leg spelling, not only `file:` (four copies)
9. **725545096 / e8bdc75e6** - cycle 2 final QA, CI pass-after, coverage, and AC-20 check-off

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT

All toolchain stages pass locally and in CI. File-size, line-length, mirror-parity, scope, and evidence-location checks pass. The canonical PowerShell coverage artifact is above the 85% floor. Every changed production file is at 99.40%, and no changed line regressed. The cycle 2 remediation items RI-7 and RI-8 are resolved with evidence.

**Total blocking findings: 0.**

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS: Before Making Changes / Design / Structure / Naming / Toolchain / Documentation

#### Language-Specific Code Change Policy (Section 3)
- PASS: PowerShell format, analyze, and test

#### General Unit Test Policy (Section 1)
- PASS: Core Principles
- PASS: Coverage & Scenarios
- PASS: Test Structure / External Dependencies

#### Language-Specific Unit Test Policy (Section 4)
- PASS: PowerShell

---

### Metrics Summary

- PASS: Pester 10497 non-disabled passing (local full suite and Windows CI), 6374 with 0 failed (Linux CI)
- PASS: Push-down contract tests 23 passed
- PASS: PowerShell canonical coverage artifact 94.58% lines repo-wide; CI 90.44%; targets copies 99.40%
- PASS: PowerShell changed lines 3/3 covered per measured copy; 0 regressed

---

### Recommendation

**Ready for PR after the merge of `origin/main`.** Merge `origin/main` (PA-2), open the PR, and check off AC-15 at S9 against the PR head. No remediation inputs file is produced for this review.

---

## Appendix A: Test Inventory

1. preimplementation gate targets (`<Surface>`) > U27 gives path-not-local for `<Label>` (27 labels x 2 surfaces), in the PathNotLocal suite
2. preimplementation gate targets (`<Surface>`) > U28 keeps a bare drive root path-leg input as its own target (2 labels x 2 surfaces)
3. preimplementation gate targets (`<Surface>`) > U29 denies a non-local path-leg input even when a sibling path is valid (x 2)
4. preimplementation gate targets (`<Surface>`) > U30 reports path-not-local before path-dot-segment for a UNC dot-dot path (x 2)
5. preimplementation gate targets (`<Surface>`) > U31 gives path-not-local for a non-local apply_patch marker path (x 2)
6. preimplementation gate targets (`<Surface>`) > U32 keeps a relative path-leg input with a later colon on the session root (x 2)
7. Claude EpicScopeTargets: nine Write deny rows (UNC, extended-length, drive-relative, `file:` URI, home-relative, root-relative backslash, `http`, `smb`, `vscode-remote`)
8. Codex epic-scope-targets: nine `apply_patch` deny rows (same nine spellings)

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands:**
```bash
git -C <worktree> log --oneline origin/main..HEAD
git -C <worktree> diff --stat origin/main...HEAD -- . ':!docs/features'
git -C <worktree> diff origin/main...HEAD -- .claude/hooks tests/
git -C <worktree> diff 2677047c1 HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
git diff --name-only origin/main...HEAD -- artifacts config scripts .claude/lib
git diff --name-only 725545096 HEAD
git rev-list --count HEAD..origin/main
git merge-tree --write-tree --name-only origin/main HEAD
git diff -U0 origin/main...HEAD -- tests .claude .codex extensions | grep '^+' | awk 'length > 121'
sha256sum <four targets copies>; wc -l <targets copies and gate test suites>
PYTHONPATH=. poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --repo-root .
poetry run python -I scripts/dev_tools/validate_evidence_locations.py --root .
gh run view 38885695856 -R drmoisan/drm-copilot --json headSha,conclusion,event
gh run view 38892084649 -R drmoisan/drm-copilot --json headSha,conclusion,event
gh run view 38898218767 -R drmoisan/drm-copilot --json conclusion,headSha,status
gh run download 38898218767 -R drmoisan/drm-copilot -n poshqc-test-results -D <scratchpad>/dl-c2
python -I <scratchpad>/cov2.py <scratchpad>/dl-c2/powershell-coverage.xml artifacts/pester/powershell-coverage.xml
python -I <scratchpad>/probe.py
```

**For PowerShell:**
```powershell
# Through the PoshQC MCP tools (executor): run_poshqc_format, run_poshqc_analyze, run_poshqc_test
# CI: ci.yml poshqc jobs (c2 baseline 38885695856, c2 fail-before 38892084649, c2 final 38898218767)
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)
