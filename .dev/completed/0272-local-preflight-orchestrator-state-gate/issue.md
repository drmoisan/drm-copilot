# local-preflight-orchestrator-state-gate (Issue #272)

- Date captured: 2026-07-02
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/local-preflight-orchestrator-state-gate/ (Issue #272)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #272
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/272
- Last Updated: 2026-07-02
- Work Mode: full-bug

## Summary

The CI-based orchestrator-state validation gate added in PR #201 (`.github/workflows/validate-orchestrator-state.yml` and `_validate-orchestrator-state.yml`) is non-functional and must be replaced with a locally-enforced pre-flight check that runs before `pr-author` creates or edits a PR, hardened by a `PreToolUse` hook so it cannot be bypassed by invoking `gh pr create` directly.

## Environment

- OS/version: Windows (Claude Code CLI runtime), PowerShell (`pwsh`) hooks
- Python version: repository `poetry` environment used by `scripts/dev_tools/validate_orchestration_artifacts`
- Command/flags used: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-complete`
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json` (gitignored, per-worktree checkpoint)

## Steps to Reproduce

1. Note that `artifacts/` is listed in `.gitignore` (line 6), so `artifacts/orchestration/orchestrator-state.json` is never committed and is never present in a CI checkout.
2. Observe that `.github/workflows/validate-orchestrator-state.yml` invokes the validator with `require-checkpoint: false`, so on every CI run it prints "No orchestrator checkpoint found... validation skipped." and exits 0.
3. Run `gh api repos/:owner/:repo/rules/branches/main` and confirm the check name `Validate orchestrator checkpoint` was never added to the `main` branch ruleset's `required_status_checks`.

## Expected Behavior

The orchestrator-state checkpoint should be validated against `--require-complete` locally, immediately before any PR-creating action, and that validation should be impossible to bypass by invoking `gh pr create` / `gh pr edit --body*` directly.

## Actual Behavior

The CI gate is a no-op: it always skips validation (no checkpoint present in a CI checkout) and, even if it did fail, the check is not registered as a required status check on the `main` branch ruleset, so it could never block a merge.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: CI job log: "No orchestrator checkpoint found... validation skipped." (exit 0) on every run of `validate-orchestrator-state.yml`.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- Root cause 1: `artifacts/` is gitignored, so the checkpoint the CI gate depends on is never present in a CI checkout by design (the checkpoint is intentionally local/per-worktree to avoid merge conflicts across concurrent `git worktree` orchestration sessions).
- Root cause 2: the check name was never wired into branch protection / ruleset required status checks.
- Related files: `.github/workflows/validate-orchestrator-state.yml`, `.github/workflows/_validate-orchestrator-state.yml`, their bundled mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/.github/workflows/`, `.claude/hooks/enforce-pr-author-skill.ps1` and its bundled mirrors, `.claude/skills/orchestrate/SKILL.md` ("## PR Authoring (pr-author Handoff)"), `.claude/agents/orchestrator.md`, `.claude/agents/pr-author.md`.

## Proposed Fix / Validation Ideas

- [x] Delete the two CI workflow files and their bundled mirrors (workflow-only removal; no ruleset changes).
- [x] Add a local pre-flight step, run before delegating to `Agent(pr-author)`, that invokes the orchestrator-state validator against `artifacts/orchestration/orchestrator-state.json --require-complete` and records the result in the checkpoint (`pr_author_preflight`).
- [x] Extend `.claude/hooks/enforce-pr-author-skill.ps1` (and its bundled mirrors, including the Codex mirror) so the existing `gh pr create` / `gh pr edit --body*` PreToolUse hook also invokes the orchestrator-state validator and fails closed (blocks the call) when the checkpoint is missing or fails `--require-complete`.
- [x] Update `.claude/skills/orchestrate/SKILL.md`, `CLAUDE.md`, `.claude/agents/pr-author.md`, and `.claude/agents/orchestrator.md` so none of them describe CI as the enforcement mechanism for checkpoint validation.
- [x] Negative-path test: verify the hook blocks `gh pr create` when the checkpoint is missing or invalid.
- [x] Run bundled-mirror contract tests (Python + Pester) and the full toolchain loop after edits.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
- [x] Implementation complete: two CI workflow files and their two bundled mirrors deleted; `enforce-pr-author-skill.ps1` (and its `.claude`/Codex bundled mirrors) hardened with the `Invoke-OrchestratorStatePreflight` local preflight check and `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` block reason; `orchestrate/SKILL.md`, `orchestrator.md`, `pr-author.md`, and `CLAUDE.md` updated to document the local enforcement mechanism. Full PowerShell toolchain (format/analyze/test) and both mirror-parity pytest suites pass. See `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/` for full evidence.
- [ ] Open PR (out of scope for this executor delegation; PR authoring is delegated separately per `.claude/skills/orchestrate/SKILL.md` § "PR Authoring (pr-author Handoff)").
