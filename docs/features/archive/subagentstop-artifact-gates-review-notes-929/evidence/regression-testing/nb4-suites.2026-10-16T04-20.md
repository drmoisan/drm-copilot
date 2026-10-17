# NB-4 Eight-Suite Run After Conversion (P8-T12)

Timestamp: 2026-10-16T04-20

Command: sh SCRATCH/929/P8-T12-1.sh
Script: `Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1') -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'FAILED_BLOCKS=' + $r.FailedBlocksCount; 'FAILED_CONTAINERS=' + $r.FailedContainersCount; 'PASSED=' + $r.PassedCount; exit [int]($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount)`
EXIT_CODE: 0

Output Summary:
- `FAILED=0`, `FAILED_BLOCKS=0`, `FAILED_CONTAINERS=0`, `PASSED=224`.
- `PASSED=224` equals the P7-T4 pre-conversion value (`post-merge-verification.2026-10-16T04-10.md`); the conversion added and removed no test.
- Every `Passed |` line recorded in P7-T4 is present: the full output of this run is line-for-line identical to the P7-T4 runner output (`diff` of the two captured outputs exited 0 with no output) (AC-08).
- The R4 names (`Passed | R4 ...`) and both dispatch names (`Passed | dispatches each distinct discovery reference exactly once`, `Passed | stops at the first failing reference and returns DISCOVERY_ARTIFACT_GATE_BLOCKED`) are present below.

