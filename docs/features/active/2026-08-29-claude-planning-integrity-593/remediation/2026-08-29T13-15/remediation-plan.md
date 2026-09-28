# Claude Planning Integrity — Numeric-Provenance Remediation Plan

- **Issue:** #593
- **Work mode:** full-feature remediation
- **Requirements source:** `docs/features/active/2026-08-29-claude-planning-integrity-593/remediation/2026-08-29T13-15/remediation-inputs.md`
- **Original plan:** `docs/features/active/2026-08-29-claude-planning-integrity-593/plan.2026-08-29T12-07.md`
- **Reviewed head:** `4c87251f2783c0e4383fe33545fd8b8df5eded53`
- **Merge base:** `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`

## Scope and Traceability

This remediation changes only Claude runtime contract owners, their exact bundle mirrors, their focused tests, the named Python contract test, and evidence below `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/`. It excludes `.codex/**`, `.agents/**`, generic plan-progress surfaces, product code, all source requirement files, review artifacts, issue #586 executor-owned preflight behavior, push, publication, pull-request creation, and merge actions.

| Remediation input | Implementing tasks | Verifying tasks |
| --- | --- | --- |
| R1: independent numeric derivation evidence and validator rejection | P1-T1 through P1-T4 | P2-T1 through P2-T3, P4-T3, P4-T8, P5-T1 |
| R2: copied-count and duplicated-search fixture coverage | P2-T1 through P2-T3 | P4-T3, P4-T7, P4-T8 |
| R3: canonical Claude contracts and exact bundle mirrors only | P1-T1, P1-T2, P3-T1 through P3-T6 | P4-T4, P4-T7 |
| R4: reproducible numeric Python coverage baseline | P0-T4 | P4-T8, P5-T2 |
| R5: complete QA loop and parity evidence | P4-T1 through P4-T8 | P5-T1, P5-T2 |

Numeric provenance remains stronger than matching totals: each numeric acceptance-criterion record must name the complete symbol or method family, state the exhaustive repository/search scope used to derive it, contain non-empty primary and cross-check derivation records, use distinct strategy or query-expression evidence, independently enumerate member sets, and explicitly compare those sets. Equal counts, distinct query text, or equal member sets alone do not prove a complete family search or exhaustive scope and do not pass.

### Phase 0 — Policy and Reproducible Baselines

- [x] [P0-T1] Read `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/powershell/SKILL.md`, `.agents/skills/python/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, and `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`; write the ordered-read receipt to `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/phase0-instructions-read.2026-08-29T13-15.md`.
  - Acceptance: the receipt contains `Timestamp:`, `Policy Order:`, and every listed path in the stated order.
- [x] [P0-T2] Inspect the current contract owners `.claude/agents/task-researcher.md`, `.claude/skills/research-issue/SKILL.md`, `.claude/agents/prd-feature.md`, `.claude/skills/fill-feature-docs/SKILL.md`, `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, and their corresponding focused tests; write a target inventory to `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/numeric-provenance-target-inventory.2026-08-29T13-15.md`.
  - Acceptance: the inventory identifies the current labels/functions/tests to be changed and confirms that issue #586 preflight files are excluded.
- [x] [P0-T3] Before modifying either hook, run the focused Pester suite with JaCoCo line coverage for `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` and `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` against `.claude/hooks/validate-task-researcher-output.ps1` and `.claude/hooks/validate-prd-feature-output.ps1`; write the command, XML output, per-file eligible/covered/missed line counts, and percentages to `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/numeric-provenance-powershell-coverage.2026-08-29T13-15.md`.
  - Acceptance: the Markdown receipt has `Timestamp:`, the exact `New-PesterConfiguration`/`Invoke-Pester` command, `EXIT_CODE:`, and numeric line coverage for both existing hooks; it does not use command coverage as a substitute.
- [x] [P0-T4] Before modifying `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`, run `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing`; write the printed numeric `scripts.dev_tools` coverage table to `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/baseline/python-coverage-remediation.2026-08-29T13-15.md`.
  - Acceptance: the receipt has `Timestamp:`, `Command:`, `EXIT_CODE:`, and the reproducible numeric percentage, statement, and missed-line values. The existing focused-only baseline is preserved but is not represented as a coverage baseline.

### Phase 1 — Independent Numeric-Derivation Contracts

