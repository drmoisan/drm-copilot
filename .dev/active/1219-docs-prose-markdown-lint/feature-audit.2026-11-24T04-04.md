# Feature Audit: docs-prose-markdown-lint (#1219)

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1219-docs-prose-markdown-lint`
**Base Branch:** `origin/epic/documentation-estate-families-integration`
**Head Branch:** `feature/docs-prose-markdown-lint-1219`
**Work Mode:** `full-feature`
**Audit Type:** Re-review (remediation cycle 3)

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-families-integration` (resolved `6624aac72e7c30d69b947a9b134ad4f04c3caaff` at PR-context generation)
- **Head branch/commit:** `feature/docs-prose-markdown-lint-1219` (commit `6d4e82d7acd24bf47aad7cbd4428a943cce56de1`)
- **Merge base:** `6624aac72e7c30d69b947a9b134ad4f04c3caaff` (the integration tip, merged into the branch in `ebfbe0da6`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 03:59:31 UTC for head `6d4e82d7a`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1219-docs-prose-markdown-lint/evidence/{baseline,qa-gates,other}/`, including the cycle-3 files `readme-linting-row.2026-11-23T14-25.md`, `task-check.P1-T2.2026-11-23T14-30.md`, `decisions.2026-11-23T14-26.md`, `decisions.2026-11-24T03-56.md`, `pester-gate.2026-11-24T03-56.md`, `contracts.2026-11-24T03-56.md`, and `self-review.2026-11-24T03-56.md`
  - Prior reviews: `policy-audit`, `code-review`, `feature-audit`, and `remediation-inputs` stamped `2026-11-23T12-30`, `2026-11-23T12-58`, and `2026-11-23T14-11`
  - Additional evidence: direct inspection of the branch diff, the cycle-3 diff `69293991a..6d4e82d7a`, the per-path numstat across the old and new merge bases, the coverage and JUnit XML counters, and bundle pairs compared with `cmp`
- **Feature folder used:** `.dev/active/1219-docs-prose-markdown-lint`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`, 35 items) and `user-story.md` (`## Acceptance Criteria`, 11 items)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources.
- **Scope note:** The audit scope is the full diff `6624aac7..6d4e82d7` (90 files). Cycle 3 changed the engineering README index row and added evidence and review records; the merge `ebfbe0da6` is neutral for the item's paths. No production module, spec, or user-story file changed after the 14-11 review.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1219-docs-prose-markdown-lint/spec.md` — primary
- `.dev/active/1219-docs-prose-markdown-lint/user-story.md` — secondary

### From spec.md

