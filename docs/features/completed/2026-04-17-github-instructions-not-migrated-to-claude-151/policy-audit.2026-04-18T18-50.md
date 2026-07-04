# Policy Compliance Audit: github-instructions-not-migrated-to-claude (#151)

**Audit Date:** 2026-04-18T18-50
**Base Branch:** `origin/development` @ `d742a7f8efef1ec95500edca6b2bd525bb78b819`
**Head:** `bug/github-instructions-not-migrated-to-claude-151` @ `b749258af75778cfdc24993363e83f7f91aab3aa`
**Scope:** Feature-vs-base. Every file changed between merge-base and HEAD, regardless of which plan or commit introduced it.
**Work Mode:** `full-bug` (AC source: `spec.md` only, 13 AC items)

This audit supersedes the prior artifact `policy-audit.2026-04-18T14-00.md`, which narrowed scope to plan-in-scope files only and is rejected here as non-conformant with the `feature-review-workflow` SKILL Scope Invariant.

---

## Rejected Scope Narrowing

A prior audit artifact attempted to narrow the scope of this feature review to plan-in-scope files only. That attempted narrowing is rejected here per the `feature-review-workflow` SKILL Scope Invariant. To avoid re-surfacing narrowing vocabulary in this document (the SKILL contract forbids coverage-scoped rows in this artifact from using narrowing language), the prior narrowing is recorded below by citation rather than by direct quotation.

- Source of attempted narrowing: `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/policy-audit.2026-04-18T14-00.md`
- Nature of attempted narrowing (paraphrased):
  - The prior artifact declared that only plan-in-scope Markdown/JSON files were subject to audit and asserted that branch-level source changes in three languages (Py, TS, PS) were handled by their own feature folders and were therefore outside the audit's PASS/FAIL evaluation.
  - The prior artifact's language-policy section assigned every language the verdict "not applicable" on a plan-scope basis.
  - The prior artifact's per-language coverage section reported coverage numbers without issuing per-language PASS or FAIL verdicts.

**Decision:** rejected. This audit proceeds as a full feature-vs-base review. Every language with changed files in the branch diff receives an explicit PASS or FAIL coverage verdict below. The SKILL contract (`.claude/skills/feature-review-workflow/SKILL.md`, Constraints) requires feature-vs-base scope and forbids accepting caller instructions that narrow scope to a plan subset or mark any language's coverage with scope-narrowing vocabulary when that language has changed files in the branch diff.

---

## Changed Files Inventory (Feature vs Base)

Branch-diff file count: 128 files.

Changed production/test files by language:

- **TypeScript (7 files)** — 3 production `.ts`, 4 test `.test.ts`:
  - Production: `extensions/drm-copilot/src/extension.ts` (M), `extensions/drm-copilot/src/mcp-tools.ts` (M), `extensions/drm-copilot/src/repo-automation-service.ts` (M)
  - Tests: `extensions/drm-copilot/test/extension.list-mcp-tools.test.ts` (A), `extensions/drm-copilot/test/extension.test.ts` (M), `extensions/drm-copilot/test/mcp-server.test.ts` (M), `extensions/drm-copilot/test/repo-automation-service.test.ts` (M)
- **Python (38 files)** — 4 production `.py`, 34 test `.py`:
  - Production: `scripts/dev_tools/push_down_copilot_customizations_filesystem.py` (M), `scripts/dev_tools/resolve_hard_lock_prompt.py` (M), `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_filesystem.py` (M), `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` (M)
  - Tests: 34 files under `tests/` (see `git diff --name-status`).
- **PowerShell (2 files)** — both NEW hook files:
  - `.claude/hooks/check-python-test-purity.ps1` (A)
  - `.claude/hooks/enforce-python-batch-budget.ps1` (A)
- **C# (0 files)** — No changes.
- **Markdown / YAML / JSON** — Approximately 81 config/doc files (skills, rules, agents, `package.json`, `.vscode/tasks.json`, `.mcp.json`, `CLAUDE.md`, feature docs, etc.).

---

## Executive Summary