- [x] [P1-T1] Update `.claude/agents/task-researcher.md` and `.claude/skills/research-issue/SKILL.md` to require separate non-empty primary and cross-check derivation records for each numeric fact proposed for an approved `spec.md` acceptance criterion.
  - Acceptance: each record identifies the complete symbol or method family being derived, the exhaustive repository/search scope that covers that entire family, inclusion rules, exclusion rules, search strategy or query expression, independently enumerated member set, count, and an explicit member-set comparison; the cross-check may not reuse the primary search strategy or query expression. A record that searches only a narrow named pattern, omits a family member or overload, or does not state exhaustive scope is rejected even when its query text and member set differ from the primary record.
- [x] [P1-T2] Update `.claude/agents/prd-feature.md` and `.claude/skills/fill-feature-docs/SKILL.md` so a PRD can approve a numeric `spec.md` criterion only from the complete dual-derivation research record.
  - Acceptance: missing, repeated, incomplete, disagreeing, member-set-mismatched, incomplete-family, or non-exhaustive-scope derivations cause the numeric assertion to be withheld; distinct query text plus equal member sets does not substitute for a complete-family/exhaustive-scope record; a nonnumeric criterion remains permitted.
- [x] [P1-T3] Update `.claude/hooks/validate-task-researcher-output.ps1` to validate the explicit primary and cross-check derivation fields, including the complete family and exhaustive scope fields; reject blank derivation evidence, a normalized duplicate strategy/query expression, a narrow named-pattern search, and unequal or un-compared member sets.
  - Acceptance: diagnostics identify the missing, repeated, incomplete-family, non-exhaustive-scope, or narrow-search dimension and do not accept copied equal counts, distinct query text, or equal member sets as proof of complete independent derivation.
- [x] [P1-T4] Update `.claude/hooks/validate-prd-feature-output.ps1` with the same dual-derivation, complete-family, exhaustive-scope, distinct-search, and member-set-comparison validation for numeric `spec.md` criteria.
  - Acceptance: the hook rejects copied-count, duplicated-search, incomplete-family, missing-exhaustive-scope, and narrow named-pattern records even when the displayed primary and cross-check counts or member sets match.

### Phase 2 — Focused Regression Coverage

- [x] [P2-T1] Extend `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` with inline Pester fixtures for a passing independently exhaustive complete-family derivation and rejection cases for a copied count, duplicated search strategy/query expression, missing primary evidence, missing cross-check evidence, mismatched member-set comparison, omitted complete-family declaration, omitted exhaustive scope, and a narrow named-pattern search that does not cover the declared family.
  - Acceptance: every fixture invokes the exported validation path, uses Arrange-Act-Assert structure, and creates no temporary files; the narrow-search fixture is rejected even when it supplies distinct query text and equal member sets.
- [x] [P2-T2] Extend `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` with inline Pester fixtures for a passing independently exhaustive complete-family derivation and the same copied-count, duplicated-search, missing-evidence, member-set, complete-family, exhaustive-scope, and narrow-named-pattern rejection cases.
  - Acceptance: every fixture invokes `Invoke-PrdFeatureOutputValidation`, uses mocks and inline content only, and creates no temporary files; the incomplete-family and narrow-search fixtures are rejected even when their displayed counts and member sets match the cross-check.
- [x] [P2-T3] Update `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` to assert that both validators and the canonical research/PRD contracts require distinct primary/cross-check derivation evidence, complete-family identification, exhaustive search scope, and member-set comparison.
  - Acceptance: deleting the distinct-search, copied-count-rejection, complete-family, exhaustive-scope, or narrow-named-pattern-rejection invariant causes the named Python test to fail; distinct query text plus equal member sets does not satisfy the asserted contract.

### Phase 3 — Required Claude Bundle Mirrors

- [x] [P3-T1] Copy `.claude/agents/task-researcher.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md` after P1-T1 is complete.
  - Acceptance: `git hash-object` reports identical hashes for the canonical and mirrored files.
- [x] [P3-T2] Copy `.claude/skills/research-issue/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/research-issue/SKILL.md` after P1-T1 is complete.
  - Acceptance: `git hash-object` reports identical hashes for the canonical and mirrored files.
- [x] [P3-T3] Copy `.claude/agents/prd-feature.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/prd-feature.md` after P1-T2 is complete.
  - Acceptance: `git hash-object` reports identical hashes for the canonical and mirrored files.
- [x] [P3-T4] Copy `.claude/skills/fill-feature-docs/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/fill-feature-docs/SKILL.md` after P1-T2 is complete.
  - Acceptance: `git hash-object` reports identical hashes for the canonical and mirrored files.
