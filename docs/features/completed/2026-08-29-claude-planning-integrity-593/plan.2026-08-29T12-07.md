# Claude Planning Integrity — Atomic Plan

- **Issue:** #593
- **Work mode:** full-feature
- **Requirements:** `docs/features/active/2026-08-29-claude-planning-integrity-593/spec.md`, `docs/features/active/2026-08-29-claude-planning-integrity-593/user-story.md`
- **Research:** `docs/features/active/2026-08-29-claude-planning-integrity-593/research/2026-08-29T12-12-claude-planning-integrity-research.md`

## Scope and Traceability

Only `.claude/**`, exact mirrors below `extensions/drm-copilot/resources/claude-customizations/.claude/**`, focused tests, and `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/**` are in scope. Exclude `.codex/**`, `.agents/**`, Codex runtime behavior, product code, and `scripts/dev_tools/plan_progress_report.py`.

Issue #586 retains the executor-owned `DIRECTIVE: PREFLIGHT VALIDATION ONLY` loop, exact `PREFLIGHT:` values, convergence reporting, and iteration ceiling. This plan adds a planner pre-check only; it creates no second clearance loop.

| Spec AC | Tasks |
| --- | --- |
| Dual exhaustive numeric provenance | P1-T1–P1-T5, P5-T1, P5-T3, P5-T4, P6-T1, P6-T4, P6-T5, P7-T1–P7-T4 |
| Three review dimensions and excess-round investigation | P2-T1–P2-T5, P5-T2, P5-T4, P6-T1, P6-T4, P6-T5 |
| Named-section counter and outside-box fixture | P3-T1–P3-T4, P5-T3, P5-T4, P6-T1, P6-T2, P6-T4, P6-T5 |
| Batched intake and rejected pending add | P4-T1–P4-T3, P5-T3, P5-T4, P6-T3, P6-T4, P6-T5 |

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read `AGENTS.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, and `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`; write `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/baseline/phase0-instructions-read.md`.
  - Acceptance: contains `Timestamp:`, `Policy Order:`, and every file in the stated order.
- [x] [P0-T2] Capture Pester/analyzer and numeric coverage baselines for `.claude/hooks/validate-planner-output.ps1`, `.claude/hooks/validate-task-researcher-output.ps1`, the intended `.claude/hooks/validate-prd-feature-output.ps1`, and the intended `.claude/lib/requirements/GeneratedDocumentCounters.psm1` in `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/baseline/powershell.2026-08-29T12-07.md`.
  - Acceptance: absent new files are recorded as absent, not passing; existing-file values are numeric.
- [x] [P0-T3] Run `poetry run pytest tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q`; write `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/baseline/python-focused.2026-08-29T12-07.md`.
  - Acceptance: exit code zero and observed pass summary are recorded.

### Phase 1 — Numeric Acceptance-Criterion Provenance

- [x] [P1-T1] Update `.claude/agents/task-researcher.md` and `.claude/skills/research-issue/SKILL.md` to require `## Numeric Derivation Evidence` before an approved `spec.md` acceptance criterion records a number.
  - Acceptance: evidence names the complete symbol/method family, inclusion/exclusion rules, member set, and an independently constructed full-family cross-check that agrees; one grep cannot authorize a number.
- [x] [P1-T2] Update `.claude/agents/prd-feature.md` and `.claude/skills/fill-feature-docs/SKILL.md` to require the exact research record and omit a numeric criterion when provenance is absent, incomplete, or disagrees.
  - Acceptance: nonnumeric criteria are allowed, but numeric facts cannot be inferred from first-pass search results.
- [x] [P1-T3] Create `.claude/hooks/validate-prd-feature-output.ps1` and attach it to `.claude/agents/prd-feature.md` as a `SubagentStop` validator.
  - Acceptance: permits nonnumeric criteria and rejects a numeric criterion without a complete, matching derivation record.
