# Combined E3 suites (plan [P11-T1], issue #905)

Timestamp: 2026-10-11T23-27
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-scoped.ps1 tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
EXIT_CODE: 0
Output Summary: SUMMARY: passed=190 failed=0 skipped=0 notrun=0; CONTAINER-ERRORS: 0. A `PASSED-TEST:` line is present for each of the 114 W-NEW-TESTS titles: 45 entry titles (D1 to D11, P1 to P9, F1 to F12, T1 to T13), 35 R1 rows, 25 R2 rows, 8 R3 rows, and the R4 test (`<SCRATCHPAD>/e905-newtests.ps1`: `W-NEW-TESTS-PASSED: 114`). The runner argument `WSUITESCHANGED` expands to the seven W-SUITES-CHANGED files listed above.

```text
ENTRY-TITLES: 45 | passed=45
R1-ROWS-PASSED: 35
R2-ROWS-PASSED: 25
R3-ROWS-PASSED: 8
R4-PASSED: 1
W-NEW-TESTS-PASSED: 114
```

```text
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true and invokes the validator exactly once
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false with the validator text embedded verbatim
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true without invoking the validator
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true without invoking the validator when the seam reports absent
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false with a payload anomaly message for empty input text
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false with a payload anomaly message for malformed input text
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false identically to any other non-conforming result
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | contains no TaskMaster/TMW/Outlook/VSTO token in its own source text
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true without invoking the validator when last_assistant_message is an empty string
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | reports Present = $true with the declaration when the profile reader returns a value
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true when the validator reports success with EMPTY output
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $false when the validator reports success but emits a success line
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | returns Ok = $true when the validator reports success with whitespace-only output
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 2 with a DISCOVERY_ARTIFACT_GATE_BLOCKED reason on stderr when last_assistant_message references a failing artifact
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 0 when last_assistant_message references a conforming artifact
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 0 when last_assistant_message carries no discovery artifact reference
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 0 when last_assistant_message is an empty string
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 0 when the required-artifact declaration is absent
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 2 with a payload anomaly reason for empty stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 2 with a payload anomaly reason for malformed stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 2 with a payload anomaly reason when last_assistant_message is absent
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | keeps validating when stop_hook_active is true
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | exits 2 in a separate process when stdin is not a JSON envelope
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | R4 skips a token that is empty after trimming
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a GitHub PR URL
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a PR # reference
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a gh pr create confirmation with a PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a gh pr edit confirmation with a PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks with PR_AUTHOR_OUTPUT_EMPTY when the assistant message is blank
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks when output has no PR URL or number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks with a payload anomaly when the input text is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks with a payload anomaly when the input text is malformed JSON
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks when the output mentions gh pr create but has no PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | returns false for null/empty/whitespace output
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | returns true for a PR URL
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | returns false for prose with no PR reference
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | exits 2 in a separate process when the stdin envelope lacks a PR reference
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with PR_AUTHOR_OUTPUT_NO_PR on stderr when last_assistant_message lacks a PR reference
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 0 when last_assistant_message reports a pull request URL
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with PR_AUTHOR_OUTPUT_EMPTY when last_assistant_message is an empty string
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for empty stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for malformed stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason when last_assistant_message is absent
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | keeps validating when stop_hook_active is true
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | allows a spec without numeric acceptance criteria
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | detects a numeric spec acceptance criterion
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | does not count numeric boxes outside Acceptance Criteria
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects a numeric claim without a complete research record
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects a research record whose independent cross-check disagrees
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | accepts an independently exhaustive complete-family research record
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects an invalid envelope and a blank assistant message
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects missing and nonexistent spec paths
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | accepts a nonnumeric spec without research evidence
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects numeric specs with missing or nonexistent research paths
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | accepts matching numeric provenance and extracts artifact labels
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects every missing numeric-evidence field and a missing section
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects copied-count, duplicate-search, member-set, scope, and narrow-pattern records
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on all with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on all with a word cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on exactly with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on exactly with a word cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on the with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on the with a word cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on these with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on these with a word cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on those with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on those with a word cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a threshold
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a comparator
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on an exit code
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on an issue or PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a line number or file:line
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on an AC or task identifier
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a version
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a date or timestamp
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a section reference
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on zero
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a unit of size or duration
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a count citing .claude/rules/
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a count citing .github/instructions/
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a count citing .github/copilot-instructions.md
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a non-noun word after the cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 accepts the exhaustive scope entire worktree
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 accepts the exhaustive scope whole worktree with all directories
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 accepts the exhaustive scope entire repository accepted before R3
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 rejects the exhaustive scope the hooks folder
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when last_assistant_message lacks an existing spec-path
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 0 when last_assistant_message carries an existing spec-path whose spec has no derived numeric criterion
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with the empty-message reason when last_assistant_message is an empty string
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for empty stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for malformed stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason when last_assistant_message is absent
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | keeps validating when stop_hook_active is true
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when the spec-path file cannot be read
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 in a separate process when the stdin envelope lacks a spec-path
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 0 without a research-path when the acceptance criteria contain only non-derived numerals
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when the research-path file cannot be read
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks with a payload anomaly when the input text is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks when the output does not advertise a research-path token
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks with a payload anomaly when the input text is malformed JSON
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | blocks with the existing empty-output reason when the assistant message is blank
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
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when last_assistant_message lacks a research-path
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 0 when last_assistant_message carries a valid research-path
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with the existing empty-output reason when last_assistant_message is an empty string
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for empty stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for malformed stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason when last_assistant_message is absent
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | keeps validating when stop_hook_active is true
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when the research-path file cannot be read
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 with the validate-task-researcher-output: prefix when subagentstop-envelope.ps1 fails to load
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | has no S1, S2, S3 or S6 guard-shape finding
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 2 in a separate process when the stdin envelope lacks a research-path
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | exits 0 when the research-path uses the research.yyyy-MM-ddTHH-mm.md form
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11T10-26-subagentstop-envelope-artifact-gates-addendum-research.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11-short-name-research.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 20261011-short-name-research.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11T1026-short-name-research.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11T10-26-short-name.research.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11-short-name.research.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 20261011-short-name.research.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts 2026-10-11T1026-short-name.research.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts research.2026-10-11T10-26.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts research.2026-10-11.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts research-addendum.2026-10-11T10-26.md
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R1 accepts research-addendum.2026-10-11.md
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
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R3 accepts the exhaustive scope entire worktree
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R3 accepts the exhaustive scope whole worktree with all directories
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R3 accepts the exhaustive scope entire repository accepted before R3
PASSED-TEST: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R3 rejects the exhaustive scope the hooks folder
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns ExitCode 1 and the module-not-found message when the shared module is absent
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns ExitCode 0 with EMPTY Output when the shared module reports no error
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns a non-zero ExitCode and non-empty Output for an artifact that is not on disk
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns a non-zero ExitCode and non-empty Output when ValidatorArgs is incomplete
BLOCK-ERRORS: 0
CONTAINER-ERRORS: 0
SUMMARY: passed=190 failed=0 skipped=0 notrun=0
```
