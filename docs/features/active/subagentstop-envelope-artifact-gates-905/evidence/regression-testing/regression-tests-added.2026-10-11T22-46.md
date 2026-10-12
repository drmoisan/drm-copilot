# Regression tests added (Phase 2, issue #905)

Timestamp: 2026-10-11T22-46

## [P2-T1] validate-discovery-artifact-gate.Tests.ps1 (D1 to D11 and R4)

Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-its.ps1 -File tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
EXIT_CODE: 0
Output Summary: PARSE-ERRORS: 0; the eleven D titles each appear once with TAGS: E3-Entry; `IT-TITLE: R4 skips a token that is empty after trimming | TAGS: NONE` appears once. The Context listing ends with the R4 context, preceded by the stdin-envelope context. R-SIZE: 398 lines (at most 500).

Resume note: the test content was written by the previous executor and committed in the WIP checkpoint 3aad71302. This executor reconciled it against the [P2-T1] task text and section 4 (titles, tags, mocks, rule 9 driver construction, placement) and found no missing or divergent element; no `Describe`, `Context`, or `It` was duplicated. R-RESET was re-run at resume (`P2-T1 (resume): none present`).

Additional commands (same route):

- `r-reset.ps1 -TaskId 'P2-T1 (resume)'` -> `R-RESET P2-T1 (resume): none present`
- `e905-sel.ps1 -File tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 -Pattern "^    Context '"` (wraps `Select-String -LiteralPath <file> -Pattern <pattern>`)
- `r-size.ps1 tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`

```text
FILE: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
IT-TITLE: returns Ok = $true and invokes the validator exactly once | TAGS: NONE
IT-TITLE: returns Ok = $false with the validator text embedded verbatim | TAGS: NONE
IT-TITLE: returns Ok = $true without invoking the validator | TAGS: NONE
IT-TITLE: returns Ok = $true without invoking the validator when the seam reports absent | TAGS: NONE
IT-TITLE: returns Ok = $false with the documented empty-input message for an empty string | TAGS: NONE
IT-TITLE: returns Ok = $false with the documented empty-input message for $null | TAGS: NONE
IT-TITLE: returns Ok = $false with a non-empty message describing the parse failure | TAGS: NONE
IT-TITLE: returns Ok = $false identically to any other non-conforming result | TAGS: NONE
IT-TITLE: contains no TaskMaster/TMW/Outlook/VSTO token in its own source text | TAGS: NONE
IT-TITLE: returns Ok = $true without invoking the validator when the payload carries no output property | TAGS: NONE
IT-TITLE: reports Present = $true with the declaration when the profile reader returns a value | TAGS: NONE
IT-TITLE: exits 0 when the subagent output references no discovery artifact | TAGS: NONE
IT-TITLE: exits 1 with a Write-Error when CLAUDE_HOOK_INPUT is empty | TAGS: NONE
IT-TITLE: returns Ok = $true when the validator reports success with EMPTY output | TAGS: NONE
IT-TITLE: returns Ok = $false when the validator reports success but emits a success line | TAGS: NONE
IT-TITLE: returns Ok = $true when the validator reports success with whitespace-only output | TAGS: NONE
IT-TITLE: exits 2 with a DISCOVERY_ARTIFACT_GATE_BLOCKED reason on stderr when last_assistant_message references a failing artifact | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message references a conforming artifact | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message carries no discovery artifact reference | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message is an empty string | TAGS: E3-Entry
IT-TITLE: exits 0 when the required-artifact declaration is absent | TAGS: E3-Entry
IT-TITLE: blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for empty stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for malformed stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason when last_assistant_message is absent | TAGS: E3-Entry
IT-TITLE: keeps validating when stop_hook_active is true | TAGS: E3-Entry
IT-TITLE: exits 2 in a separate process when stdin is not a JSON envelope | TAGS: E3-Entry
IT-TITLE: R4 skips a token that is empty after trimming | TAGS: NONE
PARSE-ERRORS: 0
```

