# Remediation Inputs — Issue 1219 (re-audit after light cycle 1)

Timestamp: 2026-11-23T12-58
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design
Issue: 1219
Base: origin/epic/documentation-estate-families-integration
Merge-Base: 7c4bdc734a0c59f9a3057108b719f67adeef88ca
Reviewed-Head: 0f5a4be23d40dbc1b08fd3afc8d0bc16767300f0
Remediation plan target: `.dev/active/1219-docs-prose-markdown-lint/remediation-plan.2026-11-23T12-58.md` (authored by `atomic-planner`)
Source review artifacts:
- `.dev/active/1219-docs-prose-markdown-lint/policy-audit.2026-11-23T12-58.md`
- `.dev/active/1219-docs-prose-markdown-lint/code-review.2026-11-23T12-58.md`
- `.dev/active/1219-docs-prose-markdown-lint/feature-audit.2026-11-23T12-58.md`

## Disposition

Finding R1 of `remediation-inputs.2026-11-23T12-30.md` is resolved: `consumer-onboarding.md` `## Linting` now opens with "Lint steps are part of the written workflow.", the renamed `It` passes, and no "Linting is optional" text remains under `.dev/engineering/documentation-estate/` or `tests/`. All 46 acceptance criteria evaluate PASS, and coverage, toolchain, file-size, bundle-parity, harness-parity, evidence-location, and supply-chain checks are met.

A repository search for the R1 sentence found one related consumer-facing file that this item's workflow change also makes inaccurate and that no epic child corrects. The fix is contained to three statements in one Markdown template and changes no spec acceptance criterion, public interface, validator contract, hook decision, or production logic. It adds one file (`extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md`) to the item's inventory, and the prior cycle was light, so this cycle takes the full path. Under the orchestrate classification rule, a file outside the branch diff makes the cycle a design cycle; the orchestrator owns that mode line.

A second finding concerns the PowerShell coverage artifact: the cycle-1 selection run overwrote `artifacts/pester/powershell-coverage.xml`, which now reports 0.12% repo-wide. The fix is one parallel Pester gate run after the R2 edit; it changes no file in the repository.

Scope boundary: edit only the three statements named below in the one template file, plus new task-check, gate, and self-review evidence. Do not edit any production module, workflow or Vale template, skill surface, bundle copy under `claude-customizations` or `codex-and-agents-customizations`, `spec.md`, `user-story.md`, engineering page, the template `README.md`, or any existing evidence or review record.

## Finding R2 (code review, Major): epic template states that linting is optional

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the template is a repository file that the branch can edit, the accurate wording follows from the init-written workflow and the corrected onboarding page already on this branch, and no sibling item or owner decision is needed.
Finding-Scope: contained

- Location: `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md`
  - line 16 (frontmatter `nfrs` entry): "Linting is optional; the page check is the required page gate."
  - line 82 (`## Non-Goals`): "Adopting a Markdown or prose linter as a required gate; linting stays optional."
  - line 95 (shared design list): "Linting is optional: `init -Write` writes linter configuration as data, and `check` is the required page gate." (continues on line 96)
- Observed: after this item, the init-written `_docs-quality.yml` runs markdownlint through the pinned markdownlint-cli2 action and the pinned, checksum-verified Vale release with the `DocsTonality` style, and an error-level alert fails the Vale step. A consumer that plans an estate from this template is told that linting is optional and that a required linter gate is out of scope, which contradicts the workflow docs init writes. Sibling 1223 lists the template as out of its scope (`.dev/active/1223-docs-epic-scale-routing/spec.md` line 114), and the 1219 non-goals do not exclude it.
- Required:
  1. Line 16: replace with an accurate `nfrs` entry, for example "The init-written workflow runs markdownlint and Vale; the page check is the required page-structure gate." Keep it a single plain YAML list scalar within the epic-manifest YAML subset (no unquoted `: ` sequence, no leading special character).
  2. Line 82: remove the non-goal or replace it with an accurate one (for example, "Adding linters beyond the markdownlint and Vale steps of the init-written workflow.").
  3. Lines 95-96: replace with an accurate statement, for example "Linting: `init -Write` writes linter configuration as data and a workflow that runs markdownlint and Vale; `check` is the required page-structure gate."
  4. Do not change any other line, the manifest fields, waves, or the companion `README.md`. Use no consumer identifier (the onboarding neutrality test scans this file).

## Finding R3 (policy audit and code review, Major): PowerShell coverage artifact reports 0.12%

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the artifact is regenerated by the repository launcher on this machine, no production file changed after the 12-11 gate that measured 96.85%, and no external input or owner decision is needed.
Finding-Scope: contained

- Location: `artifacts/pester/powershell-coverage.xml` (local, gitignored), `sessioninfo start=1795437692434` (2026-11-23 12:41 UTC).
- Observed: the cycle-1 two-file selection run (`task-check.P0-T1.2026-11-23T12-44.md`) rewrote the XML; it reports 61 covered of 48871 lines repo-wide, below the 85% default line threshold. The coverage artifact at the reviewed head is not a gate run.
- Required: after the R2 edit and its task check, run one parallel Pester gate through the launcher (`sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`) as the last test run before review. Record in a new `evidence/qa-gates/pester-gate.<timestamp>.md` the JUnit counts, repo-wide line coverage, and per-file coverage for `DocsPagePlaceholder.psm1`, `DocsLedgerCommands.psm1`, and `DocsProfileCommands.psm1`. Run no selection run after the gate. A launcher exit 75 is a queue timeout: re-run after the holder finishes.

## Verification Commands

1. `Grep 'Linting is optional|linting stays optional'` over `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/`: no match.
2. Through the test-execution launcher (parallel only): `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1 tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1`; exit code 0 and 0 failures; record the result as a new task-check artifact under `.dev/active/1219-docs-prose-markdown-lint/evidence/other/`.
3. Search `tests/` for every test that reads `feature-templates/epic/documentation-estate/epic.md` and record a disposition for each in the task-check artifact.
4. One parallel Pester gate (`sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`) after step 2: exit code 0, 0 failures, repo-wide line coverage at least 85%, `DocsPagePlaceholder.psm1` at least 85%, and no regression against `evidence/baseline/pester-gate.2026-11-23T07-39.md`; record under `evidence/qa-gates/`.
5. Final self-review artifact under `.dev/active/1219-docs-prose-markdown-lint/evidence/qa-gates/` recording the edited lines and the results above.

## Do Not Do

- No edit to any production module, template under `.claude/lib/docs/`, DocsTonality style, skill surface, bundle copy, `spec.md`, `user-story.md`, engineering page, or existing evidence or review file.
- No serial, single-process, shuffled, or reversed test run; no temporary files in tests; no edit or deletion of existing evidence.
- No new Python; no hand edit to a harness-generated file.

## Non-remediation notes

- Warning (file size): `.claude/lib/docs/DocsLedgerCommands.psm1` at 760 logical lines (advisory tier); no action in this item.
- Minor: the Vale download URL in `_docs-quality.yml` line 89 hard-codes `v3.25.1`; the spec AC asserts that literal URL, so it is not changed.
- Info and Nit rows of the code review require no change.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
