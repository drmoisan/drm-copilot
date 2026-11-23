# Feature Audit: docs-prose-markdown-lint (#1219)

**Audit Date:** 2026-11-23
**Feature Folder:** `.dev/active/1219-docs-prose-markdown-lint`
**Base Branch:** `origin/epic/documentation-estate-families-integration`
**Head Branch:** `feature/docs-prose-markdown-lint-1219`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-families-integration` (resolved `7de484cc11b3ccd27b751fa9c8f5055140fc521d` at PR-context generation)
- **Head branch/commit:** `feature/docs-prose-markdown-lint-1219` (commit `16b38d3cf103c7a657cd1f5dff8db184f4f99572`)
- **Merge base:** `7c4bdc734a0c59f9a3057108b719f67adeef88ca`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-23 12:26:53 UTC for head `16b38d3cf`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1219-docs-prose-markdown-lint/evidence/{baseline,qa-gates,other}/`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` (final gate), direct inspection of the branch diff and test files
- **Feature folder used:** `.dev/active/1219-docs-prose-markdown-lint`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`, 35 items) and `user-story.md` (`## Acceptance Criteria`, 11 items)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources. The `issue.md` early-draft checklist is not an AC source for this mode.
- **Scope note:** The integration branch advanced after the merge base (child 1222 page templates). That movement touches no file in this branch's diff except `core.json`, where both add distinct entries. The audit scope is the full diff `7c4bdc73..16b38d3c`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1219-docs-prose-markdown-lint/spec.md` — primary
- `.dev/active/1219-docs-prose-markdown-lint/user-story.md` — secondary

### From spec.md

