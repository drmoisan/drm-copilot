# Policy Compliance Audit: Epic Merge Gate Standalone Authorization Record (Issue #670)

---

**Audit Date:** 2026-09-17
**Auditor:** feature-review agent
**Base Branch:** `origin/epic/worktree-scoped-state-resolution-integration` @ `79fd5a95c00cd99238b69a3195788206ae96f4cd` (merge base `79fd5a95c00cd99238b69a3195788206ae96f4cd`)
**Head Branch:** `feature/2026-09-13-epic-merge-gate-authorization-record-670` @ `332ab835133af49092d8155c40ea0152560f5557`
**Scope:** full branch diff against the resolved base (58 files; 18 outside the feature `evidence/` tree)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, the file the MCP template resolver serves. The MCP tools are not in this agent's tool set, so the asset file was read directly and its structure followed. Artifact validation used the CLI `scripts/dev_tools/validate_orchestration_artifacts.py`, which backs the MCP validator.

**Code Under Test:**

- `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` (new, 443 lines)
- `.claude/hooks/enforce-epic-merge-gate.ps1` (modified, 483 lines)
- `.codex/hooks/enforce-epic-merge-gate.ps1` (modified, 379 lines)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` (new, 168 lines)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1` (new, 203 lines)
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` (new, 194 lines)
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled mirror (one coverage entry each)
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (one path entry)
- `.claude/rules/orchestrator-state.md`, `.claude/skills/parallel-orchestrate/SKILL.md` (documentation)
- Five bundled mirrors under `extensions/drm-copilot/resources/` (byte-identical copies)
- Feature documents: `spec.md` (checkbox changes only), `plan.2026-09-13T20-46.md`, and 40 evidence files

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 6 files (3 production: 1 new, 2 modified; 3 new test suites) plus 2 mirrored production copies | 80 new tests; 4627 in the whole-tree run | PASS: 434 targeted pass, 0 fail; whole tree 4625 pass, 2 environmental fail that pass in a clean export (227/227) | 95.48% lines repo-wide; parent hook 96.72% lines; Codex hook 98.59% lines | 95.56% lines repo-wide; helpers 100.00%, parent 96.67%, Codex 99.34% lines | 100.00% (187 of 187 executable changed lines) |
| PowerShell data (.psd1) | 2 files | N/A | N/A (configuration data) | N/A (configuration data, not executable) | N/A (configuration data) | N/A |
| JSON | 1 file | N/A | PASS: pack-manifest completeness test green | N/A (configuration file) | N/A (configuration file) | N/A |
| Markdown | 44 files (4 runtime documentation, 40 feature documents and evidence) | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |
| Python | 0 files | N/A | N/A (zero files changed) | N/A (zero files changed) | N/A (zero files changed) | N/A |
| TypeScript | 0 files | N/A | N/A (zero files changed) | N/A (zero files changed) | N/A (zero files changed) | N/A |
| C# | 0 files | N/A | N/A (zero files changed) | N/A (zero files changed) | N/A (zero files changed) | N/A |

PowerShell is exempt from the branch-coverage threshold because Pester measures command and line coverage only (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`). No branch figure is evaluated for it.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - zero TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/baseline/phase0-pester-coverage.2026-09-13T20-46.md` and `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/baseline/p1-post-registration-coverage.2026-09-13T20-46.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-09-17 08:44:42 -0400, after the last source edit at 08:39:12 -0400), summarized in `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/qa-gates/p8-pester-coverage.2026-09-13T20-46.md`
- Per-language comparison summary: Section 1.2.1 of this audit and `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/qa-gates/coverage-comparison.2026-09-13T20-46.md`

**Verdict rule check:** numeric baseline, post-change, and changed-code coverage are present for the only coverage language with changed files (PowerShell). All required baseline, QA, and comparison artifacts exist on disk.

---

## Executive Summary

The branch adds a fourth allow condition to the epic merge gate: a standalone `gh pr merge --merge` is allowed only when an orchestrator checkpoint carries a PR-specific, session-bound `standalone_merge_authorizations` record. The Claude hook gains the branch through a new dot-sourced helpers file, and the Codex hook gains an in-place counterpart. The change set also includes four reason codes, three new Pester suites, coverage and pack-manifest registration, documentation in the orchestrator-state rule and the parallel-orchestrate skill, and byte-identical bundled mirrors.

**Policy documents evaluated:**
- PASS `CLAUDE.md` and `.claude/rules/tonality.md`
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (code change and unit test)
- N/A Python, TypeScript, C#: zero changed files on the branch
- N/A Bash: zero changed files on the branch
- PASS JSON: one manifest entry, validated by `test_push_down_claude_pack_manifest_completeness.py`