- [x] [P1-T4] Update `.claude/hooks/validate-task-researcher-output.ps1`, create `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`, and extend `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` with inline fixtures.
  - Acceptance: the task-researcher validator rejects a numeric `spec.md` acceptance-criterion provenance record that omits a complete family, member set, inclusion/exclusion rules, or matching independent cross-check; the PRD validator rejects a numeric claim without that complete record; missing provenance, incomplete family, missing rules, and disagreeing cross-checks fail; a complete dual derivation passes; no temporary file is used.
- [x] [P1-T5] Create `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` asserting the required numeric-evidence and rejection rules in `.claude/agents/task-researcher.md`, `.claude/skills/research-issue/SKILL.md`, `.claude/agents/prd-feature.md`, `.claude/skills/fill-feature-docs/SKILL.md`, `.claude/hooks/validate-task-researcher-output.ps1`, and `.claude/hooks/validate-prd-feature-output.ps1`.
  - Acceptance: deleting any required full-family, independent-cross-check, or rejection assertion fails the named test.

### Phase 2 — Planner Review Before Existing Preflight

- [x] [P2-T1] Update `.claude/skills/atomic-plan-contract/SKILL.md` with a mandatory planner review before executor preflight: citation-to-tree verification, AC-to-implementation traceability, and scope-boundary consistency.
  - Acceptance: current-pass citations and siblings are re-derived; all three dimensions must pass; existing `SELF-REVIEW: RE-DERIVED THIS PASS` remains distinct.
- [x] [P2-T2] Update `.claude/agents/atomic-planner.md` to require `PLANNER-INTERNAL-REVIEW:` with three results, re-derived citations, AC mapping, and unresolved gaps.
  - Acceptance: a missing/blocked dimension emits `SELF-REVIEW: BLOCKED` and stops handoff.
- [x] [P2-T3] Update `.claude/hooks/validate-planner-output.ps1` to reject output missing a required dimension, citation enumeration, or traceability record.
  - Acceptance: existing `plan-path` and exact `PREFLIGHT:` validation remains; executor clearance is not duplicated.
- [x] [P2-T4] Update `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` so a well-scoped item with `preflight.iterations > 1` requires a process-defect investigation identifying the incomplete review dimension.
  - Acceptance: #586's executor loop, convergence signal, and iteration ceiling are unchanged; excess rounds are not routine iteration.
- [x] [P2-T5] Extend `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` and `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` with a passing declaration and every missing-dimension fixture.
  - Acceptance: each negative fixture retains valid plan-path/preflight data, isolating the review failure.

### Phase 3 — Section-Bounded Generated-Document Counting

- [x] [P3-T1] Create `.claude/lib/requirements/GeneratedDocumentCounters.psm1` as a pure named-section checkbox counter.
  - Acceptance: the caller supplies a heading; counting starts after it and stops at the next equal-or-shallower heading; no whole-file fallback or I/O exists.
- [x] [P3-T2] Update `.claude/skills/acceptance-criteria-tracking/SKILL.md` to use `.claude/lib/requirements/GeneratedDocumentCounters.psm1` for generated-document summaries and exclude `scripts/dev_tools/plan_progress_report.py`.
  - Acceptance: `## Acceptance Criteria` is supplied by name when authoritative.
- [x] [P3-T3] Create `tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1` with boxes before, inside, and after `## Acceptance Criteria`, a nested heading, and a following equal-level heading.
  - Acceptance: outside boxes cannot change totals and the equal-level heading ends the range; no temporary file is used.
- [x] [P3-T4] Extend `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` and `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` for explicit named-section scoping.
  - Acceptance: a whole-document scan or missing boundary behavior fails a focused test.

### Phase 4 — Batched Parallel Intake

- [x] [P4-T1] Update `.claude/skills/parallel-plan/SKILL.md` to require the complete initial item set in one `/parallel-plan <slug> <item> [<item> ...]` invocation before waves are calculated.
  - Acceptance: `/parallel-plan` is initial intake; promotion and bounded waves remain intact.