S1. Pester content test asserts the markdownlint-cli2 step pinned at `696eb3f2509270d7b882d2aa68347bc676e7af34 # v25.0.0` with `config: docs/documentation-estate/.markdownlint.json` and `globs: ${{ steps.docs-lint-scope.outputs.globs }}`.
S2. Pester content test asserts the `docs-lint-scope` step reads the profile, writes `globs` and `roots` to `$env:GITHUB_OUTPUT`, and contains `DOCS_LINT_SCOPE_EMPTY`.
S3. Pester content test asserts the Vale install env (`VALE_VERSION: "3.25.1"`, pinned `VALE_SHA256`), the v3.25.1 download URL, `Get-FileHash -Algorithm SHA256`, `-cne`, and a `VALE_SHA256_MISMATCH` throw before the first `tar`.
S4. Recorded evidence shows a mismatch run that exits non-zero, reports `VALE_SHA256_MISMATCH`, and leaves no extracted `vale` binary.
S5. Pester content test asserts the Vale run step env `DOCS_LINT_ROOTS`, `--config docs/documentation-estate/.vale.ini`, and a final `exit $LASTEXITCODE`.
S6. Pester content test asserts every `uses:` is a 40-character lowercase SHA with `# vX.Y.Z`, and checkout and upload-artifact match the pins table.
S7. Pester content test asserts `contents: read` at workflow and job levels and no other scope.
S8. Pester content test asserts no `run:` body contains `${{`.
S9. Pester content test asserts `shell: pwsh` on every run step, the lint steps under `if: ${{ !cancelled() }}` in order after the documentation steps, and the upload under `if: ${{ always() }}`.
S10. Existing assertions that the template contains none of `setup-python`, `setup-node`, `python`, `npm`, `node` pass unchanged.
S11. Recorded evidence shows actionlint 1.7.12 over the template with exit 0.
S12. Pester test asserts `Invoke-DocsInitCommand -Write` writes the five DocsTonality files equal to the template sources.
S13. Pester content test per DocsTonality file asserts `extends: existence`, `ignorecase: true`, `scope: ~blockquote`, the tonality comment, no repository names, and the specified levels.
S14. Pester content test asserts Hyperbole lists `perfect` and `world-class`, and Exclamation sets `nonword: true` with the two tokens.
S15. Pester test asserts the 1219 anchor rows after the 1034 row, unchanged 1021 and 1034 rows, and one `.github/workflows/` row.
S16. Pester content test asserts the `.vale.ini` lines `BasedOnStyles = Vale, DocsBase, DocsTonality` and `Vale.Spelling = warning` under `[*.md]`.
S17. Recorded evidence shows checksum-verified Vale 3.25.1 over a page containing `perfect` with `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `DocsTonality.Hyperbole` at error level.
S18. Pester tests assert counts 0, 1, 3, and 2 on one line.
S19. Pester test asserts a one-line-break wrap counts 1 and a blank-line separation counts 0.
S20. Pester test asserts wrong-case variants count 0.
S21. Pester tests assert 0 inside front matter, backtick and tilde fences, inline code, and HTML comments.
S22. Pester test asserts an unterminated front matter page counts 1.
S23. Pester test asserts CRLF equals LF.
S24. Pester tests assert `Get-DocsPlaceholderReport` skips non-`.md` and invalid UTF-8 pages, sums `total`, omits zero counts, and orders ordinally.
S25. Pester test asserts the `ConvertTo-DocsPlaceholderReportLine` summary line and per-page lines.
S26. Pester test asserts coverage result keys equal the prior set plus `placeholders`, `placeholders.total` 0 on the fixture, and context members `ListFile`, `ReadBytes`, `TestFile` with no `WriteText`.
S27. Pester test asserts the coverage exit code is the same with and without the token.
S28. `DocsCoverageReport.psm1` unchanged on the branch; its two test files pass unchanged.
S29. `DocsPagePlaceholder.psm1` at least 85% line coverage, recorded under `evidence/qa-gates/`.
S30. Docs-init skill on every surface and `consumer-onboarding.md` contain the replacement statement and no "no workflow step runs Vale or markdownlint" sentence; the two content tests pass with the updated token.
S31. `consumer-onboarding.md` no longer states PowerShell is the only runtime; `command-reference.md` `### coverage` names `placeholders` and the token.
S32. Bundle copies byte-identical; `core.json` lists the six new files; four push-down contract tests pass.
S33. `Invoke-HarnessGeneration.ps1 -Check` exits 0 and `HarnessGeneration.RepoGate.Tests.ps1` passes.
S34. `DocsLedgerCommands.psm1` at no more than 762 logical lines; every changed file at or below 800.
S35. One parallel Pester gate with clean format and analyze, recorded under `evidence/qa-gates/`.

### From user-story.md

U1. Init-written workflow runs pinned markdownlint-cli2 with the estate config over profile-derived globs.
U2. Workflow downloads Vale 3.25.1, verifies SHA-256, throws `VALE_SHA256_MISMATCH` before extraction; mismatch evidence recorded.
U3. Workflow runs Vale with the estate config and fails the step on an error-level alert.
U4. Every `uses:` pinned with a version comment; `contents: read` only; no `${{` in `run:`.
U5. Docs init writes the five DocsTonality files with the specified levels; `.vale.ini` lines present.
U6. A page containing `perfect` produces a `DocsTonality.Hyperbole` error and Vale exit 1 (recorded live evidence).
U7. Coverage reports the `placeholders` section with the counting rules and an unchanged exit code.
U8. `DocsCoverageReport.psm1` unchanged; new module at least 85% line coverage.
U9. Docs-init skill on every surface and the consumer onboarding page describe markdownlint and Vale and contain no statement that no workflow step runs the linters.
U10. Bundle identity, `core.json`, push-down contract tests, and harness check exit 0.
U11. `DocsLedgerCommands.psm1` grows by at most 4 logical lines; every changed file at or below 800.