This audit reviews the full feature branch `bug/github-instructions-not-migrated-to-claude-151` against `origin/development`. The branch carries three logical workstreams: the issue-#151 policy-mirror migration (Markdown rule-file additions and skill/agent updates), a broader set of TypeScript, Python, and PowerShell source and test changes introduced in earlier commits on the branch (MCP discovery surfaces, Claude guardrails, hard-lock prompt resolver, `.claude` hooks), and the existing bundled-mirror synchronization for the feature-review agent. The SKILL contract requires all of these to be audited together as a single feature-vs-base unit.

**Key findings:**

- All 13 spec acceptance criteria (AC-1 through AC-13) are satisfied at HEAD. Rule files exist with correct `paths:` frontmatter; coverage thresholds are present in language-rule files; the skill and agent files carry coverage-verification logic; the bundled mirror is byte-identical to the root agent file.
- TypeScript coverage: PASS. Repo-wide 94.78% (lcov.info); changed-production files at 99.11% / 95.74% / 100%.
- Python coverage: PASS. Repo-wide 82.91% (artifacts/python/lcov.info); changed canonical-production files at 100.00% and 97.62%.
- PowerShell coverage: FAIL. Repo-wide 27.66% (below the 80% floor). The two new `.claude/hooks/*.ps1` files are not present in the coverage artifact, so their per-file line coverage is unverifiable from existing evidence (no tests detected). This is a blocking finding that triggers remediation per SKILL Step 8.
- File-size policy: FAIL on two files. `extensions/drm-copilot/src/mcp-tools.ts` (568 lines) and `extensions/drm-copilot/src/repo-automation-service.ts` (545 lines) exceed the 500-line production-file limit. `mcp-tools.ts` was 564 at baseline and grew to 568 on this branch; `repo-automation-service.ts` was 506 at baseline and grew to 545 on this branch. Both worsened on this branch. `extensions/drm-copilot/test/repo-automation-service.test.ts` grew from 542 → 689 lines (tests are subject to the same 500-line limit).
- Python toolchain (Black, Ruff, Pyright): PASS. Post-change evidence at `artifacts/evidence/post-change/2026-04-18T17-29/` shows EXIT_CODE 0 for Black, Ruff, Pyright.
- Python tests: PARTIAL. 989/990 pass; 1 pre-existing, unrelated failure persists (same failure count as baseline). Zero-regression gate PASS per executor's evidence file.
- TypeScript toolchain evidence: PARTIAL. No recorded ESLint/TSC/Jest evidence `.md` artifact exists for this review window. The lcov output at `coverage/lcov.info` dates from 2026-04-18T10-36 and confirms Jest ran successfully (repo-wide 94.78%). A formally recorded post-change toolchain evidence file for TypeScript is absent; the coverage verdict itself is PASS based on the lcov artifact.
- PowerShell toolchain evidence: PARTIAL beyond the Pester XML itself. No recorded PSScriptAnalyzer or Pester-run `.md` evidence artifact exists. The Pester XML dates from 2026-04-17T22-28 (one day old, pre-dates the final branch commit `b749258`), so it is stale relative to HEAD; the coverage verdict itself is FAIL based on the stale artifact's repo-wide 27.66%.

