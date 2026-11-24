# Code Review: docs-prose-markdown-lint (#1219)

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1219-docs-prose-markdown-lint`
**Feature Folder Selection Rule:** Named by the delegation; no version subfolder exists.
**Base Branch:** `origin/epic/documentation-estate-families-integration` (merge base `6624aac72e7c30d69b947a9b134ad4f04c3caaff`)
**Head Branch:** `feature/docs-prose-markdown-lint-1219` at `6d4e82d7acd24bf47aad7cbd4428a943cce56de1`
**Review Type:** Re-review (remediation cycle 3)

---

## Executive Summary

This re-review covers the full branch diff (90 files) at head `6d4e82d7a`, measured from the merge base `6624aac72`. The prior review (`code-review.2026-11-23T14-11.md`) found one Major item, R4: the engineering topic index `.dev/engineering/documentation-estate/README.md` line 36 described the onboarding page as covering "optional linting".

Cycle 3 replaced "optional linting" with "linting" in that row and changed no other line of the README (`git diff 6624aac72..HEAD` on the file: 1 insertion, 1 deletion). The row now reads "Prerequisites, the optional python pack, linting, adoption steps, consumer CI and the epic template". A search of tracked files for the claim in both word orders and for "no required linter", outside historical feature records, returns only this row, where "optional" qualifies the python pack. R4 is resolved.

The branch then merged the integration tip `6624aac72` (merge commit `ebfbe0da6`). The merge was clean and is neutral for the item: the per-path numstat of the item diff is the same across the old base `7c4bdc734` and the new base `6624aac72` for every pre-existing path. Integration content landed in five files the item also changes (the docs-init skill and its three copies, `core.json`, and `DocsProfileCommands.Tests.ps1`); the item's own lines in those files are unchanged, and the added content is the #1218 families section, the #1218 and #1231 manifest entries, and one #1218 test. A targeted parallel Pester run of 1029 cases over every test that reads the item's files passed with 0 failures, and the harness check and five push-down contract tests passed.

Reviewed evidence: the refreshed PR context summary and appendix (generated 2026-11-24 03:59:31 UTC at `6d4e82d7a`), the cycle-3 diff `69293991a..6d4e82d7a`, the full branch diff, the cycle-3 evidence files, the current coverage and JUnit XML, and bundle pairs compared with `cmp`.

**What changed (whole branch):**
- `.claude/lib/docs/templates/_docs-quality.yml`: lint-scope, markdownlint-cli2, Vale install with SHA-256 check, and Vale run steps; actions pinned by commit.
- Five `DocsTonality` Vale styles and the `.vale.ini` change; `DocsPagePlaceholder.psm1` (new) and its wiring in `DocsLedgerCommands.psm1`; five init rows in `DocsProfileCommands.psm1`.
- Bundle mirrors, `core.json`, docs-init skill on all surfaces, `consumer-onboarding.md`, `command-reference.md`, the bundled documentation-estate epic template (cycle 2), and the engineering README index row (cycle 3).

**Top 3 risks:**
1. CI has not run: no PR exists for the branch yet, so the integration-lane tests and the CI quality checks are unconfirmed at the head.
2. The local coverage XML now holds the cycle-3 targeted run (selection population only); any consumer that reads its report-level counter as a repo-wide figure would see 16.26%. The repo-wide figure of record is the cycle-2 full gate.
3. The Vale download URL hard-codes `v3.25.1` while the archive name uses `VALE_VERSION` (unchanged from the prior reviews; the checksum check fails closed).

**PR readiness recommendation:** **Ready** — no Blocker or Major finding remains.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.dev/engineering/documentation-estate/README.md` | line 36 (`## Topic Pages`, `consumer-onboarding.md` row) | R4 fix verified: the row reads "Prerequisites, the optional python pack, linting, adoption steps, consumer CI and the epic template"; only that line changed. | None. | Resolution record. | `git diff 6624aac72..HEAD -- .dev/engineering/documentation-estate/README.md`; `git grep -i -P` search returns this row only. |
| Info | `.dev/active/1219-docs-prose-markdown-lint/evidence/other/decisions.2026-11-23T14-26.md` | D1 | The plan's P1-T1 acceptance ("the proximity search returns no match") was unsatisfiable, because the retained phrase "the optional python pack, linting" still matches the 40-character proximity pattern. The executor recorded the deviation and verified the narrower assertion (no occurrence of "optional linting"). | None. | The deviation is recorded and the narrower assertion matches the finding's intent; the retained phrase is accurate. | Decision record; this review's search. |
| Info | `artifacts/pester/powershell-coverage.xml` (local, not committed) | `sessioninfo start=1795492062603` | The XML holds the cycle-3 targeted run (03:47:42 to 03:49:13 UTC, 2026-11-24): report `LINE` counter 7983 covered, 41111 missed (selection population). Per-file counters for the item modules equal the cycle-2 gate: `DocsPagePlaceholder.psm1` 37/37, `DocsLedgerCommands.psm1` 327/328, `DocsProfileCommands.psm1` 92/94. | None. The repo-wide figure of record is the cycle-2 full gate (96.85%). | Owner-directed targeted run (instruction dated 2026-11-23); recorded in `decisions.2026-11-24T03-56.md` D1. | XML counters read by this review; `pester-gate.2026-11-24T03-56.md`. |
| Info | `tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1`, `.claude/skills/docs-init/SKILL.md` (and copies), `core.json` | merged hunks | The merge `ebfbe0da6` added integration content (#1218, #1231) to files the item changes; the item's own hunks are unchanged and the merged files remain consistent (skill copies byte-identical; harness check no drift). | None. | Merge neutrality record. | Numstat comparison across bases; `git merge-tree --write-tree` clean; targeted run 1029 passed. |
| Warning | `.claude/lib/docs/DocsLedgerCommands.psm1` | whole file | File is at 760 logical lines (advisory tier, at or above 700). | No action required in this item. | File-size advisory tier. | `awk 'END{print NR}'` = 760. |
| Minor | `.claude/lib/docs/templates/_docs-quality.yml` | line 89 | The download base URL hard-codes `v3.25.1` while `$archiveName` derives from `$env:VALE_VERSION`. | Optional, after this item, with a spec update: build the URL from `$env:VALE_VERSION`. | Two sources for one version; the checksum comparison still fails closed. The spec AC asserts the literal URL. Carried from the prior reviews. | Template lines 84-89; spec `### Workflow template`. |
| Info | `.claude/lib/docs/templates/page-check/vale/DocsTonality/Exclamation.yml` | lines 6-11 | With `ignorecase: true`, `'!\s+[A-Z]'` also matches a lowercase letter after `!`. | None required; mandated by the spec. | Documents matching behavior. | File content; spec `### Tonality style`. |
| Info | `.claude/lib/docs/templates/_docs-quality.yml` | lines 73-104 | After a `DOCS_LINT_SCOPE_EMPTY` failure, later lint steps still run under `!cancelled()` with empty outputs. | None required; spec D6. | Explains possible secondary log output. | Template; spec D6. |
| Nit | `.claude/lib/docs/DocsPagePlaceholder.psm1` | line 122 | `[OutputType([string[]], [object[]])]` lists `object[]` although the function returns `string[]`. | Optional: declare `[OutputType([string[]])]`. | Help accuracy only. | Lines 122, 129. |

No Blocker or Major finding. R4 of the prior review is resolved and recorded as an Info row. The Warning, Minor, Info, and Nit rows are non-blocking.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `Measure-DocsPagePlaceholder` counts on the masked text of the existing page line model after the front-matter body start, so code, comments, and inline code are excluded by the library's own rules; the one-line-break tolerance and blank-line rejection follow the spec.
- `Get-DocsPlaceholderReport` filters `.md` paths ordinally, de-duplicates and sorts through an ordinal `SortedSet`, decodes with the strict UTF-8 helper, and catches only `DecoderFallbackException`.
- `Invoke-DocsCoverageCommand` gains the `placeholders` key and text lines without changing the exit code path; `DocsCoverageReport.psm1` is untouched.
- Cycles 1, 2, and 3 touched no production module, and the merge left the three item modules byte-unchanged.

#### API and safety notes

- Exports are exactly the four spec functions (asserted by test). Script-scope variables are constants. PSScriptAnalyzer reports 0 findings.

#### Error handling and logging

- Module-scope `$ErrorActionPreference = 'Stop'`; read failures other than decoding propagate to the command's existing runtime-error handler.

### Workflow template and Vale style audit

- Three `uses:` references pinned to 40-character SHAs with version comments; `contents: read` only; no `${{` in any `run:` body; every run step `shell: pwsh`.
- Vale archive hash compared with `-cne` and a `throw` before `tar`; only the `vale` member is extracted; the mismatch run and the hyperbole run are recorded.

### Documentation audit

- `consumer-onboarding.md` `## Linting` and `## Consumer CI` are consistent with the written workflow; the README index row now matches the page.
- The bundled epic template states the linting behavior accurately (cycle 2).
- The merged docs-init `## Documentation Families` section (from #1218) sits before the item's `## Linter Configuration` section and does not restate linting behavior, so no new inconsistency arises.
- Historical mentions of optional linting remain only in append-only records of earlier items under `.dev/active`, `.dev/potential`, and `.dev/epics`; these are not current guidance and are not findings.

---

## Test Quality Audit

No test of the item changed in cycle 3. The new and changed tests on the branch cover every spec AC that names a Pester assertion.

### Reviewed test and QA artifacts

- `evidence/other/task-check.P1-T2.2026-11-23T14-30.md` — parallel run of `DocumentationEstateOnboarding.Tests.ps1`, the only test that reads the README: 18 cases, 0 failures; one launcher exit 75 recorded as a queue timeout and re-run.
- `evidence/qa-gates/pester-gate.2026-11-24T03-56.md` — targeted parallel run after the merge (41 files, 8 shards): 1029 cases, 0 failures, 0 errors; the JUnit header in `artifacts/pester/pester-junit.xml` reads `tests="1029" errors="0" failures="0"`, which this review confirmed. The selection rule (cycle task test, every docs test naming the item's modules or templates, the two docs-authoring-roles suites, and the harness repo gate) covers every test that reads a file the item or the merge changed in the item's paths.
- `evidence/qa-gates/contracts.2026-11-24T03-56.md` — harness `-Check` no drift; five push-down contract pytest files, 45 passed.
- `evidence/qa-gates/pester-gate.2026-11-23T14-00.md` — the cycle-2 full gate (29193 passed, 0 failed), the repo-wide coverage evidence of record.

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

No external research was performed. Merge neutrality was checked by comparing `git diff --numstat 7c4bdc734..69293991a` with `git diff --numstat 6624aac72..6d4e82d7a` and by `git merge-tree --write-tree` of the base and head.

---

## Verdict

R4 is resolved with verified evidence, and the merge of the integration tip is neutral for the item. No blocking finding remains. The Warning, Minor, Info, and Nit rows are non-blocking. The branch is ready for a PR to the integration branch; CI at the PR head remains to be confirmed.
