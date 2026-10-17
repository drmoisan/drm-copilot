# Baseline of the E3 suites ([P0-T22], issue #905)

Timestamp: 2026-10-11T14-48
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-scoped.ps1 tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
EXIT_CODE: 0
Output Summary: SUMMARY: passed=85 failed=0 skipped=0 notrun=0; CONTAINER-ERRORS: 0; no FAILED: lines.

SUMMARY: passed=85 failed=0 skipped=0 notrun=0
CONTAINER-ERRORS: 0
FAILED lines: none

Runner note: the first invocation bound the first path to `-ExcludeTag` positionally and ran 4 tests; the runner was corrected in its I/O only (`[CmdletBinding(PositionalBinding = $false)]`) and re-run. The corrected run is recorded below.

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
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | blocks when CLAUDE_HOOK_INPUT is empty
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
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns ExitCode 1 and the module-not-found message when the shared module is absent
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns ExitCode 0 with EMPTY Output when the shared module reports no error
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns a non-zero ExitCode and non-empty Output for an artifact that is not on disk
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns a non-zero ExitCode and non-empty Output when ValidatorArgs is incomplete
BLOCK-ERRORS: 0
CONTAINER-ERRORS: 0
SUMMARY: passed=85 failed=0 skipped=0 notrun=0
```
