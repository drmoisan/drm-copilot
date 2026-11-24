# Remediation Inputs — Issue 1219 (initial review)

Timestamp: 2026-11-23T12-30
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: light
Issue: 1219
Base: origin/epic/documentation-estate-families-integration
Merge-Base: 7c4bdc734a0c59f9a3057108b719f67adeef88ca
Reviewed-Head: 16b38d3cf103c7a657cd1f5dff8db184f4f99572
Source review artifacts:
- `.dev/active/1219-docs-prose-markdown-lint/policy-audit.2026-11-23T12-30.md`
- `.dev/active/1219-docs-prose-markdown-lint/code-review.2026-11-23T12-30.md`
- `.dev/active/1219-docs-prose-markdown-lint/feature-audit.2026-11-23T12-30.md`

## Disposition

All 46 acceptance criteria in `spec.md` and `user-story.md` evaluate PASS. Coverage, toolchain, file-size, bundle-parity, harness-parity, evidence-location, and supply-chain checks are met with recorded evidence. One related documentation finding remains. It is autonomous and contained: the fix edits one sentence of an engineering page already in the branch diff and one assertion of a test file already in the branch diff, and changes no spec acceptance criterion, public interface, validator contract, hook decision, or production logic. This is the first remediation cycle and it is opened by a review, so it takes the light path.

Scope boundary: edit only the sentence and test named below. Do not edit any production module, template, skill, bundle copy, spec, or evidence file.

## Finding R1 (code review, Major): stale "Linting is optional." sentence

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the page and its test are both on this branch, and the accurate wording follows from the workflow template and the replacement paragraph already written in the same section, so the fix needs no external input or owner decision.
Finding-Scope: contained

- Location: `.dev/engineering/documentation-estate/consumer-onboarding.md` line 33 (first sentence of `## Linting`), and `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` lines 174-179 (`It 'states that linting is optional and check is the required page gate'`, asserting `$text.Contains('Linting is optional')`).
- Observed: the section opens with "Linting is optional." The same section, as changed by this item, states that the written workflow runs markdownlint and the pinned Vale release and that an error-level alert fails the Vale step. A repository that calls the written `_docs-quality.yml` cannot skip the lint steps without editing it, so the sentence is inaccurate. Decision D13 of the spec makes correcting documentation falsified by this change part of the item.
- Required: replace "Linting is optional." with an accurate sentence that keeps the existing statement that `check` is the required page gate, for example: "`check` is the required page gate, and the written workflow also runs markdownlint and Vale." (keep the following sentences, including the existing "`check` is the required page gate: ..." sentence, consistent; remove any duplication). Rename the `It` and change its asserted token to a distinctive substring of the new sentence; keep the assertion that `check` is the required page gate. The new `It` name must be unique under the case-folding `test-name-uniqueness.Tests.ps1` guard.

## Light Fix Tasks

- [x] [P0-T1] Fix R1 in `.dev/engineering/documentation-estate/consumer-onboarding.md` line 33 by replacing "Linting is optional." with an accurate sentence, and update the matching `It` name and asserted token in `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` lines 174-179.

## Verification Commands

1. `Grep 'Linting is optional'` over `.dev/engineering/documentation-estate/` and `tests/scripts/claude-lib/docs/`: no match.
2. Static check (format check mode and PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`) over `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1`: 0 findings, 0 rewrites.
3. Through the test-execution launcher (parallel only): `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1 tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`; record the result as a new task-check artifact under `.dev/active/1219-docs-prose-markdown-lint/evidence/other/`.

## Do Not Do

- No edit to any production module, template, DocsTonality style, skill surface, bundle copy, `spec.md`, `user-story.md`, or existing evidence file.
- No serial, single-process, shuffled, or reversed test run; no edit or deletion of existing evidence.
- No new Python.

## Non-remediation notes

- Warning (file size): `.claude/lib/docs/DocsLedgerCommands.psm1` at 760 logical lines (advisory tier); no action in this item.
- Minor: the Vale download URL in `_docs-quality.yml` line 89 hard-codes `v3.25.1`; the spec AC asserts that literal URL, so it is not changed in this cycle.
- Info and Nit rows of the code review require no change.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
