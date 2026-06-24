# Policy Compliance Audit: require-pr-author-agent-for-prs (Issue #231)

**Audit Date:** 2026-06-24
**Feature Folder:** `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231`
**Base Branch:** `main`
**Merge-base SHA:** `258aa903542346cc534c03da39e4b938223c1f2d`
**Branch head SHA:** `0beb721d21c86ed944cc1090bae5085f595ea936`
**Work Mode:** full-feature (AC sources: `spec.md`, `user-story.md`)
**Code Under Test:**
- `.claude/hooks/enforce-pr-author-skill.ps1` (modified, +143/-2)
- `.claude/hooks/validate-pr-author-output.ps1` (new, +136)
- `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (modified, +178)
- `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1` (new, +122)
- `.claude/agents/pr-author.md` (new)
- `.claude/agents/orchestrator.md` (modified)
- `.claude/settings.json` (modified)
- `.claude/skills/orchestrate/SKILL.md` (modified)
- Bundled Claude mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/**` (all)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` (new)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author.toml` (modified)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` (modified)
- `extensions/drm-copilot/resources/customizations/.github/agents/pr-author.agent.md` (modified)
- Feature scoping/evidence docs and `coverage.xml` (generated artifact)

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | New/Modified Hook Line Coverage | Branch Coverage | Verdict |
|----------|---------------|-------|-------------|---------------------------------|-----------------|---------|
| PowerShell | 5 changed `.ps1` (2 root hooks + 1 Codex translation + 2 test files); plus 4 bundled mirrors | 56 in-scope (41 enforce + 15 validate); full repo 288 | PASS — 56/56, 0 fail (reviewer rerun) | enforce 92.05% command / 93.15% JaCoCo line; validate 86.49% command / 84.85% JaCoCo line | Not separately reported by Pester (command/line only) | PASS (see note 5.2) |
| Markdown / TOML / JSON (agents, skills, settings, prompts, config) | agents, settings.json, orchestrate SKILL, codex toml/config, copilot agent.md | N/A | PASS — structural + validity review | N/A | N/A | PASS |

## Executive Summary

The reviewed feature is **PARTIALLY COMPLIANT / Needs revision**. The core implementation is present and well structured: the new `pr-author` agent, the strengthened PreToolUse hook (Cases D/E/F and malformed), the new SubagentStop validator, settings/orchestrate wiring, and consistent cross-ecosystem copies (Claude root and bundled byte-identical; Codex hook identical to root apart from the required `# Converted hook` header; Codex/Copilot docs equivalent). The PowerShell toolchain is clean on independent rerun (format clean with repo settings, PSScriptAnalyzer 0 findings, 56/56 tests pass), and line/command coverage for both changed hooks meets the 85% line threshold by the command-coverage metric the repository's Pester tooling natively reports. The guardrail-not-cryptographic disclosure is present in all five documentation surfaces, and evidence-location compliance passes (`validate_evidence_locations.py --root .` exit 0).

One Blocking correctness gap was identified. Acceptance Criterion AC3 and spec FR-2 step 4 / FR-4 state that inline `--body` on `gh pr edit` "remains blocked by Case A." The implementation blocks inline `--body` only on `gh pr create`; `gh pr edit --body "inline text"` returns **allow**. This is a pre-existing condition (the baseline hook already scoped the Case A inline-body block to `isPrCreate` only), but the feature now asserts in spec, AC3, and agent documentation that this path is blocked, and adds no test for it. The result is a documented enforcement path that is bypassable through the exact mechanism (`gh pr edit` with a body) the feature claims to restrict, with no test coverage. This is recorded as a Blocking finding and routed to remediation.

**Policy documents evaluated (reading order):**
- [PASS] `CLAUDE.md`
- [PASS] `.claude/rules/general-code-change.md`
- [PASS] `.claude/rules/general-unit-test.md`
- [PASS] `.claude/rules/powershell.md`
- [PASS] `.claude/rules/quality-tiers.md`
- [PASS] `.claude/rules/tonality.md`
- [PASS] `.claude/rules/ci-workflows.md` (not triggered; no `pwsh` workflow steps changed)

