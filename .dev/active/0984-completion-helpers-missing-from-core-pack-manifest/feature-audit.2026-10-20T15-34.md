# Feature Audit: Completion helpers missing from the Claude core pack manifest (#984)

---

**Audit Date:** 2026-10-20
**Feature Folder:** `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984`
**Base Branch:** `main`
**Head Branch:** `bug/completion-helpers-missing-from-core-pack-manifest-984`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `58e5001c5907d74ee24f205690d891b4352fda23`)
- **Head branch/commit:** `bug/completion-helpers-missing-from-core-pack-manifest-984` (commit `a114539915767e4d9f04fe1c8df3b1debb8b11df`)
- **Merge base:** `58e5001c5907d74ee24f205690d891b4352fda23`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-20 15:26:50 UTC for head `a114539915767e4d9f04fe1c8df3b1debb8b11df`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/evidence/**`
  - Additional evidence: reviewer re-runs of Pytest (targeted and full with coverage), Jest (changed file and full with coverage), Black, Ruff, Pyright, Prettier, ESLint, TSC, the Codex generator `--check`, `cmp` mirror parity, and a parse of `artifacts/pester/powershell-coverage.xml`
- **Feature folder used:** `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984`
- **Requirements source:** `spec.md` (authoritative for `full-bug`); `issue.md` `## Acceptance Criteria` evaluated as the traceability mirror of spec AC1 to AC4
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`; `spec.md` is therefore the authoritative AC source.
- **Scope note:** PR context was current for the head SHA and was not regenerated. The full branch diff (109 files) was reviewed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/spec.md` — only authoritative source (full-bug)
- `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/issue.md` — traceability mirror of spec AC1 to AC4 (not authoritative under full-bug; status reported for consistency)

### From spec.md

1. AC1: Claude `core.json` includes `.claude/hooks/enforce-completion-helpers.ps1`, and a fresh push-down into a clean target puts the file in place (proved by completeness tests with empty exceptions, the closure test, and a published-set assertion for the core-only selection). The Codex `core.json` still carries `.codex/hooks/enforce-completion-helpers.ps1`. [issue.md AC1]
2. AC2: A manifest dependency-closure test fails if any manifested hook depends on a sibling or lib file that is missing from the manifest, proven by an in-memory self-test in which a synthetic manifest missing a target is reported as failing; the exhaustiveness guard fails on an unrecognized `$PSScriptRoot` form. [issue.md AC2; FR-4]
3. AC3: With the helper deliberately removed, an `Edit` of a path other than the checkpoint is allowed, and an `Edit` of `artifacts/orchestration/orchestrator-state.json` is still denied with `COMPLETION_CONSISTENCY_BLOCKED:` naming the helper; a `HookPayload.psm1` load failure still denies every call. Proven by the new Pester file in repository and bundle roots. [issue.md AC3; FR-5]
4. AC4: `extensions/drm-copilot/CHANGELOG.md` `## [Unreleased]` has a `### Fixed` entry stating that repositories that received the Claude push-down at 1.1.19, 1.1.20, or 1.1.21 must re-run the Claude push-down, and that the hook no longer denies non-checkpoint edits when the helper is absent. [issue.md AC4; FR-8]
5. AC5: Claude `core.json` also includes `.claude/agents/pr-author.md`, `.claude/hooks/validate-pr-author-output.ps1`, `.claude/hooks/check-python-test-purity.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/check-powershell-test-purity.ps1`, and `.claude/hooks/enforce-powershell-batch-budget.ps1`, and the command-text closure check passes for `.claude/settings.json` and agent frontmatter. [FR-1, FR-4.8]
6. AC6: The grandfathered exception sets in the Python completeness test and its TypeScript twin are empty, and the "remain absent" assertion is replaced by an "exception set is empty" assertion. [FR-3]
7. AC7: `.codex/scripts/post-codex-worktree-session.ps1` is in the Codex core manifest (or the plan records evidence that its exclusion is intentional), and `generate_codex_agent_variants.py --check` passes. [FR-2]
8. AC8: For `enforce-discovery-artifact-gate.ps1`, `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`, and any confirmed Codex counterpart, an out-of-scope path is allowed when only the evaluation-only dependency failed and an in-scope path still fails closed; repository and bundle copies are equal; each hook has a Handler exemption entry; the guard, structural, and exemption suites pass. [FR-6]
9. AC9: The Codex `enforce-completion-consistency.ps1` is unchanged and the rationale is recorded in the plan; mirror parity, the 500-line limit, and the full toolchain pass hold for all changed files. [FR-7, NFR-1, NFR-2]

### From issue.md (traceability mirror)

1. `core.json` includes `.claude/hooks/enforce-completion-helpers.ps1`, and a fresh push-down into a clean target puts the file in place.
2. A manifest completeness test fails if any manifested hook depends on a sibling or lib file that is missing from the manifest.
3. With the helper deliberately removed, an `Edit` of a path other than the checkpoint is allowed, and an `Edit` of `artifacts/orchestration/orchestrator-state.json` is still denied with `COMPLETION_CONSISTENCY_BLOCKED`.
4. Release notes for the next harness version tell downstream repositories that received 1.1.19 to re-run push-down.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1: helper in Claude core; core-only push-down publishes it; Codex core still carries its helper | PASS | Diff adds `.claude/hooks/enforce-completion-helpers.ps1` to Claude `core.json`; `test_core_only_selection_publishes_issue_984_path` (7 rows) and `test_codex_core_selection_publishes_issue_984_path[.codex/hooks/enforce-completion-helpers.ps1]` pass; completeness tests pass with empty exceptions | `poetry run pytest -q -p no:cacheprovider --no-cov tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (58 passed with the other targeted files) | "Fresh push-down" is proven through the authoritative published-set computation (`compute_published_paths`), as the criterion specifies. |
| 2 | AC2: closure test fails on a missing sibling/lib dependency; exhaustiveness guard fails on unrecognized form | PASS | `test_synthetic_manifest_missing_target_is_reported`, `test_unrecognized_psscriptroot_form_fails_exhaustiveness_guard`; fail-before run reported `core: .claude/hooks/enforce-completion-consistency.ps1 -> .claude/hooks/enforce-completion-helpers.ps1` (`evidence/regression-testing/fail-before-python-ts.2026-10-20T13-34.md`) | `poetry run pytest ... tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py` | The real-bundle closure test failed against the unfixed manifest for the expected reason. |
| 3 | AC3: helper removed: non-checkpoint Edit allowed; checkpoint Edit denied naming helper; HookPayload failure denies all | PASS | CH1, CH2 (six path forms), CH3, CH4, CH5 on repository and mirror roots; handler line and in-scope deny in both hook copies (byte-identical) | Executor: `Invoke-PoshQCTest` over `tests/scripts/claude-hooks` (7693 passed, `evidence/qa-gates/ps-tests.2026-10-20T15-00.md`); reviewer: `cmp .claude/hooks/enforce-completion-consistency.ps1 <bundle copy>` | Pester results are from executor evidence; fail-before shows CH1/CH2/CH4/CH6 failing on the unfixed hook. |
| 4 | AC4: CHANGELOG `### Fixed` under `## [Unreleased]` with re-run instruction and hook behavior statement | PASS | `extensions/drm-copilot/CHANGELOG.md`: `### Fixed` follows `## [Unreleased]` and precedes `## [0.0.1]`; names issue #984, 1.1.19/1.1.20/1.1.21, re-run of Claude push-down, and the non-checkpoint allow | `git diff 58e5001c5..HEAD -- extensions/drm-copilot/CHANGELOG.md`; `grep -n '^## ' CHANGELOG.md` | — |
| 5 | AC5: six further Claude core paths; command-text closure passes | PASS | Diff adds all six paths; `test_claude_command_text_closure` passes; fail-before listed the five `settings.json` hooks as missing | `poetry run pytest ... test_push_down_pack_manifest_dependency_closure.py` | Reviewer also confirmed every `.claude/hooks` and `.claude/lib` path in the bundled `settings.json` is in core. |
| 6 | AC6: exception sets empty in Python and TypeScript; "remain absent" replaced by "is empty" | PASS | `PRE_EXISTING_UNRELATED_EXCEPTIONS = frozenset()` and `new Set<string>()`; `test_pre_existing_exception_set_is_empty`; Jest "keeps the pre-existing exception set empty (issue #984)" | `node run-jest.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts` (24 passed) | — |
| 7 | AC7: Codex core carries `post-codex-worktree-session.ps1`; generator `--check` passes | PASS | Codex `core.json` diff; `test_codex_core_selection_publishes_issue_984_path[.codex/scripts/post-codex-worktree-session.ps1]` passes | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` (exit 0) | Decision record documents the search finding no intentional exclusion. |
| 8 | AC8: discovery gate and both batch-budget hooks (Claude and Codex) allow out-of-scope and deny in-scope on dependency failure; mirrors equal; Handler entries; guard/structural/exemption suites pass | PASS | DV, BB, CB rows on both roots (`evidence/regression-testing/pass-after-pester.2026-10-20T13-49.md`, `evidence/qa-gates/ps-tests.2026-10-20T15-00.md`); H10, H11 (claude, codex), H12 (claude, codex) rows; reviewer `cmp` equality for all six hooks | `cmp <repo hook> <bundle hook>` for each; executor `Invoke-PoshQCTest` | Codex counterparts converted after the decision record confirmed the dependency is evaluation-only. |
| 9 | AC9: Codex `enforce-completion-consistency.ps1` unchanged with recorded rationale; mirror parity, 500-line limit, toolchain pass | PASS | `git diff --quiet 58e5001c5..HEAD -- .codex/hooks/enforce-completion-consistency.ps1` exit 0; rationale in `evidence/other/decision-record.2026-10-20T12-51.md` (FR-7); largest changed file 496 lines; toolchain clean (policy audit Section 2.5) | `wc -l <changed files>`; reviewer toolchain commands in the policy audit Appendix B | — |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 9 criteria (spec.md); 4 of 4 traceability items in issue.md
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the S9 CI green gate (`ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head), including the Linux case-sensitive hook suite named in NFR-4.
2. After release, re-run the Claude push-down in a downstream repository that received 1.1.19 to 1.1.21 and confirm `.claude/hooks/enforce-completion-helpers.ps1` is placed.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/spec.md` (authoritative); `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/issue.md` (traceability mirror)
- Total AC items: 9 (spec.md); 4 (issue.md)
- Checked off (delivered): 9 (spec.md); 4 (issue.md)
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 9 | 9 | 0 | Checkbox-backed; all items were already checked by the executor and each evaluated PASS in this audit. |
| `issue.md` | 4 | 4 | 0 | Checkbox-backed traceability mirror; already checked; each evaluated PASS. |

No source-file checkbox change was made in this review, because every criterion was already checked and every check-off is supported by the evidence evaluated above.
