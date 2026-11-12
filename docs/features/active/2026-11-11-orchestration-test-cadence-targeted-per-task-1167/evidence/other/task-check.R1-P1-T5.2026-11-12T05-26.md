# Task Check [R1 P1-T5] (task-check evidence; not a gate, no coverage measured)

Timestamp: 2026-11-12T05-26
Command: sh SCRATCH/issue-1167-psstatic.sh tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 (Invoke-Formatter drift check and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, Invoke-PoshQCLeakScan); sh SCRATCH/issue-1167-pester-tc.sh tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1; sh SCRATCH/issue-1167-pester-tc.sh <3 Pester files>
EXIT_CODE: 0
Output Summary:
- Scoped format check: drift 0; PSScriptAnalyzer: 0 findings; leak scan: 742 files, 0 failures (STATIC_EXIT=0).
- test-cadence-wording.Tests.ps1 in full: 136 passed, 0 failed (PESTER_EXIT=0), including TCW-TEMPLATE-BUG and TCW-TEMPLATE-BUG-BUNDLE under the new gate-layout assertions and the new row TCW-CANONICAL-DISCRIMINATES.
- parallel-gate-wording.Tests.ps1, test-name-uniqueness.Tests.ps1, FileSizePolicy.RepoGate.Tests.ps1: 66 passed, 0 failed (PESTER_EXIT=0); parallel-gate-wording.Tests.ps1 unchanged against HEAD (`git diff --quiet HEAD` exit 0).
- File size: 541 lines (was 499). Compaction below 500 without dropping rows was not available, so the file stays under the 700-line advisory tier as the plan allows.

Changes in tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1:
- `$script:CanonicalD15Token` (six tokens: `expected failures`, `confirmed failing`, `every other test passes`, `no-change phase`, `changes no tracked file`, `the next gate covers it`) added to the CANONICAL check, which is held in `$script:CanonicalCheck` and scoped to `## Test Cadence (Mandatory)`.
- New row TCW-CANONICAL-DISCRIMINATES: removes every in-memory line of `.claude/skills/atomic-plan-contract/SKILL.md` that holds `no-change phase` or `expected failures` and asserts that `Get-TcwCheckProblem` reports each of the six tokens missing.
- `$plannerRequired` gains `expected failures` and `no-change phase`.
- TCW-POLICY CLAUDE-RULE and AGENTS-SKILL carry an `Extra` check in `## Mandatory Toolchain Loop` requiring `every stage it runs` and forbidding `all seven stages`.
- TCW-TEMPLATE rows carry GateCount (bug 2, feature 1, refactor 1), ExpectFailGate (bug 1, others 0), and NoChangePhase (bug `**Phase 1`); the template test asserts the gate count, that each gate line names `phase-gate.P` and `## Test Cadence (Mandatory)`, is the last checkbox of its phase, and has a later checkbox, that each gate of a phase holding an `[expect-fail]` checkbox names `expected failures` with that count equal to ExpectFailGate, and that the NoChangePhase heading holds `no-change phase`.
- `$script:SweepRoot` gains `CLAUDE.md` and `.github/copilot-instructions.md`.

Changed files:
- tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1

Selection rule: the edited test file itself, parallel-gate-wording.Tests.ps1 (required unchanged and passing by the plan), test-name-uniqueness.Tests.ps1 (parses every test file under tests/), and FileSizePolicy.RepoGate.Tests.ps1 (file-size gate over the tree).