**Temporary artifacts cleanup:**
- [PASS] No temporary implementation scripts were introduced. Reviewer temp scripts were written only under the session scratchpad, not the repo.

## Rejected Scope Narrowing

No caller instruction attempted to narrow scope to a plan subset, a subset of changed files, or to mark any language's coverage as out of scope / informational only. The caller prompt explicitly directed a full branch-diff audit against the merge-base and full toolchain/coverage expectations for every language with changed files. No narrowing to record.

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` exit code: **0** (no violations).
- Diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: **none present** in the branch diff.
- All feature evidence is written under the canonical `<FEATURE>/evidence/<kind>/` tree (`evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`).
- Verdict: **PASS**.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | [PASS] | Pester `It` blocks are self-contained; mocks registered per `Context`/`BeforeEach`. Reviewer rerun of both suites passed without order dependency (56/56). |
| Isolation | [PASS] | Each test targets one decision (Cases A/B/C/D/E/F, malformed, valid, edit-no-body, read-only; six validator scenarios). |
| Fast execution | [PASS] | Combined hook suites complete in seconds in reviewer rerun. |
| Determinism | [PASS] | Clock seam `Get-CurrentDateTimeUtc` and read seam `Get-PrAuthorAuthorizationContent` are mocked; no `Start-Sleep`, no wall-clock reads, no real `gh`. |
| Readability & maintainability | [PASS] | Scenario-named `It` blocks map directly to spec Section 7 matrices. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Positive flows | [PASS] | Valid in-TTL sentinel allow; PR-URL/PR-number allow scenarios. |
| Negative flows | [PASS] | Missing/expired/wrong-issuer/malformed sentinel; empty/malformed/no-PR output. |
| Edge cases | [PASS] | Equals-form inline body, `--title`-only, read-only subcommands, unparseable `issued_at`. |
| Error handling | [PASS] | Malformed `CLAUDE_TOOL_INPUT` throws -> exit 1; malformed `CLAUDE_HOOK_INPUT` -> exit 1. |
| Gap | [PARTIAL] | No test for `gh pr edit --body "inline"` (the AC3 inline-edit-block claim). See Blocking finding F-1. |

### 1.3 No Temporary Files

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temp files created | [PASS] | Sentinel supplied via read seam; real-seam tests repoint `$script:PrAuthorAuthorizationPath` at the hook file itself, creating no files. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | [PASS] | Decision order implemented as a linear function with a single extracted `Test-PrAuthorAuthorization`. |
| Reusability | [PASS] | Injectable seams (`Get-PrAuthorAuthorizationContent`, `Get-CurrentDateTimeUtc`, `Get-PrContextArtifactExistence`) shared between entrypoint and tests. |
| Separation of concerns | [PASS] | Pure decision logic separated from I/O seams and the host entrypoint block. |
| Fail fast / explicit errors | [PASS] | Malformed tool input throws; block reasons are explicit typed strings. |
| File size limit (<500 lines) | [PASS] | enforce hook 332 lines; validate hook 137 lines; both test files under 500. |
| Named constants | [PASS] | TTL is the named `$script:PrAuthorAuthorizationTtlSeconds = 120`. |
| Public API / backward compatibility | [FAIL] | Cases A/B/C and the prior allow path preserved, BUT AC3/FR-4 claim `gh pr edit --body` (inline) is blocked; the implementation allows it. See F-1. |

## 3. Language-Specific Code Change Policy Compliance (PowerShell)

| Requirement | Status | Evidence |
|------------|--------|----------|
| PowerShell 7+ compatibility | [PASS] | `#Requires -Version 7.0`; analyzer settings enforce 7+. |
| Advanced functions / CmdletBinding | [PASS] | All functions use `[CmdletBinding()]`, `[OutputType()]`, named/validated parameters. |
| Approved verbs / singular nouns | [PASS] | `Get-`, `Test-`, `Invoke-`; read seam renamed to singular `Get-PrAuthorAuthorizationContent` (analyzer clean). |
| Design seams (minimal DI) | [PASS] | Adapter seams for clock and filesystem per `.claude/rules/powershell.md` Design Seams section. |
| No Invoke-Expression / secrets / hardcoded creds | [PASS] | None present. |
| Formatting (Invoke-Formatter) | [PASS] | Reviewer rerun with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` produced no substantive change (line-ending normalization only). |
| Linting (PSScriptAnalyzer) | [PASS] | Reviewer rerun: 0 findings across all 5 changed `.ps1` files. |
| Type checking | [N/A] | Not applicable to PowerShell. |

## 4. Language-Specific Unit Test Policy Compliance (PowerShell / Pester)

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5.x | [PASS] | `#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }`. |
| Test file location mirrors source | [PASS] | `tests/scripts/claude-hooks/*.Tests.ps1` (not colocated in source tree). |
| Describe/Context/It, one behavior per It | [PASS] | Verified across both suites. |
| External executable mocking via seam | [PASS] | No direct `gh`/`git` mocks; seams mocked instead. |
| Determinism infrastructure | [PASS] | Clock and read seams injected; no banned timing APIs. |