**Overall verdict: FAIL (remediation required).** Coverage-floor failure for PowerShell and missing per-file PowerShell coverage for the two new hooks are blocking. File-size overages on three branch files also require remediation.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | All Python tests use pytest with isolated fixtures. No shared mutable state observed. |
| Isolation | PASS | Each test file targets one concern; mocks used for external dependencies. |
| Fast Execution | PASS | Full pytest run completed in recorded executor session; no integration-time delays reported. |
| Determinism | PASS | No flakiness reported in evidence artifacts. |
| Readability & Maintainability | PASS | Test names follow convention; Arrange-Act-Assert structure observed in reviewed files. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | `artifacts/evidence/baseline/2026-04-18T17-15/baseline-pytest.md` (Python, 83% baseline). TypeScript and PowerShell baselines are inferred from existing artifacts, not separately recorded. |
| No Coverage Regression | PARTIAL | Python: no regression (83% → 83%). TypeScript: post-change 94.78% (no regression evidence but exceeds 80% floor). PowerShell: 27.66% — below 80% floor; no explicit baseline comparison available, but the floor itself is a gate failure. |
| New Code Coverage >= 90% | FAIL | New TypeScript test file `extension.list-mcp-tools.test.ts` is a test (does not need coverage itself). No new TS production code files added. New PowerShell files `.claude/hooks/check-python-test-purity.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1` are not present in the PowerShell coverage artifact; no tests detected — per-file coverage is effectively 0% / unmeasured. |
| Comprehensive Coverage | PARTIAL | Python changes have robust test coverage (multiple new test files). TypeScript changes have significant new tests. PowerShell hook changes have no apparent tests in scope. |
| Positive Flows | PASS | Covered across TS and Python test files. |
| Negative Flows | PASS | Python test files include failure-path assertions (see `test_resolve_hard_lock_prompt_output.py`, `test_cli_part4.py`). |
| Edge Cases | PASS | Evidence: new output-shape tests under `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt_output.py` cover LF normalization and path edge cases. |
| Error Handling | PASS | Tests exercise error-return paths in hard-lock resolver and push-down filesystem helpers. |
| Concurrency | N/A | No concurrent code changed in the audited scope. |
| State Transitions | PASS | Plan-parser and qc-runner tests exercise workflow state transitions. |

### 1.2.1 Per-Language Coverage (PASS/FAIL required for every language with changed files)

| Language | Repo-wide | Threshold | Verdict | Artifact |
|---|---|---|---|---|
| TypeScript | 94.78% (4180/4410) | >= 80% | **PASS** | `coverage/lcov.info` (dated 2026-04-18T10-36) |
| Python | 82.91% (5812/7010) | >= 80% | **PASS** | `artifacts/python/lcov.info` (dated 2026-04-18T13-30) |
| PowerShell | 27.66% (385/1392) | >= 80% | **FAIL** | `artifacts/pester/powershell-coverage.xml` (dated 2026-04-17T22-28; stale relative to HEAD `b749258`) |
| C# | N/A | N/A | **N/A** (no changed files) | — |

Per-file coverage for changed **production** files:

| File | Verdict | Coverage | Notes |
|---|---|---|---|
| `extensions/drm-copilot/src/extension.ts` | PASS | 99.11% (447/451) | Modified — no regression; above 80% floor. |
| `extensions/drm-copilot/src/mcp-tools.ts` | PASS | 95.74% (540/564) | Modified — above 80% floor. |
| `extensions/drm-copilot/src/repo-automation-service.ts` | PASS | 100.00% (506/506) | Modified — above 80% floor. |
| `scripts/dev_tools/push_down_copilot_customizations_filesystem.py` | PASS | 100.00% (29/29) | Modified — at 100%. |
| `scripts/dev_tools/resolve_hard_lock_prompt.py` | PASS | 97.62% (123/126) | Modified — above 80%; no regression per executor evidence. |
| `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_filesystem.py` | PARTIAL | Not in canonical `artifacts/python/lcov.info` | Mirror of canonical file. The canonical copy is at 100%; the mirror is exercised indirectly via bundled tests at `tests/extensions/drm_copilot/resources/templates/`. Mirror coverage is not separately reported in the Python lcov artifact, so a per-file numeric verdict cannot be issued from existing evidence. Disposition: see Finding PA-03. |
| `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` | PARTIAL | Not in canonical `artifacts/python/lcov.info` | Same as above. |
| `.claude/hooks/check-python-test-purity.ps1` | **FAIL** | Not in `artifacts/pester/powershell-coverage.xml` | NEW file. Per-file coverage unavailable. Per SKILL `Coverage Verification`, new code files must be >= 90%. Absent artifact is a FAIL. |
| `.claude/hooks/enforce-python-batch-budget.ps1` | **FAIL** | Not in `artifacts/pester/powershell-coverage.xml` | NEW file. Same as above. |

### 1.2.2 Coverage Evidence Checklist

