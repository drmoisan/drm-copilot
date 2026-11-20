# Preflight Fixes

Timestamp: 2026-10-31T04-33
Plan: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md

Each fix edits task text or preamble only. No task was added, removed or reordered, and no checkbox was changed.

1. `## Terms` (`RUN-ITEMS`) | missing citation | Named the run manifest `docs/features/parallel/bugs-1001-1002-1003-1006/parallel.md` (read at `origin/main`, else at the run's plan branch) as the source of each item's `blast_radius.paths`, which [P0-T2] and `RUN-HOOKS` consume. The manifest is not on `origin/main` today and the plan named no location.
2. [P0-T3] | citation correction against the tree | `config/poshqc-coverage.json` already has the root `scripts` and `config/poshqc-scan.json` already has the scan folder `tests/scripts`. Child 1 does not need to add `scripts/harness` or `tests/scripts/harness` as separate entries, so the literal check "is a coverage root" / "is a scan folder" would report a false MISMATCH. Changed the wording to "lies under a coverage root (the existing `scripts` root suffices)" and "lies under a scan folder (the existing `tests/scripts` folder suffices)". The check still asserts what it was written to assert: the files are measured and scanned.
3. `## Pre-Mortem` (Coverage bullet) | same correction as fix 2 | Changed "must be a coverage root" to "must lie under a coverage root".
4. [P5-T1] | incomplete anchor | `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` says "three scan roots" in two places: the header comment and the `Get-GuardedPowerShellFile` synopsis. The task now names both.
5. [P5-T5] | typo | Added the missing comma between the `enforce-evidence-locations` divergence note and the Codex `validate-executor-output` note.
6. [P6-T1] | validator-blind assertion that cannot fail | A before/after `git status --porcelain` listing does not change when the formatter rewrites a file that is already modified or untracked, and every file this gate formats is in that state. The evidence is now the SHA256 of each formatted file before and after the run. The acceptance condition still means "the formatter changed nothing".
7. [P2-T10] | ambiguous acceptance literal | "the three named existing suites" did not match the four suites the task names. The acceptance now names `codex-epic-runtime-contracts.Tests.ps1` and `codex-pretooluse-integration.Tests.ps1` and states that the other two (`Invoke-FullRelease.Tests.ps1`, `post-codex-worktree-session.Tests.ps1`) run in [P2-T15], as the task text already says.
8. [P2-T10] | omitted handler name | Stated that the `^epic-review$`, `^status-updater$` and `^staged-review$` groups each register `validate-required-artifact-output.ps1` with that agent's arguments, as in `.claude/agents/epic-review.md`, `status-updater.md` and `staged-review.md` frontmatter.

Post-fix validation: `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan <plan>` exited 0, and the MCP `validate_orchestration_artifacts` (plan) returned ok.
