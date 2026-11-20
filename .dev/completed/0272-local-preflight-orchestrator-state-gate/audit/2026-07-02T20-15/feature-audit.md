# Feature Audit: local-preflight-orchestrator-state-gate (#272)

**Audit Date:** 2026-07-02
**Feature Folder:** `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272`
**Base Branch:** `main`
**Head Branch:** `bug/local-preflight-orchestrator-state-gate-272`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main @ 3c5ff3289022abc3b7b16e2441c772e5f81fd9ff`)
- **Head branch/commit:** `bug/local-preflight-orchestrator-state-gate-272 @ baf137f6d672ced9ca338792a1e63540b9a13ed2`
- **Merge base:** `b1b55c3ddbb38c6f49a0e5e9d2c757ca70ae13f7`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/**`
  - Additional evidence: direct `git diff b1b55c3ddbb38c6f49a0e5e9d2c757ca70ae13f7..HEAD`, direct file `diff`s of both bundled hook mirrors, direct parse of `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`, direct run of `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state ... --require-complete` against the real checkpoint.
- **Feature folder used:** `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/`
- **Requirements source:** `spec.md` `## Acceptance Criteria` only. Work mode marker `- Work Mode: full-bug` is explicitly persisted in both `issue.md` and `spec.md`, per `feature-review-workflow`'s work-mode routing (`full-bug` → `spec.md` is the sole AC source; `issue.md`'s own "Proposed Fix / Validation Ideas" checklist is not treated as authoritative AC).
- **Work mode resolution note:** Explicit marker found; no fail-closed normalization was required.
- **Scope note:** Full feature-vs-base diff audited (37 changed files: 5 core PowerShell logic files, 4 deleted workflow files, 4 documentation files, 2 `pester.runsettings.psd1` files, 22 feature-folder docs/evidence files). No caller instruction attempted to narrow this scope; none was accepted.

---

## Acceptance Criteria Inventory

**Authoritative AC source file for this run:**
- `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/spec.md` `## Acceptance Criteria` — only source (work mode `full-bug`).

### Acceptance criteria