---

## Acceptance Criteria Evaluation

Test pass status for Pester-backed rows comes from the cycle-2 full gate (`evidence/qa-gates/pester-gate.2026-11-23T14-00.md`: 29193 passed, 0 failed) and, after the merge, the cycle-3 targeted run (`evidence/qa-gates/pester-gate.2026-11-24T03-56.md`: 1029 passed, 0 failed), whose selection includes every test file named below. No production module or item test hunk changed after the 14-11 review.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S1 | markdownlint-cli2 pin, config, globs | PASS | `DocsInitTemplate.DocsWorkflow.Tests.ps1`; template lines 73-78 | `git diff 6624aac7..HEAD -- tests/scripts/claude-lib/docs/` | In the targeted run; passed. |
| S2 | lint-scope step | PASS | content test plus executed-body test | same | In the targeted run. |
| S3 | Vale install env, URL, hash, throw before tar | PASS | install-step test; template lines 80-94 | same | In the targeted run. |
| S4 | mismatch-run evidence | PASS | `evidence/other/vale-sha256-mismatch.2026-11-23T11-54.md` | read artifact | Unchanged. |
| S5 | Vale run env and exit | PASS | run-step test; template lines 96-104 | test diff | In the targeted run. |
| S6 | `uses:` pins | PASS | pin test | test diff | In the targeted run. |
| S7 | permissions | PASS | permissions test | test diff | In the targeted run. |
| S8 | no `${{` in run bodies | PASS | run-body test | test diff | In the targeted run. |
| S9 | shell, conditions, order | PASS | shell and order tests | test diff | In the targeted run. |
| S10 | no setup-python/node tokens | PASS | unchanged assertion | test diff | In the targeted run. |
| S11 | actionlint exit 0 | PASS | `evidence/other/actionlint.2026-11-23T11-52.md` | read artifact | Workflow template unchanged since. |
| S12 | init writes DocsTonality files | PASS | `DocsPageTemplates.Tests.ps1` write test | test diff | In the targeted run. |
| S13 | DocsTonality keys and levels | PASS | per-file content tests | test diff | In the targeted run. |
| S14 | Hyperbole and Exclamation tokens | PASS | token test | test diff | In the targeted run. |
| S15 | init template rows | PASS | `DocsProfileCommands.Tests.ps1` | test diff | The merged #1218 test reads the same template set dynamically; both passed in the targeted run. |
| S16 | `.vale.ini` lines | PASS | section-scoped test | test diff | In the targeted run. |
| S17 | live Vale hyperbole evidence | PASS | `evidence/other/vale-hyperbole.2026-11-23T11-55.md` | read artifact | Unchanged. |
| S18 | counts 0, 1, 3, 2 | PASS | `DocsPagePlaceholder.Tests.ps1` | read test file | In the targeted run. |
| S19 | wrap and blank line | PASS | same | read test file | In the targeted run. |
| S20 | wrong case | PASS | same | read test file | In the targeted run. |
| S21 | excluded regions | PASS | same | read test file | In the targeted run. |
| S22 | unterminated front matter | PASS | same | read test file | In the targeted run. |
| S23 | CRLF equals LF | PASS | same | read test file | In the targeted run. |
| S24 | report filtering and order | PASS | five report tests | read test file | In the targeted run. |
| S25 | report line rendering | PASS | renderer test | read test file | In the targeted run. |
| S26 | coverage keys and context members | PASS | `DocsLedgerCommands.Tests.ps1` | `Grep WriteText` | In the targeted run. |
| S27 | exit code unchanged with token | PASS | exit-code test | test diff | In the targeted run. |
| S28 | `DocsCoverageReport.psm1` unchanged | PASS | not listed by `git diff --name-only 6624aac72 HEAD`; `DocsCoverageReport.Tests.ps1` passed in the targeted run | `git diff --name-only` | Re-checked at `6d4e82d7a`. |
| S29 | new module at least 85% | PASS | 100.00% (37/37) in `evidence/qa-gates/pester-gate.2026-11-23T14-00.md`; per-file counter in the current XML at head reads 37 covered, 0 missed | read artifact and XML | |
| S30 | skill surfaces and onboarding replacement statement | PASS | docs-init copies byte-identical (`cmp`) after the merge; onboarding page carries the replacement statement; content tests passed | `cmp`; run records | |
| S31 | runtime sentence removed; command-reference updated | PASS | onboarding and command-reference diffs | `git diff ... -- .dev/engineering/documentation-estate/` | Unchanged; the README row was also corrected (R4). |
| S32 | bundle identity, `core.json`, push-down tests | PASS | `cmp` of the module and skill pairs identical at `6d4e82d7a`; `contracts.2026-11-24T03-56.md` (five contract files, 45 passed) | `cmp` loop | `core.json` still lists the six item files; merged entries added without conflict. |
| S33 | harness check and RepoGate test | PASS | `contracts.2026-11-24T03-56.md` (no drift); `HarnessGeneration.RepoGate.Tests.ps1` in the targeted run | read artifact | |
| S34 | line limits | PASS | 760 lines; all changed code files at or below 800 | `awk 'END{print NR}'` | Re-counted at `6d4e82d7a`. |
| S35 | one parallel gate with clean static stages | PASS | `pester-gate.2026-11-23T14-00.md`, `powershell-static.2026-11-23T13-38.md` | read artifacts | The item's final QC gate; the cycle-3 targeted run is an owner-directed waiver, not a replacement gate. |
| U1 | markdownlint over profile globs | PASS | S1, S2 | as above | |
| U2 | Vale download and hash verification | PASS | S3, S4 | as above | |
| U3 | Vale run fails on error alert | PASS | S5, S17 | as above | |
| U4 | pins, permissions, no `${{` | PASS | S6, S7, S8 | as above | |
| U5 | DocsTonality files and `.vale.ini` | PASS | S12, S13, S16 | as above | |
| U6 | `perfect` produces Hyperbole error | PASS | S17 | as above | |
| U7 | placeholder section and rules | PASS | S18-S27 | as above | |
| U8 | `DocsCoverageReport.psm1` unchanged; module coverage | PASS | S28, S29 | as above | |
| U9 | skill surfaces and onboarding describe the linters | PASS | S30 | as above | The README index row now agrees with the onboarding page. |
| U10 | bundle, manifest, contracts, harness | PASS | S32, S33 | as above | |
| U11 | growth at most 4; files at most 800 | PASS | 758 to 760; S34 | as above | |