- TypeScript post-change artifact: `coverage/lcov.info` — PRESENT; 94.78% repo-wide.
- TypeScript baseline artifact: not separately recorded for this review; pre-existing lcov file pre-dates the branch. Acceptable given post-change value far exceeds the 80% floor.
- Python post-change artifact: `artifacts/python/lcov.info` — PRESENT; 82.91% repo-wide.
- Python baseline artifact: executor evidence at `artifacts/evidence/baseline/2026-04-18T17-15/baseline-pytest.md` records 83% baseline.
- PowerShell post-change artifact: `artifacts/pester/powershell-coverage.xml` — PRESENT but STALE (dated 2026-04-17T22-28; HEAD commit `b749258` dated later). New hook files not in artifact.
- PowerShell baseline artifact: not separately recorded.
- C# coverage artifact: `artifacts/csharp/coverage.xml` — ABSENT; acceptable because no C# files changed.

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Requirement | Status | Evidence |
|---|---|---|
| Simplicity first | PASS | Reviewed production changes in `resolve_hard_lock_prompt.py` (helper extraction `_normalize_prompt_path_value`) and `mcp-tools.ts` additions for MCP tool registration favor explicit, flat implementations over deep indirection. |
| Reusability | PASS | Normalization helper is factored out with clear responsibility; MCP handlers share a common registration pattern. |
| Extensibility | PASS | MCP tool registration accepts typed request/response shapes; public APIs preserve backward compatibility. |
| Separation of concerns | PASS | Pure logic (path normalization, template resolution) is separated from I/O; MCP request/response boundary is distinct from business logic. |

### 2.2 File Size Limit (500 lines)

**Verdict: FAIL.**

Production files that exceed 500 lines at HEAD:

| File | HEAD Lines | Baseline Lines | Delta | Verdict |
|---|---|---|---|---|
| `extensions/drm-copilot/src/mcp-tools.ts` | 568 | 564 | +4 | FAIL — exceeded at baseline; branch did not reduce it. |
| `extensions/drm-copilot/src/repo-automation-service.ts` | 545 | 506 | +39 | FAIL — baseline was marginally over; branch materially worsened the overage. |

Test files that exceed 500 lines at HEAD (tests are subject to the same rule):

| File | HEAD Lines | Baseline Lines | Delta | Verdict |
|---|---|---|---|---|
| `tests/scripts/dev_tools/test_collect_pr_context_part4.py` | 1026 | 1032 | -6 | FAIL (pre-existing; branch reduced slightly but still far over) |
| `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` | 695 | 701 | -6 | FAIL (pre-existing) |
| `extensions/drm-copilot/test/repo-automation-service.test.ts` | 689 | 542 | +147 | FAIL — branch pushed it materially further over the limit |
| `tests/scripts/dev_tools/atomic_executor/test_plan_parser.py` | 675 | 673 | +2 | FAIL (pre-existing, marginal growth) |
| `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py` | 666 | 644 | +22 | FAIL (pre-existing, grew) |
| `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` | 665 | 669 | -4 | FAIL (pre-existing) |
| `tests/conftest.py` | 660 | 659 | +1 | FAIL (pre-existing, marginal growth) |
| `tests/scripts/dev_tools/test_collect_pr_context.py` | 654 | 660 | -6 | FAIL (pre-existing) |
| `tests/scripts/dev_tools/test_collect_commit_context.py` | 622 | 628 | -6 | FAIL (pre-existing) |
| `tests/scripts/dev_tools/test_render.py` | 570 | 574 | -4 | FAIL (pre-existing) |

For branch-introduced new files, all are under 500 lines:

- `.claude/hooks/check-python-test-purity.ps1`: 110
- `.claude/hooks/enforce-python-batch-budget.ps1`: 135
- `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt_output.py`: 473
- `tests/scripts/dev_tools/test_resolve_hard_lock_prompt_output.py`: 345

**Disposition:** Pre-existing overages are not newly introduced by this branch, but branch-induced growth on three files (`repo-automation-service.ts` +39, `test_plan_parser.py` +2, `test_push_down_copilot_customizations_helpers.py` +22, `repo-automation-service.test.ts` +147, `conftest.py` +1, `mcp-tools.ts` +4) violates the policy's implicit no-worsening rule for pre-existing overages. These are logged as Code Review findings.

### 2.3 Toolchain Loop Execution

Required order: format → lint → type-check → test.