S1. A Pester content test of `.claude/lib/docs/templates/_docs-quality.yml` passes and asserts a step that uses `DavidAnson/markdownlint-cli2-action@696eb3f2509270d7b882d2aa68347bc676e7af34 # v25.0.0` with `config: docs/documentation-estate/.markdownlint.json` and `globs: ${{ steps.docs-lint-scope.outputs.globs }}`.
S2. A Pester content test passes and asserts a lint-scope step with `id: docs-lint-scope` that reads `docs/documentation-estate/docs-profile.json`, writes the `globs` and `roots` outputs to `$env:GITHUB_OUTPUT`, and contains the text `DOCS_LINT_SCOPE_EMPTY`.
S3. A Pester content test passes and asserts a Vale install step whose `env:` sets `VALE_VERSION: "3.25.1"` and `VALE_SHA256` to `4bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182`, whose script downloads from `https://github.com/vale-cli/vale/releases/download/v3.25.1/`, calls `Get-FileHash -Algorithm SHA256`, compares with `-cne`, and contains `throw` with `VALE_SHA256_MISMATCH` at a position before the first `tar` call.
S4. Recorded evidence under `evidence/other/` shows a run of the install sequence with an altered expected hash that exits non-zero, reports `VALE_SHA256_MISMATCH`, and leaves no extracted `vale` binary.
S5. A Pester content test passes and asserts a Vale run step whose `env:` sets `DOCS_LINT_ROOTS: ${{ steps.docs-lint-scope.outputs.roots }}` and whose script invokes Vale with `--config docs/documentation-estate/.vale.ini` and ends with `exit $LASTEXITCODE`.
S6. A Pester content test passes and asserts that every `uses:` line in the template references a 40-character lowercase hexadecimal commit SHA followed by a `# vX.Y.Z` comment, and that the checkout and upload-artifact references equal the commits in the `### Workflow pins` table.
S7. A Pester content test passes and asserts `permissions:` with `contents: read` at the workflow level and the job level, and no other permission scope.
S8. A Pester content test passes and asserts that no `run:` block body (including every line of a `run: |` block) contains `${{`.
S9. A Pester content test passes and asserts that every run step sets `shell: pwsh`, that the lint-scope, Markdown lint, Vale install, and Vale run steps carry `if: ${{ !cancelled() }}` and appear in that order after the documentation-command steps, and that the upload step carries `if: ${{ always() }}`.
S10. The existing Pester assertions that the template contains none of the tokens `setup-python`, `setup-node`, `python`, `npm`, and `node` pass unchanged.
S11. Recorded evidence under `evidence/other/` shows `actionlint` 1.7.12 run over the template with exit code 0.
S12. A Pester test passes and asserts that `Invoke-DocsInitCommand -Write` against an in-memory context writes `Certainty.yml`, `Exclamation.yml`, `Filler.yml`, `Hyperbole.yml`, and `Intensifiers.yml` under `docs/documentation-estate/.vale/styles/DocsTonality/` with content equal to the template sources.
S13. A Pester content test passes for each DocsTonality file and asserts `extends: existence`, `ignorecase: true`, `scope: ~blockquote`, a leading comment naming `.claude/rules/tonality.md`, and no occurrence of `drm-copilot`, `rgf`, or `Rgf`; it asserts `level: error` for Certainty, Exclamation, Filler, and Hyperbole and `level: warning` for Intensifiers.
S14. A Pester content test passes and asserts that the Hyperbole token list includes `perfect` and `world-class`, and that Exclamation sets `nonword: true` with the tokens `'!\s*$'` and `'!\s+[A-Z]'`.
S15. A Pester test passes and asserts that `Get-DocsInitTemplate` returns the 1219 anchor rows after the 1034 workflow row, that the 1021 rows and the 1034 row are unchanged, and that the only row with a `.github/workflows/` destination is `.github/workflows/_docs-quality.yml`.
S16. A Pester content test passes and asserts that the `.vale.ini` template contains the line `BasedOnStyles = Vale, DocsBase, DocsTonality` and the line `Vale.Spelling = warning` under `[*.md]`.
S17. Recorded evidence under `evidence/other/` shows Vale 3.25.1, verified against the upstream checksum for the asset used, run with `--config` pointing at the init-written `.vale.ini` over a page containing the word `perfect`, with `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an output summary naming `DocsTonality.Hyperbole` at error level.
S18. Pester tests in `tests/scripts/claude-lib/docs/DocsPagePlaceholder.Tests.ps1` pass and assert counts of 0, 1, and 3 for pages with zero, one, and three occurrences, and a count of 2 for two occurrences on one line.
S19. A Pester test passes and asserts that the token wrapped across one line break inside a paragraph counts 1, and that the words separated by a blank line count 0.
S20. A Pester test passes and asserts that `sme input required` and `SME Input Required` count 0.
S21. Pester tests pass and assert a count of 0 for the token inside front matter, inside a backtick fenced block, inside a tilde fenced block, inside an inline code span, and inside an HTML comment.
S22. A Pester test passes and asserts that a page with an unterminated front matter block containing the token counts 1.
S23. A Pester test passes and asserts that a CRLF page built in memory gives the same count as its LF form.
S24. Pester tests pass and assert that `Get-DocsPlaceholderReport` skips a non-`.md` page, skips a page whose bytes are not valid UTF-8, sums `total` across pages, omits pages with a count of 0 from `pages`, and orders `pages` ordinally by `page_path`.
S25. A Pester test passes and asserts that `ConvertTo-DocsPlaceholderReportLine` returns `placeholders: token="SME input required" total=<n> pages=<m>` followed by one `placeholder <page_path> count=<n>` line per listed page in `pages` order.
S26. A Pester test of `Invoke-DocsCoverageCommand` passes and asserts that the result keys equal the prior key set plus `placeholders`, that the fixture result has `placeholders.total` equal to 0, and that the context members used are `ListFile`, `ReadBytes`, and `TestFile` with no `WriteText` call.
S27. A Pester test passes and asserts that the coverage command exit code for a fixture whose pages contain the token equals the exit code for the same fixture without the token.
S28. `git diff` of the branch against its merge base shows no change to `.claude/lib/docs/DocsCoverageReport.psm1`, and `DocsCoverageReport.Tests.ps1` and `DocsCoverageReport.Properties.Tests.ps1` pass unchanged.
S29. `DocsPagePlaceholder.psm1` reaches at least 85% line coverage in the PowerShell coverage run, recorded under `evidence/qa-gates/`.
S30. The docs-init skill on every surface (`.agents`, generated `.claude`, and both bundle copies) and `.dev/engineering/documentation-estate/consumer-onboarding.md` contain no sentence stating that no workflow step runs Vale or markdownlint, and contain the replacement statement; `docs-authoring-roles.Skills.Tests.ps1` and `DocumentationEstateOnboarding.Tests.ps1` pass with the updated token.
S31. `consumer-onboarding.md` no longer states that PowerShell is the only runtime the workflow uses, and `command-reference.md` `### coverage` names the `placeholders` key and the token `SME input required`.
S32. Every new or changed file under `.claude/lib/docs/` is byte-identical to its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, and `core.json` lists `DocsPagePlaceholder.psm1` and the five DocsTonality templates; `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and `test_push_down_codex_and_agents_resource_contracts.py` pass.
S33. `Invoke-HarnessGeneration.ps1 -Check` exits 0 and `HarnessGeneration.RepoGate.Tests.ps1` passes.
S34. Recorded evidence shows `DocsLedgerCommands.psm1` at no more than 762 logical lines after the change, and every new or changed production, test, and script file at or below 800 logical lines.
S35. One parallel Pester gate run (`Invoke-PoshQCParallelTest` through the test-execution launcher) passes with the PoshQC format and analyze stages clean, recorded under `evidence/qa-gates/`.

### From user-story.md

U1. The init-written `_docs-quality.yml` runs `DavidAnson/markdownlint-cli2-action`, pinned by commit, with `config: docs/documentation-estate/.markdownlint.json` over globs derived from the profile `documentation_roots`, as asserted by a passing Pester content test.
U2. The init-written `_docs-quality.yml` downloads Vale 3.25.1, compares its SHA-256 with the pinned value, and throws `VALE_SHA256_MISMATCH` before extraction on a mismatch, as asserted by a passing Pester content test and shown by recorded mismatch-run evidence.
U3. The init-written `_docs-quality.yml` runs Vale with `--config docs/documentation-estate/.vale.ini` and fails the step on an error-level alert, as asserted by a passing Pester content test.
U4. Every `uses:` reference in the template is pinned to a full commit SHA with a version comment, permissions are `contents: read` at the workflow and job levels, and no `run:` block contains `${{`, as asserted by passing Pester content tests.
U5. Docs init writes the five `DocsTonality` rule files (Certainty, Exclamation, Filler, Hyperbole, Intensifiers) with error level for the first four and warning level for Intensifiers, and the written `.vale.ini` contains `BasedOnStyles = Vale, DocsBase, DocsTonality` and `Vale.Spelling = warning`, as asserted by passing Pester tests.
U6. A page containing the word `perfect` produces a `DocsTonality.Hyperbole` error and Vale exit code 1, shown by recorded live Vale evidence under the feature `evidence/other/` folder.
U7. The docs `coverage` command reports a `placeholders` section with the token, the total, and one line per page with a non-zero count sorted by page path; occurrences in front matter, fenced code, inline code, and HTML comments are not counted; wrong-case text is not counted; one line break between the words is tolerated; and the exit code is unchanged, as asserted by passing Pester tests.
U8. `DocsCoverageReport.psm1` is unchanged on the branch, and the new `DocsPagePlaceholder.psm1` reaches at least 85% line coverage, recorded as QA evidence.
U9. The docs-init skill on every surface and the consumer onboarding page describe the workflow as running markdownlint and Vale, and contain no statement that no workflow step runs the linters, as asserted by passing Pester content tests.
U10. Bundle copies are byte-identical, `core.json` lists the new files, the push-down contract tests pass, and `Invoke-HarnessGeneration.ps1 -Check` exits 0.
U11. `DocsLedgerCommands.psm1` grows by at most 4 logical lines, and every new or changed code and test file stays at or below 800 logical lines, shown by recorded evidence.

---

## Acceptance Criteria Evaluation

Test pass status for every Pester-backed row comes from the single final gate (`evidence/qa-gates/pester-gate.2026-11-23T12-11.md`: 29193 passed, 0 failed), which ran every test file named below.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S1 | markdownlint-cli2 step pin, config, globs | PASS | `DocsInitTemplate.DocsWorkflow.Tests.ps1` 'runs markdownlint-cli2 with the estate configuration and the scope globs'; template lines 73-78 | `git diff 7c4bdc73..HEAD -- tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1` | Exact-line regexes for uses, config, globs. |
| S2 | lint-scope step content | PASS | 'resolves the lint scope from documentation_roots into globs and roots'; plus executed-body test for two roots and zero roots | same | Body executed with `Get-Content`/`Add-Content` mocked. |
| S3 | Vale install env, URL, hash, `-cne`, throw before tar | PASS | 'installs Vale 3.25.1 and throws VALE_SHA256_MISMATCH before tar'; template lines 80-94 | same | Asserts line indices: throw before every `tar` call; `--version` after tar. |
| S4 | mismatch-run evidence | PASS | `evidence/other/vale-sha256-mismatch.2026-11-23T11-54.md`: EXIT_CODE 1, `VALE_SHA256_MISMATCH` text, directory listing with only the archive and 0 files named vale | read artifact | Runs the committed step body with an altered hash. |
| S5 | Vale run env and exit | PASS | 'runs Vale with the estate configuration and exits with its exit code'; template lines 96-104 | test diff | Last line `exit $LASTEXITCODE`. |
| S6 | every `uses:` pinned with version comment | PASS | 'pins every uses: reference to a commit SHA with a version comment' | test diff | 3 `uses:` lines; SHAs equal the spec table. |
| S7 | permissions `contents: read` only | PASS | 'grants only contents: read at the workflow and job levels' | test diff | Indent 0 and 4 blocks, single child each. |
| S8 | no `${{` in any run body | PASS | rewritten 'passes the revision through env' test iterates every line from `run:` to step end | test diff | Also asserts `run:` is the last step key. |
| S9 | shell pwsh, conditions, order | PASS | 'uses PowerShell 7 in every run step' (7 run steps) and 'orders the lint steps after the documentation steps under !cancelled() and uploads under always()' | test diff | Step indices asserted as 4..9. |
| S10 | no setup-python/setup-node/python/npm/node | PASS | Unchanged `IndexOf(..., OrdinalIgnoreCase) | Should -Be -1` assertion in the diff context | test diff | Assertion text unchanged. |
| S11 | actionlint 1.7.12 exit 0 | PASS | `evidence/other/actionlint.2026-11-23T11-52.md` (hash-verified asset, version 1.7.12, exit 0, 0 findings) | read artifact | |
| S12 | init writes five DocsTonality files equal to sources | PASS | `DocsPageTemplates.Tests.ps1` 'writes the five DocsTonality styles with their template text under -Write' | test diff | Asserts mode `create` and exact text. |
| S13 | DocsTonality keys, comment, neutrality, levels | PASS | 'declares existence, ignorecase, scope and level in <Name>' and 'carries the tonality policy comment and no repository name in <Name>' (5 cases each) | test diff | Ordinal search for `drm-copilot`, `rgf`, `Rgf`. |
| S14 | Hyperbole tokens; Exclamation nonword tokens | PASS | 'lists perfect and world-class in Hyperbole and the nonword exclamation tokens' | test diff | |
| S15 | 1219 anchor rows after 1034; one workflow row | PASS | `DocsProfileCommands.Tests.ps1` 'places the 1219 anchor rows after the 1034 workflow row and keeps one workflow row'; `DocsProfileCommands.psm1` diff | test diff | 1021/1034 rows unchanged in the production diff. |
| S16 | `.vale.ini` lines under `[*.md]` | PASS | `DocsPageTemplates.Tests.ps1` `.vale.ini` test with section-scoped regex | test diff | |
| S17 | live Vale hyperbole evidence | PASS | `evidence/other/vale-hyperbole.2026-11-23T11-55.md`: Windows zip hash verified against the upstream checksum, `vale version 3.25.1`, EXIT_CODE 1, ExpectedExitCode 1, `DocsTonality.Hyperbole` severity=error | read artifact | D15 permits the Windows asset. |
| S18 | counts 0, 1, 3, and 2 on one line | PASS | `DocsPagePlaceholder.Tests.ps1` 'counts <Expected> for <Case>' | read test file | |
| S19 | wrap counts 1; blank line counts 0 | PASS | 'counts a token wrapped across one line break'; 'counts 0 for words separated by a blank line' | read test file | |
| S20 | wrong case counts 0 | PASS | 'counts 0 for <Case> casing' (2 cases) | read test file | |
| S21 | excluded regions count 0 | PASS | 'counts 0 inside <Region>' (5 regions) | read test file | |
| S22 | unterminated front matter counts 1 | PASS | 'counts an unterminated front matter page' | read test file | |
| S23 | CRLF equals LF | PASS | 'gives the same count for CRLF and LF' | read test file | CRLF built in memory. |
| S24 | report filter, decode skip, sum, omit zero, ordinal order | PASS | Five `Get-DocsPlaceholderReport` tests | read test file | |
| S25 | report line rendering | PASS | 'renders the summary line and one line per page' | read test file | |
| S26 | coverage keys plus placeholders, total 0, context members | PASS | `DocsLedgerCommands.Tests.ps1` key-set assertion (line 325), `placeholders.total` 0, and existing 'makes zero WriteText calls' (members `ListFile`, `ReadBytes`, `TestFile`) | `Grep WriteText tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | Also asserts `placeholders` follows `parity`. |
| S27 | exit code unchanged with token | PASS | 'keeps the exit code when pages contain the token' | test diff | |
| S28 | `DocsCoverageReport.psm1` unchanged; its tests pass unchanged | PASS | `git diff --name-only 7c4bdc73..HEAD` does not list `DocsCoverageReport.psm1`, `DocsCoverageReport.Tests.ps1`, or `DocsCoverageReport.Properties.Tests.ps1`; final gate 0 failures | `git diff --name-only 7c4bdc734a0c59f9a3057108b719f67adeef88ca HEAD` | Reviewer re-ran the check against the integration merge base. |
| S29 | new module at least 85% lines | PASS | 100.00% (37/37) in `evidence/qa-gates/pester-gate.2026-11-23T12-11.md`; confirmed from the `LINE` counter in `artifacts/pester/powershell-coverage.xml` | `awk` over the coverage XML | |
| S30 | skill surfaces and onboarding replacement statement | PASS | `.agents` and generated `.claude` docs-init skills and both bundle copies carry the replacement text; `cmp` shows both bundle copies byte-identical; onboarding and skill tests pass | `cmp` of the four docs-init copies; test diff | The separate sentence "Linting is optional." is recorded in the code review; it is not the sentence this criterion names. |
| S31 | "only runtime" removed; command-reference names `placeholders` and token | PASS | `consumer-onboarding.md` diff removes "PowerShell is the only runtime it uses"; `command-reference.md` adds the paragraph | `git diff ... -- .dev/engineering/documentation-estate/` | |
| S32 | bundle byte identity, `core.json`, push-down tests | PASS | `cmp` of all ten `.claude/lib/docs` pairs reports identical; `core.json` diff adds the six entries; `evidence/qa-gates/contracts.2026-11-23T12-11.md` pytest 0 failed with the four tests in the suite | `cmp` loop | |
| S33 | harness check exit 0; RepoGate test passes | PASS | `contracts.2026-11-23T12-11.md` (`no drift`); RepoGate test in `task-check.P3-T1` and in the final gate | read artifacts | |
| S34 | `DocsLedgerCommands.psm1` at most 762; all files at most 800 | PASS | `coverage-and-limits.2026-11-23T12-13.md` (760); reviewer count 760 | `awk 'END{print NR}'` | |
| S35 | one parallel Pester gate with clean format and analyze | PASS | `pester-gate.2026-11-23T12-11.md` and `powershell-static.2026-11-23T12-11.md` | read artifacts | 8 workers. |
| U1 | markdownlint over profile-derived globs | PASS | S1, S2 | as above | |
| U2 | Vale download, hash compare, throw before extraction, mismatch evidence | PASS | S3, S4 | as above | |
| U3 | Vale run with config; step fails on error-level alert | PASS | S5; `exit $LASTEXITCODE`; S17 shows exit 1 on an error alert | as above | |
| U4 | pins, permissions, no `${{` in run | PASS | S6, S7, S8 | as above | |
| U5 | five DocsTonality files with levels; `.vale.ini` lines | PASS | S12, S13, S16 | as above | |
| U6 | `perfect` produces `DocsTonality.Hyperbole` error, exit 1 | PASS | S17 | as above | |
| U7 | coverage placeholders section and counting rules; exit unchanged | PASS | S18-S27 and 'reports placeholder counts for pages that contain the token' | as above | |
| U8 | `DocsCoverageReport.psm1` unchanged; new module at least 85% | PASS | S28, S29 | as above | |
| U9 | skill surfaces and onboarding describe markdownlint and Vale | PASS | S30 | as above | |
| U10 | bundle identity, `core.json`, push-down tests, harness check | PASS | S32, S33 | as above | |
| U11 | `DocsLedgerCommands.psm1` growth at most 4; files at most 800 | PASS | 758 to 760 (+2); S34 | as above | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

All 46 acceptance criteria are met with inspected evidence. Readiness is held by one related documentation finding recorded in the code review and policy audit: `consumer-onboarding.md` line 33 still states "Linting is optional." This sentence is outside the literal wording of every acceptance criterion, so no criterion is downgraded.

**Criteria summary:**
- **PASS:** 46 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. `consumer-onboarding.md` "Linting is optional." sentence and its assertion in `DocumentationEstateOnboarding.Tests.ps1` (see `code-review.2026-11-23T12-30.md`).

**Recommended follow-up verification steps:**

1. After the sentence and test are corrected, run `DocumentationEstateOnboarding.Tests.ps1` and `test-name-uniqueness.Tests.ps1` through the test-execution launcher and record a task-check artifact.
2. After the PR opens against the integration branch, confirm CI at the PR head matches the `## CI Cross-check` rows of the policy audit.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria not evaluated as PASS must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### Acceptance Criteria Status

- Source: `.dev/active/1219-docs-prose-markdown-lint/spec.md`, `.dev/active/1219-docs-prose-markdown-lint/user-story.md`
- Total AC items: 46
- Checked off (delivered): 46
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1219-docs-prose-markdown-lint/spec.md` | 35 | 35 | 0 | Checkbox-backed; all were already checked by the executor and each is confirmed PASS here. |
| `.dev/active/1219-docs-prose-markdown-lint/user-story.md` | 11 | 11 | 0 | Checkbox-backed; all were already checked and confirmed PASS. |

No source-file checkbox change was made: every criterion was already checked and every one evaluated PASS, so no item was unchecked. The three `## Definition of Done` items in `spec.md` are outside the `## Acceptance Criteria` section and are not counted.