Summary of verification performed by this review (not only read from executor evidence):

- Formatting: check-only `Invoke-Formatter` with the repository settings reports all six changed `.ps1` files already formatted.
- Linting: `Invoke-ScriptAnalyzer` reports 0 diagnostics on all six files.
- Tests: 17 targeted Pester suites, 434 passed and 0 failed in the review worktree. In a clean `git archive` export of HEAD, 10 suites pass 227/227 (including the two whole-tree failures) and 17/17 push-down pytest cases pass (including the issue #510 node).
- Coverage: parsed `artifacts/pester/powershell-coverage.xml` directly; the figures match the executor's evidence.
- Mirrors: six SHA-256 pairs match. Line counts: every non-Markdown file is at most 483 lines.

**Temporary artifacts cleanup:**
- PASS No temporary scripts were added to the repository by the branch.
- PASS The review's own helper scripts and the HEAD export were written only to the session scratchpad, outside the repository.

---

## Rejected Scope Narrowing

No attempt to narrow the audit scope was detected. The caller text was checked against the narrowing patterns (plan or task subset, file subset, language marked out of scope, skipped toolchain or coverage check). The only scoping statement was about feature behaviour, not audit scope, and it was not treated as a narrowing:

> "Epic manifest context for the reviewer (docs/features/epics/worktree-scoped-state-resolution/epic.md, child F3): RULING 1 forbids widening the merge gate's pr_number matcher; `--squash` handling is out of the feature's scope; four mirror surfaces exist, including extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/."

The audit covered the full 58-file branch diff against `origin/epic/worktree-scoped-state-resolution-integration`.

---

## Evidence Location Compliance

- `git diff --name-only origin/epic/worktree-scoped-state-resolution-integration...HEAD -- artifacts .github scripts/benchmarks` printed nothing. No branch file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0.
- All 40 executor evidence files are under `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, or `evidence/issue-updates/`.
- `spec.md` names `evidence/coverage/` as the coverage location. That sub-path is not in the canonical list, and the executor recorded `EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/coverage/ replaced with docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/qa-gates/` in `evidence/issue-updates/ac-status-and-followups.2026-09-13T20-46.md`. The override is correct under the non-overridable evidence-location rule.
- The review's own evidence is at `evidence/qa-gates/review-clean-state-verification.2026-09-17T09-12.md`.

Result: PASS, with zero findings.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each case builds its own checkpoint literals and envelope. Decision-level cases re-declare all three read-seam mocks inside the `It` block. No shared mutable state beyond read-only `$script:` fixtures set in `BeforeAll`. |
| **Isolation** - Each test targets single behavior | PASS | Decision matrix rows (one input combination each), predicate-level cases (one field or one block shape each), and separate contexts for reason text, branch order, matcher, and reason-code parity. |
| **Fast Execution** - Tests complete quickly | PASS | The three new suites (80 cases) run inside the 434-case targeted run in well under a minute. There are no sleeps or waits. |
| **Determinism** - Consistent results | PASS | Fixed `session_id` and `authorized_at` literals. No clock read, no process start, no disk write. Checkpoint reads are mocked (Claude) or passed as parameters (Codex). The one date string parsed (`September 13, 2026 21:04`) uses `InvariantCulture`. |
| **Readability & Maintainability** - Clear structure | PASS | Table-driven `-ForEach` with `<Name>` templating, header determinism blocks in each file, and small local builders (`Get-RecordJson`, `Get-ValidRecord`, `Get-CodexRecordJson`). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Phase 0: 95.48% lines repo-wide; parent 96.72% (118/122); Codex 98.59% (70/71). Post-registration baseline: helpers 100.00% (9/9), parent 96.49% (110/114), Codex 98.59%. Command: `Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('scripts','tests/scripts')`. |
| **No Coverage Regression** | PASS | Repo-wide 95.48% to 95.56% (+0.08 points). Codex 98.59% to 99.34%. The parent moved from 96.72% (Phase 0) to 96.67%. This -0.05 point figure is arithmetic only: 8 fully covered factory lines moved to the helpers file (118/122 to 110/114), then 6 covered branch-4 lines were added (116/120). The same four entry-point tail lines (478-480, 483) are uncovered before and after. Combined Claude pair (parent plus helpers): 216/220 = 98.18%. Changed-line coverage is 100.00%. |
| **New Code Coverage** (uniform threshold 85% lines; legacy 90% also met) | PASS | Helpers file 100/100 = 100.00%. Changed executable lines: helpers 100/100, parent 7/7, Codex 80/80 (`coverage-comparison.2026-09-13T20-46.md`, method: `-U0` diff intersected with `line` elements). |
| **Comprehensive Coverage** | PASS | Every helpers-file function is exercised: `Get-EpicMergeGateAllowDecision`, `Get-EpicMergeGateBlockDecision`, `Test-StandalonePositiveJsonInteger`, `Test-StandaloneJsonObject`, `Get-StandaloneRecordField`, `Get-StandaloneMergeAuthorizationRecord`, `Test-StandaloneNonBlankString`, `Test-StandaloneAuthorizedAt`, `Get-StandaloneRecordFailure`, `Test-StandaloneMergeAuthorizationRecord`, `Get-StandaloneAuthorizationBlockState`, `Test-StandaloneCheckpointAllowsMerge`. The only uncovered Codex line is 373 (entry-point tail). |
| **Positive Flows** - Valid inputs | PASS | Allow with the record in each of the three Claude checkpoints and both Codex checkpoints; the paired positive for the discriminator; `--squash` with a record; valid record with and without `run_slug`; non-ISO parseable `authorized_at`; branch-1, 2 and 3 regression guards. |
| **Negative Flows** - Invalid inputs | PASS | 13 non-PR-specific spellings; 8 field-shape failures; 4 session failures (differs, absent, blank record session, case-only difference); PR mismatch; absent key. |
| **Edge Cases** - Boundary conditions | PASS | `basis` of 16 characters (below 20); whitespace-only strings; one-element `pr_number` array; `pr_url` ending `/pull/6910` for PR 691; bare command with a valid record; blanket flag beside a valid record. |
| **Error Handling** - Error paths | PASS | Codex throw channel for whitespace-only and unparseable payloads (exit-2 path). The Claude envelope-anomaly and malformed-checkpoint cases stay in the unedited existing suites, which are green. |
| **Concurrency** - If applicable | N/A | The hook is a single-shot, stateless decision per process. |
| **State Transitions** - If applicable | N/A | No stateful component. Branch order (branch 3 before branch 4) is pinned by a case that mocks branch 4 to throw. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.48% lines repo-wide (parent hook 96.72%, Codex hook 98.59%) -> Post-change: 95.56% lines repo-wide (helpers 100.00%, parent 96.67%, Codex 99.34%). Change: +0.08% lines repo-wide; Codex +0.75%; parent -0.05% from relocating 8 covered lines, with no line losing coverage. New/changed-code coverage: 100.00% (187 of 187 executable changed lines). Disposition: PASS. Evidence: `evidence/baseline/phase0-pester-coverage.2026-09-13T20-46.md`, `evidence/baseline/p1-post-registration-coverage.2026-09-13T20-46.md`, `evidence/qa-gates/post-change-coverage.2026-09-13T20-46.md`, `evidence/qa-gates/coverage-comparison.2026-09-13T20-46.md`, `artifacts/pester/powershell-coverage.xml`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `Should -BeExactly` on reason codes and the full line-433 text; `-Because` on the absent-guidance assertion; row names are templated into test names. |
| **Arrange-Act-Assert Pattern** | PASS | Each case builds fixtures and mocks, makes one decision or predicate call, then asserts. |
| **Document Intent** | PASS | Describe names cite issue #670. Header comment blocks state determinism rules. The branch-order case documents intent through the throwing mock. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, no process, no `gh` or `git`. The parity case reads two repository source files as text only. |
| **Use Mocks/Stubs** | PASS | `Get-ChildOrchestratorCheckpointContent`, `Get-EpicOrchestratorCheckpointContent`, and `Get-ParallelOrchestratorCheckpointContent` are mocked in every Claude decision case. `Test-StandaloneCheckpointAllowsMerge` is mocked to throw in the branch-order case. |
| **Environment Stability** | PASS | No temporary files. `Invoke-PowerShellTestPurityDecision` returned no denial for all three files. A pattern scan for temporary-file APIs, `TestDrive`, `Mock gh`, `Mock git`, `Start-Sleep`, web cmdlets, `Get-Date`, `Set-Content`, `Out-File`, and `Start-Process` found 0 matches in each new file. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the policy review for the branch. The one carry-forward item (follow-up deferral text in the PR description) is listed in Section 8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` and `spec.md` (issue #670, epic F3), including RULING 1 and the closed anti-patterns. |
| **Read existing change plans** | PASS | `plan.2026-09-13T20-46.md`; `evidence/baseline/phase0-instructions-read.2026-09-13T20-46.md` lists the seven policy files read. |
| **Document the plan** | PASS | Approved plan with phase-by-phase check-offs; nine commits map to plan phases. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Branch 4 is a single guarded call block in each hook. Record validation is a flat, ordered sequence of checks. |
| **Reusability** | PASS | Reuses the existing read seams, `ConvertFrom-EpicMergeGateJson`, the existing PR-number extractor, and `Get-ClaudeHookEnvelopeValue`. No new read seam. |
| **Extensibility** | PASS | Additive, key-gated checkpoint block. Reason codes are declared once each. |
| **Separation of concerns** | PASS | Pure predicates live in the helpers file. I/O stays behind the parent hook's existing wrappers. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The helpers file holds only branch-4 logic plus the two envelope factories moved from the parent, per the spec's extraction boundary. |
| **Under 500 lines** | PASS | 483, 443, 379 (production); 168, 203, 194 (tests); 483, 443, 379 (mirrors); 177 (`core.json`); 295 and 295 (`.psd1`). Markdown files are exempt. |
| **Public vs internal** | PASS | Script-scoped functions consumed by the parent hook and tests only. |
| **No circular dependencies** | PASS | The parent dot-sources the helpers file. The helpers file dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Test-StandaloneCheckpointAllowsMerge`, `Get-StandaloneAuthorizationBlockState`, and similar; approved verbs only. |
| **Docs/docstrings** | PASS | Comment-based help on every new function. The header states the split rationale and the disclosure. |
| **Comment why, not what** | PASS | Examples: the unary-comma comment on array unrolling, the reason-code single-declaration comment, and the branch-4 ordering comment. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Command: `Invoke-Formatter -ScriptDefinition <LF-normalized content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (check-only, in memory). Result: 6/6 already formatted. Executor: `Invoke-PoshQCFormat` reported 177/177 already formatted with equal before-and-after hashes. |
| **2. Linting** | PASS | Command: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`. Result: 0 diagnostics on each of 6 files. |
| **3. Type checking** | N/A | Not applicable to PowerShell. |
| **4. Architecture and contract checks** | PASS | `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_poshqc_bundled_parity.py`: 17/17 in the clean export. In the review worktree, 16/17 pass; the one failure is the issue #510 gitignored `.claude/state/` node. `codex-epic-runtime-contracts.Tests.ps1`: 10/10. |
| **5. Testing** | PASS | Targeted: 434/434. Whole tree (executor): 4627 tests with 2 failures, both reproduced as dependent on the live gitignored checkpoint and green in the clean export. |
| **Full toolchain loop** | PASS | Executor loop pass 2 had no auto-fix. Pass 1 restarted after 6 analyzer diagnostics, which were fixed. This review re-verified every stage on the committed tree without any stage rewriting a file. |
| **Explicit reporting** | PASS | Commands and results are recorded here, in Appendix B, and in `evidence/qa-gates/review-clean-state-verification.2026-09-17T09-12.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages per phase; Section 9 below. |
| **Design choices explained** | PASS | The spec records designs (i)+(ii) adopted and (iii)-(v) rejected or blocked, and the asymmetric extract-versus-in-place rationale. |
| **Update supporting documents** | PASS | `.claude/rules/orchestrator-state.md` gains a new section and an Enforcement bullet. `.claude/skills/parallel-orchestrate/SKILL.md` gains the writer procedure. Both mirrors match. |
| **Provide next steps** | PASS | FU-1 to FU-4 deferral paragraph prepared in `evidence/issue-updates/ac-status-and-followups.2026-09-13T20-46.md` for the PR description. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | Check-only run: 6/6 already formatted; files use LF line endings (0 CRLF). |
| **Linting with PSScriptAnalyzer** | PASS | 0 diagnostics on 6 files (Phase 0 baseline for the two modified hooks was 0). |
| **Fix all findings** | PASS | Pass-1 findings (`PSUseShouldProcessForStateChangingFunctions` on 4 builders; `PSUseOutputTypeCorrectly` on 2 field readers) were fixed by renaming to `Get-*` and declaring `[OutputType([object], [object[]])]`. No suppressions were added. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | Hooks declare PowerShell 7+ (existing header). Tests carry `#Requires -Version 7.0`. Verified under 7.6.6 with Pester 5.6.1 and PSScriptAnalyzer 1.25.0. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `[CmdletBinding()]` and `[OutputType()]` on every new production function. |
| **Parameter validation** | PASS | `[Parameter(Mandatory)]`, `[AllowNull()]`, `[AllowEmptyString()]`, `[AllowEmptyCollection()]`, and typed `[int]` PR numbers. |
| **Avoid global state** | PASS | Only `$script:` constants (reason codes, key, guidance text). |
| **Error handling** | PASS | Claude side stays non-throwing and fails closed through deny envelopes. Codex keeps its exit-2 throw channel unchanged. A blank envelope `session_id` fails closed. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | See Section 2.3. |
| **Approved verbs** | PASS | `Get-`, `Test-`, `Invoke-` only. |
| **Comment why** | PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | Clean (check-only). |
| **Step 2: Analyze** | PASS | 0 diagnostics. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | 434/434 targeted; 227/227 in the clean export. |
| **Rerun loop if needed** | PASS | Executor needed 2 passes (one analyzer restart). |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | PASS | One line inserted in sorted position in `core.json`, matching existing two-space indentation. |
| **Schema validation** | PASS | `test_push_down_claude_pack_manifest_completeness.py` green. |
| **Required $schema** | N/A | The file's existing `$schema` convention is unchanged; no new JSON file was added. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | No comments or trailing commas were introduced. |
| **Deterministic key order** | PASS | Path array entries remain lexically ordered. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `BeforeAll`, `Describe`/`Context`/`It`, `-ForEach`, `Should -Invoke`, `Mock`. |
| **Use PoshQC Configuration** | PASS | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` gains `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` in `CodeCoverage.Path`, and the coverage report contains the file's `sourcefile` node. |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | `#Requires -Version 7.0`, consistent with the hooks under test. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | Decision-level: 15 (Claude) and 28 (Codex). Predicate-level: 37. |
| **Test Behavior Over Implementation** | PASS | Assertions are on decisions, reason codes, and message field names. The branch-order case asserts non-invocation of branch 4, which is the specified behaviour. |
| **Mocking Used Sparingly** | PASS | Only the three I/O read seams, plus one throwing mock that proves ordering. |
| **Organization** | PASS | Test files: `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1`. Code files: `.claude/hooks/enforce-epic-merge-gate*.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`. This follows the established `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/` mirror layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | All three end in `.Tests.ps1`, following the sibling split convention (`<hook>.<Topic>.Tests.ps1`). |
| **Describe/Context/It Structure** | PASS | 3 Describe blocks; 3, 4, and 4 Contexts; 80 expanded cases. |
| **Logical Grouping** | PASS | Grouped by decision matrix, reason text and order, matcher, block shapes, field shapes, session binding, checkpoint verdicts, and parity. |
| **Docstrings/Comments** | PASS | Header blocks plus comment help on local builders. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | Executor: `Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('scripts','tests/scripts')` (`tests/powershell` dropped because the folder does not exist; the executed test set is identical). Review: `Invoke-Pester` with an explicit suite list for targeted re-verification. |
| **No Alternative Test Runners** | PASS | Pester only. |

---

## 5. Test Coverage Detail

### Test-StandaloneCheckpointAllowsMerge and Get-StandaloneAuthorizationBlockState (18 predicate cases plus 15 decision cases)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| rejects <Name> as not PR specific (13 rows) | Negative | helpers 331-370, 409-415, 438-442 | PASS |
| reports <Expected> for <Name> (5 rows) | Negative / Edge Case | helpers 409-442 | PASS |
| allows a valid record held in any checkpoint slot | Positive | helpers 418-426 | PASS |
| decides <Expected> for <Name> (11 rows, Claude) | Positive / Negative | parent 418-427; helpers 372-443 | PASS |

**Coverage:** 100% of the helpers file (100/100 executable lines).

### Test-StandaloneMergeAuthorizationRecord and field helpers (19 cases)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| names <Field> when <Name> (8 rows) | Negative | helpers 299-322 | PASS |
| names pr_url first when both pr_url and basis fail | Edge Case | helpers 299-304 | PASS |
| accepts a well-formed record (with and without run_slug) | Positive | helpers 299-329 | PASS |
| accepts a non-ISO parseable authorized_at; rejects a non-string one | Edge Case | helpers 217-247 | PASS |
| names session_id when <Name> (4 rows) | Negative | helpers 323-328 | PASS |
| selects the entry for the requested PR | Positive / Negative | helpers 153-193 | PASS |

**Coverage:** 100%.

### Invoke-EpicMergeGateDecision branch 4 and matcher (4 cases)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| denies an explicit PR with no record using both tokens | Negative | parent 420-426 | PASS |
| keeps the existing fall-through text for a bare merge | Edge Case | parent 420, 429 | PASS |
| allows parallel item 501 through branch 3 first | Positive | parent 413-415 | PASS |
| extracts the same numbers for the six existing spellings | Regression | parent 146-190 | PASS |

**Coverage:** parent 96.67%; uncovered 478, 479, 480, 483 (process entry-point tail, pre-existing).

### Codex standalone branch (28 cases)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| decides <Expected> for <Name> (10 rows) | Positive / Negative / Regression | Codex 122-182, 289-358 | PASS |
| reason text and throw channel (4 cases) | Negative / Error Handling | Codex 22-40, 131, 166-190 | PASS |
| record shape counterparts (13 cases) | Negative / Edge Case | Codex 193-358 | PASS |
| spells the four reason codes identically | Regression | source text | PASS |

**Coverage:** Codex hook 99.34%; uncovered line 373 (entry-point tail).

**Not covered:** only the pre-existing entry-point tails listed above.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (new) | 80 | PASS |
| Tests Passed (targeted review run) | 434 (100%) | PASS |
| Tests Failed (targeted review run) | 0 | PASS |
| Whole-tree run (executor) | 4627 tests, 2 failed, 0 errors, 9 skipped | PASS (both failures environmental; 0 in clean export) |
| Clean-export run (review) | 227 passed, 0 failed | PASS |
| Functions Tested (helpers file) | 12/12 (100%) | PASS |
| Test File Size | 168 / 203 / 194 lines | PASS |
| Code Coverage | 95.56% lines repo-wide; branch coverage not measured (PowerShell exemption) | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | check-only `Invoke-Formatter` with `pssa.settings.psd1` | 6/6 already formatted | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 diagnostics x 6 files | PASS |
| Pester Tests | `Invoke-Pester` (17 suites) | 434 passed, 0 failed | PASS |
| Test purity | `Invoke-PowerShellTestPurityDecision` x 3 | no denial | PASS |
| No Python in hooks | `enforcement-hooks-no-python-invocation.Tests.ps1` | 27 passed | PASS |

**For Python (contract tests only; no Python files changed):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Push-down contracts (worktree) | `poetry run pytest <three files> -q` | 16 passed, 1 failed (issue #510 `.claude/state/` node) | PASS (environmental) |
| Push-down contracts (clean export) | `python -m pytest <three files> -q` | 17 passed | PASS |

**Notes:**
Pre-existing, environment-only failures unrelated to this change: (1) `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:145` and (2) `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:165`. Both read the live gitignored `artifacts/orchestration/orchestrator-state.json`. Also (3) issue #510, where the resource-contract test enumerates the gitignored `.claude/state/`. All three pass when that state is absent. Items (1) and (2) are a determinism defect in pre-existing suites and are recorded as a follow-up recommendation, not as a finding against this branch.

---

## 8. Gaps and Exceptions

### Identified Gaps

- `spec.md` acceptance criterion "Follow-ups FU-1 through FU-4 are filed as issues, or their deferral is explicitly recorded in the pull-request description, before this feature is closed" cannot be evaluated before the pull request exists. The deferral paragraph is prepared verbatim in `evidence/issue-updates/ac-status-and-followups.2026-09-13T20-46.md`. The PR author must carry it into the PR description. This is a hand-off item, not a code or policy defect.
- Pre-existing test-determinism defect (outside this branch): two suites read live gitignored orchestration state. A follow-up issue is recommended.

### Approved Exceptions

- Evidence path: `spec.md` names `evidence/coverage/`. The executor used `evidence/qa-gates/` and recorded the rejection under the non-overridable evidence-location rule.
- Scan-folder substitution: `tests/powershell` does not exist, so it was dropped from `-ScanFolders`. The executed test set is identical (recorded in `phase0-pester-coverage`).

### Removed/Skipped Tests

**None.** All planned tests were implemented. No existing test was edited or removed (`git diff --stat` over `tests/` lists only the three added files).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **cf7b6b32** - feat(hooks): capture phase 0 policy reads and pre-change baselines (#670)
2. **540c915c** - feat(hooks): extract merge-gate envelope factories and register coverage (#670)
3. **7e8df63d** - feat(hooks): add fail-first standalone merge authorization suites (#670)
4. **0cac59d6** - feat(hooks): add standalone merge authorization predicates (#670)
5. **fadfaa87** - feat(hooks): wire standalone merge authorization into the Claude gate (#670)
6. **4b2ea8b7** - feat(hooks): add Codex standalone merge authorization branch (#670)
7. **cb77cf96** - feat(hooks): document standalone merge authorization and sync mirrors (#670)
8. **26cf6094** - feat(hooks): record coverage comparison and bounded change set (#670)
9. **332ab835** - feat(hooks): clear analyzer findings and record final QC loop (#670)

### Files Modified

1. **`.claude/hooks/enforce-epic-merge-gate-authorization.ps1`** (NEW): branch-4 predicates, four reason-code constants, honest disclosure, and the two envelope factories moved from the parent.
2. **`.claude/hooks/enforce-epic-merge-gate.ps1`** (MODIFIED): header rewritten to four conditions plus the squash scope note; `.NOTES` disclosure; dot-source of the helpers file; branch-4 call block; factories removed. `Get-EpicMergeGateCommandPrNumber` and the three checkpoint path assignments are unchanged.
3. **`.codex/hooks/enforce-epic-merge-gate.ps1`** (MODIFIED): in-place standalone branch reading the child and epic checkpoints; four reason-code constants; no parallel path.
4. **Three new Pester suites** (NEW): see Appendix A.
5. **`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`** and bundled copy (MODIFIED): coverage entry for the helpers file.
6. **`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`** (MODIFIED): helpers-file path.
7. **`.claude/rules/orchestrator-state.md`** (MODIFIED): new key-gated section, nine invariants, disclosure, Enforcement bullet naming FU-3.
8. **`.claude/skills/parallel-orchestrate/SKILL.md`** (MODIFIED): four allow conditions and the writer procedure.
9. **Five bundled mirrors** (NEW/MODIFIED): byte-identical to their sources (SHA-256 verified).
10. **`spec.md`, `plan.2026-09-13T20-46.md`, and 40 evidence files** (MODIFIED/NEW): check-offs and execution evidence.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All policy requirements evaluated for the branch diff are met. Coverage is at or above threshold for every changed PowerShell production file, with no regression on changed lines. The toolchain is clean on the committed tree. Evidence locations are canonical. The only open item is the PR-description hand-off for follow-ups FU-1 through FU-4.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: spec, rulings, and plan present.
- PASS Design Principles: additive, key-gated, no new seam.
- PASS Module & File Structure: largest file 483 lines.
- PASS Naming, Docs, Comments: approved verbs, comment help.
- PASS Toolchain Execution: format, lint, contracts, and tests clean on the committed tree.
- PASS Summarize & Document: rules and skill documentation updated and mirrored.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 434/434 targeted tests passing; 227/227 in the clean export
- PASS 12/12 helpers-file functions exercised
- PASS 95.56% line coverage repo-wide (PowerShell); 100.00% on changed executable lines
- PASS Test files mirror the established `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/` layout
- PASS Format and lint clean
- PASS 80 new tests run in well under a minute

---

### Recommendation

**Ready for merge**, subject to the normal PR-authoring step: the PR description must include the FU-1 through FU-4 deferral paragraph from `evidence/issue-updates/ac-status-and-followups.2026-09-13T20-46.md`. CI for this epic-child PR should also be confirmed green on the PR head before merge.

---

## Appendix A: Test Inventory

### Complete Test List

1. enforce-epic-merge-gate.ps1 standalone authorization (issue #670) › decision matrix › decides <Expected> for <Name> (11 rows: record in per-feature, epic, and parallel checkpoints; record naming 777 only; no key; blanket true; session differs; session absent; discriminator 777; paired positive 501; squash with record)
2. enforce-epic-merge-gate.ps1 standalone authorization (issue #670) › reason text and branch order › denies an explicit PR with no record using both the gate token and the absent code
3. enforce-epic-merge-gate.ps1 standalone authorization (issue #670) › reason text and branch order › keeps the existing fall-through text for a bare merge even with a valid record present
4. enforce-epic-merge-gate.ps1 standalone authorization (issue #670) › reason text and branch order › allows parallel item 501 through branch 3 before the standalone branch is consulted
5. enforce-epic-merge-gate.ps1 standalone authorization (issue #670) › the pr_number matcher is unchanged › extracts the same numbers for the six existing spellings
6. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › blocks that are not PR specific › rejects <Name> as not PR specific (13 rows)
7. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › field shape failures on the matched record › names <Field> when <Name> (8 rows)
8. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › field shape failures on the matched record › names pr_url first when both pr_url and basis fail
9. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › valid records and session binding › accepts a well-formed record whose session matches
10. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › valid records and session binding › accepts a well-formed record that omits the optional run_slug
11. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › valid records and session binding › accepts an authorized_at value that is not an ISO date-time but still parses
12. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › valid records and session binding › rejects a non-string authorized_at value
13. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › valid records and session binding › names session_id when <Name> (4 rows)
14. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › valid records and session binding › selects the entry for the requested PR and returns nothing for another PR
15. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › checkpoint-level verdicts › reports <Expected> for <Name> (5 rows)
16. enforce-epic-merge-gate-authorization.ps1 predicates (issue #670) › checkpoint-level verdicts › allows a valid record held in any checkpoint slot
17. Codex enforce-epic-merge-gate standalone authorization (issue #670) › decision matrix › decides <Expected> for <Name> (10 rows)
18. Codex enforce-epic-merge-gate standalone authorization (issue #670) › reason text and the throw channel › denies an explicit PR with no record using both the gate token and the absent code
19. Codex enforce-epic-merge-gate standalone authorization (issue #670) › reason text and the throw channel › keeps the existing deny text for a bare merge even with a valid record present
20. Codex enforce-epic-merge-gate standalone authorization (issue #670) › reason text and the throw channel › still raises through the throw channel for <Name> (2 rows)
21. Codex enforce-epic-merge-gate standalone authorization (issue #670) › record shape counterparts › denies a non-PR-specific block when <Name> (5 rows)
22. Codex enforce-epic-merge-gate standalone authorization (issue #670) › record shape counterparts › denies a malformed record naming <Field> when <Name> (7 rows)
23. Codex enforce-epic-merge-gate standalone authorization (issue #670) › record shape counterparts › allows a record whose authorized_at is a parseable non-ISO date-time
24. Codex enforce-epic-merge-gate standalone authorization (issue #670) › reason-code spelling parity › spells the four reason codes identically in the Claude helpers file and the Codex hook

---

## Appendix B: Toolchain Commands Reference

All commands were run by this review against `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a51b6017c8cb9c138` unless noted. PowerShell commands ran through `pwsh -NoProfile -File <scratchpad script>` because the worktree isolation guard refuses direct `pwsh` command text.

```bash
# Scope
git diff --stat origin/epic/worktree-scoped-state-resolution-integration...HEAD
git diff --name-status origin/epic/worktree-scoped-state-resolution-integration...HEAD
git diff origin/epic/worktree-scoped-state-resolution-integration...HEAD -- .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1
git diff --stat origin/epic/worktree-scoped-state-resolution-integration...HEAD -- tests/ .claude/settings.json '.claude/hooks/enforce-orchestration-preimplementation-gate*' '.codex/hooks/enforce-orchestration-preimplementation-gate*'
git diff --name-only origin/epic/worktree-scoped-state-resolution-integration...HEAD -- artifacts .github scripts/benchmarks

# Evidence locations and ignore status
poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
git check-ignore -v .claude/state/powershell-batch-budget.worktree-agent-a51b6017c8cb9c138-ac477202.json

# Python contract tests (worktree, then clean export)
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q -p no:cacheprovider
git archive --format=tar -o <scratchpad>/h2.tar HEAD -- .agents .claude .codex .github scripts tests extensions/drm-copilot AGENTS.md CLAUDE.md pyproject.toml poetry.lock
git archive --format=tar -o <scratchpad>/h3.tar HEAD -- config
```

```powershell
# Formatting (check-only, no write)
$normalized = (Get-Content -Raw -LiteralPath $f) -replace "`r?`n", "`n"
(Invoke-Formatter -ScriptDefinition $normalized -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1) -ne $normalized

# Linting
@(Invoke-ScriptAnalyzer -Path $f -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1).Count

# Testing (targeted, 17 suites; and 10 suites in the clean export)
$cfg = New-PesterConfiguration; $cfg.Run.Path = $suites; $cfg.Run.PassThru = $true; Invoke-Pester -Configuration $cfg

# Coverage (parse existing artifact; not regenerated)
[xml]$x = Get-Content -Raw -LiteralPath artifacts/pester/powershell-coverage.xml
[xml]$j = Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; $j.SelectNodes('//testcase[failure or error]')

# Mirrors, line counts, tokens, purity
(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $mirror -Algorithm SHA256).Hash
@(Get-Content -LiteralPath $f).Count
[regex]::Matches((Get-Content -Raw -LiteralPath .codex/hooks/enforce-epic-merge-gate.ps1), 'route_id|items|parallel').Count
. ./.claude/hooks/check-powershell-test-purity.ps1; Invoke-PowerShellTestPurityDecision -ToolInputRaw $envelope
```

Executor commands of record: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat|Invoke-PoshQCAnalyze|Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders ...` (see `evidence/qa-gates/p8-*.2026-09-13T20-46.md`).

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-17
**Policy Version:** Current (as of audit date)
