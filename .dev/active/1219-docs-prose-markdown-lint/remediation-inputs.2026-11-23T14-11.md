# Remediation Inputs — Issue 1219 (re-audit after remediation cycle 2)

Timestamp: 2026-11-23T14-11
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design
Issue: 1219
Base: origin/epic/documentation-estate-families-integration
Merge-Base: 7c4bdc734a0c59f9a3057108b719f67adeef88ca
Reviewed-Head: 69293991ae9585c5a371de4b55ffa5f290554ac9
Remediation plan target: `.dev/active/1219-docs-prose-markdown-lint/remediation-plan.2026-11-23T14-11.md` (authored by `atomic-planner`)
Source review artifacts:
- `.dev/active/1219-docs-prose-markdown-lint/policy-audit.2026-11-23T14-11.md`
- `.dev/active/1219-docs-prose-markdown-lint/code-review.2026-11-23T14-11.md`
- `.dev/active/1219-docs-prose-markdown-lint/feature-audit.2026-11-23T14-11.md`

## Disposition

Findings R2 and R3 of `remediation-inputs.2026-11-23T12-58.md` are resolved. The epic template `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` now states at lines 16, 82, and 95-96 that the init-written workflow runs markdownlint and Vale and that `check` is the required page-structure gate; only those statements changed, and the three tests that read the file passed. `artifacts/pester/powershell-coverage.xml` holds the cycle-2 gate run (13:44:59 to 13:53:19 UTC) at 96.85% repo-wide, with `DocsPagePlaceholder.psm1` 100%, `DocsLedgerCommands.psm1` 99.70%, and `DocsProfileCommands.psm1` 97.87%. All 46 acceptance criteria evaluate PASS, and toolchain, coverage, file-size, bundle-parity, harness-parity, evidence-location, and supply-chain checks are met.

A search for the same claim in other word orders ("optional linting", "no required linter") outside historical feature records found one current statement that the item's change makes inaccurate and that no epic child corrects. The fix is two words in one Markdown index row. It changes no spec acceptance criterion, public interface, validator contract, hook decision, or production logic, and needs no test run. The file (`.dev/engineering/documentation-estate/README.md`) is outside the branch diff, so the cycle takes the full path.

Scope boundary: edit only the one row named below, plus new task-check and self-review evidence. Do not edit any production module, template, skill surface, bundle copy, `spec.md`, `user-story.md`, other engineering page, or any existing evidence or review record.

## Finding R4 (code review and policy audit, Major): engineering README index row describes the onboarding page as covering optional linting

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the README is a repository file that the branch can edit, the accurate wording follows from the onboarding page section already corrected on this branch, and no sibling item or owner decision is needed.
Finding-Scope: contained

- Location: `.dev/engineering/documentation-estate/README.md` line 36, `## Topic Pages` table, row for `consumer-onboarding.md`: "Prerequisites, the optional python pack, optional linting, adoption steps, consumer CI and the epic template".
- Observed: `consumer-onboarding.md` `## Linting` (line 33) opens "Lint steps are part of the written workflow." and describes the markdownlint and Vale steps of the init-written workflow, which fail on findings. The index row still labels that section "optional linting". Spec `## Scope` item 4 requires the engineering pages that describe the changed behavior to be updated in the same change. No test reads the README; no documentation-estate-families child lists it.
- Required:
  1. In that row, replace "optional linting" with "linting" (resulting cell: "Prerequisites, the optional python pack, linting, adoption steps, consumer CI and the epic template"). Keep "the optional python pack", which remains accurate.
  2. Change no other line of the README and no other file except new evidence.
  3. Run no Pester selection or gate after the edit: no test reads the README, and a selection run would overwrite the cycle-2 gate coverage XML. The cycle-2 gate (`evidence/qa-gates/pester-gate.2026-11-23T14-00.md`) stays the coverage evidence because no code or test file changes.

## Verification Commands

1. `Grep 'optional linting'` over `.dev/engineering/documentation-estate/`: no match.
2. `Grep '(?i)(optional[^.\n]{0,40}lint|lint[^.\n]{0,40}optional|no required linter)'` over the repository excluding `.dev/active`, `.dev/potential`, `.dev/epics`, `.dev/archive`, and `.dev/completed`: no match.
3. `Grep 'engineering/documentation-estate/README'` over `tests/`: no match (confirms no test needs a run); record in a new task-check artifact under `.dev/active/1219-docs-prose-markdown-lint/evidence/other/`.
4. `git diff` of the README against the reviewed head: one line changed.
5. Final self-review artifact under `.dev/active/1219-docs-prose-markdown-lint/evidence/qa-gates/` recording the edited row and the results above, and that no Pester run followed the cycle-2 gate.

## Do Not Do

- No edit to any production module, template, DocsTonality style, skill surface, bundle copy, `spec.md`, `user-story.md`, other engineering page, or existing evidence or review file.
- No Pester run of any kind in this cycle; no serial, single-process, shuffled, or reversed test run; no temporary files in tests.
- No new Python; no hand edit to a harness-generated file.

## Non-remediation notes

- Warning (file size): `.claude/lib/docs/DocsLedgerCommands.psm1` at 760 logical lines (advisory tier); no action in this item.
- Minor: the Vale download URL in `_docs-quality.yml` line 89 hard-codes `v3.25.1`; the spec AC asserts that literal URL, so it is not changed.
- Historical mentions of optional linting in other items' records (`.dev/active/1024-*`, `1034-*`, `1037-*`, `1038-*`, `1169-*`, `.dev/potential/promoted/`, `.dev/epics/documentation-estate-tooling/epic.md`) are append-only records of earlier decisions, not current guidance; no change.
- Info and Nit rows of the code review require no change.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