```text
SEL: 23:    Context 'recognized, conforming referenced artifact' {
SEL: 36:    Context 'recognized, non-conforming referenced artifact' {
SEL: 49:    Context 'no recognized artifact reference' {
SEL: 61:    Context 'fail-open when the domain profile is absent' {
SEL: 75:    Context 'empty or absent CLAUDE_HOOK_INPUT' {
SEL: 91:    Context 'malformed CLAUDE_HOOK_INPUT JSON' {
SEL: 100:    Context 'validator-not-found-style failure' {
SEL: 111:    Context 'domain neutrality' {
SEL: 118:    Context 'payload with no output field' {
SEL: 129:    Context 'Get-RequiredDiscoveryArtifactDeclaration seam' {
SEL: 140:    Context 'script entrypoint (end-to-end)' {
SEL: 172:    Context 'defect D-2 avoidance: a passing validation must yield an Ok result' {
SEL: 212:    Context 'script entrypoint (stdin envelope, issue #905)' {
SEL: 384:    Context 'Find-DiscoveryArtifactReference rule R4 (issue #905)' {
SEL-COUNT: 14
```

```text
LINES: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | 398
```

## [P2-T2] validate-pr-author-output.Tests.ps1 (P9)

Timestamp: 2026-10-11T22-46
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-its.ps1 -File tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
EXIT_CODE: 0
Output Summary: PARSE-ERRORS: 0; `exits 2 in a separate process when the stdin envelope lacks a PR reference` appears once with TAGS: E3-Entry. The builder `New-SubagentStopEnvelopeJson` is the last statement of the outer `BeforeAll`. R-RESET: `P2-T2: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
IT-TITLE: allows when output contains a GitHub PR URL | TAGS: NONE
IT-TITLE: allows when output contains a PR #<n> reference | TAGS: NONE
IT-TITLE: allows when output contains a gh pr create confirmation with a PR number | TAGS: NONE
IT-TITLE: allows when output contains a gh pr edit confirmation with a PR number | TAGS: NONE
IT-TITLE: blocks when output is empty | TAGS: NONE
IT-TITLE: blocks when output has no PR URL or number | TAGS: NONE
IT-TITLE: blocks when CLAUDE_HOOK_INPUT content is empty | TAGS: NONE
IT-TITLE: blocks when CLAUDE_HOOK_INPUT is malformed JSON | TAGS: NONE
IT-TITLE: blocks when the output mentions gh pr create but has no PR number | TAGS: NONE
IT-TITLE: returns false for null/empty/whitespace output | TAGS: NONE
IT-TITLE: returns true for a PR URL | TAGS: NONE
IT-TITLE: returns false for prose with no PR reference | TAGS: NONE
IT-TITLE: exits 0 when CLAUDE_HOOK_INPUT reports a PR URL | TAGS: NONE
IT-TITLE: exits 1 when CLAUDE_HOOK_INPUT is empty | TAGS: NONE
IT-TITLE: exits 1 when CLAUDE_HOOK_INPUT is malformed JSON | TAGS: NONE
IT-TITLE: exits 2 in a separate process when the stdin envelope lacks a PR reference | TAGS: E3-Entry
PARSE-ERRORS: 0
```

## [P2-T3] validate-pr-author-output.Coverage.Tests.ps1 (P1 to P8)

