# Policy Compliance Audit: Mermaid Diagram Claude Runtime Port (Issue #491)

---

**Audit Date:** 2026-08-20
**Code Under Test:** Feature branch `drm-copilot-wt-2026-08-19T08-39` vs base `main` (merge base `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec`, head `3338400c0726c58b3b9a4fe40147e84697c87fea`). Production changes: `.claude/hooks/enforce-mermaid-validation.ps1`; `.claude/lib/mermaid/MermaidGrammar.psm1`, `MermaidLineScanner.psm1`, `MermaidMarkdownFences.psm1`, `MermaidValidation.psm1`; `.claude/rules/mermaid.md`; `.claude/skills/mermaid-diagram/SKILL.md` plus nine `references/*.md`; `.claude/settings.json`; byte-identical mirrors of all of the above under `extensions/drm-copilot/resources/claude-customizations/.claude/`; `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (16 entries); `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled parity copy; `.github/instructions/mermaid.instructions.md` (upstream Copilot pack, user-authored commit `90085df9`). Tests: five new Pester suites under `tests/scripts/claude-lib/mermaid/`, one new hook suite `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`, and a modified `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`. Docs: feature folder (issue/spec/user-story/plan/research/evidence) and five `docs/features/potential/` entries.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 5 production, 2 runsettings, 7 test files | 3107 (this review's fresh run; executor recorded 3086) | PASS 3107 pass, 0 fail, 9 skipped | 95.97% lines (5168/5385, 59 files) | 96.21% lines (5792/6020, 64 files) | 99.30% / 100% / 100% / 98.66% / 89.04% per new file (all >= 85%) |
| JSON (config) | 4 files (`settings.json` x2, `core.json`, none schema-governed) | N/A | PASS (parsed, validated by distribution suites) | N/A (config files) | N/A (config files) | N/A |
| Markdown (docs) | 13 `.claude` docs + feature docs | N/A | N/A | N/A | N/A | N/A |

TypeScript, Python, C#, and Bash have zero changed source files on this branch; their coverage rows are N/A by the zero-changed-files rule. The Python and TypeScript test suites executed in this audit (distribution suites) verify distribution artifacts changed by this branch, not Python/TypeScript source changes.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero changed TypeScript source files)
- TypeScript post-change coverage artifact: `N/A - out of scope`
- PowerShell baseline coverage artifact: `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/evidence/baseline/powershell-coverage.baseline.2026-08-19T10-23.xml`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (regenerated during this review at head `3338400c` by the repo-module run; per-file figures byte-identical to the executor's recorded run)
- Per-language comparison summary: Section 1.2.1 below; executor artifact `evidence/qa-gates/coverage-delta.2026-08-20T11-40.md` independently reproduced by this reviewer

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill missing audit evidence from memory or inference. If evidence is missing, stop and list the exact missing artifact paths.

---

## Rejected Scope Narrowing

None detected. The caller prompt explicitly stated "Determine review scope yourself from the branch diff per your scope invariant. I am supplying inputs only and am not narrowing scope." No plan-subset, file-subset, or language-coverage narrowing was attempted. The audit scope is the full branch diff `71aebdb9..3338400c` against `main`.

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — EXIT_CODE 0, zero violations.
- Branch-diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: zero matches. All 30 evidence files land under `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/evidence/<kind>/` (baseline, qa-gates, regression-testing, other), which is canonical.
- `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none required; no non-canonical path was supplied.
- Context note: `docs/features/potential/2026-08-20-evidence-locations-hook-swallows-its-deny.md` (filed on this branch) records that `enforce-evidence-locations.ps1` is currently inert, so compliance here was verified directly rather than assumed from hook enforcement. The branch does not depend on the broken hook behavior.

---

## Executive Summary

This audit covers the full feature-vs-base diff for issue #491, which ports the Mermaid Chart Copilot instruction pack (`.github/instructions/mermaid.instructions.md`) into the native Claude runtime as a rule, a skill with nine syntax references, a PreToolUse hook, and four dependency-free PowerShell validator modules, with complete bundled-mirror distribution and coverage registration. All changed production code is PowerShell; the JSON changes are configuration and manifest entries verified by dedicated distribution suites.

The reviewer re-ran, rather than accepted, the executor's claims: PSScriptAnalyzer (0 findings), format check (no file changed), the 341-test targeted Pester subset, the full 3107-test PoshQC repo-module run with coverage regeneration at head, both pytest distribution suites plus the bundled-parity suite (13 passed), the Jest pack-manifest completeness suite (15 passed), and nine live hook probes through the real `pwsh` entry point. Every executor-reported figure was reproduced exactly.

**Policy documents evaluated:**
- [x] `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- [x] `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- [x] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python source changes)
- N/A Bash (no Bash changes)
- [x] JSON: settings/manifest JSON parsed and gate-verified by the distribution suites (files are not `$schema`-governed config)

**Note on `.github/instructions/mermaid.instructions.md`:** the branch ADDS this file. It is the upstream instruction pack published by the Mermaid Chart VS Code extension, downloaded verbatim in user-authored commit `90085df9` ("(docs): downloaded mermaid instructions for github from official extension", author Dan Moisan). It is the source artifact this feature ports, not an agent modification of an existing policy document. No existing policy file under `.github/instructions/` or `.claude/rules/` was modified by an agent on this branch.

**Temporary artifacts cleanup:**
- [x] All temporary/one-time scripts created during development have been deleted (executor evidence references `<scratchpad>` scripts, which live outside the repo; no throwaway script appears in the diff)
- [x] Ongoing tooling scripts: none added

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each suite imports its module(s) or dot-sources the hook in `BeforeAll`; no cross-suite shared state; full-suite run (3107) and 8-suite subset run (341) both green, which exercises different orderings. |
| **Isolation** - Each test targets single behavior | PASS | One `It` per defect class, fail-open item, or false-positive construct (test names enumerated in Appendix A pattern; e.g., `rejects an unclosed square bracket and reports its opening line`). |
| **Fast Execution** - Tests complete quickly | PASS | 341 tests in 8.02s across the 8 new/modified suites (reviewer run); the hook suite (real subprocess cases limited to 3 entry-point tests) is the slowest at 2.55s. |
| **Determinism** - Consistent results | PASS | Pure string fixtures in here-strings; on-disk reads mocked through the `Get-MermaidOnDiskContent` wrapper seam; no wall clock, RNG, sleeps, or network anywhere in the new tests (grep verified). |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `It` names stating construct and expected outcome; suites grouped by module and concern (grammar / scanner / fences / validation / accept-matrix / hook / contract). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline:** 95.97% lines (5168/5385, 59 files), 2786 pass / 9 skip.<br>**Command:** `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"`<br>**Artifact:** `evidence/baseline/powershell-coverage.baseline.2026-08-19T10-23.xml` (preserved copy; live path is overwritten per run).<br>**Timestamp:** 2026-08-19 10:23. |
| **No Coverage Regression** | PASS | **Post-change:** 96.21% lines (5792/6020, 64 files; reviewer's fresh run at head). **Change:** +0.24 points on a denominator larger by exactly the 5 registered new files. Per-file no-regression check over the 59 common files: **0 decreases, 0 dropped files** (reviewer recomputed from both XMLs; matches executor's `coverage-delta.2026-08-20T11-40.md`). |
| **New Code Coverage** | PASS | `MermaidGrammar.psm1` 99.30% (141/142), `MermaidLineScanner.psm1` 100% (163/163), `MermaidMarkdownFences.psm1` 100% (79/79), `MermaidValidation.psm1` 98.66% (147/149), `enforce-mermaid-validation.ps1` 89.04% (65/73). All five >= 85% (repo uniform threshold). The hook file's uncovered lines are the entry-point wiring below the dot-sourcing guard, measured and visible per the Coverage Exclusion Policy. |
| **Comprehensive Coverage** | PASS | Every exported function of the four modules is exercised; hook decision function, entry point, and all helper functions covered (see Section 5). Uncovered: 1 line in `MermaidGrammar.psm1`, 2 in `MermaidValidation.psm1`, 8 entry-point/guard lines in the hook. |
| **Positive Flows** - Valid inputs | PASS | One valid-diagram accept case per deep-checked type (flowchart, sequence, class, state, ER) plus gantt/pie keyword-only accepts; hook allow paths for `.mmd` and Markdown writes. |
| **Negative Flows** - Invalid inputs | PASS | Missing/arrow/bracket first line, misspelled keyword, per-type invalid arrows (5 types), each bracket class, unterminated quote, unclosed subgraph, empty/whitespace, empty body, malformed frontmatter — each a named reject case. |
| **Edge Cases** - Boundary conditions | PASS | CRLF/LF byte-equivalent verdicts (valid and invalid), frontmatter (`title`, nested `config`, `id`), line-offset arithmetic, nested fences, blockquoted fences, tilde fences, unclosed fence, marker separated by a blank line (not honored). |
| **Error Handling** - Error paths | PASS | Fail-open matrix: empty/absent/unparseable `CLAUDE_TOOL_INPUT`, missing/empty `file_path`, out-of-scope path, Edit fragment, missing module on disk — each asserted to allow. |
| **Concurrency** - If applicable | N/A | The validator is a pure per-invocation string pass; the hook is a single-shot subprocess. No concurrent state exists. |
| **State Transitions** - If applicable | N/A | Stateless by design (spec `## Data & State`). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.97% lines -> Post-change: 96.21% lines. Change: +0.24% lines (denominator grew by the 5 registered files; not a like-for-like delta). New/changed-code coverage: 98.18% (aggregate 595/606 lines over the five new files; per-file minimum 89.04%, all >= 85%). Changed-lines regression: none (0 per-file decreases over all 59 common files). Disposition: PASS. Evidence: `evidence/baseline/powershell-coverage.baseline.2026-08-19T10-23.xml`, `artifacts/pester/powershell-coverage.xml` (regenerated at head during this review), `evidence/qa-gates/coverage-delta.2026-08-20T11-40.md`. No branch-coverage gate applies to PowerShell (Pester measures line/command coverage only, per `.claude/rules/quality-tiers.md`).
- TypeScript: zero changed source files. Disposition: N/A (zero changed files).
- Python: zero changed source files. Disposition: N/A (zero changed files).
- C#: zero changed source files. Disposition: N/A (zero changed files).
- Bash: zero changed files. Disposition: N/A (zero changed files).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions use Pester `Should` with specific expected values (verdicts, finding classes, line numbers, reason-token prefixes), so a failure names the divergent field. |
| **Arrange-Act-Assert Pattern** | PASS | Here-string fixture (arrange), `Test-MermaidDiagram`/`Invoke-MermaidValidationDecision` call (act), verdict/finding assertions (assert), consistently across all suites. |
| **Document Intent** | PASS | `It` names are full behavioral sentences; the accept-matrix suite maps one case per research §4 false-positive construct. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No database, network, API, or subprocess dependencies. Three hook entry-point tests spawn a real `pwsh` subprocess deliberately, matching the established hook contract-test precedent in this repository. |
| **Use Mocks/Stubs** | PASS | `Get-MermaidOnDiskContent` is mocked for every managed-diagram case (including a call-count assertion), so no test reads or writes a repo file. |
| **Environment Stability** | PASS | No temp files (grep for `New-TemporaryFile`/`GetTempPath`/`TestDrive`/`Set-Content`/`New-Item`/`Out-File` over the new test files: zero hits); fixtures are here-strings per the spec's hook-self-interaction constraint. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document, plus `code-review.2026-08-20T11-39.md` and `feature-audit.2026-08-20T11-39.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #491; `issue.md` work mode `full-feature`; spec.md with 7 binding decisions (D1–D7). |
| **Read existing change plans** | PASS | Two research artifacts under `research/` predate the plan and are cited as authoritative by spec.md; `evidence/other/phase0-instructions-read.md` records the policy reading. |
| **Document the plan** | PASS | `plan.2026-08-19T08-50.md` (261 lines, phased P0–P7 with per-task evidence pointers). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Dependency-free structural validation (D1) instead of an 83.9 MB browser-bound parser; line-based fence tracker instead of a CommonMark parser; data tables in one module. |
| **Reusability** | PASS | Validator logic lives in importable modules, not the hook; `Test-MermaidDiagram` returns a structured result usable by a future CI deep check (documented seam). |
| **Extensibility** | PASS | Keyword allowlist and arrow tables are single data structures (one-line-per-keyword updates); `Verified` flag distinguishes documented from sidebar-only keywords; `LineOffset` parameter serves both file and fence callers. |
| **Separation of concerns** | PASS | Grammar data (`MermaidGrammar`), line scanning (`MermaidLineScanner`), fence tracking (`MermaidMarkdownFences`), orchestration (`MermaidValidation`), and I/O + protocol (hook) are separate files; the only filesystem access is the hook's named wrapper seam. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Four modules with the split the research recommended; each has a header stating its single concern. |
| **Under 500 lines** | PASS | Reviewer-measured: hook 390; modules 491/488/298/496; SKILL.md 184; rule 142; references 32–82; test suites 234–488. All under 500. |
| **Public vs internal** | PASS | Explicit `Export-ModuleMember` lists; hook functions scoped to the script with a dot-sourcing guard for tests. |
| **No circular dependencies** | PASS | Linear import chain: Validation -> {Grammar, LineScanner, MarkdownFences}; LineScanner -> Grammar; hook -> Validation. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Test-MermaidManagedDiagram`, `Get-MermaidFenceBlock`, `Invoke-MermaidValidationDecision`; PSScriptAnalyzer verb check clean. |
| **Docs/docstrings** | PASS | Every function carries comment-based help; module headers state contract, fail-open policy, pin, and purity claims. |
| **Comment why, not what** | PASS | The DELIBERATE DIVERGENCE note (why fail-open differs from `enforce-evidence-locations.ps1`), the clamped-closer rationale in `Get-MermaidBodyFinding`, the near-miss-vs-drift rationale at the misspelling check. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCFormat -Root (Get-Location).Path` (reviewer re-run)<br>**Result:** no file changed (`git status --porcelain` empty afterwards). |
| **2. Linting** | PASS | **Command:** `Invoke-PoshQCAnalyze -Root (Get-Location).Path` (reviewer re-run)<br>**Result:** "PSScriptAnalyzer passed: no findings". Zero suppressions in any new file (grep for `SuppressMessage`: only the pre-existing attribute in the contract suite). |
| **3. Type checking** | N/A | Not applicable for PowerShell. No Python/TypeScript/C# source changed. |
| **4. Testing** | PASS | **Command:** `Invoke-PoshQCTest -Root (Get-Location).Path` (reviewer re-run at head)<br>**Result:** 3107 passed, 0 failed, 9 skipped. Distribution suites: pytest 13 passed; Jest 15 passed. |
| **Full toolchain loop** | PASS | Reviewer's single sequential pass (format -> analyze -> test -> distribution suites) completed with zero findings and zero mutations. Stages 4 (architecture) and 6 (contract) have no PowerShell tooling in this repo; the contract obligations here are the pack-manifest/parity suites and the PreToolUse deny-shape contract suite, all green. |
| **Explicit reporting** | PASS | Executor: `evidence/qa-gates/final-poshqc-{format,analyze,test}.2026-08-20T11-40.md` and phase gate records. Reviewer: this document. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `3338400c feat(491): port mermaid instructions into the native Claude runtime`; spec.md `## Implementation Strategy` matches the delivered diff. |
| **Design choices explained** | PASS | D1–D7 with recorded rationale and rejected alternatives. |
| **Update supporting documents** | PASS | Rule, skill, references authored; out-of-scope record present in both rule and skill; four latent repo defects filed as `docs/features/potential/` entries instead of scope creep. |
| **Provide next steps** | PASS | Follow-ups recorded: emitter retrofit, CI-side `mmdc` deep check, Codex port (spec `## Out of Scope` items 4, 5, 8). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Command:** `Invoke-PoshQCFormat -Root .` (reviewer)<br>**Result:** all files already formatted; zero working-tree changes. |
| **Linting with PSScriptAnalyzer** | PASS | **Command:** `Invoke-PoshQCAnalyze -Root .` (reviewer)<br>**Result:** no findings repo-wide. |
| **Fix all findings** | PASS | Zero findings to fix; zero new suppressions added (verified by grep). |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | Hook header pins "PowerShell 7+" (hooks run under `pwsh -NoProfile` by registration, so 5.1 compatibility is not a runtime requirement for this class); no syntax outside the repo's established hook conventions. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | Every function uses `[CmdletBinding()]` with `[OutputType()]`. |
| **Parameter validation** | PASS | `[Parameter(Mandatory)]`, `[AllowEmptyString()]`, `[AllowNull()]`, `[AllowEmptyCollection()]` applied deliberately; empty-content paths verified safe (reviewer inspected `Get-MermaidFenceBlock` and probed live). |
| **Avoid global state** | PASS | Constants in `$script:` scope; validator functions pure per module-header contract. |
| **Error handling** | PASS | Deliberate fail-open with narrow `try/catch` around JSON parse, module import, and file read only, each returning a sentinel; divergence from the hard-fail hook documented in the header so it is not "fixed". |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 390/491/488/298/496 production lines; `MermaidGrammar.psm1` was compacted from 563 to 491 (executor claim consistent with delivered 491-line file). |
| **Approved verbs** | PASS | `Get-`, `Test-`, `Import-`, `Invoke-`, `Resolve-`, `Split-` only; analyzer clean. |
| **Comment why** | PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | Reviewer re-run; no changes. |
| **Step 2: Analyze** | PASS | Reviewer re-run; no findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | Reviewer re-run; 3107/0/9 with coverage regenerated. |
| **Rerun loop if needed** | PASS | Reviewer's pass was clean first time; executor evidence records per-phase green gates (`phase1/2/3-toolchain-pass`). |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | PASS | `settings.json` (both copies) and `core.json` edits are minimal appends preserving existing style; files parse cleanly (reviewer parsed `settings.json` with Python `json.load`; executor evidence `core-json-references-verification.2026-08-20T11-22.md` records the same for `core.json`). |
| **Schema validation** | N/A | These files are not `$schema`-governed; their correctness gates are the pack-manifest completeness and parity suites, all green. |
| **Required $schema** | N/A | Not applicable to these file classes. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | No comments or trailing commas introduced; parse verified. |
| **Deterministic key order** | PASS | Appends only; no reordering in the diff. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `Describe`/`Context`/`It`, `BeforeAll`/`BeforeDiscovery`, modern `Should` syntax, `Mock` with `-ParameterFilter` throughout the new suites. |
| **Use PoshQC Configuration** | PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, extended with the five new `CodeCoverage.Path` entries under an issue-#491 comment; bundled parity copy updated identically (`test_poshqc_bundled_parity.py` green). |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | Suites run under the repo's standard `pwsh` runner; no version-gated syntax observed. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 300 new tests across 6 new/1 modified suites; each `It` targets one construct, defect class, fail-open item, or protocol property. |
| **Test Behavior Over Implementation** | PASS | Assertions target verdicts, finding classes, line numbers, and emitted JSON shape, not internals. |
| **Mocking Used Sparingly** | PASS | Exactly one mock target (`Get-MermaidOnDiskContent`), used only where filesystem isolation is mandatory. |
| **Organization** | PASS | `tests/scripts/claude-lib/mermaid/*` mirrors `.claude/lib/mermaid/*`; `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` mirrors `.claude/hooks/enforce-mermaid-validation.ps1`, matching the repository's established `tests/scripts/claude-*` convention for `.claude` production code. No colocation. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | All six new files use the `*.Tests.ps1` suffix. |
| **Describe/Context/It Structure** | PASS | Suites use Describe + Context grouping by concern (e.g., accept paths, reject paths, fail-open, managed diagrams, entry point). |
| **Logical Grouping** | PASS | Accept-matrix constructs isolated in their own suite so the false-positive contract is auditable in one file. |
| **Docstrings/Comments** | PASS | Self-documenting `It` sentences; header comments state each suite's scope. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | Reviewer full run green (3107/0/9) with coverage. |
| **No Alternative Test Runners** | PASS | Pester via PoshQC only. |

---

## 5. Test Coverage Detail

### MermaidGrammar.psm1 (95 tests in MermaidGrammar.Tests.ps1)

| Test area | Scenario Type | Status |
|-----------|--------------|--------|
| Keyword resolution (known, unknown-plausible, non-keyword, misspelling radius) | Positive/Negative/Edge | PASS |
| Arrow pattern accessors per deep-checked type | Positive | PASS |
| Statement-keyword / non-edge-keyword / post-colon-type / bracket-structural classifiers | Positive/Negative | PASS |

**Coverage:** 99.30% (141/142 lines). Not covered: 1 line.

### MermaidLineScanner.psm1

Quote-aware bracket deltas, comment/directive detection, arrow-candidate extraction with affix rules, unterminated-quote detection. **Coverage:** 100% (163/163).

### MermaidMarkdownFences.psm1

Fence open/close matching, nesting stack, blockquote stripping, tilde/backtick interplay, unclosed-fence tolerance, opt-out marker adjacency. **Coverage:** 100% (79/79).

### MermaidValidation.psm1 (43 top-level `It` cases)

Frontmatter extraction/malformation, managed-diagram detection (non-empty `id:` only), keyword-line location, per-type accept/reject matrix, CRLF/LF equivalence, line offsets, all seven fail-open items. **Coverage:** 98.66% (147/149). Not covered: 2 lines.

### enforce-mermaid-validation.ps1 (28 tests)

All hook decision paths (see feature audit AC-11..AC-17) plus 3 real-subprocess entry-point protocol cases. **Coverage:** 89.04% (65/73). Not covered: 8 lines of entry-point wiring below the dot-sourcing guard (measured, not excluded, per the Coverage Exclusion Policy).

**Not covered overall:** 11 lines across 5 files, all in the >=85% per-file envelope.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full repo run, reviewer) | 3116 (3107 passed + 9 skipped) | PASS |
| Tests Passed | 3107 (100% of non-skipped) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time (8 new/modified suites) | 8.02s | Fast |
| Discovery Time (8 suites) | 744ms for 341 tests | Fast |
| New tests added by this feature | 300 (271 lib + 28 hook + 1 contract) | PASS |
| Test File Size | 234–488 lines per suite | Maintainable |
| Code Coverage | 96.21% lines repo-wide; 96.05% commands (runner headline) | PASS |

Note: the executor's recorded run counted 3086 passed; the reviewer's fresh run counted 3107. The delta (+21) is in dynamically generated repo-state-dependent cases outside this feature's suites; both runs report 0 failures and identical per-file coverage for the five new files, so the difference is informational.

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | No file changed | PASS |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | 0 findings, 0 new suppressions | PASS |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 3107 passed / 0 failed / 9 skipped | PASS |

**Distribution gates (TypeScript/Python suites over changed JSON/mirror artifacts):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Resource parity | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` | green (within 13 passed) | PASS |
| Manifest completeness (Python) | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q` | green | PASS |
| Bundled runsettings parity | `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` | green | PASS |
| Manifest completeness (TS) | `npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts` | 15 passed | PASS |
| No-Python-invocation gate | `Invoke-Pester tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | green (within 341-test subset) | PASS |
| Byte-identity (reviewer direct) | `cmp` over all 17 mirrored files | 17/17 IDENTICAL | PASS |

**Notes:**
Pre-existing sub-85% files (`new-claude-worktree-session.ps1` 61.33%, `validate-bash.ps1` 81.58%, `enforce-completion-helpers.ps1` 84.88%) are untouched by this branch, were at or below the same level in the baseline, and did not regress. They are outside this feature's remediation scope.

**Policy rule `modified-workflow-needs-green-run`:** does not fire. The diff contains no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (verified against the full name-status diff).

**Coverage Exclusion Policy:** the runsettings change ADDS five production paths to `CodeCoverage.Path` and adds no `exclude` entry. No production path is excluded. PASS.

---

## 8. Gaps and Exceptions

### Identified Gaps
**None blocking.** Two informational items, both detailed in `code-review.2026-08-20T11-39.md`:
- No single Pester case combines the opt-out marker with a managed diagram; the impossibility of the marker suppressing the managed guard is structural (the marker path exists only for Markdown fences; the managed gate keys on `.mmd`/`.mermaid` file paths and runs first) and was verified by code inspection and live probes. Severity: Info.
- The Copilot pack's Rule 2 ("always preview after generating") ports as a conditional workflow step (D6), a deliberate, recorded weakening because rendering tools are harness-dependent. Severity: Info; recorded in spec D6 and the skill.

### Approved Exceptions
- **Template sourcing.** The review artifacts were created from the authoritative bundled template assets at `extensions/drm-copilot/resources/templates/policy_audit/` — the exact files the template-asset resolver maps each selector to, per `extensions/drm-copilot/src/policy-audit-template-assets.ts` (`template`, `code-review-template`, `feature-audit-template`). The template content used is therefore identical to the resolver's output.
- **PowerShell branch coverage:** exempt by rule (`.claude/rules/quality-tiers.md`); Pester does not measure branch coverage. Not a gap.

### Removed/Skipped Tests
**None.** Skip count is 9 before and after (unchanged pre-existing skips); no test of this feature is skipped and none was removed.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **90085df9** — `(docs): downloaded mermaid instructions for github from official extension` (adds `.github/instructions/mermaid.instructions.md`, user-authored)
2. **3338400c** — `feat(491): port mermaid instructions into the native Claude runtime` (everything else)

### Files Modified

1. **`.claude/rules/mermaid.md`** (NEW) — path-scoped standards, validation mandate, managed-diagram constraint, opt-out marker, out-of-scope disposition table.
2. **`.claude/skills/mermaid-diagram/SKILL.md` + 9 `references/*.md`** (NEW) — workflow, eight generation recipes, conditional rendering, syntax references pinned to Mermaid 11.17.0 with WebFetch fallback.
3. **`.claude/hooks/enforce-mermaid-validation.ps1`** (NEW) — thin PreToolUse gate; syntax + managed-diagram gates; documented fail-open divergence.
4. **`.claude/lib/mermaid/*.psm1`** (NEW, 4 files) — grammar data, quote-aware scanner, fence tracker, validation orchestration.
5. **`.claude/settings.json`** (MODIFIED) — 11th `Write|Edit` PreToolUse hook entry + `Skill(mermaid-diagram *)` allow.
6. **`extensions/drm-copilot/resources/claude-customizations/.claude/**`** (NEW/MODIFIED, 17 files) — byte-identical mirrors.
7. **`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`** (MODIFIED) — 16 new entries including all nine references.
8. **`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` + bundled copy** (MODIFIED) — five `CodeCoverage.Path` entries with issue-#491 comment.
9. **Tests** (NEW/MODIFIED, 7 files) — 300 new tests; contract suite count 14 -> 15 with a new deny-shape `It` block.
10. **`.github/instructions/mermaid.instructions.md`** (NEW) — upstream source pack.
11. **Feature folder + 5 `docs/features/potential/` entries** (NEW) — scoping docs, plan, research, 30 evidence artifacts, latent-defect records.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All policy gates pass on independently re-run evidence: formatter (no changes), PSScriptAnalyzer (0 findings, 0 suppressions), Pester (3107/0/9), PowerShell line coverage 96.21% repo-wide with all five new files >= 85% and zero per-file regressions against the preserved baseline, distribution parity byte-verified, manifest completeness green on both suites, evidence locations canonical, no dependency-manifest change, and no prohibited coverage exclusion.

**Fail-closed reminder:** no required baseline artifact, QA artifact, coverage metric, or comparison artifact is missing.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- [x] Before Making Changes: PASS
- [x] Design Principles: PASS
- [x] Module & File Structure: PASS (all files < 500 lines)
- [x] Naming, Docs, Comments: PASS
- [x] Toolchain Execution: PASS (single clean pass, reviewer re-run)
- [x] Summarize & Document: PASS

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- [x] Tooling & Baseline: PASS
- [x] PowerShell Design & Safety: PASS
- [x] Structure & Naming: PASS
- [x] Toolchain: PASS

#### General Unit Test Policy (Section 1)
- [x] Core Principles: PASS
- [x] Coverage & Scenarios: PASS
- [x] Test Structure: PASS
- [x] External Dependencies: PASS
- [x] Policy Audit: PASS

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- [x] Framework & Scope: PASS
- [x] Test Style & Structure: PASS
- [x] Naming & Readability: PASS
- [x] Toolchain: PASS

---

### Metrics Summary

- 3107/3107 non-skipped tests passing (100%)
- 96.21% repo-wide PowerShell line coverage (baseline 95.97%; 0 per-file regressions)
- New-file coverage: 99.30% / 100% / 100% / 98.66% / 89.04% (all >= 85%)
- 0 lint findings, 0 new suppressions, 0 format deltas
- 17/17 mirror files byte-identical; 16/16 manifest entries present
- All code quality checks passing

---

### Recommendation

**Ready for merge.** Zero blocking findings. See `code-review.2026-08-20T11-39.md` for the two informational notes and `feature-audit.2026-08-20T11-39.md` for the per-criterion evaluation (25/25 spec criteria PASS, 8/8 user-story criteria PASS).

---

## Appendix A: Test Inventory

New and modified suites of this feature (341 tests including pre-existing contract/no-python cases; 300 net-new):

1. `tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1` — keyword resolution (known/plausible/non-keyword/one-edit misspelling), per-type arrow patterns, classifier accessors.
2. `tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1` — quote-aware bracket deltas, directive/comment recognition, arrow-candidate extraction and affix rules, unterminated-quote detection.
3. `tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1` — fence open/close/nesting/blockquote/tilde/unclosed rules, `Split-MermaidTextLine` normalization, opt-out marker adjacency.
4. `tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1` — the 43-case accept/reject/fail-open/frontmatter/CRLF matrix plus `Test-MermaidManagedDiagram` (5 cases).
5. `tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1` — 22 accept cases, one per research §4 false-positive construct plus generics/aliases/mid-arrow-text extensions.
6. `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` — 28 cases: deny/allow per surface, opt-out scope (honored, one-block-only, blank-line-not-honored), managed-diagram (Edit/Write/seam-call-count/no-id/no-file), fail-open matrix, missing-module, named negative control, 3 subprocess protocol cases.
7. `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` — hook count 14 -> 15; new `enforce-mermaid-validation.ps1 emits a PreToolUse deny shape` case.

Flat inventory of exact `It` names: run `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/mermaid/, tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 -Output Detailed"`.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCFormat -Root (Get-Location).Path

# Linting
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCAnalyze -Root (Get-Location).Path

# Testing + coverage (repo-module run; the coverage-authoritative path)
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path

# Feature-scoped subset
Invoke-Pester -Path tests/scripts/claude-lib/mermaid/, tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1, tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1, tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -Output Normal
```

**Distribution gates:**
```bash
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
cd extensions/drm-copilot && npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts
```

**Evidence-location scan:**
```bash
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-08-20
**Policy Version:** Current (as of audit date)