- [x] [P3-T5] Copy `.claude/hooks/validate-task-researcher-output.ps1` to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1` after P1-T3 is complete.
  - Acceptance: `git hash-object` reports identical hashes for the canonical and mirrored files.
- [x] [P3-T6] Copy `.claude/hooks/validate-prd-feature-output.ps1` to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1` after P1-T4 is complete.
  - Acceptance: `git hash-object` reports identical hashes for the canonical and mirrored files.

### Phase 4 — Final Toolchain and Bundle Verification

- [x] [P4-T1] Run the repository PoshQC formatter over `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`, and `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`; record the result in `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-powershell-format.2026-08-29T13-15.md`.
  - Acceptance: the receipt contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If formatting changes a file or fails, restart Phase 4 at P4-T1 after updating the required mirror.
- [x] [P4-T2] Run the repository PoshQC analyzer over the same two hooks and focused Pester test files; record the result in `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-powershell-analyze.2026-08-29T13-15.md`.
  - Acceptance: the receipt has the required evidence fields and reports zero new analyzer findings.
- [x] [P4-T3] Run the two focused Pester suites with JaCoCo coverage for both changed hooks; record the exact command, XML path, test totals, and per-file line coverage comparison to P0-T3 in `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-powershell-tests-and-coverage.2026-08-29T13-15.md`.
  - Acceptance: all tests pass; the evidence records eligible, covered, missed, percentage, and P0-T3 comparison for each changed hook; both `.claude/hooks/validate-task-researcher-output.ps1` and `.claude/hooks/validate-prd-feature-output.ps1` retain or exceed their P0-T3 line-coverage baselines and meet the repository 85% production line-coverage threshold. The evidence additionally identifies every new production line in `.claude/hooks/validate-prd-feature-output.ps1` from the reviewed-head diff, maps it to the JaCoCo line result, and reports its aggregate new-production line coverage at or above 90%. Every newly added validation path is covered; command coverage is reported only as informational. Any per-file regression, 85% threshold miss, or PRD-hook new-production coverage below 90% is recorded as remediation-required and prevents a passing result.
- [x] [P4-T4] Run `poetry run black .`; before and after that command, capture `git status --porcelain --untracked-files=all` and `git diff --name-only HEAD --`, then record the command and raw observations in `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-format.2026-08-29T13-15.md`.
  - Acceptance: the evidence carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and the validator-recognized `Output Summary:` field. Its `Output Summary:` contains four labelled raw observations: `Pre-Worktree-Observation:` and `Post-Worktree-Observation:` from `git status --porcelain --untracked-files=all`, plus `Pre-Diff-Observation:` and `Post-Diff-Observation:` from `git diff --name-only HEAD --`; it also records Black's `left unchanged` clean-success marker. If either post-command observation differs from its corresponding pre-command observation, or Black fails, record the change and restart Phase 4 at P4-T1 before repeating all subsequent checks.
- [x] [P4-T5] Run `poetry run ruff check .`; record pre/post-command `git status --porcelain` observations and the result in `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-lint.2026-08-29T13-15.md`.
  - Acceptance: the evidence has the required fields, the unchanged-worktree observation, and Ruff's `All checks passed` marker. If Ruff changes a file or fails, restart Phase 4 at P4-T1.
- [x] [P4-T6] Run `poetry run pyright`; write the result to `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-type.2026-08-29T13-15.md`.
  - Acceptance: the evidence has the required fields and reports no new type errors.
- [x] [P4-T7] Run `poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q`; write the result to `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-focused.2026-08-29T13-15.md`.
  - Acceptance: the named focused tests pass, including exact Claude resource mirror coverage.
- [x] [P4-T8] Run `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing`; write the numeric post-remediation coverage table and comparison with P0-T4 to `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-full-coverage.2026-08-29T13-15.md`.
  - Acceptance: the full suite passes, the evidence has the required fields, and it compares reproducible baseline and post-remediation statement/missed-line/percentage values. If P0-T4 cannot supply numeric coverage, this task records remediation-required rather than claiming a comparison.

### Phase 5 — Acceptance Evidence and Completion Handoff

- [x] [P5-T1] Verify the numeric-provenance acceptance criterion against P1-T1 through P4-T8 and write the mapping to `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-remediation-acceptance.2026-08-29T13-15.md`.
  - Acceptance: the mapping identifies the independently exhaustive complete-family positive case; copied-count, duplicated-search, incomplete-family, missing-exhaustive-scope, and narrow-named-pattern rejection tests; bundle evidence; and any unmet condition. It reports the P0-T3 baseline and P4-T3 post-remediation eligible, covered, missed, and percentage values for both changed hooks; confirms each hook retains or exceeds baseline and meets the repository 85% production line-coverage threshold; and separately reports the reviewed-head-diff-derived new-production line set, covered line set, and >=90% aggregate new-production line-coverage verdict for `.claude/hooks/validate-prd-feature-output.ps1`, or records remediation-required. It does not alter source requirement files.