Timestamp: 2026-10-11T22-48
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-its.ps1 -File tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
EXIT_CODE: 0
Output Summary: PARSE-ERRORS: 0; each P1 to P8 title appears once with TAGS: E3-Entry, inside the new `Describe 'validate-pr-author-output entry point (stdin envelope, issue #905)'`. The existing issue #786 `Describe` is unchanged. R-RESET: `P2-T3: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
IT-TITLE: exits 1 when CLAUDE_HOOK_INPUT is empty | TAGS: NONE
IT-TITLE: exits 0 when the output reports a pull request URL | TAGS: NONE
IT-TITLE: exits 2 with PR_AUTHOR_OUTPUT_NO_PR on stderr when last_assistant_message lacks a PR reference | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message reports a pull request URL | TAGS: E3-Entry
IT-TITLE: blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT | TAGS: E3-Entry
IT-TITLE: exits 2 with PR_AUTHOR_OUTPUT_EMPTY when last_assistant_message is an empty string | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for empty stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for malformed stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason when last_assistant_message is absent | TAGS: E3-Entry
IT-TITLE: keeps validating when stop_hook_active is true | TAGS: E3-Entry
PARSE-ERRORS: 0
```

## [P2-T4] validate-prd-feature-output.Coverage.Tests.ps1 (F1 to F12)

Timestamp: 2026-10-11T22-48
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-its.ps1 -File tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
EXIT_CODE: 0
Output Summary: PARSE-ERRORS: 0; each F1 to F12 title appears once with TAGS: E3-Entry, inside the new `Describe 'validate-prd-feature-output entry point (stdin envelope, issue #905)'` whose `BeforeAll` defines `New-SubagentStopEnvelopeJson`, `Invoke-PrdFeatureOutputStdinEntry`, and `$script:PwshExe`. The existing issue #786 `Describe` is unchanged. Every built-in mock carries a `-ParameterFilter` on the literal path. R-RESET: `P2-T4: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
IT-TITLE: blocks when CLAUDE_HOOK_INPUT is empty | TAGS: NONE
IT-TITLE: exits 2 with a stderr reason when last_assistant_message lacks an existing spec-path | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message carries an existing spec-path whose spec has no derived numeric criterion | TAGS: E3-Entry
IT-TITLE: blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT | TAGS: E3-Entry
IT-TITLE: exits 2 with the empty-message reason when last_assistant_message is an empty string | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for empty stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for malformed stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason when last_assistant_message is absent | TAGS: E3-Entry
IT-TITLE: keeps validating when stop_hook_active is true | TAGS: E3-Entry
IT-TITLE: exits 2 with a stderr reason when the spec-path file cannot be read | TAGS: E3-Entry
IT-TITLE: exits 2 in a separate process when the stdin envelope lacks a spec-path | TAGS: E3-Entry
IT-TITLE: exits 0 without a research-path when the acceptance criteria contain only non-derived numerals | TAGS: E3-Entry
IT-TITLE: exits 2 with a stderr reason when the research-path file cannot be read | TAGS: E3-Entry
PARSE-ERRORS: 0
```

## [P2-T5] validate-prd-feature-output.Tests.ps1 (R2 rows and RS-18 fixtures)

Timestamp: 2026-10-11T22-50
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-its.ps1 -File tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
EXIT_CODE: 0
Output Summary: PARSE-ERRORS: 0; the two R2 template titles `R2 triggers on <Name>` (10 rows) and `R2 does not trigger on <Name>` (15 rows) appear with TAGS: NONE inside the new `Context 'Test-SpecNumericCriterion rule R2 (issue #905)'`, the last child block of `Describe 'validate-prd-feature-output.ps1'`. RS-18 applied: line 41 `- [ ] All 8 call sites are covered`; line 47 `- [ ] All 99 unrelated boxes` and `- [ ] All 7 unrelated boxes`; lines 98 and 107 `- [ ] The 2 call sites are covered`; no test title changed. `Select-String ... -Pattern '\[ \] 1 call','\[ \] 8 call'` returned no match (SEL-COUNT: 0). R-RESET: `P2-T5: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
IT-TITLE: allows a spec without numeric acceptance criteria | TAGS: NONE
IT-TITLE: detects a numeric spec acceptance criterion | TAGS: NONE
IT-TITLE: does not count numeric boxes outside Acceptance Criteria | TAGS: NONE
IT-TITLE: rejects a numeric claim without a complete research record | TAGS: NONE
IT-TITLE: rejects a research record whose independent cross-check disagrees | TAGS: NONE
IT-TITLE: accepts an independently exhaustive complete-family research record | TAGS: NONE
IT-TITLE: rejects empty, malformed, and output-free invocation payloads | TAGS: NONE
IT-TITLE: rejects missing and nonexistent spec paths | TAGS: NONE
IT-TITLE: accepts a nonnumeric spec without research evidence | TAGS: NONE
IT-TITLE: rejects numeric specs with missing or nonexistent research paths | TAGS: NONE
IT-TITLE: accepts matching numeric provenance and extracts artifact labels | TAGS: NONE
IT-TITLE: rejects every missing numeric-evidence field and a missing section | TAGS: NONE
IT-TITLE: rejects copied-count, duplicate-search, member-set, scope, and narrow-pattern records | TAGS: NONE
IT-TITLE: R2 triggers on <Name> | TAGS: NONE
IT-TITLE: R2 does not trigger on <Name> | TAGS: NONE
PARSE-ERRORS: 0
```

```text
SEL-COUNT: 0
```

## [P2-T6] validate-task-researcher-output.Coverage.Tests.ps1 (new; T1 to T13 and R1 rows)

Timestamp: 2026-10-11T22-52
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-its.ps1 -File tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1
EXIT_CODE: 0
Output Summary: PARSE-ERRORS: 0; each T1 to T13 title appears once with TAGS: E3-Entry; the R1 template titles `R1 accepts <Name>` (13 rows, a1 to a13) and `R1 rejects <Name> (<Category>)` (22 rows, r1 to r22) appear with TAGS: NONE. `git status --porcelain` lists `?? tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` (untracked). R-SIZE: 272 lines (at most 500). R-RESET: `P2-T6: none present`.

`git status --porcelain` observation:

```text
 M docs/features/active/subagentstop-envelope-artifact-gates-905/evidence/other/batch-budget-resets.md
 M docs/features/active/subagentstop-envelope-artifact-gates-905/plan.2026-10-11T07-59.md
 M tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
 M tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
 M tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
 M tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
