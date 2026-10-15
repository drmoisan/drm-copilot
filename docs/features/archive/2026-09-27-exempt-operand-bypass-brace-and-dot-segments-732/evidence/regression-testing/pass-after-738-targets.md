# Pass-after run over the targets suites and the legacy Codex contracts (issue #738)

Timestamp: 2026-10-09T04-08
Task: [P4-T11]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/scoped-task.sh (R-SCOPED over 3 files)
EXIT_CODE: 0

## Output

```text
FILES: 3
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
PassedCount: 129
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: preimplementation gate targets (.claude/hooks).U01 resolves an absolute path-leg input to itself
PASSED: preimplementation gate targets (.claude/hooks).U02 resolves a relative path-leg input to the session root
PASSED: preimplementation gate targets (.claude/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED: preimplementation gate targets (.claude/hooks).U04 normalizes a backslash path-leg input
PASSED: preimplementation gate targets (.claude/hooks).U05 resolves two patch-marker paths in order
PASSED: preimplementation gate targets (.claude/hooks).U06 denies an unbalanced segment
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for cd
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for pushd
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for popd
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for chdir
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for Set-Location
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for sl
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for Push-Location
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for Pop-Location
PASSED: preimplementation gate targets (.claude/hooks).U08 denies a wrapper-led git segment without reading its -C value
PASSED: preimplementation gate targets (.claude/hooks).U09 denies a substitution-bearing git segment
PASSED: preimplementation gate targets (.claude/hooks).U10 resolves a wrapper-led non-git segment to the session root
PASSED: preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_DIR=/x git add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_WORK_TREE=/x git add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_COMMON_DIR=/x git add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_INDEX_FILE=/x git add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U11 gives git-relocation for export GIT_DIR=/x && git add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --git-dir=/x add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --git-dir /x add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --work-tree /x add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git -c core.worktree=/x add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U13 collects every value of a repeated -C selector
PASSED: preimplementation gate targets (.claude/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED: preimplementation gate targets (.claude/hooks).U15 gives selector-dot-segment for a dot and a dot-dot selector
PASSED: preimplementation gate targets (.claude/hooks).U16 gives selector-backslash for a backslash selector
PASSED: preimplementation gate targets (.claude/hooks).U17 gives selector-missing-value for a trailing -C
PASSED: preimplementation gate targets (.claude/hooks).U18 gives git-option-unmodeled for an unknown global option
PASSED: preimplementation gate targets (.claude/hooks).U19 resolves a chained command to the session root and the selector
PASSED: preimplementation gate targets (.claude/hooks).U20 rejects a relative session root and normalizes a backslash session root
PASSED: preimplementation gate targets (.claude/hooks).U21 returns the four patch-marker paths and nothing for a plain command
PASSED: preimplementation gate targets (.claude/hooks).U22 gives none for no epic scope
PASSED: preimplementation gate targets (.claude/hooks).U22 gives deny for an unresolved target result
PASSED: preimplementation gate targets (.claude/hooks).U22 gives deny for an ambiguous target
PASSED: preimplementation gate targets (.claude/hooks).U22 gives deny for an unresolved selector target
PASSED: preimplementation gate targets (.claude/hooks).U22 gives deny for a non-epic target
PASSED: preimplementation gate targets (.claude/hooks).U22 gives evaluate for all-epic targets
PASSED: preimplementation gate targets (.claude/hooks).U23 resolves a target equal to the session root once
PASSED: preimplementation gate targets (.codex/hooks).U01 resolves an absolute path-leg input to itself
PASSED: preimplementation gate targets (.codex/hooks).U02 resolves a relative path-leg input to the session root
PASSED: preimplementation gate targets (.codex/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED: preimplementation gate targets (.codex/hooks).U04 normalizes a backslash path-leg input
PASSED: preimplementation gate targets (.codex/hooks).U05 resolves two patch-marker paths in order
PASSED: preimplementation gate targets (.codex/hooks).U06 denies an unbalanced segment
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for cd
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for pushd
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for popd
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for chdir
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for Set-Location
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for sl
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for Push-Location
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for Pop-Location
PASSED: preimplementation gate targets (.codex/hooks).U08 denies a wrapper-led git segment without reading its -C value
PASSED: preimplementation gate targets (.codex/hooks).U09 denies a substitution-bearing git segment
PASSED: preimplementation gate targets (.codex/hooks).U10 resolves a wrapper-led non-git segment to the session root
PASSED: preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_DIR=/x git add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_WORK_TREE=/x git add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_COMMON_DIR=/x git add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_INDEX_FILE=/x git add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U11 gives git-relocation for export GIT_DIR=/x && git add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --git-dir=/x add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --git-dir /x add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --work-tree /x add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git -c core.worktree=/x add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U13 collects every value of a repeated -C selector
PASSED: preimplementation gate targets (.codex/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED: preimplementation gate targets (.codex/hooks).U15 gives selector-dot-segment for a dot and a dot-dot selector
PASSED: preimplementation gate targets (.codex/hooks).U16 gives selector-backslash for a backslash selector
PASSED: preimplementation gate targets (.codex/hooks).U17 gives selector-missing-value for a trailing -C
PASSED: preimplementation gate targets (.codex/hooks).U18 gives git-option-unmodeled for an unknown global option
PASSED: preimplementation gate targets (.codex/hooks).U19 resolves a chained command to the session root and the selector
PASSED: preimplementation gate targets (.codex/hooks).U20 rejects a relative session root and normalizes a backslash session root
PASSED: preimplementation gate targets (.codex/hooks).U21 returns the four patch-marker paths and nothing for a plain command
PASSED: preimplementation gate targets (.codex/hooks).U22 gives none for no epic scope
PASSED: preimplementation gate targets (.codex/hooks).U22 gives deny for an unresolved target result
PASSED: preimplementation gate targets (.codex/hooks).U22 gives deny for an ambiguous target
PASSED: preimplementation gate targets (.codex/hooks).U22 gives deny for an unresolved selector target
PASSED: preimplementation gate targets (.codex/hooks).U22 gives deny for a non-epic target
PASSED: preimplementation gate targets (.codex/hooks).U22 gives evaluate for all-epic targets
PASSED: preimplementation gate targets (.codex/hooks).U23 resolves a target equal to the session root once
PASSED: enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps all four surface copies of the targets module byte-identical by SHA256 hash
PASSED: enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps every surface copy of the targets module under the 500-line cap
PASSED: Legacy Codex hooks use native lifecycle contracts.parse-checks each root and bundled hook and keeps every file within 500 lines
PASSED: Legacy Codex hooks use native lifecycle contracts.keeps the canonical hooks byte-identical to their bundled copies
PASSED: Legacy Codex hooks use native lifecycle contracts.reads stdin in every hook entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.contains no legacy Claude environment-variable dependency in hooks or shared modules
PASSED: Legacy Codex hooks use native lifecycle contracts.lists every shared hook module in the core pack manifest
PASSED: Legacy Codex hooks use native lifecycle contracts.ignores poisoned Claude variables when safe Codex stdin payloads are supplied
PASSED: Legacy Codex hooks use native lifecycle contracts.fails closed with exit 2 and stderr for malformed stdin on every hook
PASSED: Legacy Codex hooks use native lifecycle contracts.emits the current PreToolUse deny envelope for shell and patch violations
PASSED: Legacy Codex hooks use native lifecycle contracts.fails closed when the canonical checkpoint is deleted or becomes invalid JSON
PASSED: Legacy Codex hooks use native lifecycle contracts.denies preimplementation and batch-budget violations through their pure decisions
PASSED: Legacy Codex hooks use native lifecycle contracts.allows exempt checkpoint writes and preparation-mode delegations (issue #535)
PASSED: Legacy Codex hooks use native lifecycle contracts.reconstructs update patches in memory and includes move destinations
PASSED: Legacy Codex hooks use native lifecycle contracts.uses one SubagentStop continuation and stops repeated continuation loops
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a feature documentation path as implementation path False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies the orchestrator checkpoint as implementation path False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a production script as implementation path True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a plain text file as implementation path False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an empty command as implementation command False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an apply_patch add of a script as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an apply_patch add of documentation as implementation command False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an apply_patch rename onto a script as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a git commit as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a pytest run as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an unrelated command as implementation command False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null tool_input as no implementation delegation
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).detects an implementation delegation inside a serialized tool_input
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats an unrelated serialized tool_input as no delegation
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null checkpoint payload as not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a checkpoint missing lifecycle readiness as not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a complete checkpoint as ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns empty checkpoint content when the checkpoint file is absent
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns the checkpoint file content when the checkpoint file is present
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows when no mapped tool_input is supplied
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).throws a hook-named error for malformed mapped tool_input JSON
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a documentation file path without consulting the checkpoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation command when the checkpoint is not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation delegation when the checkpoint is not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows an implementation path when the checkpoint is ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).reads the checkpoint from disk when no checkpoint text is supplied
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an apply_patch implementation through its own entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies a mapped Edit implementation through its own entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a mapped Write of feature documentation through its own entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).fails closed with exit 2 when its entrypoint receives empty stdin
```

Output Summary: PassedCount 129, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0; 0 FAILED: lines listed above.

Section-5.7 matching: UROW_PASSED_COUNT .claude/hooks 42, .codex/hooks 42; every ID U01 to U23 satisfied on both surfaces (all expansions PASSED); PARITY_PASSED 2; UROW_CONDITION_MET True.
