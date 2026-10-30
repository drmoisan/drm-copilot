# Remediation Inputs — Issue #1010 (cycle 1)

- Timestamp: 2026-10-30T21-59
- Issue: #1010
- Branch: bug/preimplementation-gate-item-worktree-1010
- Source review: `code-review.2026-10-30T21-54.md` (verdict PASS, zero blocking findings)
- Remediation-Mode: proportionate

## Reason for this cycle

The review verdict is PASS. This cycle addresses related non-blocking findings inside the item before merge, per the repository owner's standing instruction that follow-ups related to the work in progress are fixed in the item through a remediation cycle and not deferred to new issues. Every finding below is `autonomous` and is confined to files already in the branch diff, plus their tests and bundle mirrors. No spec acceptance criterion and no public interface changes.

## Findings

### F1 — Duplicated helper functions have no enforced parity (Minor)

- Severity: Minor (non-blocking)
- Remediability: autonomous
- Location: `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, functions `Get-OrchestrationGateWorktreeList`, `Invoke-OrchestrationGateWorktreeList`, and `Get-OrchestrationGateCommandOperandPath`.
- Observation: the Codex file header states that these functions are byte-identical to the Claude copies. That is true today, but no test enforces it, so the copies can drift.
- Required outcome: add a Pester row that compares the definition text of each of the three functions across the two surfaces and fails on any difference. Put it in an existing or new test file under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks`, following the parity-suite conventions already on the branch, for example `enforce-orchestration-preimplementation-gate.Parity.Tests.ps1`. The row must be able to fail; demonstrate this with a mutated-text case or an explicit negative row.

### F2 — Command-operand parser drops pathspecs after unmodeled value options (Minor)

- Severity: Minor (non-blocking)
- Remediability: autonomous
- Location: `Get-OrchestrationGateCommandOperandPath` on both surfaces.
- Observation: a pathspec that follows an option the parser does not model, such as `git commit -m msg /abs/wt/file`, is not collected. The commit is then evaluated against the session-root checkpoint. The result is stricter, not looser, but an item worktree commit written in that common form is denied.
- Required outcome: model the value-taking options of `git commit` and `git add` that commonly precede pathspecs, at minimum `-m`/`--message`, `-F`/`--file`, `--author`, `--date`, `-C`/`-c` as commit options (reuse-message, distinct from the git global `-C`), and `--pathspec-from-file`. A pathspec after them must then be collected as an operand. Add rows to both TargetWorktree suites, including `git commit -m msg /abs/wt/file` admitted against a ready item checkpoint. Keep both copies byte-identical (F1) and update the bundle mirrors. Keep the Codex `-epic-scope` file at or below its 500-line pin.

## Findings not taken into this cycle

- Nit: the Codex resolver scans every command for `apply_patch` markers. This matches the existing epic-scope leg, so it is left unchanged as consistent behavior. It is not an issue.
- Info: the always-mocked listing wrapper is uncovered by design (spec R5). No action.
