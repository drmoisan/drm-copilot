# 2026-11-23-docs-family-page-templates - Plan

- **Issue:** #1222
- **Parent (optional):** #1217 (epic documentation-estate-families, wave 0)
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23T00-39
- **Status:** Draft
- **Version:** 0.3

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell policy: `.claude/rules/powershell.md`. Tool routes, launchers, command-text restrictions, and the batch budget are owned by the `execution-environment` skill and are not restated here.

**All work must comply with these policies; do not duplicate their content here.**

## Execution Constraints

- Sources: `spec.md` (acceptance criteria, `## Decisions` Q1 to Q11, Approach A), `user-story.md`, `issue.md`, and `research/research.2026-11-23T05-45.md` (section 6 holds the section lists and table skeletons).
- `SCRATCH` is `<session scratchpad>/issue-1222/`. Every helper script (for example the template copy script) lives under `SCRATCH`; evidence records the token `SCRATCH`, never a host path.
- Autonomous mode: do not halt for decisions; take the recommended option and record it in `<FEATURE>/evidence/other/decision.<timestamp>.md`.
- No new Python. Implementation is PowerShell 7.4 or bash. Existing Python contract tests may be run.
- Parallel-only test runs: no serial, single-process, shuffled, or reversed runs. Evidence is append-only; timestamps are read from the clock and never back-dated. Related findings are fixed inside this item by remediation cycles; only unrelated findings become issues.
- Templates use LF line endings and are domain-neutral. Template Markdown is written by Write or a copy script; the batch-budget hook does not see those files and the files are not PowerShell or Python, so the cap does not bind.
- File-size hard limit is 800 lines; each new test file stays under 500 lines; tests create no temporary file.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baselines
- [x] [P0-T1] Capture the PowerShell static baseline (PoshQC format check and PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`) over `tests/scripts/claude-runtime/` and `tests/scripts/claude-lib/docs/`, written to `<FEATURE>/evidence/baseline/powershell-static.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with the finding count per tool; the baseline is taken before any file is changed, so a format run that rewrites nothing is the success observation.
- [x] [P0-T2] Run the `Phase 0 baseline` Pester gate once through the launcher `pester` suite and record `<FEATURE>/evidence/baseline/pester-gate.<timestamp>.md`.
  - Acceptance: `Output Summary:` holds the pass and fail counts read from `artifacts/pester/pester-junit.xml` and the repo-wide line coverage read from `artifacts/pester/powershell-coverage.xml`; PoshQC MCP results are not evidence.
- [x] [P0-T3] Run the push-down contract tests `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_codex_and_agents_pack_manifest_completeness.py` once through the launcher `pytest` suite, plus `generate_codex_agent_variants.py --check`, and record `<FEATURE>/evidence/baseline/pushdown-contracts.<timestamp>.md`.
  - Acceptance: the artifact records pass and fail counts and the generator exit code; no coverage figure is required because no Python production file changes.

### Phase 1 — Templates
- [x] [P1-T1] Create `product-overview.md`, `security.md`, and `adr.md` under `.claude/skills/docs-author-page/templates/` with mode `explanation`, the Behavior-table H2 sections in order, the table skeletons of research section 6, `surface_refs: []`, and the placeholder tokens `"<owner-id>"`, `"<yyyy-mm-dd>"`, `["<audience-id>"]`.
  - Acceptance: front matter holds exactly the five keys; `adr.md` opens with a note giving the `NNNN-short-slug.md` naming, has no Review Date section, and names no repository directory; no `How to ` or `Step <n>` heading; none of the non-portable content of research section 5 appears.
- [x] [P1-T2] Create `onboarding.md`, `runbook.md`, and `playbook.md` in the same folder with mode `how-to`, the Behavior-table H2 sections in order, and literal ordered-list lines (`1.`, `2.`) in Steps (onboarding), Diagnostics and Remediation (runbook), and Coordination Steps (playbook).
  - Acceptance: each file has at least one line matching the ordered-list pattern of `DOCS_PAGE_MODE_STEPS_MISSING` outside fences and comments; Related sections use plain bullets, not Markdown links.
- [x] [P1-T3] Create `service-management.md` (mode `explanation`; H2 parts SLI, SLO and SLA; Change and Release Management; Incident Management with the H3 subsections of research section 6 and a leading note to keep the covered part and delete the others) and `alerts-catalog.md` (mode `reference`; Purpose, Catalog table, Severity Scale table, Related) in the same folder.
  - Acceptance: `alerts-catalog.md` contains no `docs:generated:start` or `docs:generated:end` marker and no concrete alert identifier or condition.
- [x] [P1-T4] Edit `.claude/skills/docs-author-page/templates/architecture-overview.md` to add `## Data Flow`, `## Trust Boundaries`, and `## Failure Domains` between `## Interactions` and `## Boundaries and Constraints`, each with the table skeleton of research section 6; mode stays `explanation`; the existing diagram sentence stays.
  - Acceptance: the heading order is Components, Interactions, Data Flow, Trust Boundaries, Failure Domains, Boundaries and Constraints.
- [x] [P1-T5] Copy the eight new templates and the edited `architecture-overview.md` byte-identically (LF) from `.claude/skills/docs-author-page/templates/` to `.agents/skills/docs-author-page/templates/` and to the two bundle roots `extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-author-page/templates/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-author-page/templates/`, through a copy script under `SCRATCH`.
  - Acceptance: `git status --porcelain` lists nine files at each of the four roots (the 36 file entries of eight additions and one modification per root) and no file contains a carriage return.
  - Existing tests: `docs-authoring-roles.Templates.Tests.ps1` (`covers 32 template files`, front-matter and body-rule cases over the existing `Templates` key) is unchanged because the new ids are not in that key; `docs-authoring-roles.Mirrors.Tests.ps1` (the per-template byte identity case and the manifest counts 23 and 20) is unchanged for the same reason. The extended `architecture-overview.md` stays covered by both and must still pass them.
- [x] [P1-T6] Add the eight new template paths, once each and in alphabetical position with the existing template lines, to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/shared.json`; the Codex `core.json` lines are edited by hand because `render_manifest` adds no skill or template paths. The task follows P1-T5 so the bundled templates and their manifest entries land before the Phase 1 gate.
  - Acceptance: `test_bundled_claude_files_are_listed_in_some_pack_manifest` and `test_pre_existing_exception_set_is_empty` in `test_push_down_claude_pack_manifest_completeness.py`, and `test_bundled_codex_files_are_listed_in_some_pack_manifest` in `test_push_down_codex_and_agents_pack_manifest_completeness.py`, pass; each manifest remains valid JSON.
  - Existing tests: the two `lists every ... file of the feature exactly once` cases of `docs-authoring-roles.Mirrors.Tests.ps1` (expected counts 23 and 20) read the `Templates` key, which does not change, so they are unchanged and still pass with the added lines.
- [x] [P1-T7] [phase-gate] Run the full toolchain loop (stages 1 to 6 per `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill) and record `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md`.
  - Acceptance: the unit and contract stages pass with no `[expect-fail]` test, including the manifest-completeness tests named in P1-T6, the push-down resource-contract tests, and the `Templates` and `Mirrors` suites; SKILL.md is unchanged in this phase, so no SKILL.md parity or generator test is affected.