1. `.github/workflows/validate-orchestrator-state.yml` and `.github/workflows/_validate-orchestrator-state.yml`, plus their bundled mirrors at `extensions/drm-copilot/resources/codex-and-agents-customizations/.github/workflows/`, are deleted, with no other in-repo workflow file referencing `validate-orchestrator-state`, `_validate-orchestrator-state`, `Validate orchestrator checkpoint`, or `Orchestrator State Gate` (confirm via repository-wide grep after deletion).
2. `enforce-pr-author-skill.ps1` blocks `gh pr create`/`gh pr edit --body*` with reason `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` when `artifacts/orchestration/orchestrator-state.json` is missing, verified by a new Pester test in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` using a mocked `$Invoker` seam.
3. `enforce-pr-author-skill.ps1` blocks with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` when the checkpoint exists but fails `--require-complete`, verified by a corresponding Pester test.
4. `enforce-pr-author-skill.ps1` allows `gh pr create --body-file`/`gh pr edit --body-file` (subject to the existing five receipt checks passing) when the checkpoint exists and passes `--require-complete`, verified by extending the existing `Context 'allowed commands'` tests with a passing preflight mock.
5. The identical hook edit lands byte-for-byte in `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`, verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passing.
6. The equivalent edit lands in `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` with the 3-line `# Converted hook` header preserved and the body otherwise byte-identical to the root hook's new body (with one documented, tool-governed, intentional one-line exception).
7. The orchestrator invokes the orchestrator-state validator before delegating to `Agent(pr-author)` and records the result under a new `pr_author_preflight` field in `artifacts/orchestration/orchestrator-state.json`, matching the field shape in Technical Specifications. (Documentation of this required behavior is complete; the runtime behavior itself is explicitly deferred to a future live orchestrator session, left unchecked by the executor.)
8. `.claude/skills/orchestrate/SKILL.md` (`## PR Authoring (pr-author Handoff)`), `.claude/agents/orchestrator.md` (`## PR Creation Delegation`), and `.claude/agents/pr-author.md` document the local preflight step and the `pr_author_preflight` checkpoint field; no claim that CI enforces the orchestrator-state gate remains in any of these three files or in `CLAUDE.md`.
9. The hook's existing `exit 0` / JSON-`permissionDecision` contract is unchanged for all existing cases (A, B, C, and the five receipt checks); confirmed by all pre-existing Pester tests in `enforce-pr-author-skill.Tests.ps1` continuing to pass unmodified.
10. `enforce-pr-author-skill.ps1` remains under the 500-line file-size cap after the change.
11. Full PowerShell toolchain pass completed (format → analyze → test via PoshQC) with zero errors and no coverage regression (line >= 85%, branch >= 75%) on the changed file.
12. Branch-ruleset non-goal explicitly documented: no change is made to `main`'s `required_status_checks` (confirmed unchanged at 11 entries, none named `Validate orchestrator checkpoint` or `Orchestrator State Gate`).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Workflow files + mirrors deleted, no remaining workflow-file references | PASS | `git diff --name-status` shows 4 `D` entries; zero-match grep. | `git diff --name-status b1b55c3...HEAD -- .github/workflows _validate...` / `grep -rn "validate-orchestrator-state\|_validate-orchestrator-state\|Validate orchestrator checkpoint\|Orchestrator State Gate" --include="*.yml" .` | AC is scoped to "workflow file" and passes as literally worded. Two non-workflow Markdown files (`README.md`, `.agents/skills/orchestrate/SKILL.md`) still reference the deleted gate — out of this AC's literal scope but flagged in code-review/policy-audit as a Major finding. |
| 2 | Blocks with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` when checkpoint missing (mocked test) | PASS | `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` `It 'blocks gh pr create --body-file when the checkpoint is missing'`; `artifacts/pester/pester-junit.xml` confirms this test name executed and passed. | Direct file read; `grep -o 'tests="[0-9]*"' artifacts/pester/pester-junit.xml` | — |
| 3 | Blocks with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` when `--require-complete` fails (mocked test) | PASS | Same file, `It 'blocks gh pr create --body-file with the summarized output when --require-complete fails'`. | Direct file read; junit confirmation. | — |
| 4 | Allows `--body-file` when preflight passes (subject to 5 receipt checks) | PASS | `enforce-pr-author-skill.Tests.ps1` `Context 'allowed commands'` `BeforeEach` extended with `Mock -CommandName Invoke-OrchestratorStatePreflight -MockWith { @{ HasErrors = $false; ErrorText = '' } }`, confirmed via diff. | `git diff ... -- tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | — |
| 5 | Byte-identical `.claude` mirror | PASS | `diff .claude/hooks/enforce-pr-author-skill.ps1 extensions/.../claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` → zero differences (independently run by this audit). | `diff` (exit 0, no output) | Stronger evidence than the cited pytest reference: this audit directly diffed the two files byte-for-byte. |
| 6 | Codex mirror header preserved, body byte-identical (documented one-line exception) | PASS | `diff <(tail -n +4 codex-mirror) .claude/hooks/enforce-pr-author-skill.ps1` → exactly one line differs (`.claude/hooks/validate-orchestrator-output.ps1` → `.codex/hooks/validate-orchestrator-output.ps1` inside a docstring cross-reference), matching the documented, tool-governed exception in `evidence/other/implementation-deviations.md` #5. | `diff` (independently run by this audit) | Header confirmed intact (`# Converted hook` / `# Review the generated hook behavior before enabling it.` / blank line). |
| 7 | Orchestrator invokes validator + records `pr_author_preflight` before delegation | PARTIAL | Documentation is complete and correct in `orchestrate/SKILL.md` (mandatory sequence step 2) and `orchestrator.md` (`## PR Creation Delegation`), confirmed by diff. Runtime execution is explicitly out of scope for this implementation delegation and has not occurred. | `git diff ... -- .claude/skills/orchestrate/SKILL.md .claude/agents/orchestrator.md` | Correctly left unchecked in `spec.md` by the executor, with an inline explanation. This audit concurs with PARTIAL, not FAIL — the mechanism is fully specified and ready for a live orchestrator session to exercise; only the one-time runtime execution artifact is missing, by explicit, documented design. |
| 8 | 3 named files + `CLAUDE.md` document the mechanism; no CI-enforcement claim in those 4 files | PASS | Diff confirms additive documentation in all 4 files; direct grep of all 4 files for `CI` + `orchestrator-state`/`checkpoint` context confirms no incorrect CI-enforcement claim remains in any of them. | `git diff ... -- .claude/agents/orchestrator.md .claude/agents/pr-author.md .claude/skills/orchestrate/SKILL.md CLAUDE.md` | Two files **outside** this AC's 4-file scope (`README.md`, `.agents/skills/orchestrate/SKILL.md`) still make the exact claim this AC forbids for the named files — flagged separately in code-review/policy-audit; does not affect this AC's own PASS verdict, which is scoped exactly as written. |
| 9 | Hook's `exit 0`/JSON contract unchanged; all pre-existing tests pass unmodified | PASS | `git diff ... -- tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` shows only additive `Mock` lines inserted, zero existing assertion lines changed or removed; `artifacts/pester/pester-junit.xml` confirms `tests="46"` and `tests="53"` sub-suites both present with 0 failures. | `git diff`; `grep -o 'tests="[0-9]*"' artifacts/pester/pester-junit.xml` | — |
| 10 | `enforce-pr-author-skill.ps1` under 500 lines | PASS | `wc -l .claude/hooks/enforce-pr-author-skill.ps1` → 497. | `wc -l .claude/hooks/enforce-pr-author-skill.ps1` (independently run by this audit) | — |
| 11 | Full toolchain pass, zero errors, no coverage regression (line >=85%, branch >=75%) on changed file | FAIL | Format (`evidence/qa-gates/final-poshqc-format.md`) and analyze (`final-poshqc-analyze.md`) report zero-diff/zero-error; test-pass is independently corroborated (53/53, junit). The coverage-regression sub-clause cannot be corroborated: `artifacts/pester/powershell-coverage.xml` contains no entry for the changed file and reports 0% for every file it does list; no branch-coverage metric is produced by this repo's PowerShell tooling at all (pre-existing, repo-wide limitation). | `mcp__drm-copilot__run_poshqc_test` evidence (feature-provided); this audit's direct parse of `artifacts/pester/powershell-coverage.xml` | `spec.md` currently marks this criterion `[x]`. This audit's independent evidence-corroboration check does not support that check-off — see Note below and the discrepancy called out in the Summary. |
| 12 | Branch-ruleset non-goal documented; no ruleset file changed | PASS | No ruleset/branch-protection file exists in-repo to modify (confirmed: no such file in the branch diff); `spec.md`'s Scope & Non-Goals documents the independent `gh api` confirmation (11 required checks, none named `Validate orchestrator checkpoint`/`Orchestrator State Gate`). | `git diff --name-only` (no ruleset file present) | Not independently re-verified against live GitHub API by this audit (no `gh`/network access in this review context); accepted on the strength of spec.md's documented prior confirmation and the absence of any ruleset-file diff. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 10 criteria (#1, #2, #3, #4, #5, #6, #8, #9, #10, #12)
- **PARTIAL:** 1 criterion (#7 — documentation complete, runtime execution correctly deferred by design)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion (#11 — coverage-regression sub-clause not corroborated by canonical artifact)

**Top gaps preventing PASS:**

1. AC #11's coverage-regression sub-clause cannot be verified from the canonical `artifacts/pester/powershell-coverage.xml` artifact, which does not contain any data for the changed file. This is the primary blocking gap.
2. `spec.md` currently has AC #11 checked off (`[x]`) despite this audit's independent finding; the check-off should be revisited once corroborating evidence exists (see Acceptance Criteria Check-Off below — this audit does not unilaterally revert the checkbox, consistent with review-only, no-source-mutation scope, but records the discrepancy for the remediation cycle to resolve).
3. AC #7's runtime-execution gap is a documented, by-design deferral (not a defect), but remains open until a live orchestrator session actually populates `pr_author_preflight`.

**Recommended follow-up verification steps:**

1. Regenerate `artifacts/pester/powershell-coverage.xml` via a Pester run that correctly picks up the repo-tracked `pester.runsettings.psd1` `CodeCoverage.Path` addition, then re-run this audit's Section 5 verification against the regenerated artifact.
2. On the next live orchestrator session that delegates PR authoring for this feature, confirm `pr_author_preflight` is recorded in `artifacts/orchestration/orchestrator-state.json` per the documented shape, and check off AC #7 at that time.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules: criteria evaluated as PASS in this audit are already checked `[x]` in `spec.md` (this audit made no new check-offs, since all 10 PASS items were already marked complete by the executor and this audit's evaluation concurs with those check-offs). Criterion #7 (PARTIAL) is correctly left unchecked. Criterion #11 (FAIL per this audit) is currently marked `[x]` in `spec.md` by the executor — **this audit does not revert that checkbox**, consistent with this agent's review-only, no-source-mutation scope, but flags the discrepancy explicitly for the remediation cycle: the checkbox should be reverted to `[ ]` (or the coverage evidence corroborated) before this feature is considered closed.

### AC Status Summary

- Source: `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/spec.md`
- Total AC items: 12
- Checked off in source file (as found): 11 (all except #7)
- This audit's independent PASS count: 10
- This audit's independent PARTIAL/FAIL count: 2 (#7 PARTIAL, #11 FAIL)
- Items remaining per this audit (should not be considered closed): "#7 — orchestrator invokes validator and records `pr_author_preflight` before delegating to `Agent(pr-author)`" (correctly unchecked); "#11 — full PowerShell toolchain pass ... no coverage regression (line >= 85%, branch >= 75%)" (currently checked in `spec.md`, but this audit's coverage-artifact corroboration finding does not support that check-off).

| Source File | Total AC | Checked in file (as found) | This audit's PASS | This audit's PARTIAL/FAIL | Notes |
|-------------|----------|----------------------------|--------------------|----------------------------|-------|
| `spec.md` | 12 | 11 | 10 | 2 (1 PARTIAL, 1 FAIL) | Checkbox-backed; discrepancy on AC #11 flagged for remediation, not corrected directly by this audit. |