?? docs/features/active/subagentstop-envelope-artifact-gates-905/evidence/regression-testing/
?? tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1
```

```text
FILE: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1
IT-TITLE: exits 2 with a stderr reason when last_assistant_message lacks a research-path | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message carries a valid research-path | TAGS: E3-Entry
IT-TITLE: blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT | TAGS: E3-Entry
IT-TITLE: exits 2 with the existing empty-output reason when last_assistant_message is an empty string | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for empty stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for malformed stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason when last_assistant_message is absent | TAGS: E3-Entry
IT-TITLE: keeps validating when stop_hook_active is true | TAGS: E3-Entry
IT-TITLE: exits 2 with a stderr reason when the research-path file cannot be read | TAGS: E3-Entry
IT-TITLE: exits 2 with the validate-task-researcher-output: prefix when subagentstop-envelope.ps1 fails to load | TAGS: E3-Entry
IT-TITLE: has no S1, S2, S3 or S6 guard-shape finding | TAGS: E3-Entry
IT-TITLE: exits 2 in a separate process when the stdin envelope lacks a research-path | TAGS: E3-Entry
IT-TITLE: exits 0 when the research-path uses the research.yyyy-MM-ddTHH-mm.md form | TAGS: E3-Entry
IT-TITLE: R1 accepts <Name> | TAGS: NONE
IT-TITLE: R1 rejects <Name> (<Category>) | TAGS: NONE
PARSE-ERRORS: 0
```

```text
LINES: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | 272
```

## [P2-T7] validate-prd-feature-output.Tests.ps1 (R3 rows)

Timestamp: 2026-10-11T22-52
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-its.ps1 -File tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
EXIT_CODE: 0
Output Summary: PARSE-ERRORS: 0; `R3 accepts the exhaustive scope <Name>` (3 rows) and `R3 rejects the exhaustive scope <Name>` (1 row) each appear once with TAGS: NONE, inside the new `Context 'Test-NumericDerivationEvidence rule R3 (issue #905)'` placed after the R2 context as the last child block of `Describe 'validate-prd-feature-output.ps1'`. No existing test changed. R-SIZE: 212 lines (at most 500). R-RESET: `P2-T7: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
IT-TITLE: allows a spec without numeric acceptance criteria | TAGS: NONE
IT-TITLE: detects a numeric spec acceptance criterion | TAGS: NONE
IT-TITLE: does not count numeric boxes outside Acceptance Criteria | TAGS: NONE
IT-TITLE: rejects a numeric claim without a complete research record | TAGS: NONE
IT-TITLE: rejects a research record whose independent cross-check disagrees | TAGS: NONE
IT-TITLE: accepts an independently exhaustive complete-family research record | TAGS: NONE
IT-TITLE: rejects empty, malformed, and output-free invocation payloads | TAGS: NONE
IT-TITLE: rejects missing and nonexistent spec paths | TAGS: NONE
IT-TITLE: accepts a nonnumeric spec without research evidence | TAGS: NONE
IT-TITLE: rejects numeric specs with missing or nonexistent research paths | TAGS: NONE
IT-TITLE: accepts matching numeric provenance and extracts artifact labels | TAGS: NONE
IT-TITLE: rejects every missing numeric-evidence field and a missing section | TAGS: NONE
IT-TITLE: rejects copied-count, duplicate-search, member-set, scope, and narrow-pattern records | TAGS: NONE
IT-TITLE: R2 triggers on <Name> | TAGS: NONE
IT-TITLE: R2 does not trigger on <Name> | TAGS: NONE
IT-TITLE: R3 accepts the exhaustive scope <Name> | TAGS: NONE
IT-TITLE: R3 rejects the exhaustive scope <Name> | TAGS: NONE
PARSE-ERRORS: 0
```

```text
LINES: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | 212
```

## [P2-T8] validate-task-researcher-output.Coverage.Tests.ps1 (R3 rows)

Timestamp: 2026-10-11T22-53
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-its.ps1 -File tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1
EXIT_CODE: 0
Output Summary: PARSE-ERRORS: 0; `R3 accepts the exhaustive scope <Name>` (3 rows) and `R3 rejects the exhaustive scope <Name>` (1 row) each appear once with TAGS: NONE, inside the new `Describe 'Test-NumericDerivationEvidence rule R3 (issue #905)'` placed after the R1 `Describe`; its `BeforeAll` dot-sources the hook and defines `$script:R3EvidenceText` as the thirteen default builder lines joined with LF. R-SIZE: 319 lines (at most 500). R-RESET: `P2-T8: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1
IT-TITLE: exits 2 with a stderr reason when last_assistant_message lacks a research-path | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message carries a valid research-path | TAGS: E3-Entry
IT-TITLE: blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT | TAGS: E3-Entry
IT-TITLE: exits 2 with the existing empty-output reason when last_assistant_message is an empty string | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for empty stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for malformed stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason when last_assistant_message is absent | TAGS: E3-Entry
IT-TITLE: keeps validating when stop_hook_active is true | TAGS: E3-Entry
IT-TITLE: exits 2 with a stderr reason when the research-path file cannot be read | TAGS: E3-Entry
IT-TITLE: exits 2 with the validate-task-researcher-output: prefix when subagentstop-envelope.ps1 fails to load | TAGS: E3-Entry
IT-TITLE: has no S1, S2, S3 or S6 guard-shape finding | TAGS: E3-Entry
IT-TITLE: exits 2 in a separate process when the stdin envelope lacks a research-path | TAGS: E3-Entry
IT-TITLE: exits 0 when the research-path uses the research.yyyy-MM-ddTHH-mm.md form | TAGS: E3-Entry
IT-TITLE: R1 accepts <Name> | TAGS: NONE
IT-TITLE: R1 rejects <Name> (<Category>) | TAGS: NONE
IT-TITLE: R3 accepts the exhaustive scope <Name> | TAGS: NONE
IT-TITLE: R3 rejects the exhaustive scope <Name> | TAGS: NONE
PARSE-ERRORS: 0
```

```text
LINES: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | 319
```
