# release-commit-allowance-preimplementation-gate (Issue #1201)

- Date captured: 2026-11-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/release-commit-allowance-preimplementation-gate/ (Issue #1201)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1201
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1201
- Last Updated: 2026-11-17
- Work Mode: full-bug

## Summary

The preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, its helpers, and the `.codex/hooks` twin) denies every agent `git add` / `git commit` unless `artifacts/orchestration/orchestrator-state.json` holds a ready checkpoint. A routine release version bump has no orchestration checkpoint, so an agent running a release skill cannot commit the bumped version files. A destination repository cannot add its own exemption: the hooks are push-down managed (a local edit is overwritten on refresh), and a separate local hook cannot override another hook's deny. The exemption must ship from this repository, with each destination declaring its own allowance in a file that push-down never writes. High priority.

## Environment

- OS/version: Windows 11 and Linux, Claude Code and Codex runtimes
- Python version: not applicable
- Command/flags used: an agent release skill running `git add package.json CHANGELOG.md` then `git commit -m "..."` on a `release/v*` branch with no orchestration checkpoint
- Data source or fixture: any destination repository receiving the push-down hooks

## Steps to Reproduce

1. In a destination repository with the pushed-down hooks, check out a release branch with no orchestration checkpoint.
2. Bump the version files and have an agent run `git add` on them.
3. Observe PREIMPLEMENTATION_GATE_BLOCKED.

## Expected Behavior

1. Repository-owned config file `.claude/release-commit-allowance.json` (listed in no pack manifest; push-down never creates, overwrites or deletes it). Schema version 1: `{ "schema_version": 1, "allowances": [ { "id": "release-version-bump", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json", "CHANGELOG.md"] } ] }`. `id` non-empty and unique; `branch_patterns` non-empty list of globs matched against the full current branch name; `allowed_paths` non-empty list of literal repository-relative forward-slash paths (no globs, directories, `..` segments, or absolute paths). File absent: gate behaves exactly as today. File present but unreadable or invalid (bad JSON, unknown schema_version, missing or empty fields, a glob or directory in allowed_paths): the gate denies with a specific code, for example `RELEASE_ALLOWANCE_CONFIG_INVALID: <detail>`; never silently allow.
2. New allow leg in the gate, command leg only (Bash and PowerShell `command` input; Write/Edit path leg and delegation leg unchanged). Allow-side only: consulted after the checkpoint readiness check fails, like the cleanup-context legs (#1026) and the orchestration-bookkeeping staging exemption (#539); never suppresses another hook's deny; never changes trigger classification.
   - Branch: resolve the current branch of the target worktree (honour literal `git -C <path>` like the existing resolver; deny an unexpandable `-C` value such as a shell variable). Detached HEAD or an unmatched branch gets no allowance.
   - Chained commands fail closed: the whole line must split cleanly and every segment must independently qualify as an allowed `git add` or `git commit` under the same allowance; any other segment denies.
   - `git add`: only literal path operands, each in that allowance's allowed_paths, optionally after `--`. Deny -A, --all, -u, --update, `.`, globs, directories, -f/--force, --pathspec-from-file, -p/-i, and any operand not in the list.
   - `git commit`: allowed options only -m/--message, -F/--file (repeatable), -s/--signoff. Deny -a/--all, --amend, --no-verify/-n, -c/-C/--reuse-message, --fixup/--squash, --allow-empty, --only/--include, any pathspec operand, and any `git -c <key>=<value>` prefix. The staged index (`git diff --cached --name-only -z` in the target worktree) must be non-empty and every staged path in allowed_paths; an unreadable index denies.
   - Deny suffixes follow the cleanup-leg convention, one code per failure: RELEASE_ALLOWANCE_BRANCH_NOT_MATCHED, RELEASE_ALLOWANCE_PATH_NOT_ALLOWED, RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED, RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED, RELEASE_ALLOWANCE_STAGED_INDEX_EMPTY, RELEASE_ALLOWANCE_STAGED_INDEX_UNREADABLE. The suffix is appended to the existing PREIMPLEMENTATION_GATE_BLOCKED reason only when a release allowance exists for the repository; repositories without the file see today's text.
3. Out of scope: no change to the pr-author hooks (PR creation stays exclusive to pr-author); no change to git push handling or any other gate; no default allowance ships in the payload.
4. Tests and contracts: Pester tests for the config parser (valid, absent, each invalid case) and table-driven tests for the allow leg (allowed add, allowed commit, each forbidden option, a forbidden operand, branch mismatch, detached HEAD, chained command with one non-qualifying segment, staged index with an extra path, empty index, unreadable index, unexpandable `-C`). Mock git through the existing wrapper seam; no live git, no temporary files. A push-down contract test asserting no pack manifest lists the allowance file and a refresh leaves an existing allowance file byte-identical. Keep `.claude`/`.codex` twins byte-identical; add any new helper to the core pack manifest so the dependency-closure test passes.
5. Documentation: the allowance file, schema, matching rules and deny codes in the execution-environment skill (hook section) and in the rule that describes the preimplementation gate; a changelog entry stating destinations receive the leg through the next push-down refresh and opt in by creating the file.

## Actual Behavior

Every agent `git add` / `git commit` without a ready checkpoint is denied, including a release version bump.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.`

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The gate has allow legs for cleanup contexts (#1026) and orchestration bookkeeping (#539) but none for a repository-declared release commit. Acceptance: without the file, decisions and deny text unchanged (existing gate tests pass unmodified); with a valid file, an agent on a matching branch can `git add <allowed paths>` then `git commit -m "<message>"` with only those paths staged and no checkpoint; every forbidden variation is denied with its specific code; a push-down refresh does not modify the allowance file. The epic #1018 architecture is changing the hooks (dispatcher, generators, push-down consolidation), so this change may need adapting when merged into the epic integration branch.

## Proposed Fix / Validation Ideas

- [ ] Config parser module (PowerShell) with the validation rules above
- [ ] Allow leg sibling file wired into the gate after the readiness failure, both runtimes, bundles and core pack manifest
- [ ] Table-driven Pester tests with the git wrapper seam; push-down contract test
- [ ] Docs and changelog

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