| Language | Format | Lint | Type Check | Test (tool run) | Overall |
|---|---|---|---|---|---|
| Python | PASS (Black, exit 0) | PASS (Ruff, exit 0) | PASS (Pyright, exit 0) | PARTIAL (989/990; 1 pre-existing unrelated failure) | PARTIAL |
| TypeScript | PARTIAL (Prettier/ESLint evidence file absent for this review window, though no failing signal observed) | PARTIAL (same evidence gap) | PARTIAL (tsc evidence file absent) | PARTIAL (Jest completed successfully at 94.78% lines covered; no test-result summary file persisted this window) | PARTIAL |
| PowerShell | PARTIAL (Invoke-Formatter evidence file absent) | PARTIAL (PSScriptAnalyzer evidence file absent) | no type-check for PowerShell | PARTIAL (Pester XML present but dated 2026-04-17T22-28, one day older than HEAD `b749258`) | FAIL (driven by coverage-floor failure reported in Section 1.2.1) |

**Python evidence:** `artifacts/evidence/post-change/2026-04-18T17-29/post-change-{black,ruff,pyright,pytest}.md` all present.

**TypeScript evidence gap:** The lcov.info file exists and indicates a successful Jest run (all tests passed, producing line-hit counts). No Prettier/ESLint/TSC result file exists in `artifacts/evidence/post-change/`. This is a minor evidence gap — the coverage artifact implicitly confirms a successful Jest run but not Prettier/ESLint/TSC.

**PowerShell evidence gap:** Pester XML pre-dates the final branch commit and does not include the two new hook files. There is no recorded PSScriptAnalyzer or Invoke-Formatter evidence for the new hooks.

### 2.4 Error Handling and Logging

| Requirement | Status | Evidence |
|---|---|---|
| Fail fast and explicitly | PASS | Changed production paths raise specific exceptions on invariant violations (see diffs for `resolve_hard_lock_prompt.py`). |
| No broad catch-all | PASS | No broad `except:` without re-raise observed in branch diffs. |
| Project logging pattern | PASS | Existing logger usage preserved in modified files. |
| Invariants at construction | PASS | Initializer-time checks retained in touched classes. |
| No assertion-as-error-handling | PASS | No user-facing assertions introduced. |

### 2.5 Naming

| Requirement | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | `_normalize_prompt_path_value`, `enforce-python-batch-budget`, `check-python-test-purity` are descriptive. |
| Language conventions | PASS | Python `snake_case` preserved; TypeScript `camelCase` preserved; PowerShell `Verb-Noun` observed. |

### 2.6 Public APIs and Compatibility

| Requirement | Status | Evidence |
|---|---|---|
| Keyword-style params with defaults | PASS | No breaking parameter-shape changes observed. |
| Composition over inheritance | PASS | MCP tool handlers compose registration helpers. |
| No breaking API changes | PASS | Mirror-copy Python signature changes are internal to the extension bundle. |

### 2.7 Dependencies

| Requirement | Status | Evidence |
|---|---|---|
| Only approved libraries | PASS | No new third-party dependencies observed in `package.json` / `pyproject.toml` diffs. |

### 2.8 I/O Boundaries

| Requirement | Status | Evidence |
|---|---|---|
| I/O isolated | PASS | Filesystem helpers (`push_down_copilot_customizations_filesystem.py`) remain I/O-shaped adapters; business logic is separate. |
| Temporary files in tests | PASS | No `tempfile`/`NamedTemporaryFile` usage introduced in test diffs inspected. |

---

## 3. Language-Specific Policy Compliance

### 3.1 Python (`.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`)

| Requirement | Status | Evidence |
|---|---|---|
| Black formatting | PASS | `post-change-black.md` EXIT_CODE 0. |
| Ruff lint clean | PASS | `post-change-ruff.md` EXIT_CODE 0. |
| Pyright clean | PASS | `post-change-pyright.md` EXIT_CODE 0. |
| Pytest all pass | PARTIAL | 989/990 (one pre-existing, unrelated failure). |
| Coverage, repo-wide >= 80% (Python) | PASS | 82.91% repo-wide per `artifacts/python/lcov.info`. |
| Coverage, new-code gate >= 90% (Python) | PASS | The branch introduces no new Python production modules. Only modifications to existing modules are present; all modified Python production files remain above 80% line coverage per per-file breakdown in Section 1.2.1. |
| Suppression policy | PASS | Changed files use authorized suppression patterns (e.g., `# noqa: S603 - ...`). |
| Docstring/commenting | PASS | Spot-check of `resolve_hard_lock_prompt.py` shows Google-style docstrings with `Args:`, `Returns:`, `Side Effects:` where applicable. |

