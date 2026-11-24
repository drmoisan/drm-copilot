# Code Review: docs-prose-markdown-lint (#1219)

**Review Date:** 2026-11-23
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1219-docs-prose-markdown-lint`
**Feature Folder Selection Rule:** Named by the delegation; no version subfolder exists.
**Base Branch:** `origin/epic/documentation-estate-families-integration` (merge base `7c4bdc734a0c59f9a3057108b719f67adeef88ca`)
**Head Branch:** `feature/docs-prose-markdown-lint-1219` at `69293991ae9585c5a371de4b55ffa5f290554ac9`
**Review Type:** Re-review (remediation cycle 2, R4)

---

## Executive Summary

This re-review covers the full branch diff (77 files) at head `69293991a`. The prior review (`code-review.2026-11-23T12-58.md`) found two Major items: R2, three statements in the bundled epic template `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` that described linting as optional, and R3, a PowerShell coverage XML overwritten by a selection run (0.12% repo-wide).

Cycle 2 (commit `69293991a`) replaced the three template statements and nothing else (`git diff 0f5a4be23..HEAD` on the template: 4 insertions, 4 deletions). The `nfrs` entry is a single plain YAML scalar with no `: ` sequence, the list keeps four entries, and `DocumentationEstateEpicTemplate.Tests.ps1`, `DocumentationEstateOnboarding.Tests.ps1`, and `cross-epic-skill-contract.Tests.ps1` passed (60 cases, 0 failures). The new wording matches the init-written workflow and the corrected onboarding page. R2 is resolved. One parallel Pester gate then regenerated `artifacts/pester/powershell-coverage.xml`: session 13:44:59 to 13:53:19 UTC, 96.85% repo-wide, with per-file figures equal to the evidence record. R3 is resolved.

Reviewed evidence: the refreshed PR context summary and appendix (generated 14:07:41 UTC at `69293991a`), the cycle-2 diff `0f5a4be23..69293991a`, the full branch diff, the cycle-2 evidence files, the coverage and JUnit XML, and bundle pairs compared with `cmp`.

A wider search for the same claim in other wordings ("optional linting", "linting stays optional", "no required linter") outside historical feature records found one remaining current statement: the topic index `.dev/engineering/documentation-estate/README.md` line 36 describes `consumer-onboarding.md` as covering "optional linting". The earlier searches used the tokens "Linting is optional" and "linting stays optional", which do not match this word order. This is recorded as one new Major finding.

**What changed (whole branch):**
- `.claude/lib/docs/templates/_docs-quality.yml`: lint-scope, markdownlint-cli2, Vale install with SHA-256 check, and Vale run steps; actions pinned by commit.
- Five `DocsTonality` Vale styles and the `.vale.ini` change; `DocsPagePlaceholder.psm1` (new) and its wiring in `DocsLedgerCommands.psm1`; five init rows in `DocsProfileCommands.psm1`.
- Bundle mirrors, `core.json`, docs-init skill on all surfaces, `consumer-onboarding.md`, `command-reference.md`, and (cycle 2) the bundled documentation-estate epic template.

**Top 3 risks:**
1. The engineering topic index still tells maintainers that the onboarding page covers "optional linting", while the page and the written workflow now run markdownlint and Vale.
2. The Vale download URL hard-codes `v3.25.1` while the archive name uses `VALE_VERSION` (unchanged from the prior reviews; the checksum check fails closed).
3. Any Pester selection run after the cycle-2 gate would again overwrite the coverage XML; the README fix needs no test run.

**PR readiness recommendation:** **Needs Revision** — change two words in one engineering index row; no code change and no test run is required.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.dev/engineering/documentation-estate/README.md` | line 36 (`## Topic Pages`, `consumer-onboarding.md` row) | The row lists the onboarding page content as "Prerequisites, the optional python pack, optional linting, adoption steps, consumer CI and the epic template". After this item, the page's `## Linting` section (line 33) opens "Lint steps are part of the written workflow." and the init-written workflow runs markdownlint and the pinned Vale release and fails on findings, so "optional linting" is inaccurate. | Replace "optional linting" with "linting" (or "the linting steps") in that row and change no other text. Keep "the optional python pack", which remains accurate. | Same class as R1 and R2: a related statement made inaccurate by this item. Spec `## Scope` item 4 requires the engineering pages that describe the changed behavior to be updated in the same change. No test reads the README and no sibling epic child names it, so no other item corrects it. | `Grep '(?i)(optional[^.\n]{0,40}lint|lint[^.\n]{0,40}optional|no required linter)'` outside `.dev/active`, `.dev/potential`, and `.dev/epics` returns this row only; `consumer-onboarding.md` line 33; spec `## Scope` item 4. |
| Warning | `.claude/lib/docs/DocsLedgerCommands.psm1` | whole file | File is at 760 logical lines (advisory tier, at or above 700). | No action required in this item. | File-size advisory tier. | `awk 'END{print NR}'` = 760. |
| Minor | `.claude/lib/docs/templates/_docs-quality.yml` | line 89 | The download base URL hard-codes `v3.25.1` while `$archiveName` derives from `$env:VALE_VERSION`. | Optional, after this item, with a spec update: build the URL from `$env:VALE_VERSION`. | Two sources for one version; the checksum comparison still fails closed. The spec AC asserts the literal URL. Carried from the prior reviews. | Template lines 84-89; spec `### Workflow template`. |
| Info | `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` | lines 16, 82, 95-96 | R2 fix verified: the three statements now describe the markdownlint and Vale steps of the init-written workflow and name `check` as the required page-structure gate; no consumer identifier; frontmatter still parses. | None. | Resolution record. | Cycle-2 diff; `task-check.P1-T2.2026-11-23T13-28.md`; `pester-gate.2026-11-23T14-00.md`. |
| Info | `artifacts/pester/powershell-coverage.xml` (local, not committed) | `sessioninfo start=1795441499479` | R3 fix verified: the XML holds the cycle-2 gate run (13:44:59 to 13:53:19 UTC); report `LINE` counter 47330 covered, 1541 missed (96.85%); `DocsPagePlaceholder.psm1` 37/37, `DocsLedgerCommands.psm1` 327/328, `DocsProfileCommands.psm1` 92/94. | None. Run no Pester selection before the PR. | Resolution record. | XML counters read by this review; `pester-gate.2026-11-23T14-00.md`. |
| Info | `.claude/lib/docs/templates/page-check/vale/DocsTonality/Exclamation.yml` | lines 6-11 | With `ignorecase: true`, `'!\s+[A-Z]'` also matches a lowercase letter after `!`. | None required; mandated by the spec. | Documents matching behavior. | File content; spec `### Tonality style`. |
| Info | `.claude/lib/docs/templates/_docs-quality.yml` | lines 73-104 | After a `DOCS_LINT_SCOPE_EMPTY` failure, later lint steps still run under `!cancelled()` with empty outputs. | None required; spec D6. | Explains possible secondary log output. | Template; spec D6. |
| Nit | `.claude/lib/docs/DocsPagePlaceholder.psm1` | line 122 | `[OutputType([string[]], [object[]])]` lists `object[]` although the function returns `string[]`. | Optional: declare `[OutputType([string[]])]`. | Help accuracy only. | Lines 122, 129. |

