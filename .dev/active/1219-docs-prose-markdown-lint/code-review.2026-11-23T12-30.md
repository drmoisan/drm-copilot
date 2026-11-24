# Code Review: docs-prose-markdown-lint (#1219)

**Review Date:** 2026-11-23
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1219-docs-prose-markdown-lint`
**Feature Folder Selection Rule:** Named by the delegation; no version subfolder exists.
**Base Branch:** `origin/epic/documentation-estate-families-integration` (merge base `7c4bdc734a0c59f9a3057108b719f67adeef88ca`)
**Head Branch:** `feature/docs-prose-markdown-lint-1219` at `16b38d3cf103c7a657cd1f5dff8db184f4f99572`
**Review Type:** Initial review

---

## Executive Summary

The branch delivers the three parts of the epic #1217 child 1219: lint steps in the init-written `_docs-quality.yml`, a five-rule `DocsTonality` Vale style written by docs init and loaded by the written `.vale.ini`, and a pure placeholder counter (`DocsPagePlaceholder.psm1`) whose `placeholders` section is appended to the docs `coverage` result and text output. The diff is 60 files (+1826/-150); of these, 3 are production PowerShell modules, 7 are YAML or INI templates, 7 are test files, and the remainder are bundle mirrors, skill and engineering documentation, and feature evidence. Reviewed evidence: the PR context summary and appendix, the full diff, the final static, Pester, contracts, coverage-and-limits, actionlint, Vale mismatch, and Vale hyperbole artifacts, and `artifacts/pester/powershell-coverage.xml`.

Implementation quality is high. The counter reuses the existing page line model, so the excluded regions follow the library's existing masking rules; the integration in `Invoke-DocsCoverageCommand` is two lines and leaves `DocsCoverageReport.psm1` untouched; the workflow follows the pinned-SHA, least-privilege, env-only expression rules and verifies the Vale archive before extraction. Tests are in-memory and assert the exact behaviors in the spec, including an executed run of the lint-scope step body with its I/O mocked.

**What changed:**
- `.claude/lib/docs/templates/_docs-quality.yml`: four new steps (lint scope, markdownlint-cli2, Vale install with SHA-256 check, Vale run) under `if: ${{ !cancelled() }}`; checkout and upload-artifact pinned by commit.
- `.claude/lib/docs/templates/page-check/vale/DocsTonality/*.yml` (5 new) and `vale.ini` (`BasedOnStyles` adds `DocsTonality`; `Vale.Spelling = warning`).
- `.claude/lib/docs/DocsPagePlaceholder.psm1` (new, 136 lines); `DocsLedgerCommands.psm1` (+2 net logical lines); `DocsProfileCommands.psm1` (five init rows under a 1219 anchor).
- Bundle mirrors, `core.json` (6 entries), docs-init skill on all four surfaces, `consumer-onboarding.md`, `command-reference.md`.

**Top 3 risks:**
1. `consumer-onboarding.md` still opens `## Linting` with "Linting is optional.", which no longer matches a workflow whose lint steps fail the job.
2. The Vale download URL hard-codes `v3.25.1` while the archive name uses `VALE_VERSION`; a later version bump that edits only `VALE_VERSION` and `VALE_SHA256` would request a mismatched path (the checksum check would still stop the run).
3. The template runs only in consumer CI; this repository exercises it through content tests, actionlint, and recorded live proofs rather than a live workflow run (spec non-goal).

**PR readiness recommendation:** **Needs Revision** — one contained documentation sentence and its test assertion must be corrected; no code change is required.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.dev/engineering/documentation-estate/consumer-onboarding.md` | line 33, `## Linting` | The section opens with "Linting is optional." The same section now states that the written workflow runs markdownlint and Vale and that an error-level alert fails the Vale step. A consumer that calls the written workflow cannot opt out of the lint steps without editing it. The stale sentence is asserted by `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` lines 174-179 (`$text.Contains('Linting is optional')`). | Replace the sentence with an accurate one, for example: "`check` remains the required page gate; the written workflow also runs markdownlint and Vale." Update the `It` name and the asserted token in `DocumentationEstateOnboarding.Tests.ps1` to the new wording, and re-run that file and `test-name-uniqueness.Tests.ps1` through the launcher. | The item's own decision D13 is to correct documentation made false by this change; this sentence is in the paragraph the item edited. | `Grep 'Linting is optional'` returns `consumer-onboarding.md:33`; test lines 174-179. |
| Warning | `.claude/lib/docs/DocsLedgerCommands.psm1` | whole file | File is at 760 logical lines (advisory tier, at or above 700). | No action required in this item; the spec records that `Invoke-DocsCoverageCommand` moves to its own module if combined epic growth would exceed 800. | File-size advisory tier. | `awk 'END{print NR}'` = 760; `evidence/qa-gates/coverage-and-limits.2026-11-23T12-13.md`. |
| Minor | `.claude/lib/docs/templates/_docs-quality.yml` | line 89 | The download base URL hard-codes `v3.25.1` while `$archiveName` derives from `$env:VALE_VERSION`. | Optional, after this item: build the URL from `$env:VALE_VERSION` so the version is stated once. The spec AC asserts the literal URL, so a change belongs with a spec update. | Two sources for one version; a partial bump would download a wrong path. The checksum comparison still fails closed. | Template lines 84-89; spec `### Workflow template`. |
| Info | `.claude/lib/docs/templates/page-check/vale/DocsTonality/Exclamation.yml` | lines 6-11 | With `ignorecase: true`, the token `'!\s+[A-Z]'` also matches a lowercase letter after an exclamation mark. | None required; the spec mandates `ignorecase: true` on every rule, and flagging any word after `!` matches the rule intent. | Documents actual matching behavior. | File content; spec `### Tonality style`. |
| Info | `.claude/lib/docs/templates/_docs-quality.yml` | lines 73-104 | When the lint-scope step fails (`DOCS_LINT_SCOPE_EMPTY`), the later lint steps still run under `!cancelled()` with empty outputs. | None required; the job is already failed by the lint-scope step, and the spec chose `!cancelled()` (D6) so lint findings are reported alongside documentation-command failures. | Explains possible secondary error output in consumer logs. | Template; spec D6. |
| Info | `.dev/active/1219-docs-prose-markdown-lint/evidence/qa-gates/coverage-and-limits.2026-11-23T12-13.md` | row `git diff <merge base of origin/main and HEAD>` | The `DocsCoverageReport.psm1` no-change check used the merge base with `origin/main`, not the integration branch. | None required; this review re-ran the check against the integration merge base `7c4bdc73` and the file is absent from the diff. | Evidence is append-only and is not rewritten. | `git diff --name-only 7c4bdc73..HEAD`. |
| Nit | `.claude/lib/docs/DocsPagePlaceholder.psm1` | line 122 | `[OutputType([string[]], [object[]])]` lists `object[]` although the function returns `string[]` through the unary comma. | Optional: declare `[OutputType([string[]])]`. | Help accuracy only. | Lines 122, 129. |

One Major finding blocks readiness; no Blocker findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `Measure-DocsPagePlaceholder` normalizes CRLF once, takes `BodyStartLine` from the existing front-matter parser, and searches the `Masked` text of `Get-DocsPageLineModel`, so fenced code (backtick and tilde), HTML comments, and inline code spans are excluded by the same rules other page checks use. The regex permits one line break with surrounding spaces or tabs and rejects a blank line, as specified.
- The empty-body case after a terminated front matter block is handled with an empty `string[]` (D-E4), found by a test.
- `Get-DocsPlaceholderReport` filters `.md` paths ordinally, de-duplicates and sorts through an ordinal `SortedSet`, decodes through the library's strict `ConvertFrom-DocsUtf8Bytes`, and catches only `DecoderFallbackException`.
- `Invoke-DocsCoverageCommand` adds the `placeholders` key after the existing keys and concatenates text lines; the exit code path is unchanged and `WriteText` is still never used.
- `Get-DocsInitTemplate` appends five rows under a distinct `# --- 1219: tonality styles ---` anchor, leaving 1021 and 1034 rows unchanged; `Invoke-DocsInitCommand` behavior is unchanged.

#### API and safety notes

- Exports are exactly the four spec functions (asserted by test). Approved verbs throughout. Script-scope variables are constants. PSScriptAnalyzer reports 0 findings.

#### Error handling and logging

- Module-scope `$ErrorActionPreference = 'Stop'` and `-ErrorAction Stop` imports. A `ReadBytes` exception other than a decode failure propagates to the command's existing runtime-error handler (exit 3), which is the established behavior for read failures.

### Workflow template and Vale style audit

- All three `uses:` references are 40-character SHAs with version comments; permissions are `contents: read` at both levels; no `${{` appears in any `run:` body; every run step is `shell: pwsh`.
- The Vale install computes `Get-FileHash` SHA-256, lower-cases it, compares with `-cne`, and throws `VALE_SHA256_MISMATCH` before `tar`; `tar` extracts only the `vale` member. The mismatch proof shows no extracted binary, and the actual archive hash equals the committed pin.
- The Vale run passes roots as an array (`@valeRoots`) rather than a joined string, which avoids word-splitting of paths, and ends with `exit $LASTEXITCODE`.
- The lint scope writes step outputs with a fixed multiline delimiter through `Add-Content` to `$env:GITHUB_OUTPUT`.
- DocsTonality files: `extends: existence`, `ignorecase: true`, `scope: ~blockquote`, the levels from the spec, and a leading comment naming the tonality section; no repository-specific tokens. The Hyperbole list includes `perfect` and `world-class`. The live Vale proof shows `DocsTonality.Hyperbole` at error level with exit 1.

---

## Test Quality Audit

The new and changed tests cover every spec AC that names a Pester assertion. Coverage of the new module is 100% (37/37); changed lines in the two modified modules are covered.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocsPagePlaceholder.Tests.ps1` — 29 cases over the counter, report, renderer, and export surface; in-memory pages and an in-memory `ReadBytes` closure that logs reads.
- `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1` — step-block parsing of the committed template; asserts pins, permissions, env-only expressions in every `run:` line, step order and conditions, the checksum throw before `tar`, the Vale run invocation; executes the lint-scope body with `Get-Content`/`Add-Content` mocked for two roots and for zero roots.
- `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` — result key set plus `placeholders`, `placeholders.total` 0 on the fixture, context member set without `WriteText`, exit code equal with and without the token.
- `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1`, `DocsProfileCommands.Tests.ps1` — DocsTonality content and levels, `.vale.ini` lines, init rows and write-through equality.
- `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1`, `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` — replacement statement tokens; still asserts the stale "Linting is optional" sentence (finding above).
- `evidence/qa-gates/pester-gate.2026-11-23T12-11.md` — one parallel run, 0 failures, coverage figures confirmed against the XML.
- `evidence/other/vale-sha256-mismatch.2026-11-23T11-54.md`, `vale-hyperbole.2026-11-23T11-55.md`, `actionlint.2026-11-23T11-52.md` — live proofs with hash-verified downloads.

### Quality assessment prompts

- **Determinism:** No clock, network, random, or temporary-file use in tests; template text is read read-only.
- **Isolation:** One behavior per `It`; the lint-scope execution test restores `$env:GITHUB_OUTPUT` in `finally`.
- **Speed:** In-memory tests; full gate 760.89 s for 29211 cases with 8 workers.
- **Diagnostics:** Exact array comparisons and `-Because` clauses on ordering assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No tokens or credentials; the workflow uses no secrets. |
| No unsafe subprocess or command construction | ✅ PASS | No `Invoke-Expression`; Vale paths are passed as an array; no `${{` interpolation in `run:` bodies. |
| Input validation at boundaries | ✅ PASS | Lint scope throws on zero roots; counter filters non-`.md` paths and invalid UTF-8. |
| Error handling remains explicit | ✅ PASS | Narrow `DecoderFallbackException` catch; checksum mismatch throws before extraction. |
| Configuration / path handling is safe | ✅ PASS | Downloads go to `$env:RUNNER_TEMP`; only the `vale` member is extracted; permissions are read-only. |
| Supply chain pinning | ✅ PASS | Actions pinned by SHA; Vale pinned by version and SHA-256 confirmed against the upstream checksums file. |

---

## Research Log

No external research was performed by the reviewer. The Vale checksum provenance relies on `evidence/other/vale-checksum-confirmation.2026-11-23T05-58.md` and is corroborated by the mismatch run, which computed the downloaded archive hash equal to the committed pin.

---

## Verdict

The implementation, tests, coverage, parity, and supply-chain controls meet the spec and repository policy. One related documentation defect remains: `consumer-onboarding.md` still states "Linting is optional." and a test asserts it. The fix is contained to that sentence and its test assertion, changes no acceptance criterion or interface, and can be made on the branch without external input. After that fix and a launcher run of the affected test files, the branch is ready for the PR into the integration branch. The Warning, Minor, Info, and Nit rows are non-blocking.
