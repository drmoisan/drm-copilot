# Target Suites Baseline (P0-T27)

Timestamp: 2026-10-16T01-08

Command: sh SCRATCH/issue-929/P0-T27-1.sh
Script: `Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1','tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1','tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1','tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1','tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1') -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'FAILED_BLOCKS=' + $r.FailedBlocksCount; 'FAILED_CONTAINERS=' + $r.FailedContainersCount; 'PASSED=' + $r.PassedCount; exit [int]($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount)`
EXIT_CODE: 0

Output Summary:
- `FAILED=0`
- `FAILED_BLOCKS=0`
- `FAILED_CONTAINERS=0`
- `PASSED=982`
- The line `Passed | R3 accepts the exhaustive scope entire worktree` is printed (twice: once from the prd-feature suite and once from the task-researcher Coverage suite).
- This run is the success-case observation of the runner format used by every later runner script. No failed test, block, or container; no pre-existing failure.

Full output (986 lines; 982 `Passed |` lines plus the four total lines):
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
Passed | R3 rejects the exhaustive scope the hooks folder
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
Passed | R3 rejects the exhaustive scope the hooks folder
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
Passed | returns ExitCode 1 and the module-not-found message when the shared module is absent
Passed | returns ExitCode 0 with EMPTY Output when the shared module reports no error
Passed | returns a non-zero ExitCode and non-empty Output for an artifact that is not on disk
Passed | returns a non-zero ExitCode and non-empty Output when ValidatorArgs is incomplete
Passed | S1: repository claude PreToolUse .claude/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S1: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
Passed | S2: repository claude PreToolUse .claude/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try
Passed | S2: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try
Passed | S2: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
Passed | S3: repository claude PreToolUse .claude/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S3: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
Passed | S4: repository claude PreToolUse .claude/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S4: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
Passed | S5: repository claude PreToolUse .claude/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 pre-loads every runtime edge under a guard
Passed | S5: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 pre-loads every runtime edge under a guard
Passed | S5: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
Passed | S6: repository claude PreToolUse .claude/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 returns the dependency decision first in its decision function
Passed | S6: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function
Passed | S6: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function
Passed | S6: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
Passed | S7: discovers hooks from .claude/settings.json and .codex/config.toml
Passed | S8: names every exemption with its justification
Passed | F1: reports an unguarded direct edge in a synthetic hook
Passed | F2: reports a try body that holds more than the import statement
Passed | F3: reports a guarded Import-Module without -ErrorAction Stop
Passed | F4: reports a hook without the bootstrap try
Passed | F5: reports a missing tail check or one placed before the dot-source early return
Passed | F6: reports a runtime import that is not pre-loaded under a guard
Passed | F7: reports a transitive Import-Module that is neither terminating nor covered
Passed | F8: does not report the named exemptions
Passed | ships an empty allowlist
Passed | detects a bare python invocation
Passed | detects an ampersand-invoked python invocation
Passed | detects a dot-invoked python invocation
Passed | detects a quoted python constant invocation
Passed | detects python3, py, and poetry as interpreter commands
Passed | detects an interpreter name written in mixed case
Passed | detects a subprocess start whose FilePath is an interpreter
Passed | detects a subprocess start whose first positional argument is an interpreter
Passed | reports no finding for a subprocess start targeting an unrelated executable
Passed | detects an ampersand-invoked variable that is not a scriptblock parameter
Passed | detects an ampersand-invoked expression in the command position
Passed | detects an Invoke-Expression call
Passed | detects the built-in alias of Invoke-Expression
Passed | reports no finding for interpreter names inside string literals
Passed | reports no finding for interpreter names inside comments
Passed | reports no finding for function names beginning with Invoke-Python
Passed | reports no finding for a scriptblock-parameter seam invocation
Passed | reports no finding when a seam variable differs from its parameter by letter case
Passed | reports no finding for dot-sourcing a sibling helper path variable
Passed | reports no finding for dot-sourcing an inline sibling helper path
Passed | still reports a dot-sourced expression that is not a Join-Path call
Passed | still reports a Join-Path load that does not resolve a ps1 sibling
Passed | still reports an ampersand-invoked inline sibling-load expression
Passed | enumerates only the guarded roots and never the bundled mirror
Passed | reports no Python invocation beyond the allowlist across the guarded tree
Passed | carries no stale allowlist entry
Passed | AC-15 claude hooks path is under a scan root
Passed | AC-15 codex hooks path is under a scan root
Passed | AC-15 bundled mirror path is outside every scan root
Passed | AC-15 unrelated path is outside every scan root
Passed | AC-15 enumeration includes at least one codex hooks file
Passed | baseline mock interception probe
Passed | B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill.epic-base-branch.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill-helpers.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorStateUnconditional.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-authorization.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-resolution.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming enforce-epic-worktree-removal-gate-resolution.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/check-python-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 blocks naming DiscoveryValidation.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeTargetResolution.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming enforce-prd-feature-before-planner-helpers.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming EpicScopeResolution.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming enforce-parallel-cohort-barrier-helpers.ps1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
Passed | B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming enforce-parallel-drift-gate-helpers.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 blocks naming subagentstop-envelope.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 blocks naming DiscoveryValidation.psm1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 blocks naming feature-review-coverage-thresholds.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 blocks naming validate-feature-review-coverage-metrics.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 blocks naming validate-feature-review-coverage-rules.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 blocks naming subagentstop-envelope.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-planner-output.ps1 blocks naming subagentstop-envelope.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 blocks naming subagentstop-envelope.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-pr-author-output.ps1 blocks naming subagentstop-envelope.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-resolution.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-routing.ps1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateEpicWaveBarrier.psm1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateCompletion.psm1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateUnconditional.psm1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
Passed | B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming subagentstop-envelope.ps1 when that direct edge fails
Passed | B2: PreToolUse .claude/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: SubagentStop .claude/hooks/validate-planner-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: SubagentStop .claude/hooks/validate-pr-author-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B2: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: SubagentStop .claude/hooks/validate-planner-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: SubagentStop .claude/hooks/validate-pr-author-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B3: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
Passed | B4: has a reason-prefix entry for every discovered Claude hook and no other
Passed | baseline mock interception probe
Passed | C1: reports a nested EpicScopeReadiness.psm1 failure under enforce-pr-author-skill-helpers.ps1 as that top-level dependency
Passed | C2: reports a nested hook-command-scanner.ps1 load failure under enforce-pr-author-skill.epic-base-branch.ps1 as that top-level dependency
Passed | C3: denies through the merge gate when enforce-epic-merge-gate-authorization.ps1 fails to load
Passed | C4: makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1
Passed | C4: makes the pre-loaded OrchestratorStateCompletion visible to the lazy-load check in .claude/hooks/validate-orchestrator-output-routing.ps1
Passed | C4: makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1
Passed | C5: enforce-mermaid-validation.ps1 returns no deny when MermaidValidation is unavailable
Passed | C6: enforce-mermaid-validation.ps1 denies naming HookPayload.psm1 when that import fails
Passed | C7: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED:
Passed | C8: .claude/hooks/validate-feature-review-coverage.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail
Passed | C8: .claude/hooks/validate-planner-output.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail
Passed | C8: .claude/hooks/validate-prd-feature-output.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail
Passed | C8: .claude/hooks/validate-orchestrator-output.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail
FAILED=0
FAILED_BLOCKS=0
FAILED_CONTAINERS=0
PASSED=982
```