One Major finding blocks readiness (R4, the engineering README index row); no Blocker findings. R2 and R3 of the prior review are resolved and recorded as Info rows.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `Measure-DocsPagePlaceholder` counts on the masked text of the existing page line model after the front-matter body start, so code, comments, and inline code are excluded by the library's own rules; the one-line-break tolerance and blank-line rejection follow the spec.
- `Get-DocsPlaceholderReport` filters `.md` paths ordinally, de-duplicates and sorts through an ordinal `SortedSet`, decodes with the strict UTF-8 helper, and catches only `DecoderFallbackException`.
- `Invoke-DocsCoverageCommand` gains the `placeholders` key and text lines without changing the exit code path; `DocsCoverageReport.psm1` is untouched.
- Cycles 1 and 2 touched no production module.

#### API and safety notes

- Exports are exactly the four spec functions (asserted by test). Script-scope variables are constants. PSScriptAnalyzer reports 0 findings.

#### Error handling and logging

- Module-scope `$ErrorActionPreference = 'Stop'`; read failures other than decoding propagate to the command's existing runtime-error handler.

### Workflow template and Vale style audit

- Three `uses:` references pinned to 40-character SHAs with version comments; `contents: read` only; no `${{` in any `run:` body; every run step `shell: pwsh`.
- Vale archive hash compared with `-cne` and a `throw` before `tar`; only the `vale` member is extracted; the mismatch run and the hyperbole run are recorded.

