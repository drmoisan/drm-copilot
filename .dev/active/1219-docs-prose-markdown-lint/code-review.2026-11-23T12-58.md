# Code Review: docs-prose-markdown-lint (#1219)

**Review Date:** 2026-11-23
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1219-docs-prose-markdown-lint`
**Feature Folder Selection Rule:** Named by the delegation; no version subfolder exists.
**Base Branch:** `origin/epic/documentation-estate-families-integration` (merge base `7c4bdc734a0c59f9a3057108b719f67adeef88ca`)
**Head Branch:** `feature/docs-prose-markdown-lint-1219` at `0f5a4be23d40dbc1b08fd3afc8d0bc16767300f0`
**Review Type:** Re-review (remediation cycle 1, R4)

---

## Executive Summary

This re-review covers the full branch diff (65 files) at head `0f5a4be23`. The prior review (`code-review.2026-11-23T12-30.md`) found one Major item, R1: the stale sentence "Linting is optional." in `.dev/engineering/documentation-estate/consumer-onboarding.md` and its assertion in `DocumentationEstateOnboarding.Tests.ps1`. Cycle 1 (commit `0f5a4be23`) replaced the sentence with "Lint steps are part of the written workflow.", kept the "`check` is the required page gate: ..." sentence, and renamed the `It` and its asserted token. The rest of the `## Linting` section is consistent with the replacement. A search for "Linting is optional" under `.dev/engineering/documentation-estate/` and `tests/` returns no match, the renamed `It` name occurs once under `tests/`, and the task check records 23 passed, 0 failed in a parallel selection run. R1 is resolved.

Reviewed evidence: the refreshed PR context summary and appendix (generated 12:50:25 UTC at `0f5a4be23`), the cycle-1 diff `16b38d3cf..0f5a4be23`, the full branch diff, `evidence/other/task-check.P0-T1.2026-11-23T12-44.md`, the final gate artifacts, and bundle pairs compared with `cmp`.

The search for the R1 sentence across the repository found the same statement in a consumer-facing file that this item's change also makes inaccurate. The bundled epic template `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` states that linting is optional (line 16, `nfrs`; line 95, shared design) and lists "Adopting a Markdown or prose linter as a required gate; linting stays optional." as a non-goal (line 82). The template is pushed down to consumer repositories, and the epic child that edits epic-scale guidance (1223) excludes it from scope. This is recorded as one new Major finding.

**What changed (whole branch):**
- `.claude/lib/docs/templates/_docs-quality.yml`: lint-scope, markdownlint-cli2, Vale install with SHA-256 check, and Vale run steps; actions pinned by commit.
- Five `DocsTonality` Vale styles and the `.vale.ini` change; `DocsPagePlaceholder.psm1` (new) and its wiring in `DocsLedgerCommands.psm1`; five init rows in `DocsProfileCommands.psm1`.
- Bundle mirrors, `core.json`, docs-init skill on all surfaces, `consumer-onboarding.md` (including the cycle-1 sentence), `command-reference.md`.

**Top 3 risks:**
1. The bundled epic template still tells consumer planners that linting is optional and that a required linter gate is a non-goal, while the init-written workflow now fails on markdownlint and error-level Vale findings.
2. The Vale download URL hard-codes `v3.25.1` while the archive name uses `VALE_VERSION` (unchanged from the prior review; the checksum check fails closed).
3. The local `artifacts/pester/powershell-coverage.xml` now holds the cycle-1 selection run rather than the final gate and reports 0.12% repo-wide.