### Phase 2 — Helper Key and Tests
- [ ] [P2-T1] Add the `FamilyTemplateModes` key (an ordered map of the eight new ids to their modes) to `Get-DocsAuthoringNamedSet` in `tests/scripts/claude-runtime/DocsAuthoringRoles.Helpers.ps1`, additive, existing keys unchanged.
  - Existing tests that read the helper: `docs-authoring-roles.Templates.Tests.ps1`, `docs-authoring-roles.Mirrors.Tests.ps1`, `docs-authoring-roles.WorkflowText.Tests.ps1`, `docs-authoring-roles.Skills.Tests.ps1`, `docs-authoring-roles.Registration.Tests.ps1`, `docs-authoring-roles.Allowlist.Tests.ps1`: all unchanged, because they read the `Templates`, `TemplateModes`, `Roles`, `Skills`, and table keys, none of which changes.
- [ ] [P2-T2] Create `tests/scripts/claude-runtime/docs-authoring-roles.FamilyTemplates.Tests.ps1` (under 500 lines) that reads `FamilyTemplateModes`, `Get-DocsAuthoringSkillRoot`, and `Get-DocsPackManifestPath`, with one `It` per rule so each rule has a test that fails when it is broken:
  - SHA-256 identity of the nine templates at four roots; each new path exactly once in the three manifests;
  - LF-only: no carriage return in any of the nine templates at any of the four roots;
  - five-key JSON front matter with `surface_refs: []` through `ConvertFrom-DocsPageFrontMatter`; the Behavior-table mode and ordered H2 sections; ordered-list lines in the three how-to templates;
  - no `How to ` or `Step <n>` heading in explanation and reference templates; no generated marker in `alerts-catalog`; the architecture-overview section order and mode;
  - `adr.md`: the leading note holds `NNNN-short-slug.md`, no heading matches `Review Date`, and no repository directory path (`docs/` or `src/`) appears;
  - `service-management.md`: the three H2 part headings each hold the H3 subsections of research section 6 in order, and a leading note before the first H2 tells the author to keep the covered part and delete the others;
  - domain-neutrality over all nine templates: none contains `drm-copilot`, `ALR-`, `Sev1`, `Sev2`, `Sev3`, `src/`, `tests/`, `docs/architecture/adr`, `review_due`, `SME input required`, or a `diataxis:` key;
  - Related sections: the body of every H2 whose title starts with `Related` holds no Markdown link (`](`) and at least one plain bullet;
  - every template id in a table row of each SKILL.md copy with its mode.
  - Acceptance: the SKILL.md row case passes only after P3-T2, so it is tagged `[expect-fail]` until then and its failure is named in `phase-gate.P2` evidence; every other case passes; `AfterAll` restores any imported state and `Invoke-PoshQCLeakScan` reports no new finding.