### Documentation audit

- `consumer-onboarding.md` `## Linting` and `## Consumer CI` are consistent with the written workflow.
- The bundled epic template now states the linting behavior accurately in its `nfrs`, `## Non-Goals`, and `## Shared Design` sections. The replacement non-goal ("Adding linters beyond the markdownlint and Vale steps of the init-written workflow.") is accurate and scoped. The template is neither generated nor mirrored, so a single edit is complete; `Invoke-HarnessGeneration.ps1 -Check` reports no drift.
- The engineering topic index `.dev/engineering/documentation-estate/README.md` still labels the onboarding page as covering "optional linting" (finding above). Other historical mentions are in completed or other features' records under `.dev/active`, `.dev/potential`, and `.dev/epics/documentation-estate-tooling/epic.md`; those are append-only records, not current guidance, and are not findings.

---

## Test Quality Audit

No test changed in cycle 2. The new and changed tests on the branch cover every spec AC that names a Pester assertion.

### Reviewed test and QA artifacts

- `evidence/other/task-check.P1-T2.2026-11-23T13-28.md` — parallel selection (3 shards) of `DocumentationEstateEpicTemplate.Tests.ps1`, `DocumentationEstateOnboarding.Tests.ps1`, and `cross-epic-skill-contract.Tests.ps1`: 60 cases, 0 failures; one disposition per test that reads the template.
- `evidence/qa-gates/pester-gate.2026-11-23T14-00.md` — one full parallel gate after the task check: 29211 cases, 29193 passed, 0 failed, 18 skipped; JUnit header in `artifacts/pester/pester-junit.xml` reads `tests="29215" failures="0" errors="0" disabled="22"`, which the record notes (the header counts disabled cases differently).
- `tests/scripts/claude-lib/docs/DocsPagePlaceholder.Tests.ps1`, `DocsInitTemplate.DocsWorkflow.Tests.ps1`, `DocsLedgerCommands.Tests.ps1`, `DocsPageTemplates.Tests.ps1`, `DocsProfileCommands.Tests.ps1`, `DocumentationEstateOnboarding.Tests.ps1`, `docs-authoring-roles.Skills.Tests.ps1` — unchanged since the prior review; all passed in the gate.
- No test under `tests/` reads `.dev/engineering/documentation-estate/README.md` (search for the path returns no match), so the R4 fix needs no test run.

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

No external research was performed. Sibling ownership of `.dev/engineering/documentation-estate/README.md` was checked by searching `.dev` for the path: only the completed tooling epic and item 1038 records name it; no documentation-estate-families child lists it.

---

## Verdict

R2 and R3 are resolved with verified evidence. One related Major documentation finding remains (R4): the engineering topic index row for `consumer-onboarding.md` still says "optional linting". The fix is two words in one Markdown file, changes no acceptance criterion, interface, validator contract, hook decision, or production logic, and needs no test run. The file is outside the branch diff, so the remediation path is full. The Warning, Minor, Info, and Nit rows are non-blocking.