**PR readiness recommendation:** **Needs Revision** — correct three sentences in one bundled template and re-run the single Pester gate; no code change is required.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` | lines 16, 82, 95 | The consumer epic template states "Linting is optional; the page check is the required page gate." (`nfrs`), "Adopting a Markdown or prose linter as a required gate; linting stays optional." (`## Non-Goals`), and "Linting is optional: `init -Write` writes linter configuration as data, and `check` is the required page gate." (shared design). After this item the init-written `_docs-quality.yml` runs markdownlint and Vale and an error-level alert fails the job, so these statements are inaccurate for a consumer that plans an estate from the template. | Reword the three statements to state that the init-written workflow runs markdownlint and the pinned Vale release and that `check` remains the required page-structure gate; replace the non-goal with an accurate one or remove it. Keep the frontmatter within the epic-manifest YAML subset and run `DocumentationEstateEpicTemplate.Tests.ps1` and `DocumentationEstateOnboarding.Tests.ps1` (neutrality test reads this file) through the launcher. | Same class as R1: a related statement falsified by this item's change. Sibling 1223 excludes the template (`1223-docs-epic-scale-routing/spec.md` line 114) and the 1219 non-goals do not exclude it, so no other item corrects it. | `Grep 'Linting is optional'` over the repository; template lines 16, 82, 95; `.dev/active/1223-docs-epic-scale-routing/spec.md` line 114. |
| Warning | `.claude/lib/docs/DocsLedgerCommands.psm1` | whole file | File is at 760 logical lines (advisory tier, at or above 700). | No action required in this item. | File-size advisory tier. | `awk 'END{print NR}'` = 760. |
| Minor | `.claude/lib/docs/templates/_docs-quality.yml` | line 89 | The download base URL hard-codes `v3.25.1` while `$archiveName` derives from `$env:VALE_VERSION`. | Optional, after this item, with a spec update: build the URL from `$env:VALE_VERSION`. | Two sources for one version; the checksum comparison still fails closed. Carried from the prior review. | Template lines 84-89; spec `### Workflow template`. |
| Major | `artifacts/pester/powershell-coverage.xml` (local, not committed) | `sessioninfo start=1795437692434` | The cycle-1 selection run (2026-11-23 12:41 UTC) rewrote the coverage XML; it now reports 61 covered of 48871 lines (0.12% repo-wide), below the 85% default. The coverage artifact at the reviewed head is therefore not a gate run, and the review procedure reads the artifact without regenerating it. | Run one parallel Pester gate through the launcher (`run-test-suite.sh pester`) after the R2 fix, as the last test run before review, and record repo-wide and per-file figures under `evidence/qa-gates/`. | Coverage verification is mandatory for PowerShell, which has changed files on the branch. No production file changed after the 12-11 gate, so the 96.85% figure is expected to reproduce. | `git diff --name-only 16b38d3cf 0f5a4be23`; XML header and report counters; stop hook `validate-feature-review-coverage`. |
| Info | `.claude/lib/docs/templates/page-check/vale/DocsTonality/Exclamation.yml` | lines 6-11 | With `ignorecase: true`, `'!\s+[A-Z]'` also matches a lowercase letter after `!`. | None required; mandated by the spec. | Documents matching behavior. | File content; spec `### Tonality style`. |
| Info | `.claude/lib/docs/templates/_docs-quality.yml` | lines 73-104 | After a `DOCS_LINT_SCOPE_EMPTY` failure, later lint steps still run under `!cancelled()` with empty outputs. | None required; spec D6. | Explains possible secondary log output. | Template; spec D6. |
| Nit | `.claude/lib/docs/DocsPagePlaceholder.psm1` | line 122 | `[OutputType([string[]], [object[]])]` lists `object[]` although the function returns `string[]`. | Optional: declare `[OutputType([string[]])]`. | Help accuracy only. | Lines 122, 129. |

Two Major findings block readiness (R2 epic template, R3 coverage artifact); no Blocker findings. R1 of the prior review is resolved and is not repeated in the table.

Revision note: this review was revised before it completed, after the stop hook `validate-feature-review-coverage` reported the 0.12% artifact figure; the coverage-artifact row moved from Info to Major.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `Measure-DocsPagePlaceholder` counts on the masked text of the existing page line model after the front-matter body start, so code, comments, and inline code are excluded by the library's own rules; the one-line-break tolerance and blank-line rejection follow the spec.
- `Get-DocsPlaceholderReport` filters `.md` paths ordinally, de-duplicates and sorts through an ordinal `SortedSet`, decodes with the strict UTF-8 helper, and catches only `DecoderFallbackException`.
- `Invoke-DocsCoverageCommand` gains the `placeholders` key and text lines without changing the exit code path; `DocsCoverageReport.psm1` is untouched.
- Cycle 1 touched no production file.

