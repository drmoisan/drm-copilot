# Fail-before: new tests against the unchanged hooks (plan [P2-T10], issue #905) [expect-fail]

Timestamp: 2026-10-11T22-54
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-scoped.ps1 tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: SUMMARY: passed=117 failed=78 skipped=0 notrun=0; CONTAINER-ERRORS: 0. The 78 FAILED comparison keys equal the 78 W-FB titles of plan section 4 exactly: discovery D1 to D11 and R4 (12); pr-author P9 (1) and P1 to P8 (8); prd-feature R2 trigger word-cardinal rows (5), R2 non-trigger FB rows (12), R3 FB rows (2), F1 to F12 (12); task-researcher T1 to T13 (13), R1 a2 to a12 (11), R3 FB rows (2). No other test failed and no FB title is missing.

Mechanism observed: the unchanged discovery and pr-author hooks read the unset environment variable and exit 1 (D, P tests; D6 and P3 fail on their exit-code assertion before the validator-count assertion). The unchanged prd-feature and task-researcher hooks throw from `Write-Error` under `$ErrorActionPreference = 'Stop'`, so the in-process F and T tests fail on the `Thrown` assertion; F3 and T3 exit 0 because the unchanged hooks accept the environment-variable payload. T11 reports the S1 and S6 findings. The FB R1 rows fail on the line 97 regex; the FB R2 rows fail on the line 68 any-digit rule; the FB R3 rows fail on the unchanged scope pattern; the R4 test fails on its `$thrown` assertion with `Cannot bind argument to parameter 'Path' because it is an empty string.` (RS-21).

Failure first-message lines are the text after the second ` | ` separator on each `FAILED:` line below.