- [ ] [P2-T3] Create `tests/scripts/claude-lib/docs/DocsAuthorPageTemplates.Acceptance.Tests.ps1` (under 500 lines; `BeforeAll` follows `DocsPageCheck.Tests.ps1` imports and profile construction) that enumerates the template directory at discovery, substitutes the placeholder tokens in memory (an element id of `cli-command-` plus 64 hexadecimal characters for reference templates with a generated block), places the page under `docs/guide/` with a linking `docs/README.md`, runs `Get-DocsPageCheckFinding`, and asserts zero findings of severity `error`; plus negative case 1 (a how-to template with ordered-list lines removed yields `DOCS_PAGE_MODE_STEPS_MISSING`) and negative case 2 (an explanation template with an added `## How to ...` heading yields `DOCS_PAGE_MODE_INSTRUCTION_HEADING`).
  - Acceptance: the cases pass in a parallel Pester run, read committed files with `[System.IO.File]::ReadAllText`, create no temporary file, and `AfterAll` removes imported modules and helper functions.
  - Existing tests: `DocsPageCheck.Tests.ps1` (696 lines) is not edited and is unchanged.
- [ ] [P2-T4] [phase-gate] [expect-fail] Run the full toolchain loop and record `<FEATURE>/evidence/qa-gates/phase-gate.P2.<timestamp>.md`; the unit stage accepts only the named SKILL.md table-row case of `docs-authoring-roles.FamilyTemplates.Tests.ps1` as an expected failure, confirmed failing, and every other test passes.

### Phase 3 — SKILL.md and Generation
- [ ] [P3-T1] Edit `.agents/skills/docs-author-page/SKILL.md` (the source): replace the `## Templates` table with columns `Template`, `diataxis_mode`, and `Use when` listing all 16 templates; in `## Steps` item 1, after its first sentence, state that the author chooses by family from the table, that a family page without a surface element uses `surface_refs: []`, and that `alerts-catalog` pages are `reference` and may need their own `directory_modes` entry. Step 6 and the three `find` strings of `scripts/harness-generation/sources/skills/docs-author-page.substitutions.json` stay unchanged.
  - Acceptance: `docs-authoring-roles.WorkflowText.Tests.ps1` (the `## Steps` tokens `may be refused by the runtime` and `the root writes it`) is unchanged and passes; `docs-authoring-roles.Skills.Tests.ps1` and `DocumentationEstateOnboarding.Tests.ps1` name the skill only and are unchanged.
- [ ] [P3-T2] Run `scripts/harness-generation/Invoke-HarnessGeneration.ps1` to regenerate `.claude/skills/docs-author-page/SKILL.md`, run it again with `-Check`, inspect `git status --porcelain`, and copy by script any bundle SKILL.md (`extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-author-page/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-author-page/SKILL.md`) the generator did not write.
  - Acceptance: `-Check` exits 0 and reports no drift; the four SKILL.md copies hash equal to their sources per `docs-authoring-roles.Mirrors.Tests.ps1`; the `[expect-fail]` tag of P2-T2 is removed and its SKILL.md row case now passes.
- [ ] [P3-T3] [phase-gate] Run the full toolchain loop, with `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` in the contract stage, and record `<FEATURE>/evidence/qa-gates/phase-gate.P3.<timestamp>.md`.