- [x] [P5-T2] Record the remediation result and unresolved items, if any, in `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/other/numeric-provenance-remediation-summary.2026-08-29T13-15.md`.
  - Acceptance: the summary preserves earlier failure evidence, references only canonical evidence paths, states whether P0-T4 enabled a numeric Python comparison, and makes no completion claim when a QA or parity gate is unresolved.

## Preflight Round Investigation

- **Process-defect signal:** this revision follows `PREFLIGHT: REVISIONS REQUIRED` in round 2 for a well-scoped remediation plan. The round count is treated as evidence of an inadequate internal self-review, not normal iteration.
- **Missed internal-review dimensions:** the preceding review did not fully verify acceptance-criterion-to-implementation traceability for the separate 90% new-production threshold on `.claude/hooks/validate-prd-feature-output.ps1`; it did not verify citation-to-tree coverage of the complete-family and exhaustive-scope record requirements through every contract, validator, and fixture task; and it did not verify scope-boundary/observability consistency by requiring a validator-recognized `Output Summary:` field with reproducible pre/post worktree and diff observations for the Black write-mode command.
- **Corrective action:** before every further preflight handoff, the planner must inspect each remediation input sentence against the precise task and acceptance condition that implements it, verify all named contract/test/hook files against the tree, and verify that each write-mode command has a recorded evidence-schema field and a restart condition. This same plan file is then revalidated; no new sibling plan is created.

## Required Planner Internal Self-Review

SELF-REVIEW: RE-DERIVED THIS PASS

- **Citation-to-tree verification — pass.** The remediation inputs were re-read against the current tree. The numeric-provenance owners are `.claude/agents/task-researcher.md`, `.claude/skills/research-issue/SKILL.md`, `.claude/agents/prd-feature.md`, `.claude/skills/fill-feature-docs/SKILL.md`, `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, their two Pester suites, and `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`. Each file has an explicit task in P1, P2, or P3. P1-T1 through P1-T4 and P2-T1 through P2-T3 now require and test the complete symbol/method family and exhaustive search scope, including narrow named-pattern rejection fixtures; no task treats distinct query text plus equal sets as sufficient. `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/baseline/python-focused.2026-08-29T12-07.md` was verified as test-count-only; P0-T4 provides the missing numeric baseline without inventing data.
- **Acceptance-criterion-to-implementation traceability — pass.** The table maps R1 through R5 to only existing task identifiers. R1 requires complete-family/exhaustive-scope, distinct strategy/query, and member-set comparison records in P1-T1 through P1-T4; P2-T1 through P2-T3 provide positive and copied-count, duplicated-search, incomplete-family, missing-scope, and narrow-search rejection coverage. P0-T3/P0-T4 and P4-T3/P4-T8 provide the required numeric coverage comparisons. P4-T3 requires both changed PowerShell hooks to retain or exceed P0-T3 and meet 85% production line coverage, and separately requires the `.claude/hooks/validate-prd-feature-output.ps1` reviewed-head-diff-derived new-production line coverage to meet 90%; P5-T1 reports each of those values and verdicts. P3-T1 through P3-T6 and P4-T7 verify exact bundle parity.
- **Scope-boundary consistency — pass.** The plan updates only listed Claude contract owners, exact bundle mirrors, their focused tests, the named Python contract test, and canonical feature evidence. P4-T4 confines worktree/diff observations to the plan's QA evidence and requires the evidence-schema `Output Summary:` field, raw pre/post observations, and a Phase-4 restart on any change. The plan does not alter the issue #586 executor preflight loop, generic counters, Codex surfaces, source requirements, review artifacts, external state, or unrelated files. The required preflight below validates this remediation plan only; it does not add a runtime preflight loop.

## Preflight Handoff

DIRECTIVE: PREFLIGHT VALIDATION ONLY

The atomic executor must validate this exact remediation plan for citation-to-tree coverage, traceability, scope boundaries, atomic task structure, canonical evidence paths, and full QA requirements. It must return exactly `PREFLIGHT: ALL CLEAR` or `PREFLIGHT: REVISIONS REQUIRED`; any revision must be made in this same file before a further validation handoff.