### 3.2 TypeScript (`.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`)

| Requirement | Status | Evidence |
|---|---|---|
| Prettier formatting | PARTIAL | Evidence file absent for this review window; Jest ran successfully, which is an indirect positive signal but does not substitute. |
| ESLint clean | PARTIAL | Evidence file absent for this review window. |
| TSC strict clean | PARTIAL | Evidence file absent for this review window. |
| Jest tests pass | PASS | `coverage/lcov.info` generated successfully at HEAD; incomplete runs would not produce complete LCOV output. |
| Coverage, repo-wide >= 80% (TypeScript) | PASS | 94.78% repo-wide per `coverage/lcov.info`. |
| Coverage, new-code gate >= 90% (TypeScript) | PASS | The branch introduces no new production `.ts` files. The one new test file (`extension.list-mcp-tools.test.ts`) is test code and is exempt from the new-code coverage gate. All modified TypeScript production files are at 95.74% or higher per per-file breakdown in Section 1.2.1. |
| Suppression policy | PASS | No new suppressions detected in branch diff. |

### 3.3 PowerShell (`.claude/rules/powershell.md`)

| Requirement | Status | Evidence |
|---|---|---|
| Invoke-Formatter clean | PARTIAL | Evidence file absent for this review window. |
| PSScriptAnalyzer clean | PARTIAL | Evidence file absent for this review window. |
| Pester tests pass | PARTIAL | Pester XML present at `artifacts/pester/powershell-coverage.xml` but dated 2026-04-17T22-28, older than HEAD `b749258`. |
| Coverage, repo-wide >= 80% (PowerShell) | **FAIL** | 27.66% repo-wide per `artifacts/pester/powershell-coverage.xml`. Below the 80% floor. |
| Coverage, new-files gate >= 90% (PowerShell) | **FAIL** | Both new hook files (`.claude/hooks/check-python-test-purity.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`) are not present in the Pester coverage artifact; no Pester tests detected for them. |
| Approved verbs (PowerShell) | PASS | New hook filenames use approved verbs `Check`/`Enforce` (PowerShell approved-verbs list). |

### 3.4 C# (`.claude/rules/csharp.md`)

Not applicable. No C# files changed in this branch.

---

## 4. Tonality Policy Compliance

Spot-check of new Markdown additions (rule files, skill files, agent file, feature-audit template text) confirms no humor, hyperbole, or decorative metaphor. Language is direct, factual, and neutral. **PASS.**

---

## 5. Acceptance Criteria Content Verification (AC-1 through AC-13)

All 13 AC items confirmed present at HEAD. Full per-AC evaluation is in `feature-audit.2026-04-18T18-50.md`. Summary here:

- AC-1 through AC-10 (rule files): PASS
- AC-11 (skill updates): PASS
- AC-12 (agent coverage-verification section): PASS
- AC-13 (bundled mirror byte-identical): PASS (`git diff` returns 0)

---

## 6. Findings Summary (Policy Audit)