### Phase 4 — Final QA
- [ ] [P4-T1] Run the final static loop (PoshQC format, PSScriptAnalyzer) over the new and touched `.ps1` files and record `<FEATURE>/evidence/qa-gates/final-static-powershell.<timestamp>.md` with each step's command, exit code, and finding count; restart from format if any step rewrites a file.
- [ ] [P4-T2] Run the final Pester gate once through the launcher `pester` suite with coverage and record `<FEATURE>/evidence/qa-gates/final-pester-gate.<timestamp>.md`, comparing it with the P0-T2 artifact; run `Invoke-PoshQCLeakScan`; record `<FEATURE>/evidence/qa-gates/final-leak-scan.<timestamp>.md`.
  - Acceptance: no new failing test, repo-wide coverage not below the baseline, per-file figures read from the single run; the changed files are test infrastructure and Markdown, so no production file enters the denominator.
- [ ] [P4-T3] Run the push-down contract tests, `generate_codex_agent_variants.py --check`, and `HarnessGeneration.RepoGate.Tests.ps1` and record `<FEATURE>/evidence/qa-gates/final-contracts.<timestamp>.md`; confirm through `git diff --name-only` against the merge base of `origin/main` and `HEAD`, with `git status --porcelain`, that no path under `.claude/lib/docs/` changed.
- [ ] [P4-T4] Check off the acceptance criteria in `spec.md` and `user-story.md` per the `acceptance-criteria-tracking` skill, then walk the three templates under `.dev/templates/policy_audit/` against the branch diff from the merge base and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item; fix every FAIL row and re-run P4-T1 to P4-T3 before rewriting it.

## Pre-Mortem

- Review checklists: a reviewer could flag tone in placeholder text or a hand-edited generated file. Mitigation: neutral literal placeholders; SKILL.md is edited only in the `.agents` source and regenerated; the P4-T4 self-review walks the policy-audit, code-review, and feature-audit templates.
- Coverage: only Markdown, JSON manifests, and test files change, so the PowerShell coverage denominator is unchanged. Mitigation: the P0-T2 baseline is compared with the P4-T2 run, and the acceptance negative cases prove the tests can fail.
- Mirror parity: nine templates at four roots, three manifests, and SKILL.md at source, generated, and two bundle copies. Mitigation: one copy script (P1-T5), one manifest task (P1-T6, ahead of the Phase 1 gate), the generator `-Check` (P3-T2), and contract tests in every gate. The `execution-environment` brief states no fact this plan changes (no CI job, status context, tool route, or batch-budget rule), so no brief-update task is needed.
- File size: templates and SKILL.md are Markdown and exempt; both new test files stay under 500 lines and `DocsPageCheck.Tests.ps1` is not extended.
- Test isolation: gates are one `Invoke-PoshQCParallelTest` run through the launcher and one `pytest -n auto` run, each re-run only after a fix; no Jest change. The new tests use in-memory content, create no temporary file, and clean imported modules and functions in `AfterAll`; `Invoke-PoshQCLeakScan` is run in P4-T2.
- CI-only behavior: line endings are LF under `.gitattributes` and byte identity is hash-compared; paths use `Join-Path` and forward slashes with exact case; no fixture reads gitignored `artifacts/` state.
- Evidence: all artifacts are under `<FEATURE>/evidence/<kind>/` as `<name>.<timestamp>.md` with clock-read UTC stamps, append-only; counts come from the Pester JUnit and coverage files, never PoshQC MCP results.

## Size Justification

The plan has 21 canonical tasks, one above the guideline of 20, in about 115 lines, within the legacy 40-task and 400-line pair and the 250-line guideline. The excess comes from three mandatory phase gates, three Phase 0 baselines (static, Pester, push-down contracts), and template authoring split into four tasks by mode so each task keeps one binary outcome. Merging tasks would create bucket tasks.

## Test Plan

- Unit: `docs-authoring-roles.FamilyTemplates.Tests.ps1` and `DocsAuthorPageTemplates.Acceptance.Tests.ps1`, with the existing `docs-authoring-roles.*` suites unchanged.
- Integration: CI integration and golden lanes only.
- Manual/CLI: generator `-Check`; push-down contract pytest files.
- Coverage evidence: baselines under `<FEATURE>/evidence/baseline/`, final artifacts under `<FEATURE>/evidence/qa-gates/`, compared in P4-T2.
- AC to task map: template content criteria, P1-T1 to P1-T4 and P2-T2; checker acceptance and negative cases, P2-T3; SKILL.md criteria, P3-T1 and P3-T2; parity and manifests, P1-T5, P1-T6, P2-T2; regression, contract, no `.claude/lib/docs/` change, and size criteria, P0-T3, P4-T2, P4-T3.

## Open Questions / Notes

- Decisions Q1 to Q11 are recorded in `spec.md` `## Decisions`; no open question remains.
- The alerts-catalog directory-mode interaction is flagged to the epic in `spec.md` `## Cross-Feature Notes`.