## 5. Test Coverage Detail

### 5.1 Reviewer-Verified Coverage (independent rerun)

Targeted Pester run over both hook suites with `CodeCoverage.Path` = the two hooks:
- Combined: 113 of 125 commands executed = **90.4%** command coverage; 56/56 tests pass.
- `enforce-pr-author-skill.ps1`: **92.05%** command (81/88) / **93.15%** JaCoCo line (68/73).
- `validate-pr-author-output.ps1`: **86.49%** command (32/37) / **84.85%** JaCoCo line (28/33).
- Uncovered lines in both files are exclusively the host-bound entrypoint blocks (enforce L323-331; validate L129-136), exercised only by end-to-end `pwsh` subprocess tests not attributable to in-process Pester instrumentation.

### 5.2 Threshold Verdict and Branch-Coverage Note

- Line/command coverage: both files exceed the 85% threshold by the command-coverage metric the repository's Pester tooling natively emits (92.05% and 86.49%). **PASS.**
- Note: `validate-pr-author-output.ps1` is 84.85% by the JaCoCo physical-line metric (one tenth of a percent below 85% on that alternate metric); the shortfall is entirely the host-bound entrypoint block. Per the repository's documented PowerShell entry-point-block coverage limitation, the entrypoint is host-bound wiring exercised by subprocess tests; the command-coverage metric is the repository's reporting standard and is met.
- Branch coverage: Pester emits command/line coverage only for PowerShell; the JaCoCo report contains no BRANCH counter for these files. Branch-completeness is established by the asserted scenario matrix (Cases A/B/C/D/E/F, two malformed forms, valid, edit-no-body, read-only; six validator scenarios). **Verdict for the changed-files coverage gate: PASS** on the line metric; branch percentage is not measurable from the available tooling and is substituted by the enumerated scenario matrix.

### 5.3 Repo-Wide PowerShell Coverage Artifact

- The committed `artifacts/pester/powershell-coverage.xml` (and root `coverage.xml`) reflect a different scan folder set (`scripts/dev-tools`, `scripts/powershell`) and do not contain the two PR-author hooks; reviewer regenerated targeted coverage for the in-scope files directly (Section 5.1). The mandatory coverage evidence for the changed PowerShell files is therefore present and verified.

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| In-scope hook tests | 56 (41 enforce + 15 validate) |
| In-scope result | 56 passed, 0 failed, 0 errors (reviewer rerun) |
| Full repository Pester suite (per evidence) | 288 tests, 0 failures |
| PSScriptAnalyzer findings (reviewer) | 0 |
| Format substantive changes (reviewer) | 0 |