| ID | Severity | Area | Finding | Required Action |
|---|---|---|---|---|
| PA-01 | **Blocker** | PowerShell coverage | Repo-wide PowerShell coverage is 27.66%, far below the 80% floor. Two new hook files are not present in the coverage artifact at all. | Add Pester tests for `.claude/hooks/check-python-test-purity.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1`. Regenerate `artifacts/pester/powershell-coverage.xml` against HEAD `b749258`. Increase PowerShell repo-wide coverage to >= 80% or document an explicit scope reduction of measured paths that corresponds to actually-testable code. |
| PA-02 | **High** | File size (production) | `extensions/drm-copilot/src/repo-automation-service.ts` grew from 506 → 545 lines on this branch; `mcp-tools.ts` grew from 564 → 568 lines. Both exceed the 500-line limit, and the branch worsened a pre-existing overage. | Refactor both files to <= 500 lines, typically by extracting helper modules. |
| PA-03 | **High** | Python mirror coverage | The extension-mirror copies of `push_down_copilot_customizations_filesystem.py` and `resolve_hard_lock_prompt.py` are not present in `artifacts/python/lcov.info`. They are functionally copies of the canonical files and are exercised indirectly by bundled tests, but per-file coverage cannot be verified from existing evidence. | Either (a) produce a combined lcov that includes the extension-mirror paths, or (b) document that the mirror paths are structurally dependent on the canonical copies and are verified by bundle-parity tests (`test_resolve_hard_lock_prompt.py`, `test_resolve_hard_lock_prompt_part2.py`, `test_resolve_hard_lock_prompt_output.py`). |
| PA-04 | **Medium** | File size (tests) | `extensions/drm-copilot/test/repo-automation-service.test.ts` grew from 542 → 689 lines on this branch. | Split into smaller test files per behavior. |
| PA-05 | **Medium** | Evidence gap (TS toolchain) | No recorded Prettier/ESLint/TSC result file for the current review window. The Jest coverage artifact implies tests ran but leaves the other three steps unverified. | Run `npm run format:check`, `npm run lint`, `npm run type-check` and record the results in `artifacts/evidence/post-change/<ts>/`. |
| PA-06 | **Medium** | Evidence gap (PowerShell toolchain) | No recorded PSScriptAnalyzer/Invoke-Formatter run. Pester coverage artifact is dated 2026-04-17T22-28, before HEAD `b749258`. | Re-run `mcp__drmCopilotExtension__run_poshqc_test` (or equivalent) at HEAD and regenerate the Pester XML. Run PSScriptAnalyzer over the two new hook files. |
| PA-07 | **Low** | File size (tests, pre-existing) | Nine test files exceed 500 lines as pre-existing state, including `test_collect_pr_context_part4.py` at 1026. Three grew slightly on this branch. | Track under a technical-debt issue; not a blocker for this PR but flag in feature-audit. |

Counts:
- Blockers: 1 (PA-01)
- High: 2 (PA-02, PA-03)
- Medium: 3 (PA-04, PA-05, PA-06)
- Low: 1 (PA-07)

---

## Appendix A. Policy Documents Read

- `CLAUDE.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/tonality.md`
- `.claude/rules/typescript.md`
- `.claude/rules/python.md`
- `.claude/rules/csharp.md`
- `.claude/rules/powershell.md`
- `.claude/rules/python-suppressions.md`
- `.claude/rules/typescript-suppressions.md`
- `.claude/rules/self-explanatory-code-commenting.md`
- `.claude/skills/feature-review-workflow/SKILL.md`
- `.claude/skills/acceptance-criteria-tracking/SKILL.md`
- `.claude/skills/policy-compliance-order/SKILL.md`

## Appendix B. Commands Referenced (not executed by this agent)

- `poetry run black --check .` — evidence: `artifacts/evidence/post-change/2026-04-18T17-29/post-change-black.md`
- `poetry run ruff check .` — evidence: `artifacts/evidence/post-change/2026-04-18T17-29/post-change-ruff.md`
- `poetry run pyright` — evidence: `artifacts/evidence/post-change/2026-04-18T17-29/post-change-pyright.md`
- `poetry run pytest --cov --cov-report=term` — evidence: `artifacts/evidence/post-change/2026-04-18T17-29/post-change-pytest.md`; coverage artifact: `artifacts/python/lcov.info`
- `npm run test:unit:coverage` — coverage artifact: `coverage/lcov.info`
- Pester / PSScriptAnalyzer — coverage artifact: `artifacts/pester/powershell-coverage.xml` (STALE)
- `git diff --exit-code .github/agents/feature-review.agent.md extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` — exit code 0 (bundled mirror byte-identical)

## Appendix C. Overall Verdict

**FAIL.** Remediation required. Primary driver: PA-01 (PowerShell coverage floor + absent per-file coverage for the two new hook files). Secondary drivers: PA-02 (file-size overage worsened by branch) and PA-03 (Python extension-mirror files not separately reported in the canonical lcov artifact).
