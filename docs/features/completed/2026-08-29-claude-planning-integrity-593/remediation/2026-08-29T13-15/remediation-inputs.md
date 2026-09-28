# Remediation Inputs: Claude Planning Integrity (#593)

Timestamp: 2026-08-29T13-15

## Authoritative Requirements

The primary requirement is the first acceptance criterion in both `../../spec.md` and `../../user-story.md`: an approved numeric `spec.md` criterion requires exhaustive family provenance and an independently constructed cross-check. The original feature plan is `../../plan.2026-08-29T12-07.md`.

## Blocking Findings

1. `.claude/hooks/validate-task-researcher-output.ps1` and `.claude/hooks/validate-prd-feature-output.ps1` accept equal `Primary Count` and `Cross-check Count` values without evidence of two independently constructed derivations. A copied count can satisfy the current validation.
2. `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`, `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`, and `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` do not reject that copied-count case.
3. `evidence/baseline/python-focused.2026-08-29T12-07.md` supplies a focused pass count but no numeric Python coverage baseline comparable to the post-change 93% result.

## Required Fixes

1. Define explicit, non-empty fields for the primary derivation and independently constructed cross-check derivation in the canonical Claude research and PRD contracts. The data must record distinct search strategies or query expressions and the member-set comparison, not only matching totals.
2. Update both numeric-derivation hook validators to reject missing primary/cross-check derivation evidence and reject a cross-check that merely repeats the primary search. Preserve explicit diagnostics.
3. Add focused Pester tests that pass with independent derivations and reject an otherwise complete copied-count/duplicated-search record. Update the Python contract test to require the new labels or invariants.
4. Copy every changed canonical `.claude/**` file to its required `extensions/drm-copilot/resources/claude-customizations/.claude/**` mirror and verify byte parity.
5. Capture or explicitly resolve the missing numeric Python coverage baseline before accepting the post-remediation Python coverage comparison. Do not state a numeric baseline without reproducible evidence.
6. Run the applicable format, analyzer/lint, type, focused/full test, coverage, and bundle-parity checks. Preserve the prior QA evidence and add post-remediation evidence under the feature's canonical `evidence/` paths.

## Verification Commands

- Pester coverage for the two numeric-derivation hooks, recorded in `../../evidence/qa-gates/`.
- `poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q`.
- `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, and `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing`.
- Hash comparison for each changed canonical Claude path and its bundle mirror.

## Do Not Do

- Do not weaken the numeric-provenance requirement to matching totals alone.
- Do not create a second preflight loop or change issue #586 executor-owned preflight semantics.
- Do not modify Codex runtime surfaces, the generic plan-progress counter, or unrelated policy documents.
- Do not replace focused fixtures with temporary-file tests or omit the copied-count rejection case.
- Do not push, publish customizations, create a pull request, merge, or alter unrelated work.