```text
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true and invokes the validator exactly once
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false with the validator text embedded verbatim
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true without invoking the validator
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true without invoking the validator when the seam reports absent
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false with the documented empty-input message for an empty string
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false with the documented empty-input message for $null
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false with a non-empty message describing the parse failure
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false identically to any other non-conforming result
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | contains no TaskMaster/TMW/Outlook/VSTO token in its own source text
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true without invoking the validator when the payload carries no output property
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | reports Present = $true with the declaration when the profile reader returns a value
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 0 when the subagent output references no discovery artifact
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 1 with a Write-Error when CLAUDE_HOOK_INPUT is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true when the validator reports success with EMPTY output
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false when the validator reports success but emits a success line
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true when the validator reports success with whitespace-only output
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a GitHub PR URL
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a PR # reference
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a gh pr create confirmation with a PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a gh pr edit confirmation with a PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks when output is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks when output has no PR URL or number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks when CLAUDE_HOOK_INPUT content is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks when CLAUDE_HOOK_INPUT is malformed JSON
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks when the output mentions gh pr create but has no PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | returns false for null/empty/whitespace output
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | returns true for a PR URL
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | returns false for prose with no PR reference
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | exits 0 when CLAUDE_HOOK_INPUT reports a PR URL
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | exits 1 when CLAUDE_HOOK_INPUT is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | exits 1 when CLAUDE_HOOK_INPUT is malformed JSON
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 1 when CLAUDE_HOOK_INPUT is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 0 when the output reports a pull request URL
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | allows a spec without numeric acceptance criteria
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | detects a numeric spec acceptance criterion
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | does not count numeric boxes outside Acceptance Criteria
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects a numeric claim without a complete research record
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects a research record whose independent cross-check disagrees
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | accepts an independently exhaustive complete-family research record
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects empty, malformed, and output-free invocation payloads
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects missing and nonexistent spec paths
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | accepts a nonnumeric spec without research evidence
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects numeric specs with missing or nonexistent research paths
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | accepts matching numeric provenance and extracts artifact labels
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects every missing numeric-evidence field and a missing section
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects copied-count, duplicate-search, member-set, scope, and narrow-pattern records
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on all with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on exactly with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on the with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on these with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on those with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a count citing .claude/rules/
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a count citing .github/instructions/
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a count citing .github/copilot-instructions.md
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 accepts the exhaustive scope entire repository accepted before R3
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 rejects the exhaustive scope the hooks folder
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | blocks when CLAUDE_HOOK_INPUT is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11T10-26-subagentstop-envelope-artifact-gates-addendum-research.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts backslash path 2026-10-11T10-26-short-name-research.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects foo.md (no date stamp)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects bad-name.md (no date stamp)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects research-input.md (no date stamp)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects research-findings.md (no date stamp)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects orchestration-mechanics.research.md (no date stamp)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects claude-ecosystem.md (no date stamp)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects hook-surface-inventory.2026-06-27.md (stamp only as a suffix)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects parallel-planner-surface.2026-08-07T12-30.md (stamp only as a suffix)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-07-22-npm-audit-fix-strategy.md (leading stamp without research ending)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-10-09T05-40-root-prettier-fixture-exclusion.md (leading stamp without research ending)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-10-11T10-26-research.md (empty short name)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-10-11T10-26--short-name-research.md (short name starts with a hyphen)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-10-11T10-26-short_name-research.md (underscore in short name)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-10-11T10-26-short name-research.md (space in short name)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-10-11T10-26-short.name-research.md (extra dot in short name)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-10-11T10-26-short-name-research.MD (upper-case extension)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-10-11T10-26-short-name-research.markdown (other extension)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-10-11T10-26-short-name-research.txt (other extension)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-10-11T12:05-short-name-research.md (stamp in another shape)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects 2026-1-11-short-name-research.md (stamp in another shape)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects research.2026-10-11T1205.md (compact time after research.)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 rejects research.2026-10-11T10-26-short-name.md (stamp after research. with a short name)
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R3 accepts the exhaustive scope entire repository accepted before R3
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R3 rejects the exhaustive scope the hooks folder
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks when CLAUDE_HOOK_INPUT is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks when the output does not advertise a research-path token
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks when CLAUDE_HOOK_INPUT is malformed JSON
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks when the output field is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks when the research-path is not under a tracked research root
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks when the research-path filename does not match the documented convention
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | allows termination when the research-path is valid and the file exists
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks when the advertised research file does not exist on disk
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | accepts a feature-folder research path
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | accepts a one-off research path under docs/research/
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | rejects the retired artifacts/research/ path with a message naming the new roots
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | rejects a feature path that lacks a /research/ segment
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | rejects a feature research path whose filename does not conform
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | extracts a quoted research-path value
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | returns true for valid research filenames
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | returns false for invalid research filenames
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | passes a non-matching research artifact unaffected
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks a matching artifact (by filename) missing the Automation Feasibility section
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | passes a matching artifact (by content) that includes the Automation Feasibility section
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks a matching artifact whose body is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks termination when a matching artifact omits the Automation Feasibility section
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | extracts a research-path from a markdown link form
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | returns null for a whitespace-only markdown-link path
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | accepts research without a numeric spec criterion
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks a numeric spec claim without numeric derivation evidence
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks an incomplete family record and missing inclusion rules
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks disagreeing independent cross-check counts
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | accepts an independently exhaustive complete-family derivation
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | rejects a copied count that does not match the cross-check member set
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | rejects a normalized duplicate search strategy
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | rejects missing primary or cross-check evidence
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | rejects mismatched member sets and missing comparison
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | rejects missing complete-family declaration and exhaustive scope
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | rejects a narrow named-pattern search that does not cover the declared family
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 2 with a DISCOVERY_ARTIFACT_GATE_BLOCKED reason on stderr when last_assistant_message references a failing artifact | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 0 when last_assistant_message references a conforming artifact | Expected 0, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 0 when last_assistant_message carries no discovery artifact reference | Expected 0, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 0 when last_assistant_message is an empty string | Expected 0, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 0 when the required-artifact declaration is absent | Expected 0, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 2 with a payload anomaly reason for empty stdin | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 2 with a payload anomaly reason for malformed stdin | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 2 with a payload anomaly reason when last_assistant_message is absent | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | keeps validating when stop_hook_active is true | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 2 in a separate process when stdin is not a JSON envelope | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | R4 skips a token that is empty after trimming | Expected $null or empty, but got Cannot bind argument to parameter 'Path' because it is an empty string..
FAILED: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | exits 2 in a separate process when the stdin envelope lacks a PR reference | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with PR_AUTHOR_OUTPUT_NO_PR on stderr when last_assistant_message lacks a PR reference | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 0 when last_assistant_message reports a pull request URL | Expected 0, but got 1.
FAILED: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT | Expected 2, but got 0.
FAILED: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with PR_AUTHOR_OUTPUT_EMPTY when last_assistant_message is an empty string | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for empty stdin | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for malformed stdin | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason when last_assistant_message is absent | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | keeps validating when stop_hook_active is true | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on all with a word cardinal | Expected $true, because R2 must trigger on: All twelve agent files contain the marker., but got $false.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on exactly with a word cardinal | Expected $true, because R2 must trigger on: The managed block lists exactly two entries., but got $false.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on the with a word cardinal | Expected $true, because R2 must trigger on: None of the nine Python files invokes Python., but got $false.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on these with a word cardinal | Expected $true, because R2 must trigger on: These three suites pass., but got $false.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on those with a word cardinal | Expected $true, because R2 must trigger on: Those four mirrors are byte-identical., but got $false.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a threshold | Expected $false, because R2 must not trigger on: Line coverage is at or above 85% for each changed file., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a comparator | Expected $false, because R2 must not trigger on: Repository-wide line coverage is >= 85% after the change., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on an exit code | Expected $false, because R2 must not trigger on: The hook exits 2 with a reason on stderr., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on an issue or PR number | Expected $false, because R2 must not trigger on: The PR body contains Refs #905 and Refs #897., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a line number or file:line | Expected $false, because R2 must not trigger on: The rule at typescript.md:57 and Pester.psm1:8567-8588 stays unchanged., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on an AC or task identifier | Expected $false, because R2 must not trigger on: AC-01, AC-5.4, P1-T2 and E4-ST3 are recorded., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a version | Expected $false, because R2 must not trigger on: The extension requires node >=18.0.0 to run., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a date or timestamp | Expected $false, because R2 must not trigger on: Evidence is written on 2026-10-11 at 2026-10-11T17-00., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a section reference | Expected $false, because R2 must not trigger on: The behavior follows research §12., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on zero | Expected $false, because R2 must not trigger on: PSScriptAnalyzer reports zero findings and 0 errors., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a unit of size or duration | Expected $false, because R2 must not trigger on: No file exceeds the 500 lines limit within the 30 seconds timeout., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a non-noun word after the cardinal | Expected $false, because R2 must not trigger on: The value is exactly 2 as documented., but got $true.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 accepts the exhaustive scope entire worktree | Expected $true, because prd-feature hook: numeric derivation evidence does not declare an exhaustive repository search scope., but got $false.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 accepts the exhaustive scope whole worktree with all directories | Expected $true, because prd-feature hook: numeric derivation evidence does not declare an exhaustive repository search scope., but got $false.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when last_assistant_message lacks an existing spec-path | Expected $null or empty, but got prd-feature hook: CLAUDE_HOOK_INPUT is empty..
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 0 when last_assistant_message carries an existing spec-path whose spec has no derived numeric criterion | Expected $null or empty, but got prd-feature hook: CLAUDE_HOOK_INPUT is empty..
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT | Expected 2, but got 0.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with the empty-message reason when last_assistant_message is an empty string | Expected $null or empty, but got prd-feature hook: CLAUDE_HOOK_INPUT is empty..
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for empty stdin | Expected $null or empty, but got prd-feature hook: CLAUDE_HOOK_INPUT is empty..
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for malformed stdin | Expected $null or empty, but got prd-feature hook: CLAUDE_HOOK_INPUT is empty..
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason when last_assistant_message is absent | Expected $null or empty, but got prd-feature hook: CLAUDE_HOOK_INPUT is empty..
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | keeps validating when stop_hook_active is true | Expected $null or empty, but got prd-feature hook: CLAUDE_HOOK_INPUT is empty..
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when the spec-path file cannot be read | Expected $null or empty, but got prd-feature hook: CLAUDE_HOOK_INPUT is empty..
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 in a separate process when the stdin envelope lacks a spec-path | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 0 without a research-path when the acceptance criteria contain only non-derived numerals | Expected $null or empty, but got prd-feature hook: CLAUDE_HOOK_INPUT is empty..
FAILED: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when the research-path file cannot be read | Expected $null or empty, but got prd-feature hook: CLAUDE_HOOK_INPUT is empty..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when last_assistant_message lacks a research-path | Expected $null or empty, but got task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 0 when last_assistant_message carries a valid research-path | Expected $null or empty, but got task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT | Expected 2, but got 0.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with the existing empty-output reason when last_assistant_message is an empty string | Expected $null or empty, but got task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for empty stdin | Expected $null or empty, but got task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for malformed stdin | Expected $null or empty, but got task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason when last_assistant_message is absent | Expected $null or empty, but got task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | keeps validating when stop_hook_active is true | Expected $null or empty, but got task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when the research-path file cannot be read | Expected $null or empty, but got task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with the validate-task-researcher-output: prefix when subagentstop-envelope.ps1 fails to load | Expected $null or empty, but got task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | has no S1, S2, S3 or S6 guard-shape finding | Expected $null or empty, because S1: bootstrap try is not the first statement after param(); S1: bootstrap flag check does not directly follow the dot-source early return; S6: Invoke-TaskResearcherOutputValidation does not return the dependency decision first, but got @('S1: bootstrap try is not the first statement after param()', 'S1: bootstrap flag check does not directly follow the dot-source early return', 'S6: Invoke-TaskResearcherOutputValidation does not return the dependency decision first').
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 in a separate process when the stdin envelope lacks a research-path | Expected 2, but got 1.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 0 when the research-path uses the research.yyyy-MM-ddTHH-mm.md form | Expected $null or empty, but got task-researcher hook: CLAUDE_HOOK_INPUT is empty; cannot validate task-researcher output..
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11-short-name-research.md | Expected $true, because R1 must accept docs/research/2026-10-11-short-name-research.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 20261011-short-name-research.md | Expected $true, because R1 must accept docs/research/20261011-short-name-research.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11T1026-short-name-research.md | Expected $true, because R1 must accept docs/research/2026-10-11T1026-short-name-research.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11T10-26-short-name.research.md | Expected $true, because R1 must accept docs/research/2026-10-11T10-26-short-name.research.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11-short-name.research.md | Expected $true, because R1 must accept docs/research/2026-10-11-short-name.research.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 20261011-short-name.research.md | Expected $true, because R1 must accept docs/research/20261011-short-name.research.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11T1026-short-name.research.md | Expected $true, because R1 must accept docs/research/2026-10-11T1026-short-name.research.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts research.2026-10-11T10-26.md | Expected $true, because R1 must accept docs/research/research.2026-10-11T10-26.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts research.2026-10-11.md | Expected $true, because R1 must accept docs/research/research.2026-10-11.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts research-addendum.2026-10-11T10-26.md | Expected $true, because R1 must accept docs/research/research-addendum.2026-10-11T10-26.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts research-addendum.2026-10-11.md | Expected $true, because R1 must accept docs/research/research-addendum.2026-10-11.md, but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R3 accepts the exhaustive scope entire worktree | Expected $true, because task-researcher hook: numeric derivation evidence does not declare an exhaustive repository search scope., but got $false.
FAILED: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R3 accepts the exhaustive scope whole worktree with all directories | Expected $true, because task-researcher hook: numeric derivation evidence does not declare an exhaustive repository search scope., but got $false.
BLOCK-ERRORS: 0
CONTAINER-ERRORS: 0
SUMMARY: passed=117 failed=78 skipped=0 notrun=0
```