Full output (228 lines; 224 `Passed |` lines plus the four total lines):
```
Passed | allows a spec without numeric acceptance criteria
Passed | detects a numeric spec acceptance criterion
Passed | does not count numeric boxes outside Acceptance Criteria
Passed | rejects a numeric claim without a complete research record
Passed | rejects a research record whose independent cross-check disagrees
Passed | accepts an independently exhaustive complete-family research record
Passed | rejects an invalid envelope and a blank assistant message
Passed | rejects missing and nonexistent spec paths
Passed | accepts a nonnumeric spec without research evidence
Passed | rejects numeric specs with missing or nonexistent research paths
Passed | accepts matching numeric provenance and extracts artifact labels
Passed | rejects every missing numeric-evidence field and a missing section
Passed | rejects copied-count, duplicate-search, member-set, scope, and narrow-pattern records
Passed | R2 triggers on all with a digit cardinal
Passed | R2 triggers on all with a word cardinal
Passed | R2 triggers on exactly with a digit cardinal
Passed | R2 triggers on exactly with a word cardinal
Passed | R2 triggers on the with a digit cardinal
Passed | R2 triggers on the with a word cardinal
Passed | R2 triggers on these with a digit cardinal
Passed | R2 triggers on these with a word cardinal
Passed | R2 triggers on those with a digit cardinal
Passed | R2 triggers on those with a word cardinal
Passed | R2 does not trigger on a threshold
Passed | R2 does not trigger on a comparator
Passed | R2 does not trigger on an exit code
Passed | R2 does not trigger on an issue or PR number
Passed | R2 does not trigger on a line number or file:line
Passed | R2 does not trigger on an AC or task identifier
Passed | R2 does not trigger on a version
Passed | R2 does not trigger on a date or timestamp
Passed | R2 does not trigger on a section reference
Passed | R2 does not trigger on zero
Passed | R2 does not trigger on a unit of size or duration
Passed | R2 does not trigger on a count citing .claude/rules/
Passed | R2 does not trigger on a count citing .github/instructions/
Passed | R2 does not trigger on a count citing .github/copilot-instructions.md
Passed | R2 does not trigger on a non-noun word after the cardinal
Passed | R3 accepts the exhaustive scope entire worktree
Passed | R3 accepts the exhaustive scope whole worktree with all directories
Passed | R3 accepts the exhaustive scope entire repository accepted before R3
Passed | R3 accepts the exhaustive scope complete source tree
Passed | R3 accepts the exhaustive scope whole repo
Passed | R3 accepts the exhaustive scope upper-case entire worktree
Passed | R3 accepts the exhaustive scope entire worktree root
Passed | R3 accepts the exhaustive scope whole repository excluding docs
Passed | R3 accepts the exhaustive scope NB-2 whole worktree restricted to code
Passed | R3 accepts the exhaustive scope NB-2 entire repository excluding docs
Passed | R3 rejects the exhaustive scope the hooks folder
Passed | R3 rejects the exhaustive scope noun without a quantifier
Passed | R3 rejects the exhaustive scope quantifier without a noun
Passed | R3 rejects the exhaustive scope path-shaped value
Passed | R3 rejects the exhaustive scope all inside allocated
Passed | R3 rejects the exhaustive scope tree inside subtree
Passed | R3 rejects the exhaustive scope worktree inside worktrees
Passed | exits 2 with a stderr reason when last_assistant_message lacks an existing spec-path
Passed | exits 0 when last_assistant_message carries an existing spec-path whose spec has no derived numeric criterion
Passed | blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
Passed | exits 2 with the empty-message reason when last_assistant_message is an empty string
Passed | exits 2 with a payload anomaly reason for empty stdin
Passed | exits 2 with a payload anomaly reason for malformed stdin
Passed | exits 2 with a payload anomaly reason when last_assistant_message is absent
Passed | keeps validating when stop_hook_active is true
Passed | exits 2 with a stderr reason when the spec-path file cannot be read
Passed | exits 2 in a separate process when the stdin envelope lacks a spec-path
Passed | exits 0 without a research-path when the acceptance criteria contain only non-derived numerals
Passed | exits 2 with a stderr reason when the research-path file cannot be read
Passed | blocks with a payload anomaly when the input text is empty
Passed | blocks when the output does not advertise a research-path token
Passed | blocks with a payload anomaly when the input text is malformed JSON
Passed | blocks with the existing empty-output reason when the assistant message is blank
Passed | blocks when the research-path is not under a tracked research root
Passed | blocks when the research-path filename does not match the documented convention
Passed | allows termination when the research-path is valid and the file exists
Passed | blocks when the advertised research file does not exist on disk
Passed | accepts a feature-folder research path
Passed | accepts a one-off research path under docs/research/
Passed | rejects the retired artifacts/research/ path with a message naming the new roots
Passed | rejects a feature path that lacks a /research/ segment
Passed | rejects a feature research path whose filename does not conform
Passed | extracts a quoted research-path value
Passed | returns true for valid research filenames
Passed | returns false for invalid research filenames
Passed | passes a non-matching research artifact unaffected
Passed | blocks a matching artifact (by filename) missing the Automation Feasibility section
Passed | passes a matching artifact (by content) that includes the Automation Feasibility section
Passed | blocks a matching artifact whose body is empty
Passed | blocks termination when a matching artifact omits the Automation Feasibility section
Passed | extracts a research-path from a markdown link form
Passed | returns null for a whitespace-only markdown-link path
Passed | accepts research without a numeric spec criterion
Passed | blocks a numeric spec claim without numeric derivation evidence
Passed | blocks an incomplete family record and missing inclusion rules
Passed | blocks disagreeing independent cross-check counts
Passed | accepts an independently exhaustive complete-family derivation
Passed | rejects a copied count that does not match the cross-check member set
Passed | rejects a normalized duplicate search strategy
Passed | rejects missing primary or cross-check evidence
Passed | rejects mismatched member sets and missing comparison
Passed | rejects missing complete-family declaration and exhaustive scope
Passed | rejects a narrow named-pattern search that does not cover the declared family
Passed | exits 2 with a stderr reason when last_assistant_message lacks a research-path
Passed | exits 0 when last_assistant_message carries a valid research-path
Passed | blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
Passed | exits 2 with the existing empty-output reason when last_assistant_message is an empty string
Passed | exits 2 with a payload anomaly reason for empty stdin
Passed | exits 2 with a payload anomaly reason for malformed stdin
Passed | exits 2 with a payload anomaly reason when last_assistant_message is absent
Passed | keeps validating when stop_hook_active is true
Passed | exits 2 with a stderr reason when the research-path file cannot be read
Passed | exits 2 with the validate-task-researcher-output: prefix when subagentstop-envelope.ps1 fails to load
Passed | has no S1, S2, S3 or S6 guard-shape finding
Passed | exits 2 in a separate process when the stdin envelope lacks a research-path
Passed | exits 0 when the research-path uses the research.yyyy-MM-ddTHH-mm.md form
Passed | R1 accepts 2026-10-11T10-26-subagentstop-envelope-artifact-gates-addendum-research.md
Passed | R1 accepts 2026-10-11-short-name-research.md
Passed | R1 accepts 20261011-short-name-research.md
Passed | R1 accepts 2026-10-11T1026-short-name-research.md
Passed | R1 accepts 2026-10-11T10-26-short-name.research.md
Passed | R1 accepts 2026-10-11-short-name.research.md
Passed | R1 accepts 20261011-short-name.research.md
Passed | R1 accepts 2026-10-11T1026-short-name.research.md
Passed | R1 accepts research.2026-10-11T10-26.md
Passed | R1 accepts research.2026-10-11.md
Passed | R1 accepts research-addendum.2026-10-11T10-26.md
Passed | R1 accepts research-addendum.2026-10-11.md
Passed | R1 accepts backslash path 2026-10-11T10-26-short-name-research.md
Passed | R1 rejects foo.md (no date stamp)
Passed | R1 rejects bad-name.md (no date stamp)
Passed | R1 rejects research-input.md (no date stamp)
Passed | R1 rejects research-findings.md (no date stamp)
Passed | R1 rejects orchestration-mechanics.research.md (no date stamp)
Passed | R1 rejects claude-ecosystem.md (no date stamp)
Passed | R1 rejects hook-surface-inventory.2026-06-27.md (stamp only as a suffix)
Passed | R1 rejects parallel-planner-surface.2026-08-07T12-30.md (stamp only as a suffix)
Passed | R1 rejects 2026-07-22-npm-audit-fix-strategy.md (leading stamp without research ending)
Passed | R1 rejects 2026-10-09T05-40-root-prettier-fixture-exclusion.md (leading stamp without research ending)
Passed | R1 rejects 2026-10-11T10-26-research.md (empty short name)
Passed | R1 rejects 2026-10-11T10-26--short-name-research.md (short name starts with a hyphen)
Passed | R1 rejects 2026-10-11T10-26-short_name-research.md (underscore in short name)
Passed | R1 rejects 2026-10-11T10-26-short name-research.md (space in short name)
Passed | R1 rejects 2026-10-11T10-26-short.name-research.md (extra dot in short name)
Passed | R1 rejects 2026-10-11T10-26-short-name-research.MD (upper-case extension)
Passed | R1 rejects 2026-10-11T10-26-short-name-research.markdown (other extension)
Passed | R1 rejects 2026-10-11T10-26-short-name-research.txt (other extension)
Passed | R1 rejects 2026-10-11T12:05-short-name-research.md (stamp in another shape)
Passed | R1 rejects 2026-1-11-short-name-research.md (stamp in another shape)
Passed | R1 rejects research.2026-10-11T1205.md (compact time after research.)
Passed | R1 rejects research.2026-10-11T10-26-short-name.md (stamp after research. with a short name)
Passed | R3 accepts the exhaustive scope entire worktree
Passed | R3 accepts the exhaustive scope whole worktree with all directories
Passed | R3 accepts the exhaustive scope entire repository accepted before R3
Passed | R3 accepts the exhaustive scope complete source tree
Passed | R3 accepts the exhaustive scope whole repo
Passed | R3 accepts the exhaustive scope upper-case entire worktree
Passed | R3 accepts the exhaustive scope entire worktree root
Passed | R3 accepts the exhaustive scope whole repository excluding docs
Passed | R3 accepts the exhaustive scope NB-2 whole worktree restricted to code
Passed | R3 accepts the exhaustive scope NB-2 entire repository excluding docs
Passed | R3 rejects the exhaustive scope the hooks folder
Passed | R3 rejects the exhaustive scope noun without a quantifier
Passed | R3 rejects the exhaustive scope quantifier without a noun
Passed | R3 rejects the exhaustive scope path-shaped value
Passed | R3 rejects the exhaustive scope all inside allocated
Passed | R3 rejects the exhaustive scope tree inside subtree
Passed | R3 rejects the exhaustive scope worktree inside worktrees
Passed | returns the guard ExitCode and Reason object in process when a dependency failure is recorded (S6 by design)
Passed | allows when output contains a GitHub PR URL
Passed | allows when output contains a PR # reference
Passed | allows when output contains a gh pr create confirmation with a PR number
Passed | allows when output contains a gh pr edit confirmation with a PR number
Passed | blocks with PR_AUTHOR_OUTPUT_EMPTY when the assistant message is blank
Passed | blocks when output has no PR URL or number
Passed | blocks with a payload anomaly when the input text is empty
Passed | blocks with a payload anomaly when the input text is malformed JSON
Passed | blocks when the output mentions gh pr create but has no PR number
Passed | returns false for null/empty/whitespace output
Passed | returns true for a PR URL
Passed | returns false for prose with no PR reference
Passed | exits 2 in a separate process when the stdin envelope lacks a PR reference
Passed | exits 2 with PR_AUTHOR_OUTPUT_NO_PR on stderr when last_assistant_message lacks a PR reference
Passed | exits 0 when last_assistant_message reports a pull request URL
Passed | blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
Passed | exits 2 with PR_AUTHOR_OUTPUT_EMPTY when last_assistant_message is an empty string
Passed | exits 2 with a payload anomaly reason for empty stdin
Passed | exits 2 with a payload anomaly reason for malformed stdin
Passed | exits 2 with a payload anomaly reason when last_assistant_message is absent
Passed | keeps validating when stop_hook_active is true
Passed | returns Ok = $true and invokes the validator exactly once
Passed | returns Ok = $false with the validator text embedded verbatim
Passed | returns Ok = $true without invoking the validator
Passed | returns Ok = $true without invoking the validator when the seam reports absent
Passed | returns Ok = $false with a payload anomaly message for empty input text
Passed | returns Ok = $false with a payload anomaly message for malformed input text
Passed | returns Ok = $false identically to any other non-conforming result
Passed | contains no TaskMaster/TMW/Outlook/VSTO token in its own source text
Passed | returns Ok = $true without invoking the validator when last_assistant_message is an empty string
Passed | reports Present = $true with the declaration when the profile reader returns a value
Passed | returns Ok = $true when the validator reports success with EMPTY output
Passed | returns Ok = $false when the validator reports success but emits a success line
Passed | returns Ok = $true when the validator reports success with whitespace-only output
Passed | exits 2 with a DISCOVERY_ARTIFACT_GATE_BLOCKED reason on stderr when last_assistant_message references a failing artifact
Passed | exits 0 when last_assistant_message references a conforming artifact
Passed | exits 0 when last_assistant_message carries no discovery artifact reference
Passed | exits 0 when last_assistant_message is an empty string
Passed | exits 0 when the required-artifact declaration is absent
Passed | blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
Passed | exits 2 with a payload anomaly reason for empty stdin
Passed | exits 2 with a payload anomaly reason for malformed stdin
Passed | exits 2 with a payload anomaly reason when last_assistant_message is absent
Passed | keeps validating when stop_hook_active is true
Passed | exits 2 in a separate process when stdin is not a JSON envelope
Passed | R4 skips a token that is empty after trimming
Passed | R4 returns no reference for a lone backtick token
Passed | R4 returns no reference for an empty-after-trim token
Passed | R4 skips a lone backtick token and returns the following discovery reference
Passed | R4 skips the trim-only token () and returns the discovery reference
Passed | R4 skips the trim-only token [] and returns the discovery reference
Passed | R4 skips the trim-only token '' and returns the discovery reference
Passed | R4 skips the trim-only token , and returns the discovery reference
Passed | R4 skips the trim-only token ; and returns the discovery reference
Passed | R4 gate allows a message containing only a lone backtick without invoking the validator
Passed | dispatches each distinct discovery reference exactly once
Passed | stops at the first failing reference and returns DISCOVERY_ARTIFACT_GATE_BLOCKED
FAILED=0
FAILED_BLOCKS=0
FAILED_CONTAINERS=0
PASSED=224
```