- [x] [P4-T2] Update `.claude/skills/parallel-add/SKILL.md` to reject pending/not-started intake with `/parallel-plan` consolidation guidance and permit one item only after execution starts in an open run.
  - Acceptance: pending/not-started, closed, and execution-started states are distinct; rejection is not a planning revision.
- [x] [P4-T3] Extend `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` with pending-add rejection, consolidation guidance, and execution-started admission.
  - Acceptance: the pending counterexample fails while the permitted path passes.

### Phase 5 — Claude Bundle Parity

- [x] [P5-T1] Copy `.claude/agents/task-researcher.md`, `.claude/skills/research-issue/SKILL.md`, `.claude/agents/prd-feature.md`, `.claude/hooks/validate-task-researcher-output.ps1`, and `.claude/hooks/validate-prd-feature-output.ps1` to matching paths under `extensions/drm-copilot/resources/claude-customizations/.claude/`.
  - Acceptance: every canonical/mirror `git hash-object` pair is identical.
- [x] [P5-T2] Copy `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/agents/atomic-planner.md`, `.claude/hooks/validate-planner-output.ps1`, and `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` to matching bundle paths.
  - Acceptance: every hash pair is identical and no `.codex/**` resource changes.
- [x] [P5-T3] Copy `.claude/skills/fill-feature-docs/SKILL.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `.claude/lib/requirements/GeneratedDocumentCounters.psm1`, `.claude/skills/parallel-plan/SKILL.md`, and `.claude/skills/parallel-add/SKILL.md` to matching bundle paths.
  - Acceptance: each mirror exists and equals its canonical source hash.
- [x] [P5-T4] Record P5-T1–P5-T3 source/mirror hashes in `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/claude-bundle-parity.2026-08-29T12-07.md`.
  - Acceptance: all changed `.claude/**` sources are listed and no pair diverges.

### Phase 6 — QA and Acceptance Evidence

- [x] [P6-T1] Run PoshQC format, analyze, and Pester for `.claude/hooks/validate-planner-output.ps1`, `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, `.claude/lib/requirements/GeneratedDocumentCounters.psm1`, and their tests; write `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/powershell-toolchain.2026-08-29T12-07.md`.
  - Acceptance: all steps pass in order; a formatter change/failure restarts at formatting.
- [x] [P6-T2] Capture numeric Pester coverage for changed hooks and `.claude/lib/requirements/GeneratedDocumentCounters.psm1` in `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/powershell-coverage.2026-08-29T12-07.md`.
  - Acceptance: before changing code, preserve the P0-T2 numeric baseline for every existing PowerShell production file that will change; after the change, capture line coverage for every changed or new PowerShell production file (`.claude/hooks/validate-planner-output.ps1`, `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, and `.claude/lib/requirements/GeneratedDocumentCounters.psm1`) and compare each changed existing file against its own baseline. Each new PowerShell production file, including `GeneratedDocumentCounters.psm1` and `validate-prd-feature-output.ps1`, has line coverage of at least 90% (which exceeds the original 85% counter minimum); no changed existing production file regresses; any command coverage reported by Pester is recorded as informational only and does not substitute for the line-coverage comparison.
- [x] [P6-T3] Run `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, and `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing`; write `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/python-toolchain.2026-08-29T12-07.md`.
  - Acceptance: record the Black clean-success marker `left unchanged` and the Ruff clean-success marker `All checks passed`, plus pre- and post-format `git status --porcelain` observations; restart from Black if either changes files or fails, and record the printed terminal coverage table.
- [x] [P6-T4] Run `poetry run pytest tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q`; write `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/focused-python-contracts.2026-08-29T12-07.md`.
  - Acceptance: exit code zero and observed pass summary.
- [x] [P6-T5] Verify every `docs/features/active/2026-08-29-claude-planning-integrity-593/spec.md` criterion against P1–P6 evidence; write `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/acceptance-criteria-checkoff.2026-08-29T12-07.md`.
  - Acceptance: all criteria map to passing tasks/tests/evidence, no unsupported numeric fact exists, and unmet criteria remain unchecked.

## Final-QA Coverage Failure and Remediation Amendment

The existing `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/powershell.coverage.2026-08-29T12-07.xml` is preserved as failure evidence. Its `hooks/validate-prd-feature-output.ps1` source-file counter records 15 covered and 16 missed lines out of 31 eligible lines (48.39%). Do not overwrite, remove, or treat that result as passing. P6-T1 through P6-T5 and all acceptance criteria remain unchecked. Execute P7-T1 through P7-T4 before restarting the Phase 6 toolchain loop at P6-T1; only passing replacement evidence permits Phase 6 and acceptance-criteria completion.

### Phase 7 — PRD Hook Coverage Remediation and Final-QA Retry

- [x] [P7-T1] Preserve the verified P6-T2 failure as a remediation baseline by writing `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/validate-prd-feature-output-coverage.2026-08-29T12-07.md` that cites the existing coverage XML and records `15/31` line coverage (`48.39%`), the original coverage command, the P0-T2 new-file-absence baseline, and the required post-remediation line-coverage comparison.
  - Acceptance: the XML remains unchanged; the remediation baseline distinguishes P0's absence observation from the observed 15/31 implementation baseline, records the expected >=90% line-coverage threshold for the new hook, and identifies test code as excluded from production coverage.
- [x] [P7-T2] Extend only `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` with inline Pester fixtures and mocks that exercise every behavioral return path in `.claude/hooks/validate-prd-feature-output.ps1`: empty payload, malformed JSON, missing output, missing or nonexistent `spec-path`, a nonnumeric spec success path, numeric spec with missing or nonexistent `research-path`, numeric spec with complete matching evidence success, successful artifact-label extraction, missing numeric-evidence section, each required numeric-evidence field absent, and disagreeing counts.
  - Acceptance: the test invokes `Invoke-PrdFeatureOutputValidation` for its payload and path branches rather than testing only helper functions; tests use mocks and inline content, create no temporary files, preserve independent Arrange-Act-Assert structure, and require no production-hook change unless a separately recorded defect proves one is necessary.
- [x] [P7-T3] Run the focused Pester coverage invocation for `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` against `.claude/hooks/validate-prd-feature-output.ps1`; write the post-remediation result to `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/validate-prd-feature-output-coverage-remediation.2026-08-29T12-07.md`.
  - Acceptance: the evidence records the exact command, exit code, eligible/covered/missed line counts, and line percentage; the new hook reaches >=90% line coverage, the post-change result is compared with both P0-T2's absent-new-file baseline and the preserved 15/31 (48.39%) remediation baseline, and command coverage remains informational only.
- [x] [P7-T4] Re-verify `.claude/hooks/validate-prd-feature-output.ps1` against `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1` with `git hash-object`; write the result to `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/claude-bundle-parity-remediation.2026-08-29T12-07.md`.
  - Acceptance: the canonical and mirror hashes match. Because P7-T2 changes only the repository test, no mirror copy is expected; if remediation exposes a production-hook defect that requires a source edit, copy that exact source edit to the mirror and repeat the hash verification before retrying P6.

## Preflight-Round-2 Process-Defect Record

The first executor preflight round found omissions that the required planner internal review should have identified: the citation-to-tree enumeration did not cover every P1 and P3 target or required absent new file, and P6-T2 did not define the required baseline, post-change line coverage, per-file comparison, or command-coverage treatment. This is an internal-review process defect, not routine preflight iteration. The deficient dimension was citation-to-tree verification, with an AC-to-implementation traceability gap for the PowerShell coverage requirement. The corrective action in this revision is a complete current-tree target enumeration, explicit target-to-task traceability, and a full re-derivation of the three required dimensions before confirming preflight round 2.

The confirming executor preflight round 2 found a further planner internal-review defect: the Scope and Traceability table cited nonexistent P5-T5 and P5-T6 entries. The deficient dimension is AC-to-implementation traceability, because the top-level AC map did not match the actual task inventory. This revision replaces the full table with only existing task identifiers, rechecks every table reference against the task inventory, and re-derives all three review dimensions. This second finding is also a process defect; it must be investigated as incomplete planner review rather than treated as ordinary preflight iteration.

## Required Planner Internal Self-Review

SELF-REVIEW: RE-DERIVED THIS PASS

- Citation-to-tree verification: re-derived the full P1 numeric-provenance target set against the current tree: `.claude/agents/task-researcher.md` (`## Research Workflow`, especially `### 4. Requirements Mapping` and `### 5. Testing Implications`); `.claude/skills/research-issue/SKILL.md` (`## Investigation Areas`, especially `### 4. Requirements Mapping to Design`); `.claude/agents/prd-feature.md` (`## Expected Outputs`, `## Output Reporting`); `.claude/skills/fill-feature-docs/SKILL.md` (`## Inputs`, `## Output Paths`, `## Worker Routing`); `.claude/hooks/validate-task-researcher-output.ps1` (`Test-ResearchFile`, `Test-AutomationFeasibilitySection`, `Invoke-TaskResearcherOutputValidation`); and `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` (`Describe 'validate-task-researcher-output.ps1'`, `Context 'payload validation'`). The completed P1 additions are now present: `.claude/hooks/validate-prd-feature-output.ps1` (`Get-ArtifactPathFromOutput`, `Test-NumericDerivationEvidence`, `Test-SpecNumericCriterion`, and `Invoke-PrdFeatureOutputValidation`) and `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` (`Describe 'validate-prd-feature-output.ps1'`). P7-T2 extends that existing focused test rather than creating a sibling suite.
- Citation-to-tree verification: re-derived the planner/preflight target set: `.claude/skills/atomic-plan-contract/SKILL.md` (`## Planner Adversarial Self-Review`, `SELF-REVIEW: RE-DERIVED THIS PASS`, `## Preflight Validation (Planner ↔ Executor)`, `Convergence signal`); `.claude/agents/atomic-planner.md` (`## Preflight Validation`); `.claude/hooks/validate-planner-output.ps1` (`Test-HasPreflightSignal`, `Get-PlanStructureValidationReport`, `Invoke-PlannerOutputValidation`); `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (`## Preflight Sub-Loop`, `iterations`, and `blocked_preflight_iteration_limit`); and `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` (planner-output validation fixtures). These citations establish the existing issue #586 executor-owned loop, exact `PREFLIGHT:` signals, convergence reporting, and iteration ceiling that P2-T1 through P2-T5 preserve.
- Citation-to-tree verification: re-derived the complete P3 generated-document counting set: `.claude/skills/acceptance-criteria-tracking/SKILL.md` (`## AC Identification`, `## AC Status Summary (Required at Completion)`, and `### Acceptance Criteria Status`); the excluded `scripts/dev_tools/plan_progress_report.py` (`count_checkboxes`, `build_report_rows`, `generate_plan_progress_report`), which counts plan task boxes and remains unchanged; `.claude/lib/requirements/GeneratedDocumentCounters.psm1` (`Get-NamedSectionCheckboxCount`); and `tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1` (`Describe 'Get-NamedSectionCheckboxCount'` and its named-section heading fixture). P3-T2 excludes the generic counter, and P3-T4 supplies hook and Python contract coverage.
- Citation-to-tree verification: re-derived the P4 intake set: `.claude/skills/parallel-plan/SKILL.md` (`## Item Intake` and the `/parallel-add` non-intake rule); `.claude/skills/parallel-add/SKILL.md` (run-state admission rules); and `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` (parallel surface contract assertions). P4-T1 through P4-T3 map each existing contract owner and its discriminating pending/not-started versus execution-started test.
- Citation-to-tree verification: re-derived canonical/mirror parity for every existing in-scope runtime target. Existing pairs checked are `.claude/agents/task-researcher.md` (`## Research Workflow`), `.claude/skills/research-issue/SKILL.md` (`## Investigation Areas`), `.claude/agents/prd-feature.md` (`## Expected Outputs`), `.claude/skills/fill-feature-docs/SKILL.md` (`## Worker Routing`), `.claude/hooks/validate-task-researcher-output.ps1` (`Invoke-TaskResearcherOutputValidation`), `.claude/hooks/validate-prd-feature-output.ps1` (`Invoke-PrdFeatureOutputValidation`), `.claude/skills/atomic-plan-contract/SKILL.md` (`## Preflight Validation (Planner ↔ Executor)`), `.claude/agents/atomic-planner.md` (`## Preflight Validation`), `.claude/hooks/validate-planner-output.ps1` (`Invoke-PlannerOutputValidation`), `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (`## Preflight Sub-Loop`), `.claude/skills/acceptance-criteria-tracking/SKILL.md` (`## AC Identification`), `.claude/lib/requirements/GeneratedDocumentCounters.psm1` (`Get-NamedSectionCheckboxCount`), `.claude/skills/parallel-plan/SKILL.md` (`## Item Intake`), and `.claude/skills/parallel-add/SKILL.md` (`# Parallel Add Skill`), each with the same relative path and named heading or function verified under `extensions/drm-copilot/resources/claude-customizations/.claude/`. P7-T4 re-verifies the existing PRD-hook pair after test-only remediation; focused tests remain repository tests, not published bundle content, and `test_push_down_claude_resource_contracts.py` supplies the all-non-memory-`.claude/**` mirror guard.
- Citation-to-tree verification: re-derived the final-QA coverage-failure target: `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/powershell.coverage.2026-08-29T12-07.xml` (`hooks/validate-prd-feature-output.ps1` source-file line counter: 15 covered, 16 missed, 31 eligible), `.claude/hooks/validate-prd-feature-output.ps1` (the four hook functions), and `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` (existing numeric/non-numeric and derivation fixtures). P7-T1 preserves the failure as remediation-baseline evidence, P7-T2 covers the currently untested artifact-extraction and invocation paths, P7-T3 captures the post-remediation result, and P7-T4 rechecks parity.
- AC-to-implementation traceability: pass. The Scope and Traceability table was re-derived from the current task inventory and contains only existing task identifiers: AC 1 maps to P1-T1–P1-T5, P5-T1, P5-T3, P5-T4, P6-T1, P6-T4, P6-T5, and P7-T1–P7-T4; AC 2 maps to P2-T1–P2-T5, P5-T2, P5-T4, P6-T1, P6-T4, and P6-T5; AC 3 maps to P3-T1–P3-T4, P5-T3, P5-T4, P6-T1, P6-T2, P6-T4, and P6-T5; and AC 4 maps to P4-T1–P4-T3, P5-T3, P5-T4, P6-T3, P6-T4, and P6-T5. P6-T2 and P7-T1–P7-T3 now require the preserved 15/31 remediation baseline, updated post-change line evidence, an explicit new-code comparison, and >=90% line coverage for the new hook.
- Scope-boundary consistency: pass. The amendment changes only the existing focused Pester test, records remediation evidence under this feature's canonical `evidence/remediation-baseline/` and `evidence/qa-gates/` paths, and conditionally re-verifies the existing Claude hook mirror. `.codex/**`, `.agents/**`, Codex runtime behavior, product code, and `scripts/dev_tools/plan_progress_report.py` remain excluded; the latter is cited only as an excluded counter, not modified. The plan adds no replacement executor loop, dependency, generic plan-progress behavior, or out-of-scope bundle publisher change.

The preflight-round-2 process-defect investigation is resolved for the plan revision: its target-enumeration and coverage-traceability gaps were corrected above. Confirming executor preflight remains the next gate; this planner self-review does not replace or duplicate it.