#### API and safety notes

- Exports are exactly the four spec functions (asserted by test). Script-scope variables are constants. PSScriptAnalyzer reports 0 findings.

#### Error handling and logging

- Module-scope `$ErrorActionPreference = 'Stop'`; read failures other than decoding propagate to the command's existing runtime-error handler.

### Workflow template and Vale style audit

- Three `uses:` references pinned to 40-character SHAs with version comments; `contents: read` only; no `${{` in any `run:` body; every run step `shell: pwsh`.
- Vale archive hash compared with `-cne` and a `throw` before `tar`; only the `vale` member is extracted; the mismatch run and the hyperbole run are recorded.

### Documentation audit (cycle 1 and related pages)

- `consumer-onboarding.md` `## Linting` now opens with "Lint steps are part of the written workflow." and states that `check` is the required page gate, followed by the paragraph describing the markdownlint and Vale steps. The section is internally consistent.
- The bundled epic template contradicts that section (finding above). Its companion `README.md` contains no lint statement.

---

## Test Quality Audit

The new and changed tests cover every spec AC that names a Pester assertion. Cycle 1 renamed one `It` and changed one asserted token; the assertion that `check` is the required page gate is kept.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` — `It 'states that lint steps are part of the written workflow and check is the required page gate'` asserts `Lint steps are part of the written workflow` and `` `check` is the required page gate ``; the name is unique under `tests/` (one case-insensitive match).
- `evidence/other/task-check.P0-T1.2026-11-23T12-44.md` — parallel selection (2 workers) of the onboarding test and `test-name-uniqueness.Tests.ps1`: 23 cases, 0 failures; dispositions recorded for each test that reads the edited section.
- `tests/scripts/claude-lib/docs/DocsPagePlaceholder.Tests.ps1`, `DocsInitTemplate.DocsWorkflow.Tests.ps1`, `DocsLedgerCommands.Tests.ps1`, `DocsPageTemplates.Tests.ps1`, `DocsProfileCommands.Tests.ps1`, `docs-authoring-roles.Skills.Tests.ps1` — unchanged since the prior review; all passed in the final gate.
- `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` (not in the diff) — parses the epic template frontmatter and checks the manifest and waves; it asserts no lint statement, so the template fix must keep the frontmatter parseable.

### Quality assessment prompts

- **Determinism:** No clock, network, random, or temporary-file use in tests.
- **Isolation:** One behavior per `It`.
- **Speed:** In-memory tests.
- **Diagnostics:** Exact comparisons and `-Because` clauses where ordering is asserted.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials; the workflow uses no secrets. |
| No unsafe subprocess or command construction | ✅ PASS | No `Invoke-Expression`; Vale roots passed as an array; no `${{` in `run:` bodies. |
| Input validation at boundaries | ✅ PASS | Lint scope throws on zero roots; counter filters non-`.md` and invalid UTF-8 pages. |
| Error handling remains explicit | ✅ PASS | Narrow catch; checksum mismatch throws before extraction. |
| Configuration / path handling is safe | ✅ PASS | Downloads to `$env:RUNNER_TEMP`; read-only permissions. |
| Supply chain pinning | ✅ PASS | Actions pinned by SHA; Vale pinned by version and SHA-256. |

---

## Research Log

No external research was performed. Sibling ownership of the epic template was checked in `.dev/active/1223-docs-epic-scale-routing/spec.md` and `.dev/epics/documentation-estate-families/epic.md`.

---

## Verdict

R1 is resolved. One related Major documentation finding remains: the bundled consumer epic template states in three places that linting is optional, which this item's workflow change makes inaccurate, and no other epic child corrects it. The fix is three sentences in one Markdown template, changes no acceptance criterion, interface, or production logic, and can be made on the branch without external input. It adds one file to the item's inventory, and the previous cycle was light, so the next cycle is full. A second Major finding is the PowerShell coverage artifact, which a selection run overwrote (0.12% repo-wide); one parallel Pester gate after the R2 fix regenerates it. The Warning, Minor, Info, and Nit rows are non-blocking.
