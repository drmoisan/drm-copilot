# NB-5 Task-Researcher Suites (P5-T7)

Timestamp: 2026-10-16T04-04

Command: sh SCRATCH/929/P5-T7-1.sh
Script: `Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1') -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'FAILED_BLOCKS=' + $r.FailedBlocksCount; 'FAILED_CONTAINERS=' + $r.FailedContainersCount; 'PASSED=' + $r.PassedCount; exit [int]($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount)`
EXIT_CODE: 0

Output Summary:
- `FAILED=0`
- `FAILED_BLOCKS=0`
- `FAILED_CONTAINERS=0`
- `PASSED=698`
- The line `Passed | has no S1, S2, S3 or S6 guard-shape finding` is printed.

Full output (702 lines; 698 `Passed |` lines plus the four total lines):
```
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
FAILED=0
FAILED_BLOCKS=0
FAILED_CONTAINERS=0
PASSED=698
```