## 7. Code Quality Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Cross-ecosystem equality (Claude root vs bundled) | [PASS] | `diff` byte-identical for all 6 paired Claude files. |
| Codex hook translation | [PASS] | Codex hook identical to root except the required `# Converted hook` header (2 lines + blank). |
| Codex/Copilot doc equivalence | [PASS] | `pr-author.toml` and `pr-author.agent.md` carry the sentinel protocol and guardrail disclosure; Copilot stated documentation-only. |
| JSON validity (`settings.json` root + bundled) | [PASS] | Both parse as valid JSON. |
| TOML validity (`config.toml`, `pr-author.toml`) | [PASS] | Both parse as valid TOML; PreToolUse hook wiring present. |
| Guardrail-not-cryptographic disclosure | [PASS] | Present in all 5 documentation surfaces; every `tamper-proof` occurrence is a negation. |
| Settings/orchestrate wiring | [PASS] | `Agent(pr-author)` added to orchestrator tools and settings allow list; SubagentStop matcher `pr-author` registered. |
| Inline-edit-body enforcement | [FAIL] | `gh pr edit --body "inline"` returns allow; contradicts AC3/FR-4. See F-1. |

## 8. Gaps and Exceptions

- **F-1 (Blocking):** `gh pr edit --body "inline text"` is allowed by the hook, contradicting AC3, spec FR-2 step 4, FR-4, and the `pr-author` agent documentation. Pre-existing scope-to-`isPrCreate` condition, not a regression, but the feature now asserts the path is blocked and adds no test. See `code-review.2026-06-24T15-59.md` F-1 and `remediation-inputs.2026-06-24T15-59.md`.
- **Observation (non-blocking):** `validate-pr-author-output.ps1` is 84.85% by the JaCoCo physical-line metric versus 86.49% by command coverage; the difference is the host-bound entrypoint block. Recorded for transparency; not a threshold failure under the repository's reporting standard.
- **Observation (non-blocking):** The repo-wide committed PowerShell coverage XML does not include these hooks; targeted coverage was regenerated by the reviewer.

## 9. Summary of Changes

The branch adds a dedicated `pr-author` agent and an authorization-sentinel enforcement mechanism (PreToolUse Cases D/E/F + malformed, layered on unchanged Cases A/B/C), a SubagentStop output validator, orchestrate/orchestrator delegation wiring, and consistent Claude/Codex/Copilot copies, with tests covering the documented scenario matrix. All toolchain stages applicable to PowerShell pass on independent rerun.

## 10. Compliance Verdict

**PARTIALLY COMPLIANT — remediation required.** Toolchain, coverage, determinism, cross-ecosystem consistency, evidence-location, and guardrail-disclosure checks pass. One Blocking acceptance-criteria/correctness gap (F-1: inline `--body` on `gh pr edit` allowed despite AC3/FR-4 claiming it is blocked) prevents a full PASS. Remediation is triggered.

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — 41 tests: tool-input parsing (3), Case A (2), Case B (2), Case C (2), allowed commands (9), Case D (2), Case E (1), Case F (1), malformed (2), valid (2), helper `Get-PrAuthorBypassReason` (3), helper `Test-PrAuthorBypassRequired` (3), real seams (4), unparseable issued_at (1), real-context block (1), end-to-end (3).
- `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1` — 15 tests: allow (4), block (5), detection helper (3), end-to-end (3).
- Missing: no test for `gh pr edit --body "inline"` (F-1).

## Appendix B: Toolchain Commands Reference

- Diff scope: `git diff --name-status 258aa90..0beb721`
- Cross-ecosystem equality: `diff <root> <bundled>` for each paired file.
- Format (reviewer): `Invoke-Formatter -ScriptDefinition <raw> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (line-ending-normalized compare).
- Lint (reviewer): `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
- Tests + coverage (reviewer): `Invoke-Pester` with `CodeCoverage.Path = [.claude/hooks/enforce-pr-author-skill.ps1, .claude/hooks/validate-pr-author-output.ps1]`, JaCoCo output parsed for per-file line counters.
- Evidence locations: `python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0).
- Executor evidence cross-checked: `evidence/qa-gates/final-format.md`, `final-analyze.md`, `final-pester.md`, `coverage-delta.md`, `guardrail-disclosure-check.md`, `cross-ecosystem-equality.md`, `regression-testing/backward-compat.md`.
