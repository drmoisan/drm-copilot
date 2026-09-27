# Bug: compare-code-point-helper-duplicated

- Issue: #716
- Type: bug
- Work Mode: full-bug
- Label: bug
- Source: GitHub issue #716 (body transcribed; the potential-entry lifecycle record is not present on this branch)

## Summary

`compareCodePoint` has multiple private or exported copies under `extensions/drm-copilot/src/lib/pr-context/`. Issue #622 (PR #703) added a copy in `autoclose.ts`. This violates the repository's reusability principle (`.claude/rules/general-code-change.md`, Design Principles item 2).

Observation at intake (origin/main 2dce111e): a search for `function compareCodePoint` under `extensions/drm-copilot/src/lib/pr-context/` returns eight definitions, not the seven the issue reports: `collector-core.ts`, `feature-docs-parsers.ts` (exported), `autoclose.ts`, `gh-client-details.ts` (exported), `render-feature-excerpts.ts`, `render.ts`, `render-pr-helpers.ts`, `verification-evidence.ts`.

## Environment

- OS/version: any
- Language: TypeScript
- Command/flags used: a grep for `function compareCodePoint` under `extensions/drm-copilot/src/lib/pr-context/`
- Data source or fixture: n/a

## Steps to Reproduce

1. Grep `extensions/drm-copilot/src/lib/pr-context/` for `function compareCodePoint`.
2. Observe multiple definitions. `feature-docs-parsers.ts` and `gh-client-details.ts` already export one each.

## Expected Behavior

One exported helper, for example in `models.ts`, is imported everywhere.

## Actual Behavior

Multiple copies, which can drift independently. Ordering determinism in the PR-context output depends on all copies staying identical.

## Impact / Severity

- Low

## Evidence

- #622 `code-review.2026-09-26T21-25.md` NB-4.

## Acceptance Criteria

- [ ] Exactly one definition of `compareCodePoint` exists under `extensions/drm-copilot/src/lib/pr-context/`, and it is exported from a single shared module.
- [ ] Every module under `extensions/drm-copilot/src/lib/pr-context/` that uses `compareCodePoint` imports it from that shared module; no private copy remains.
- [ ] The shared helper's ordering behavior is unchanged (code-unit ordering, returning -1, 0, or 1), and it is covered by a unit test, including a property-based test.
- [ ] PR-context output ordering is unchanged: the existing pr-context test suite passes without changes to expected output.
- [ ] The full TypeScript toolchain (Prettier, ESLint, tsc, dependency-cruiser, Jest with coverage) passes, with no coverage regression on changed lines.
