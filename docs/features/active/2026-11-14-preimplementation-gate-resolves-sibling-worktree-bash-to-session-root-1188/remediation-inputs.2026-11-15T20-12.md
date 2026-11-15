# Remediation Inputs — Issue 1188 (cycle 2, coordinator-relayed related finding)

Timestamp: 2026-11-15T20-12
Remediation-Mode: proportionate
Issue: 1188
Base: main
Source: coordinator relay (2026-11-15) of the fleet monitor; related to this item's fail-closed rule for shell-variable operands. Not opened by a review outcome.

## Finding F2

Severity: Blocking
Remediability: autonomous
Finding-Scope: contained

- Observed (fleet monitor, three or more agents each): (a) `cd <dir> && grep` or `git diff` reads denied by validate-bash; (b) "path does not exist" from `git -C $W ...`, because a shell variable set in an earlier Bash call is empty in the next one; (c) PREIMPLEMENTATION_GATE_BLOCKED on `git -C $W add -- $F/...` and `rm $W/$F/...`, because the gate reads command text literally and a variable operand does not resolve to the item worktree.
- Gap: this item keeps variable operands fail-closed (correct), but the agent-facing guidance never states why, so agents keep writing `$W` and `$F`.
- Required change (smallest canonical places, kept short):
  1. `## Command-Text Restrictions` of the execution-environment brief, next to the existing cd-chain guidance: one sentence stating that shell variables do not persist between Bash calls and that hooks read command text literally, so every worktree path, file path, and feature-folder path is written as a literal absolute path in each command and never as `$W` or `$F`; multi-step work puts the literal paths inside a `sh <SCRATCH>/<file>.sh` script. All six byte-identical copies.
  2. The same rule in the Codex skill mirror `.agents/skills/bash-command-shape/SKILL.md` and its bundle copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/bash-command-shape/SKILL.md`, if their text does not already state it.
  3. A contract row pinning the sentence, in the existing brief or bash-command-shape contract suite that already pins that text (for example the classify or operands Parity wording rows, or the bash-command-shape contract tests), on every edited copy.
- Out of scope (orchestrator decision ORCH-D5): `.claude/rules/bash-command-shape.md` and `.github/instructions/bash-command-shape.instructions.md` are policy documents that agents must not modify (policy-compliance-order hard constraint; refused class policy_or_settings_edit). Do not edit them, and do not edit any file under `.claude/rules/` or `.github/instructions/`.
- Constraints: the brief's process-reduction ledger replay (`ProcessReductionChain.Ledger.Tests.ps1`, rows `PRC-LEDGER-CHAIN-HOLDS` and `PRC-LEDGER-NO-EXCEPTIONS`) must keep passing; place the sentence outside the context lines of the stored ledger hunks.
- Verification: the pinning rows fail before the edit and pass after; the brief contract suite (`test_execution_environment_brief_contracts.py`) and the push-down resource contract suites pass; the ledger rows pass; task checks through the launcher.

## Context Package

- Prior cycle: remediation cycle 1 (finding R1) executed and committed; spec AC-1 to AC-15 checked.
- Canonical primary context: `artifacts/pr_context.summary.txt` (refreshed before re-audit).