---

## Summary

**Overall Feature Readiness:** READY

All 46 acceptance criteria are met with inspected evidence. Finding R4 of the prior review is resolved: the engineering topic index row for `consumer-onboarding.md` no longer describes linting as optional. The merge of the integration tip is neutral for the item's paths, and the targeted run after the merge passed with 0 failures.

**Criteria summary:**
- **PASS:** 46 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

None.

**Recommended follow-up verification steps:**

1. After the PR opens against the integration branch, confirm CI at the PR head matches the `## CI Cross-check` rows of `policy-audit.2026-11-24T04-04.md`, including the integration-lane tests excluded locally.

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
| `.dev/active/1219-docs-prose-markdown-lint/spec.md` | 35 | 35 | 0 | Checkbox-backed; all already checked; each confirmed PASS at `6d4e82d7a`. |
| `.dev/active/1219-docs-prose-markdown-lint/user-story.md` | 11 | 11 | 0 | Checkbox-backed; all already checked; each confirmed PASS at `6d4e82d7a`. |

No source-file checkbox change was made: every criterion was already checked and every one evaluated PASS. Counts were taken from the `## Acceptance Criteria` sections only (35 checked, 0 unchecked in `spec.md`; 11 checked, 0 unchecked in `user-story.md`). The three `## Definition of Done` checkboxes in `spec.md` are not acceptance criteria and were not counted.
