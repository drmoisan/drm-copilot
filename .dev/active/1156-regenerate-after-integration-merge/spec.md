# regenerate-after-integration-merge — Spec

- **Issue:** #1156
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09T21-35
- **Status:** Draft
- **Version:** 0.6 (D18 items 5 and 6 add the orchestrator's standard-gate completion of the R73 event and the `-ConfigPath` suffix rule; D18 fixes the entry-point evidence values and the Tip restore sets; D17 normative result table; D15 and D16 recorded during plan revisions)
- **Research:** `docs/features/active/regenerate-after-integration-merge-1156/research/research.2026-11-09T21-35.md`

## Overview

Today, when a feature branch merges the integration branch (epic fan-in, early start) or `origin/main` (standalone S9, parallel main sync) and the merge conflicts, the orchestrator converts the conflict into a synthetic Blocking finding and runs the full R1-R5 remediation loop. That loop counts against the three-attempt remediation limit even when the only conflicted content is generated or derived output that a deterministic command can rebuild on the merged tree.

This feature adds a repository-declared regeneration command. When every path that both sides of a merge changed matches the repository's declared generated-path patterns, the orchestrator takes a regenerate path: it runs the command on the merged tree, verifies idempotency and confinement, verifies that every non-generated path in the result equals one already-reviewed parent, runs the local unit gate, commits, and re-runs CI. The regenerate path records a delta review outcome and consumes no remediation attempt. In every other case the existing remediation loop runs unchanged. After each feature merges into an epic integration branch, the epic orchestrator runs the same command on the integration tip, commits any diff, and verifies CI before the next feature syncs.

- Target users/personas and primary use cases: the epic orchestrator operator and repository owner, whose epics contain several features that each touch the same generated artifacts (counts, inventories, generated code).
- Success metrics or expected impact: a merge whose only overlapping changes are declared generated paths completes without a planner, preflight, or full re-review cycle, and leaves `remediation_loop.completed_attempts` unchanged. A repository without a declaration behaves exactly as today.

## Behavior

### Main flow: feature-side regenerate path

1. At each point where today's procedure would convert a merge conflict into a synthetic Blocking finding (orchestrate S9 step 6 for a non-mergeable PR, epic `## Merge-Conflict Handling (Fan-In)`, epic early-start step 7, parallel `## Per-Item Merge-Conflict Handling` after the issue #643 project-file resolver escalates), the orchestrator first checks whether `config/orchestration-regeneration.json` exists in the feature worktree. When it does not exist, the orchestrator does not invoke the entry point, and today's procedure runs unchanged.
2. When the file exists, the orchestrator fetches the incoming branch and invokes `pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1 -Mode Merge -MergeRef <remote-tracking ref> -Trigger <integration_sync or main_sync>` from the feature worktree root.
3. The entry point reads and validates the config, performs `git merge --no-commit --no-ff` of the ref, derives the classifier input set, classifies, and either completes the preparation steps below or restores the worktree and reports a fallback.
4. Preparation steps (in order): resolve conflicted generated paths to the feature side, run the command (run 1), check confinement, stage run-1 output, run the command again (run 2) and the optional idempotency check, check idempotency, run the delta verification, run the declared unit gate when declared.
5. On success the entry point leaves the merge in progress with all results staged and emits one JSON object. The orchestrator then runs the standard local unit gate when the entry point reported `unit_gate: "not_run"` and, when it passes, sets the event's `unit_gate` to `pass` (D18 item 5), writes the evidence file, commits the merge with `git commit -F`, pushes, appends the `regeneration_events[]` entry and the delta `review_outcomes[]` entry with `head_sha` equal to the pushed head, and re-runs S9 on the new head.

### Alternate flow: fallback

Any classifier decision other than `regenerate`, and any failure in the preparation steps, the orchestrator-run unit gate, or the commit, ends the regenerate attempt. The entry point (or, after it has exited, the orchestrator) runs `git merge --abort`, the orchestrator appends a `regeneration_events[]` entry with `outcome: "fell_back"`, and today's procedure runs unchanged from its first step (fresh merge, synthetic Blocking finding, R1-R5). The fallback cycle consumes an attempt exactly as today; the regenerate attempt itself consumes none.

### Epic integration-tip flow

1. After the epic orchestrator records a child's `merge_status: "merged"`, and when the integration worktree contains a valid `config/orchestration-regeneration.json` (the entry point in `Validate` mode exits 0 there, D15), it fetches and fast-forwards the integration worktree, then invokes the entry point with `-Mode Tip`.
2. In `Tip` mode the entry point runs the command twice with confinement and idempotency checks, without staging and without committing, and reports the changed paths.
3. When the changed-path list is non-empty and the result is applied, the epic orchestrator runs `git add -- <changed paths>` and `git commit -F <message file>`, admitted by the new preimplementation allowance, and pushes.
4. Whether or not a regeneration commit was made, the epic orchestrator dispatches CI on the integration branch with `gh workflow run CI --ref <integration branch>`, locates the run with `gh run list --commit <tip> --workflow CI`, polls every 30 seconds for at most 90 minutes, and appends an `integration_regenerations[]` entry.
5. The epic orchestrator does not merge another child and does not launch another wave until the integration tip has a completed `CI` run with conclusion `success`.
6. When the `Tip` result is not applied, the entry point has restored every path it changed, no regeneration commit is made, CI dispatch and verification still run, and later child syncs reach the feature-side classifier as usual.

### Epic main sync

During `## Epic Integration Branch Lifecycle` step 3, when the merge of `origin/main` into the integration branch conflicts and the integration worktree holds a valid config, the epic orchestrator invokes `-Mode Merge -Trigger main_sync`. On success it commits during the in-progress merge (already admitted by the gate because `MERGE_HEAD` exists), pushes, and runs the same CI dispatch and verification before the wave launches. On fallback, today's step 3 conflict resolution runs unchanged.

### Child-side verification before sync

In epic mode, when the child's feature worktree holds a valid config (the entry point in `Validate` mode exits 0 there, D15), a child about to merge the integration branch (fan-in conflict handling or early-start step 7) first confirms with `gh run list --commit <integration tip> --workflow CI` that the tip has a completed run with conclusion `success`, polling every 30 seconds for at most 90 minutes. On timeout the child follows the existing wait branch with `blocked_reason: "awaiting_ci"`. Without a valid config the child does not wait.

### Error handling and recovery

- The entry point never leaves a partially regenerated tree: every failure branch after the merge started calls `git merge --abort` (`Merge` mode) or restores the paths it changed (`Tip` mode) before it exits.
- No branch uses `git reset --hard`.
- A present but invalid config never applies partially; it yields `config_invalid` and the validator errors are recorded under the checkpoint's `artifact_errors`.

## Inputs / Outputs

### Config file

Path: `config/orchestration-regeneration.json`, relative to the worktree root. It is repository-local: it is never placed in `extensions/drm-copilot/resources/config/`, so push-down never publishes it, and each destination repository authors its own. This repository does not add the file in this item (D11).

Version 1 shape:

- `version` (required): JSON integer `1`.
- `regeneration` (required key, value an object or `null`):
  - `command` (required): non-empty array of non-empty strings; argv executed with no shell from the worktree root. The first element resolves to an application through PATH (and PATHEXT on Windows); a resolved `.cmd` or `.bat` file runs through `ComSpec` with `/d /c` and refuses an argument holding whitespace, a double quote, or a `cmd.exe` metacharacter (`&|<>^%()`), and refuses a batch path holding a double quote or one of `&|<>^%` (whitespace and parentheses are allowed in the quoted path); a name that does not resolve is a start failure.
  - `paths` (required): non-empty array of declared path patterns.
  - `idempotency_check` (optional): non-empty array of non-empty strings; argv that must exit 0 after run 2.
  - `unit_gate` (optional): non-empty array whose every element is a non-empty array of non-empty strings; each element is one argv run in order and each must exit 0. Absent means the standard parallel gates of `## Test Isolation Checks` in the execution-environment brief, run by the orchestrator.

Validation rules (each violation produces one error string naming the key path; errors accumulate; any error yields `config_invalid`):

1. Text that does not parse as a JSON object.
2. `version` absent, or not the JSON integer `1` (a string, boolean, or fractional value is rejected).
3. `regeneration` present with a value that is neither an object nor `null`.
4. A key inside `regeneration` other than `command`, `paths`, `idempotency_check`, `unit_gate`.
5. `command` absent, not an array, empty, or holding an element that is not a string or is empty or whitespace-only.
6. `paths` absent, not an array, empty, or holding a non-string element.
7. A `paths` entry that is empty, begins with a forward slash, contains a backslash, begins with a drive letter followed by a colon, contains an empty segment, a `.` segment, or a `..` segment, or contains a square bracket character.
8. `idempotency_check` present and not a non-empty array of non-empty strings.
9. `unit_gate` present and not a non-empty array of non-empty arrays of non-empty strings.

Default-off: file absent, `regeneration` key absent, or `regeneration: null` means no configuration (reason `no_config`), and behavior equals today's behavior.

### Entry point

`pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1` with parameters:

- `-Mode` (required): `Merge`, `Tip`, or `Validate` (D15).
- `-MergeRef` (required for `Merge`, rejected for `Tip` and `Validate`): the remote-tracking ref to merge.
- `-Trigger` (required for `Merge`, rejected for `Tip` and `Validate`, D16): `integration_sync` or `main_sync`.
- `-ConfigPath` (optional): relative path of the config file; default `config/orchestration-regeneration.json`. An absolute value (leading slash or drive letter) or a value with a `..` segment is a usage error (D16).

Output: exactly one JSON object on stdout with keys `mode`, `trigger`, `decision`, `reason`, `unmatched_paths`, `config_errors`, `feature_head_sha`, `merge_head_sha`, `merge_base_sha`, `command_exit_code`, `confined`, `idempotent`, `unit_gate`, `delta_check`, `changed_paths`, `outcome`, `at`, `event`, `review_outcome`, and `evidence_text`. The value of every key for every reachable combination of mode, config state, and exit code is fixed by `### Result table (normative, D17)`; D16 states the rules that the table applies.

Exit codes: `0` regenerate path prepared (`Merge`), result applied (`Tip`), or config valid (`Validate`); `3` fall back, not applied, or config not valid (worktree restored); `1` git or process failure (worktree restored, except where the restoring `git merge --abort` or restore call itself returns non-zero, D16); `2` usage error (no config read, no git call, no process call).

Config stage (D16): in every mode, after the usage check, the config is read and validated before any git call. When the reason is `no_config` or `config_invalid`, the entry point makes no git call and no process call and exits 3, with `config_errors` holding the validator errors for `config_invalid` and empty otherwise.

### Result table (normative, D17)

Literal notation: a backticked `null`, `true`, `false`, integer, or `[]` is that JSON value; every other backticked word (quoted or bare, for example `"Merge"`, `fell_back`, `not_run`) is the JSON string with that text.

Legend for derived cells (every other cell is a JSON literal):

- `-Trigger value`: the `-Trigger` argument string as supplied.
- `validator errors`: the ordered error list returned by `Get-RegenerationConfigError` (or the parse error of rule 1).
- `HEAD sha`: trimmed stdout of `git rev-parse HEAD`.
- `MERGE_HEAD sha`: trimmed stdout of `git rev-parse -q --verify MERGE_HEAD`, the call that verifies `MERGE_HEAD` after `git merge --no-commit --no-ff`.
- `base sha`: the single line of `git merge-base --all HEAD MERGE_HEAD`.
- `classifier UnmatchedPath`: the ordinal-sorted `UnmatchedPath` returned by `Get-RegenerationPathDecision`.
- `run-1 exit`, `run-2 exit`, `check exit`, `unit-gate exit`: the non-zero exit code of the declared command run 1, the declared command run 2, `idempotency_check`, or the failing unit-gate argv.
- `C1 sorted`: the ordinal-sorted, de-duplicated C1 path list.
- `clock UTC`: the injected `-UtcNow` value rendered as ISO-8601 UTC ending in `Z`.
- `event(fell_back)`: the `New-RegenerationEvent` object with `outcome` `fell_back`, `head_sha` `null`, `evidence_path` `null`, `at` equal to the row's `at`, and every other field equal to the row's corresponding result cell. `event(regenerated)`: the same builder with `outcome` `regenerated`, `head_sha` `null`, and `evidence_path` `null` (D18).
- `delta outcome`: the `New-RegenerationDeltaReviewOutcome` object with `head_sha` `null` and `evidence_path` `null` (D18).
- `evidence text`: the `New-RegenerationEvidenceText` string of D18, with `Timestamp:` the injected clock value in the `yyyy-MM-ddTHH-mm` shape, `Command:` the `Get-RegenerationInvocationText` value of the supplied `-MergeRef`, `-Trigger`, and `-ConfigPath`, `EXIT_CODE:` `0`, and `Output Summary:` built from the row's `reason`, `confined`, `idempotent`, `unit_gate`, and `delta_check` cells.
- Git column: `none` means zero invocations of `Invoke-RegenerationGitExe`; `>=1` means at least one. Process column: the same classes for `Invoke-RegenerationProcess`. An invocation that throws counts as an invocation.
- Config state `not read`: the usage check fails before the config reader is called; the reader is not invoked.

| Row | Mode | Config state | Scenario | Exit | `mode` | `trigger` | `decision` | `reason` | `unmatched_paths` | `config_errors` | `feature_head_sha` | `merge_head_sha` | `merge_base_sha` | `command_exit_code` | `confined` | `idempotent` | `unit_gate` | `delta_check` | `changed_paths` | `outcome` | `at` | `event` | `review_outcome` | `evidence_text` | Git calls | Process calls |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| R01 | omitted | not read | `-Mode` omitted | 2 | `null` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R02 | unknown | not read | `-Mode` value other than `Merge`, `Tip`, `Validate` (ordinal) | 2 | `null` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R03 | Merge | not read | `-MergeRef` omitted or empty | 2 | `"Merge"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R04 | Merge | not read | `-Trigger` omitted or empty | 2 | `"Merge"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R05 | Merge | not read | `-Trigger` other than `integration_sync` or `main_sync` | 2 | `"Merge"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R06 | Tip | not read | `-MergeRef` supplied | 2 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R07 | Tip | not read | `-Trigger` supplied | 2 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R08 | Validate | not read | `-MergeRef` supplied | 2 | `"Validate"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R09 | Validate | not read | `-Trigger` supplied | 2 | `"Validate"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R10 | Merge | not read | `-ConfigPath` begins with a forward slash | 2 | `"Merge"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R11 | Merge | not read | `-ConfigPath` begins with a drive letter and colon | 2 | `"Merge"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R12 | Merge | not read | `-ConfigPath` holds a `..` segment | 2 | `"Merge"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R13 | Tip | not read | `-ConfigPath` begins with a forward slash | 2 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R14 | Tip | not read | `-ConfigPath` begins with a drive letter and colon | 2 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R15 | Tip | not read | `-ConfigPath` holds a `..` segment | 2 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R16 | Validate | not read | `-ConfigPath` begins with a forward slash | 2 | `"Validate"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R17 | Validate | not read | `-ConfigPath` begins with a drive letter and colon | 2 | `"Validate"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R18 | Validate | not read | `-ConfigPath` holds a `..` segment | 2 | `"Validate"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `usage_error` | `null` | `null` | `null` | `null` | none | none |
| R19 | Validate | absent file | reader returns `null` | 3 | `"Validate"` | `null` | `null` | `"no_config"` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_valid` | clock UTC | `null` | `null` | `null` | none | none |
| R20 | Validate | `regeneration` key absent | valid `version`, no `regeneration` key | 3 | `"Validate"` | `null` | `null` | `"no_config"` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_valid` | clock UTC | `null` | `null` | `null` | none | none |
| R21 | Validate | `regeneration` null | `regeneration: null` | 3 | `"Validate"` | `null` | `null` | `"no_config"` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_valid` | clock UTC | `null` | `null` | `null` | none | none |
| R22 | Validate | invalid | one or more rule violations | 3 | `"Validate"` | `null` | `null` | `"config_invalid"` | `[]` | validator errors | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_valid` | clock UTC | `null` | `null` | `null` | none | none |
| R23 | Validate | valid | config valid | 0 | `"Validate"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `valid` | clock UTC | `null` | `null` | `null` | none | none |
| R24 | Tip | absent file | reader returns `null` | 3 | `"Tip"` | `null` | `null` | `"no_config"` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | none | none |
| R25 | Tip | `regeneration` key absent | valid `version`, no `regeneration` key | 3 | `"Tip"` | `null` | `null` | `"no_config"` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | none | none |
| R26 | Tip | `regeneration` null | `regeneration: null` | 3 | `"Tip"` | `null` | `null` | `"no_config"` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | none | none |
| R27 | Tip | invalid | one or more rule violations | 3 | `"Tip"` | `null` | `null` | `"config_invalid"` | `[]` | validator errors | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | none | none |
| R28 | Tip | valid | applied, C1 non-empty | 0 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `0` | `true` | `true` | `not_run` | `not_run` | C1 sorted | `applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R29 | Tip | valid | applied, C1 empty (command changed nothing) | 0 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `0` | `true` | `true` | `not_run` | `not_run` | `[]` | `applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R30 | Tip | valid | precondition: merge in progress (`MERGE_HEAD` present) | 3 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | none |
| R31 | Tip | valid | precondition: `git status` listing non-empty | 3 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | none |
| R32 | Tip | valid | precondition `git status` call returns non-zero | 1 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | none |
| R33 | Tip | valid | run 1 cannot be started | 1 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R34 | Tip | valid | run 1 exits non-zero (restored) | 3 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | run-1 exit | `null` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R35 | Tip | valid | C1 listing or a run-1 `git hash-object` returns non-zero (restored) | 1 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `0` | `null` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R36 | Tip | valid | C1 holds a path outside the declared patterns (restored) | 3 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `0` | `false` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R37 | Tip | valid | run 2 exits non-zero (restored) | 3 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | run-2 exit | `true` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R38 | Tip | valid | `idempotency_check` exits non-zero (restored) | 3 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | check exit | `true` | `false` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R39 | Tip | valid | run-2 path set or blob id differs from the run-1 snapshot (restored) | 3 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `0` | `true` | `false` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R40 | Tip | valid | run 2 or `idempotency_check` cannot be started (restored) | 1 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `true` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R41 | Tip | valid | a post-run-2 listing or `git hash-object` returns non-zero (restored) | 1 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `0` | `true` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R42 | Tip | valid | R36 scenario and a `git checkout --` or `git clean` restore call returns non-zero | 1 | `"Tip"` | `null` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `0` | `false` | `null` | `not_run` | `not_run` | `[]` | `not_applied` | clock UTC | `null` | `null` | `null` | >=1 | >=1 |
| R43 | Merge | absent file | reader returns `null` | 3 | `"Merge"` | `-Trigger value` | `"remediation_loop"` | `"no_config"` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | none | none |
| R44 | Merge | `regeneration` key absent | valid `version`, no `regeneration` key | 3 | `"Merge"` | `-Trigger value` | `"remediation_loop"` | `"no_config"` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | none | none |
| R45 | Merge | `regeneration` null | `regeneration: null` | 3 | `"Merge"` | `-Trigger value` | `"remediation_loop"` | `"no_config"` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | none | none |
| R46 | Merge | invalid | one or more rule violations | 3 | `"Merge"` | `-Trigger value` | `"remediation_loop"` | `"config_invalid"` | `[]` | validator errors | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | none | none |
| R47 | Merge | valid | `MERGE_HEAD` absent after `git merge` (no abort call) | 1 | `"Merge"` | `-Trigger value` | `null` | `null` | `[]` | `[]` | `null` | `null` | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | none |
| R48 | Merge | valid | `git rev-parse HEAD` returns non-zero | 1 | `"Merge"` | `-Trigger value` | `null` | `null` | `[]` | `[]` | `null` | MERGE_HEAD sha | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | none |
| R49 | Merge | valid | `git merge-base --all` returns non-zero | 1 | `"Merge"` | `-Trigger value` | `null` | `null` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | none |
| R50 | Merge | valid | ours or theirs `--no-renames` listing returns non-zero | 1 | `"Merge"` | `-Trigger value` | `null` | `null` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | none |
| R51 | Merge | valid | classifier fallback: merge-base count 0 | 3 | `"Merge"` | `-Trigger value` | `"remediation_loop"` | `"multiple_merge_bases"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | none |
| R52 | Merge | valid | classifier fallback: merge-base count 2 | 3 | `"Merge"` | `-Trigger value` | `"remediation_loop"` | `"multiple_merge_bases"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | `null` | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | none |
| R53 | Merge | valid | classifier fallback: empty changed set | 3 | `"Merge"` | `-Trigger value` | `"remediation_loop"` | `"empty_set"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | none |
| R54 | Merge | valid | classifier fallback: a changed path matches no pattern | 3 | `"Merge"` | `-Trigger value` | `"remediation_loop"` | `"unmatched_path"` | classifier UnmatchedPath | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | none |
| R55 | Merge | valid | a conflict-resolution git call (`--diff-filter=U` listing, `git checkout --ours`, `git add`, or a clean-tree listing) returns non-zero | 1 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | none |
| R56 | Merge | valid | unstaged or untracked listing non-empty after conflict resolution | 3 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | none |
| R57 | Merge | valid | run 1 cannot be started | 1 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `null` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R58 | Merge | valid | run 1 exits non-zero | 3 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | run-1 exit | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R59 | Merge | valid | C1 unstaged or untracked listing returns non-zero | 1 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `0` | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R60 | Merge | valid | C1 holds a path outside the declared patterns | 3 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `0` | `false` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R61 | Merge | valid | `git add -A` of C1 returns non-zero | 1 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `0` | `true` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R62 | Merge | valid | run 2 exits non-zero | 3 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | run-2 exit | `true` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R63 | Merge | valid | run 2 or `idempotency_check` cannot be started | 1 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `null` | `true` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R64 | Merge | valid | `idempotency_check` exits non-zero | 3 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | check exit | `true` | `false` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R65 | Merge | valid | C2 unstaged or untracked listing returns non-zero | 1 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `0` | `true` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R66 | Merge | valid | C2 non-empty | 3 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `0` | `true` | `false` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R67 | Merge | valid | a cached delta listing returns non-zero | 1 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `0` | `true` | `true` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R68 | Merge | valid | delta violation against P1 (feature head) | 3 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `0` | `true` | `true` | `not_run` | `fail` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R69 | Merge | valid | delta violation against P2 (incoming tip) | 3 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `0` | `true` | `true` | `not_run` | `fail` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R70 | Merge | valid | a declared unit-gate argv cannot be started | 1 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `null` | `true` | `true` | `fail` | `pass` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R71 | Merge | valid | a declared unit-gate argv exits non-zero | 3 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | unit-gate exit | `true` | `true` | `fail` | `pass` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |
| R72 | Merge | valid | prepared, `unit_gate` declared and every argv exits 0 | 0 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `0` | `true` | `true` | `pass` | `pass` | C1 sorted | `prepared` | clock UTC | event(regenerated) | delta outcome | evidence text | >=1 | >=1 |
| R73 | Merge | valid | prepared, `unit_gate` undeclared | 0 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | `0` | `true` | `true` | `not_run` | `pass` | C1 sorted | `prepared` | clock UTC | event(regenerated) | delta outcome | evidence text | >=1 | >=1 |
| R74 | Merge | valid | R58 scenario and `git merge --abort` returns non-zero | 1 | `"Merge"` | `-Trigger value` | `"regenerate"` | `"all_match"` | `[]` | `[]` | HEAD sha | MERGE_HEAD sha | base sha | run-1 exit | `null` | `null` | `not_run` | `not_run` | `[]` | `fell_back` | clock UTC | event(fell_back) | `null` | `null` | >=1 | >=1 |

### Checkpoint and evidence outputs

- Per-feature checkpoint, tolerated top-level list `regeneration_events[]` (shape in Data & State).
- Per-feature checkpoint, one `remediation_loop.review_outcomes[]` entry per completed regenerate path.
- Epic checkpoint, tolerated top-level list `integration_regenerations[]`.
- Evidence: a new file in the feature folder's `evidence/qa-gates/` directory named `regeneration-delta.` followed by the UTC write timestamp and `.md`. It contains the lines `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (classifier reason, confined, idempotent, unit-gate result, delta result), the UTC time from the injected clock, and no absolute path. A later pass writes a new file; no existing evidence file is edited or deleted.

### Backward compatibility

- Every new key is tolerated and unvalidated by the Python, TypeScript, and PowerShell checkpoint validators; no member of `REQUIRED_STATE_KEYS` is added and no validator code changes.
- `remediation_path` stays `light` or `full`; no new value is introduced.
- The portable handoff projection drops the new keys, as it drops `review_mode`.

## API / CLI Surface

### Pure functions (host-neutral, no I/O)

- `.claude/lib/regeneration/RegenerationConfig.psm1`: `ConvertFrom-RegenerationConfigText -Text <string>` returns `{ Config, Errors }` where `Config` is the parsed `regeneration` object or `$null`; `Get-RegenerationConfigError -Document <object>` returns the list of rule violations above.
- `.claude/lib/regeneration/RegenerationClassifier.psm1`:
  - `Get-RegenerationChangedPath -OursListing <string> -TheirsListing <string>` takes NUL-separated `git diff --name-only -z --no-renames` outputs and returns the ordinal-sorted, de-duplicated intersection with empty entries removed.
  - `Test-RegenerationPathMatch -Path <string> -Pattern <string[]>` applies the glob semantics below.
  - `Get-RegenerationPathDecision -ChangedPath <string[]> -MergeBaseCount <int> -Config <object> -ConfigError <string[]>` returns `{ Decision, Reason, UnmatchedPath }`.
- `.claude/lib/regeneration/RegenerationDelta.psm1`: confinement decision, idempotency decision, delta decision, and the builders for the `regeneration_events[]` entry, the delta review outcome, the `integration_regenerations[]` entry, and the evidence text. Builders take the timestamp as an argument.

### Classifier rule order (first match wins)

| Order | Condition | Decision | Reason |
|---|---|---|---|
| 1 | `Config` is `$null` | `remediation_loop` | `no_config` |
| 2 | `ConfigError` non-empty | `remediation_loop` | `config_invalid` |
| 3 | `MergeBaseCount` is not exactly 1 | `remediation_loop` | `multiple_merge_bases` |
| 4 | `ChangedPath` empty | `remediation_loop` | `empty_set` |
| 5 | Any path matches no declared pattern | `remediation_loop` | `unmatched_path` (with `UnmatchedPath` ordinal-sorted) |
| 6 | Otherwise | `regenerate` | `all_match` |

`UnmatchedPath` is empty for every reason except `unmatched_path`.

### Glob semantics

Matching delegates to `Test-GlobMatch` in `.claude/lib/blast-radius/BlastRadiusGlob.psm1`: whole-string, ordinal, case-sensitive; a single-star wildcard and a question-mark wildcard do not cross a forward slash; a double-star wildcard crosses forward slashes; character classes are unsupported. In addition, a pattern that begins with a double-star segment followed by a forward slash also matches the remainder of the pattern at the repository root (the same rule as the mechanically-mergeable matcher of issue #643). A candidate path containing a backslash never matches. A candidate that differs from a pattern only by letter case does not match.

### Classifier input derivation (I/O adapter)

1. `git merge-base --all HEAD MERGE_HEAD`; the line count is `MergeBaseCount`.
2. With exactly one base B: `git diff --name-only -z --no-renames B HEAD` (ours) and `git diff --name-only -z --no-renames B MERGE_HEAD` (theirs).
3. `ChangedPath` is `Get-RegenerationChangedPath` of the two listings. It contains every conflicted and every auto-merged path. Merge-output text such as auto-merge lines is never parsed.

### Idempotency and confinement (`Merge` mode)

1. Resolve each conflicted path (`git diff --name-only -z --diff-filter=U`) with `git checkout --ours -- <paths>` and `git add -- <paths>`. Then `git diff --name-only -z` and `git ls-files --others --exclude-standard -z` must both be empty; otherwise the attempt fails.
2. Run 1: the declared `command`. C1 is the union of unstaged changes and untracked files. Confined means every path in C1 matches a declared pattern. Not confined is a failure. Stage C1 with `git add -A -- <C1 paths>`.
3. Run 2: the declared `command` again, then `idempotency_check` when declared. C2 is the union of unstaged changes and untracked files. Idempotent means C2 is empty and `idempotency_check`, when declared, exits 0.
4. A non-zero exit from either command run is a failure and is reported in `command_exit_code`.

### Idempotency and confinement (`Tip` mode)

Preconditions: no merge in progress and an empty `git status` listing. Run 1, then a snapshot of each path in C1 with its blob id from `git hash-object`. Confinement as above. Run 2 and the optional `idempotency_check`. Idempotent means the changed-path set and every blob id after run 2 equal the run-1 snapshot. The entry point does not stage. On a not-applied result it restores tracked changed paths with `git checkout -- <paths>` and removes untracked paths it created with `git clean -f -q -- <paths>`. The restore path sets are derived as D18 states: after the failure, a fresh unstaged listing and a fresh untracked listing give the tracked and the untracked set, because the preconditions guarantee that every listed path was changed by the entry point.

### Delta verification

With P1 = feature head (`HEAD`), P2 = incoming tip (`MERGE_HEAD`), B = merge base, and H = the staged result:

- For every path in `git diff --cached --name-only -z --no-renames P1` that matches no declared pattern, the path is in `diff(B, P2)`.
- For every path in `git diff --cached --name-only -z --no-renames P2` that matches no declared pattern, the path is in `diff(B, P1)`.

Both relations holding is `delta_check: "pass"`; either violated is `"fail"` and a fallback. Together with classifier rule 5, this shows every non-generated path in the result equals the content of one already-reviewed parent.

### Merge-gate consistency check

New byte-identical helper `enforce-epic-merge-gate-regeneration.ps1` in `.claude/hooks/` and `.codex/hooks/`, dot-sourced by `.claude/hooks/enforce-epic-merge-gate.ps1` and `.codex/hooks/enforce-epic-merge-gate.ps1` and evaluated immediately after the review guard returns no denial. It applies only when the last `remediation_loop.review_outcomes[]` entry has `review_kind` exactly `regeneration_delta` (ordinal). It then requires a `regeneration_events[]` entry whose `head_sha` equals that outcome's `head_sha` and which records `outcome: "regenerated"`, `idempotent: true`, `confined: true`, `unit_gate: "pass"`, and `delta_check: "pass"`; for the R73 path the `pass` value is set by the orchestrator after the standard gates pass (D18 item 5), and `not_run` is denied. Otherwise it denies with `EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: <detail>`. It runs no process.

### Preimplementation allowance

New function `Get-EpicRegenerationAllowance` in a new byte-identical file `hook-epic-regeneration.ps1` in `.claude/hooks/` and `.codex/hooks/`, called from `Get-OrchestrationEpicScopeDecision` in `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, only when the readiness failure is exactly `'merge-in-progress'`. It admits a Bash command only when all of the following hold:

1. The worktree HEAD is the epic `integration_branch`.
2. The command is a single `git add` with optional `--` followed by one or more paths, or a single `git commit` whose options are drawn only from `-m`, `--message`, `-F`, `--file`, and `--trailer`, optionally followed by `--` and paths.
3. Every named path, and for a `git commit` without paths every staged path read through the injected reader, matches a pattern of a valid regeneration config read from the integration worktree through an injected config reader.
4. No named path contains a backslash, an asterisk, a question mark, a square bracket, a `.` or `..` segment, or a leading forward slash.

It never admits Write or Edit, `git commit -a`, `--all`, `--amend`, `--no-verify`, or a chained command. When the config is absent or invalid, it admits nothing. Every other existing deny is unchanged.

### Agent grant

`.claude/agents/epic-orchestrator.md` gains one Bash tool grant for the command prefix `pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1` followed by any arguments, written in the same form as the existing `Invoke-CiGateParser.ps1` grant (D12). No generic command route is granted.

## Data & State

### `regeneration_events[]` entry (per-feature checkpoint)

`{ at, trigger, feature_head_sha, merge_head_sha, merge_base_sha, classifier: { decision, reason, unmatched_paths }, command_exit_code, confined, idempotent, unit_gate, delta_check, head_sha, evidence_path, outcome }`

- `at`: ISO-8601 UTC with `Z` from the injected clock.
- `trigger`: `integration_sync` or `main_sync`.
- `unit_gate`, `delta_check`: `pass`, `fail`, or `not_run`.
- `head_sha`: the pushed commit for `outcome: "regenerated"`, otherwise `null`.
- `outcome`: `regenerated` or `fell_back`. A fallback is recorded, so the audit trail shows why the loop ran.

### Delta review outcome (per-feature checkpoint)

`{ verdict: "PASS", findings: [], head_sha: <pushed head>, review_kind: "regeneration_delta", evidence_path: <relative evidence file path> }`, appended to `remediation_loop.review_outcomes[]`. `review_kind` and `evidence_path` are tolerated extra keys.

### `integration_regenerations[]` entry (epic checkpoint)

`{ trigger, after_feature_issue_num, merge_commit_sha, regeneration_commit_sha, command_exit_code, confined, idempotent, outcome, ci_run_id, ci_conclusion, verified_at }`; `trigger` is `post_feature_merge` or `main_sync`; `after_feature_issue_num` is `null` for `main_sync`; `regeneration_commit_sha` is `null` when no diff was committed; `outcome` is `applied` or `not_applied`.

### Invariants

- No `remediation_loop.cycles[]` entry is written by the regenerate path, so invariant R7 (`completed_attempts` equals the count of cycles with `candidate_applied: true`) holds without change.
- Evidence and checkpoint lists are append-only.
- No migration or backfill is required.

## Constraints & Risks

- Default-off: every new config knob defaults to today's behavior. A repository without the config file, or with `regeneration` absent or `null`, observes no new git call, no new wait, and no new deny.
- No remediation attempt is consumed by the regenerate path, whether it succeeds or falls back; the three-attempt termination guard is otherwise unchanged.
- Codex behavior equals today's behavior: Codex orchestrators do not run the regenerate path, and the `.codex/hooks/` twins are inert for checkpoints without the new keys. `.agents/skills/orchestrate/SKILL.md` and `.agents/skills/epic-orchestrate/SKILL.md` are not edited.
- Honest disclosure: the merge-gate consistency check and the preimplementation allowance are policy-level controls, not security controls. A writer in the same session can author `regeneration_events[]` and a delta outcome; the controls prove internal consistency, not origin. The `review/verdict` status description continues to name the last full review's audit file.
- Waits: the child-side and epic-side CI waits poll every 30 seconds for at most 90 minutes, and apply only when a valid config exists.
- Repositories with a nondeterministic or out-of-pattern generator always fall back and gain no benefit; they gain no new risk.
- File size: `.claude/hooks/enforce-epic-merge-gate-review.ps1` is not edited; `.claude/hooks/hook-epic-fan-in.ps1` is not edited; new logic lives in new files; entry-file edits are one guarded dot-source and one call each (D13 for the line budget of `.claude/hooks/enforce-epic-merge-gate.ps1`).
- Sibling items #1157, #1158, #1159, #1160, #1161, #1162, and #1163 may edit the same files. This spec assumes no merge order. Whichever item merges after another that moved a pinned digest in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` recomputes the digest after merging `origin/main` and records a dated combined re-baseline comment.

## Implementation Strategy

- Implementation scope: three pure PowerShell modules and one thin adapter under `.claude/lib/regeneration/`; two new hook helpers with Codex twins; one-call edits to the two merge-gate entry files and the two epic-scope gate files; documentation edits to skills, agents, and the rules file; two corpus fixtures; mirrors and manifests.
- Adapter seams in `Invoke-RegenerationPath.ps1`: `Invoke-RegenerationGitExe -GitArgs` (all git calls), `Invoke-RegenerationProcess -Argv` (declared command, idempotency check, and unit gate), a config-text reader, and a clock supplied as a `-UtcNow` scriptblock. The adapter emits one JSON object and follows the fact-request pattern of `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1`.
- Dependency changes: none. `.claude/lib/blast-radius/BlastRadiusGlob.psm1` is reused.
- Logging/telemetry: the JSON result, the checkpoint lists, and the evidence file.
- Rollout: default-off; a repository opts in by committing its own config file.

### Concrete write paths

New:

- `.claude/lib/regeneration/RegenerationConfig.psm1`
- `.claude/lib/regeneration/RegenerationClassifier.psm1`
- `.claude/lib/regeneration/RegenerationDelta.psm1`
- `.claude/lib/regeneration/Invoke-RegenerationPath.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/RegenerationConfig.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/RegenerationClassifier.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/RegenerationDelta.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/Invoke-RegenerationPath.ps1`
- `.claude/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `.codex/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `.claude/hooks/hook-epic-regeneration.ps1`
- `.codex/hooks/hook-epic-regeneration.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-epic-regeneration.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-epic-regeneration.ps1`
- `tests/scripts/claude-lib/regeneration/RegenerationConfig.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/RegenerationClassifier.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/RegenerationDelta.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Merge.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tip.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1`
- `tests/scripts/claude-hooks/hook-epic-regeneration.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1`
- `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`
- `tests/fixtures/orchestrator_state_remediation_loop/regeneration_event_tolerated_accepted.json`
- `tests/fixtures/orchestrator_state_remediation_loop/regeneration_after_completed_cycle_accepted.json`

Edited:

- `.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/epic-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
- `.claude/skills/parallel-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
- `.claude/agents/orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`
- `.claude/agents/epic-orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md`
- `.claude/rules/orchestrator-state.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
- `.claude/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
- `.codex/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.ReviewGuard.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`
- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`
- `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py`
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts`
- `.claude/skills/execution-environment/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`

## Decisions

- **D1 — Config location and default-off.** Decision: repository-local `config/orchestration-regeneration.json`, version 1, validated by a pure function; absent, missing key, or `null` means today's behavior. Rationale: push-down reads only bundle config, so the file is never published to other repositories. Rejected: a `regeneration` key in `config/orchestration-routing.json`, because it is byte-mirrored and appended into destinations by the routing merge.
- **D2 — Classifier contract and glob semantics.** Decision: pure `Get-RegenerationPathDecision` over the both-sides-changed set with the first-match rule order and `Test-GlobMatch` semantics plus the root-level double-star rule; the missing `## Merge-Conflict Remediation` section of the orchestrate skill is created to hold it. Rationale: deterministic, fail-closed, reuses an existing pure glob engine, and repairs a dangling reference. Rejected: parsing localizable auto-merge output text.
- **D3 — Checkpoint recording outside `cycles[]`.** Decision: tolerated top-level `regeneration_events[]`; no cycle entry. Rationale: R7 and the three-attempt guard hold by construction with no validator change. Rejected: a `remediation_path: "regenerate"` cycle, which needs a three-runtime contract change, a `plan_path`, and a new R7 exclusion.
- **D4 — Delta review shape.** Decision: a deterministic merge-delta verification recorded as a `PASS` review outcome with `review_kind: "regeneration_delta"` and a qa-gates evidence file. Rationale: proves every non-generated path equals an already-reviewed parent. Rejected: a narrowed `feature-review` (violates its scope invariant) and `staged-review` (non-canonical evidence location, re-judges reviewed changes).
- **D5 — Concurrent review, CI join, cross-check, and review/verdict.** Decision: append sentences to rule 7 (delta outcome is the new review for the new head) and rule 11 (the CI cross-check applies to `feature-review` outcomes only); no code change to review/verdict. Rationale: avoids false synthetic Blocking findings while keeping pinned wording. Rejected: rewriting the pinned rule sentences.
- **D6 — Merge-gate acceptance.** Decision: a key-gated consistency check in a new helper denying with `REVIEW_GATE_REGENERATION_UNVERIFIED`. Rationale: makes acceptance of regenerate evidence explicit while staying inert for every existing checkpoint. Rejected: editing `enforce-epic-merge-gate-review.ps1`, which sits one line below the advisory size tier.
- **D7 — Epic post-merge regeneration and CI before the next sync.** Decision: epic orchestrator runs `Tip` mode after each child merge, commits via a narrow new preimplementation allowance, dispatches and verifies CI, and children verify the tip's CI before syncing. Rationale: the parent cannot pause a running child, so the guarantee rests on durable GitHub state. Rejected: committing from inside a script, which would bypass the gate.
- **D8 — Parallel main sync.** Decision: adopt by reference; the child orchestrator applies the orchestrate skill's regenerate path before writing a synthetic finding, after the issue #643 resolver. Rationale: the delta outcome must live in the child checkpoint that the merge guard and the join read. Rejected: parent-level regeneration.
- **D9 — Idempotency definition.** Decision: run the command twice; idempotent when the second run leaves no diff relative to the first run's staged output (`Merge`) or blob-id snapshot (`Tip`), plus an optional exit-0 check; confinement to declared patterns; every failure aborts or restores. Rationale: a mechanical, git-observable definition that never stages on the integration branch from inside a script. Rejected: single-run regeneration and `git reset --hard` recovery.
- **D10 — Language, placement, seams, runtime scope.** Decision: PowerShell 7 modules under `.claude/lib/regeneration/`, thin adapter with git, process, config-reader, and clock seams; Claude runtime only, Codex hook twins inert. Rationale: owner language policy and testability without I/O. Rejected: new Python and a Codex orchestrator implementation in this item.
- **D11 — No self-hosted declaration.** Decision: this repository does not add `config/orchestration-regeneration.json` in this item; tests use in-memory config text. Rationale: this repository and the sibling runs keep today's default-off behavior. Rejected: declaring the Codex variant generator as this repository's regeneration command now.
- **D12 — Entry-point invocation.** Decision: `pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1`, granted to `epic-orchestrator` as one prefix grant. Rationale: follows the existing `Invoke-CiGateParser.ps1` precedent in the same tool list. Rejected: a generic command route or an `sh` launcher.
- **D13 — Merge-gate entry-file line budget.** Decision: `.claude/hooks/enforce-epic-merge-gate.ps1` stays at or under the 500-line bound pinned by `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`; its one added dot-source and one added call are offset by collapsing three existing single-statement brace blocks to the one-line form, and the bound is not raised. Rationale: the file is at the bound today, and the collapse changes no statement. Rejected: raising the pinned bound.
- **D14 — Evidence path function.** Decision: `RegenerationDelta.psm1` also exports pure `Get-RegenerationEvidencePath`, which returns the `evidence/qa-gates/regeneration-delta.<timestamp>.md` path under a feature folder for the delta outcome's `evidence_path`. Rationale: the file-name rule needs a tested implementation. Rejected: leaving the name to skill prose only.
- **D15 — Deterministic "valid config" check (`Validate` mode).** Ambiguity resolved: the spec required a valid config before the epic integration-tip flow and before the child-side CI wait, but named no mechanism that decides validity without running the declared command. Decision: the entry point gains `-Mode Validate`, which reads and validates the config only, makes no git call and no process call, and exits 0 when the config is valid or 3 with reason `no_config` or `config_invalid`. "Valid config" in the epic skill means that `Validate` mode exits 0 in the named worktree. The research recommendation (D7: the flow applies only "when the integration worktree holds a valid regeneration config"; without a declaration "the child does not wait") is kept, and this mode is its mechanical test. Rejected: judging validity by file presence, which would add a 90-minute wait for an invalid config; and having the orchestrator judge the JSON by reading it, which is not deterministic.
- **D16 — Result values, parameter boundaries, and exit-code assignment.** Ambiguities resolved, following the research exit-code scheme (0 regenerated, 3 fall back, 1 git or process failure, 2 usage):
  - The usage check runs first and reads no config; the config stage follows in every mode, as stated under `### Entry point`.
  - `outcome`: `prepared` (Merge exit 0), `fell_back` (Merge exit 3 or 1), `applied` (Tip exit 0), `not_applied` (Tip exit 3 or 1), `valid` (Validate exit 0), `not_valid` (Validate exit 3), `usage_error` (exit 2).
  - `decision` is the classifier decision in `Merge` mode (`remediation_loop` for a config-stage exit, `null` for an exit before classification: `MERGE_HEAD` absent or a git failure in classifier input derivation, D17) and `null` in `Tip` and `Validate` mode; `reason` is the classifier reason in `Merge` (`null` before classification), `no_config` or `config_invalid` for a config-stage exit in any mode, and `null` otherwise.
  - `event` is built in every `Merge`-mode result except a usage error (with `outcome` `regenerated` for exit 0 and `fell_back` otherwise), because a fallback is recorded. `review_outcome` and `evidence_text` are built only for the `Merge` exit-0 result and are `null` in every other result, because the evidence file is written only on the success path. In `Tip` and `Validate` mode all three are `null`, because the epic records `integration_regenerations[]` instead. `unit_gate` is `not_run` in `Tip` and `Validate` mode, which run no unit gate.
  - A `git merge --abort` (`Merge`) or a `git checkout --` or `git clean` restore call (`Tip`) that returns non-zero turns the result being restored into exit 1; every other result value is unchanged (rows R42 and R74 of the D17 table).
  - `-Trigger` is rejected in `Tip` and `Validate` mode, as `-MergeRef` is, because the `Tip` trigger is recorded by the epic orchestrator in `integration_regenerations[]`.
  - `-Mode` is not a mandatory PowerShell parameter, so an omitted or unknown value reaches the usage check (exit 2) instead of an interactive prompt.
  - A declared command, `idempotency_check`, or unit-gate argv that runs and exits non-zero is a check failure: exit 3, with the exit code in `command_exit_code`. Exit 1 is reserved for a git call that returns non-zero where success is required and for a process that cannot be started.
  - `git merge --no-commit --no-ff` exits non-zero for a conflicting merge, which is expected. After the call the adapter verifies `MERGE_HEAD`; when it is absent (merge refused or nothing to merge) the adapter exits 1 with no `git merge --abort` call, because no merge is in progress.
  - With `idempotency_check` undeclared, no check process runs; with `unit_gate` undeclared, no unit-gate process runs.
- **D17 — Normative result table.** Ambiguity resolved: four successive preflights each found another field of the result object whose value was not pinned for some mode, config state, or exit path. Decision: `### Result table (normative, D17)` under `### Entry point` is the single normative source for the result values of `Invoke-RegenerationPath.ps1`. It has one row per reachable combination of mode, config state, and exit path, a stable row ID, one column per result key, and the git-call and process-call count classes. No cell is blank or conditional. The data-driven Pester test in `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1` is generated from the table as one `-ForEach` case per row with one asserted value per column. A row or column of the table that is missing from that test data is a defect. Where the table and any other sentence of this spec disagree, the table governs and the other sentence is a spec defect to be corrected. Rationale: a full enumeration closes the class of unpinned fields structurally instead of one field per preflight. Rejected: continuing to add per-field D16 bullets. The table applies D15, D16, `### Classifier rule order`, `### Idempotency and confinement`, `### Delta verification`, `## Data & State`, and the research exit-code and fallback-recording recommendations (research D3: "A fallback is recorded too"; research D10: exit 0, 3, 1, 2). Cell-level resolutions for cases the spec did not previously state:
  1. Usage check order: the usage check precedes the config read, so a usage-error row has config state `not read`, makes no config read, no git call, and no process call, and reads no clock (`at` `null`). The `-ConfigPath` usage forms (leading slash, drive letter and colon, `..` segment) are usage errors in each of the three modes (rows R10 through R18). An empty `-MergeRef` or `-Trigger` counts as omitted.
  2. `mode`: the canonical mode name (`Merge`, `Tip`, `Validate`), matched ordinally and case-sensitively; `null` when `-Mode` is omitted or unknown.
  3. `trigger`: the supplied `-Trigger` value in every `Merge` row except a usage error; `null` in every usage-error row (no argument value is echoed) and in every `Tip` and `Validate` row.
  4. A `Merge` `-Trigger` other than `integration_sync` or `main_sync` is a usage error (R05), so the event builder never receives an out-of-set trigger.
  5. `at`: the injected clock value in every non-usage row in every mode, including config-stage, precondition, and git-failure rows.
  6. `feature_head_sha`: `null` in every `Tip` and `Validate` row (`Tip` makes no HEAD read; the epic orchestrator reads the tip itself for `integration_regenerations[]`); in `Merge`, the HEAD sha once `git rev-parse HEAD` succeeds after the `MERGE_HEAD` verification, `null` before that (R47, R48) and in config-stage rows.
  7. `merge_head_sha`: taken from the `git rev-parse -q --verify MERGE_HEAD` call that verifies the merge; `null` when `MERGE_HEAD` is absent (R47), in config-stage rows, and in every `Tip` and `Validate` row.
  8. `merge_base_sha`: the single merge base when the base count is exactly 1; `null` when the count is 0 or 2 (R51, R52), when `git merge-base --all` fails (R49), and before that stage.
  9. `decision` and `reason` are `null` in `Merge` rows that exit before classification (R47 through R50), amending D16; `Tip` precondition and failure rows keep `reason` `null` as D16 states.
  10. `command_exit_code`: the exit code of the last process the entry point ran to completion (declared command run 1 or run 2, `idempotency_check`, or a unit-gate argv); `0` on every success row; `null` when no process ran or when the last process could not be started (R33, R40, R57, R63, R70).
  11. `confined`: `null` before the confinement decision (including `Tip` R35, because the run-1 blob-id snapshot precedes confinement); `false` when C1 holds an out-of-pattern path; `true` from confinement onward. An empty C1 is confined (R29).
  12. `idempotent`: `null` before the idempotency decision, including a run-2 non-zero exit, a run-2 or check start failure, and a C2 or post-run-2 listing failure; `false` for a non-zero `idempotency_check`, a non-empty C2, or a snapshot mismatch; `true` from the idempotency decision onward.
  13. `delta_check`: `not_run` before the delta decision and in every `Tip` and `Validate` row; `fail` for a violation on either side; `pass` from the delta decision onward.
  14. `unit_gate`: `not_run` before the unit-gate stage, when `unit_gate` is undeclared, and in every `Tip` and `Validate` row; `fail` for a declared argv that exits non-zero (exit 3) or cannot be started (exit 1); `pass` when every declared argv exits 0.
  15. `changed_paths`: the ordinal-sorted C1 only on exit-0 rows (`Merge` R72 and R73, `Tip` R28; `[]` for `Tip` R29 because C1 is empty); `[]` in every other row, so no consumer stages paths from a fallback or not-applied result.
  16. `event`, `review_outcome`, `evidence_text`: as amended in D16 (`event` in every non-usage `Merge` row; the other two only on `Merge` exit 0; all three `null` in `Tip`, `Validate`, and usage rows). The builders receive `head_sha` `null`, which the orchestrator sets to the pushed head.
  17. `unmatched_paths` is `[]` in every row except R54; `config_errors` is `[]` in every row except the invalid-config rows R22, R27, and R46.
  18. Restore failure: a non-zero `git merge --abort` or `Tip` restore call yields exit 1 with every other cell unchanged; R42 and R74 are the pinned instances.
  19. `Tip` `git status` precondition call returning non-zero is exit 1 with no restore call and no process call (R32).
  20. Call-count classes count invocations of `Invoke-RegenerationGitExe` and `Invoke-RegenerationProcess`, including an invocation that throws.
- **D18 — Entry-point evidence values and Tip restore sets.** Ambiguities resolved: the D17 table left the `evidence_path` value inside `event` and `review_outcome`, the source of the `Command:` and `EXIT_CODE:` lines of `evidence_text`, and the path sets of the `Tip` restore unstated. Decisions, following the research shapes (research D3 `head_sha` "resulting commit or null"; research D4 `evidence_path` "<FEATURE>/evidence/qa-gates/regeneration-delta.<timestamp>.md"; research D4 evidence fields):
  1. The entry point does not know the pushed head or the evidence file name, so it passes `$null` for both `-HeadSha` and `-EvidencePath` to `New-RegenerationEvent` and `New-RegenerationDeltaReviewOutcome`. On the success path the orchestrator sets `head_sha` to the pushed head and `evidence_path` to `Get-RegenerationEvidencePath -FeatureFolder <feature folder> -Timestamp <UTC write stamp>` on both objects, and writes `evidence_text` as the content of that file. A `fell_back` event keeps `head_sha` and `evidence_path` `null`.
  2. Builder parameters: `New-RegenerationEvent -At -Trigger -FeatureHeadSha -MergeHeadSha -MergeBaseSha -Decision -Reason -UnmatchedPaths -CommandExitCode -Confined -Idempotent -UnitGate -DeltaCheck -Outcome -HeadSha -EvidencePath`; `New-RegenerationDeltaReviewOutcome -HeadSha -EvidencePath`; `New-IntegrationRegenerationEntry -Trigger -AfterFeatureIssueNum -MergeCommitSha -RegenerationCommitSha -CommandExitCode -Confined -Idempotent -Outcome -CiRunId -CiConclusion -VerifiedAt`; `New-RegenerationEvidenceText -Timestamp -Command -ExitCode -Reason -Confined -Idempotent -UnitGate -DeltaCheck`; `Get-RegenerationInvocationText -MergeRef -Trigger -ConfigPath`.
  3. Evidence text: five LF-terminated lines, `# Regeneration Delta`, `Timestamp: <yyyy-MM-ddTHH-mm>`, `Command: <invocation text>`, `EXIT_CODE: 0`, and `Output Summary: reason=<reason>; confined=<true|false>; idempotent=<true|false>; unit_gate=<value>; delta_check=<value>`. The invocation text is `pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1 -Mode Merge -MergeRef <MergeRef> -Trigger <Trigger>`, followed by ` -ConfigPath <ConfigPath>` only when `-ConfigPath` was supplied. The `EXIT_CODE:` value is the entry-point exit code of the only rows that build the text (R72, R73).
  4. `Tip` restore (rows R33 through R42): the entry point runs `git diff --name-only -z` and `git ls-files --others --exclude-standard -z`, then `git checkout -- <tracked paths>` when the first listing is non-empty and `git clean -f -q -- <untracked paths>` when the second is non-empty, each with ordinal-sorted paths after `--`. Both calls are attempted when both sets are non-empty. A restore listing that returns non-zero skips the call that depends on it and is a restore failure: exit 1, every other cell unchanged (resolution 18).
  5. Standard-gate completion (row R73, undeclared `unit_gate`): when the entry point reports `unit_gate` `not_run` and the standard parallel gates pass, the orchestrator sets the event's `unit_gate` to `pass` before appending it, so the merge-gate consistency check, which requires `unit_gate: "pass"`, admits the R73 path. When those gates fail, the orchestrator falls back as item 1 states. The evidence file keeps `evidence_text` unchanged, so its `Output Summary:` line records `unit_gate=not_run`, which is the entry point's own result; the orchestrator-run result is recorded by the event's `unit_gate` and by the gate evidence. The D17 table is unchanged, because it records the entry-point result before this step. Rejected: having the merge gate accept `not_run`, because an event that no unit gate verified would then pass. Pinned by the R73 context of `tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1` and by the orchestrate-skill sentence asserted in `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`.
  6. "Supplied" in item 3 means bound by the caller: the ` -ConfigPath <ConfigPath>` suffix appears whenever the caller passes `-ConfigPath`, including the default value passed explicitly, and never when the parameter is omitted. Pinned by the three `-ConfigPath` result cases of `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Merge.Tests.ps1`.

## Acceptance Criteria

### Config (issue AC1)

- [x] [AC1] `Get-RegenerationConfigError` returns an empty list for a valid version 1 document and returns one error naming the key path for each violation of validation rules 1 through 9 in `## Inputs / Outputs`, with errors accumulating in rule order; a Pester case per rule fails if that rule is not enforced.
- [x] [AC1] For config text that is absent, lacks the `regeneration` key, or sets `regeneration` to `null`, the classifier returns `remediation_loop` with reason `no_config`, and the adapter test asserts that the entry point makes no `git merge` call, runs no declared command, and exits 3.
- [x] [AC1] For a present but invalid config, the entry point returns reason `config_invalid` with the validator errors in `config_errors`, makes no `git merge` call, runs no declared command, and exits 3.
- [x] [AC1] The orchestrate skill's `## Merge-Conflict Remediation` section and the rules-file section `## Regeneration-Path Scope and Backward Compatibility` document `version`, `command`, `paths`, `idempotency_check`, and `unit_gate` with their validation rules and the default-off rule, pinned by `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`.
- [x] [AC1] Neither `config/orchestration-regeneration.json` nor `extensions/drm-copilot/resources/config/orchestration-regeneration.json` exists in the repository after this item, asserted by the skill-contract test (D11).
- [x] [AC1] In `Tip` mode, a config that is absent, lacks the `regeneration` key, or sets it to `null` yields reason `no_config`, and a present but invalid config yields `config_invalid` with the errors in `config_errors`; each makes no git call and no process call, exits 3, and returns the twenty-key result (D16).
- [x] [AC1] `Validate` mode exits 0 for a valid config and 3 for each of the four other config states, with no git call and no process call, and rejects `-MergeRef` and `-Trigger` with exit 2 (D15).

### Classifier (issue AC2)

- [x] [AC2] `Get-RegenerationPathDecision` applies the first-match rule order in `## API / CLI Surface`, with a Pester case for each of: all-match (`regenerate`, `all_match`), partial-match (`unmatched_path`, with the unmatched paths ordinal-sorted), no config (`no_config`), empty set (`empty_set`), config invalid (`config_invalid`), and merge-base count of 0 and of 2 (`multiple_merge_bases`); a case with both no config and an empty set returns `no_config`, proving first-match order.
- [x] [AC2] `Test-RegenerationPathMatch` cases fail if: a root-level path is not matched by a pattern that begins with a double-star segment followed by a slash and that path; a single-star wildcard matches across a slash; a case variant matches; a candidate containing a backslash matches.
- [x] [AC2] `Get-RegenerationChangedPath` returns the ordinal-sorted, de-duplicated intersection of two NUL-separated listings with empty entries removed; cases cover disjoint listings (empty result), overlapping listings, and trailing NUL terminators.
- [x] [AC2] The classifier module performs no I/O: its tests run with no git, process, or file-system mock and no temporary file.

### Regenerate path (issue AC3)

- [x] [AC3] Adapter tests with mocked `Invoke-RegenerationGitExe` and `Invoke-RegenerationProcess` assert the `Merge`-mode call order: config read, `git merge --no-commit --no-ff`, `git merge-base --all`, the ours and theirs `--no-renames` diffs, conflict resolution with `git checkout --ours` and `git add`, run 1, confinement, `git add -A`, run 2, `idempotency_check` when declared, the cached delta diffs against each parent, the declared unit-gate argvs in order; and exit 0 with `outcome` ready for commit.
- [x] [AC3] Each failure branch exits 3 (or 1 for a git or process failure), calls `git merge --abort` exactly once, and makes no `git commit` call: non-zero run 1, non-zero run 2, run-1 output outside the declared patterns, non-empty C2, non-zero `idempotency_check`, a delta violation on either side, a non-zero declared unit-gate argv, and a non-empty tree after conflict resolution. A test per branch fails if the abort is missing.
- [x] [AC3] The delta decision returns `pass` when every non-generated path changed relative to each parent is in the other parent's diff from the base, and `fail` for a one-sided violation in each direction; a generated path changed relative to both parents does not cause `fail`.
- [x] [AC3] `Tip` mode applies the blob-id snapshot idempotency rule, makes no `git add` and no `git commit` call, and on a not-applied result restores tracked paths with `git checkout --` and removes created untracked paths with `git clean -f -q --`; a test fails if any of these calls is missing or extra.
- [x] [AC3] The `regeneration_events[]` builder, delta review outcome builder, and evidence-text builder produce the exact shapes in `## Data & State`, the evidence text contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` lines, uses the injected clock value, and contains no drive letter or leading-slash absolute path.
- [x] [AC3] The orchestrate skill states that after a successful `Merge` result the orchestrator runs the standard parallel unit gates when `unit_gate` is `not_run`, writes a new evidence file (never editing an existing one), commits with `git commit -F`, pushes, appends the event and the delta outcome with `head_sha` equal to the pushed head, and re-runs S9; and that a failure after the entry point exits runs `git merge --abort` and falls back. Pinned by the skill-contract test.
- [x] [AC3] The D16 boundaries hold and each has a failing test: the per-mode `outcome`, `decision`, `event`, and `evidence_text` values; a non-zero command, check, or unit-gate exit giving exit 3; a git failure giving exit 1 in each mode with the worktree restored; a conflicting `git merge` exit treated as expected when `MERGE_HEAD` exists and as exit 1 with no abort when it does not; no check or unit-gate process for an undeclared key; omitted `-Mode`, `-Trigger` in `Tip`, and an absolute or `..` `-ConfigPath` giving exit 2; and the script body printing one JSON object that keeps `null` values.
- [x] [AC3] `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1` holds one `-ForEach` case for every row of `### Result table (normative, D17)`, keyed by its row ID; each case drives the row's mode, parameters, config state, and scenario through the mocked seams and asserts the exit code, the value of every result key listed under `### Entry point` against the row's cell, and the row's git-call and process-call count classes. A table row or result-key column with no matching assertion in the test data is a defect that fails this criterion.

### Attempt accounting (issue AC4)

- [x] [AC4] The regenerate path writes no `remediation_loop.cycles[]` entry and does not change `completed_attempts`, whether it succeeds or falls back; the orchestrate skill and `.claude/agents/orchestrator.md` `### Remediation Loop Checkpoint Shape` state this, pinned by the skill-contract test.
- [x] [AC4] `tests/fixtures/orchestrator_state_remediation_loop/regeneration_event_tolerated_accepted.json` (a `regeneration_events` entry, a delta `PASS` outcome, no cycles, `completed_attempts: 0`) and `tests/fixtures/orchestrator_state_remediation_loop/regeneration_after_completed_cycle_accepted.json` (one completed cycle, `completed_attempts: 1`, plus a regeneration event and delta outcome) carry `expected_errors: []` and pass in the Python, TypeScript, and PowerShell parity suites.
- [x] [AC4] The termination guard (halt at `completed_attempts` equal to 3 with a non-`PASS` latest verdict), the pinned sentence "CI-failure and merge-conflict cycles are never light", and the pinned remediation-docs literals remain present verbatim, proven by the existing `tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1` and `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py` passing unmodified.

### Epic integration-tip regeneration (issue AC5)

- [x] [AC5] The epic-orchestrate skill states the integration-tip flow in `## Behavior` (fast-forward, `Tip` mode, `git add` and `git commit -F` of changed paths, push, `gh workflow run CI --ref` on the integration branch even with no diff, `gh run list --commit` lookup, 30-second polling for at most 90 minutes, `integration_regenerations[]` append) and that no further child merge or wave launch occurs until the tip has a successful completed `CI` run; pinned by the skill-contract test.
- [x] [AC5] The epic-orchestrate skill states the child-side check: with a valid config, a child about to merge the integration branch confirms a successful completed `CI` run on the tip, polling 30 seconds for at most 90 minutes, and on timeout follows the wait branch with `blocked_reason: "awaiting_ci"`; without a valid config it does not wait. Pinned by the skill-contract test.
- [x] [AC5] `Get-EpicRegenerationAllowance` tests admit `git add -- <path>` and `git commit -F <file>` on the integration branch for paths matching the config patterns, and deny each of: a path outside the patterns, a path with a backslash, asterisk, question mark, square bracket, `.` or `..` segment, or leading slash; `git commit -a`, `--all`, `--amend`, `--no-verify`; a chained command; Write and Edit; a HEAD other than the integration branch; an absent or invalid config; and a readiness failure other than `'merge-in-progress'`.
- [x] [AC5] `.claude/agents/epic-orchestrator.md` contains the Bash grant for the `Invoke-RegenerationPath.ps1` prefix in the same form as the `Invoke-CiGateParser.ps1` grant and no other new grant, asserted by the skill-contract test.
- [x] [AC5] The epic main-sync flow (lifecycle step 3) states that a conflicting merge with a valid config runs `Merge` mode with trigger `main_sync`, commits during the in-progress merge, and dispatches and verifies CI before the wave launches, and that a fallback runs today's step unchanged; pinned by the skill-contract test.
- [x] [AC5] The epic-orchestrate skill states the default-off boundary in both places: the integration-tip flow and the main-sync regenerate path each run only when the integration worktree holds a valid config, and a valid config is one for which `Validate` mode exits 0; pinned section- and item-scoped by the skill-contract test.

### Documentation, schema, and gates (issue AC6)

- [x] [AC6] `.claude/skills/orchestrate/SKILL.md` contains a `## Merge-Conflict Remediation` section (repairing the S9 step 6 reference) holding capture, classification, the regenerate path, and the unchanged fallback; `## Concurrent Review and CI (review_mode)` rule 7 keeps its pinned sentence and gains an appended sentence that the delta outcome is the new review for the new head; rule 11 gains a sentence limiting the CI cross-check to `feature-review` outcomes. Pinned by the skill-contract test and by `tests/scripts/claude-runtime/concurrent-review-skill-contract.Tests.ps1` passing unmodified.
- [x] [AC6] `.claude/skills/parallel-orchestrate/SKILL.md` `## Per-Item Merge-Conflict Handling` states that the child applies the regenerate path first, after the issue #643 resolver, and only a fallback writes the synthetic Blocking finding; pinned by the skill-contract test.
- [x] [AC6] `.claude/rules/orchestrator-state.md` gains the section `## Regeneration-Path Scope and Backward Compatibility` documenting `regeneration_events[]`, `integration_regenerations[]`, `review_kind`, the tolerated-and-unvalidated status, the Claude-only scope, and the policy-level disclosure, and the `## Invariants (remediation_loop.review_outcomes)` section remains equal to the `.agents/skills/orchestrator-state/SKILL.md` copy (existing `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py` passes).
- [x] [AC6] `tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1` show: a delta outcome at the live head with a matching complete event is allowed; a delta outcome with no matching event, or with an event whose `idempotent`, `confined`, `unit_gate`, `delta_check`, or `outcome` field differs from the required value, is denied with `EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED:`; a delta outcome at a stale ancestor with a code change is still denied with `REVIEW_GATE_HEAD_STALE`; and the helper invokes no process.
- [x] [AC6] Every new or edited `.claude/` file listed in `### Concrete write paths` has a byte-identical bundle copy, the new lib and hook files appear in both `pack-manifests/core.json` files, and the existing push-down contract, pack-manifest completeness, and dependency-closure tests pass.
- [x] [AC6] The `PINNED_FROZEN_SURFACE_HASHES` entries for `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` are re-baselined in place with a dated comment, and the test that reads them passes.
- [x] [AC6] The execution-environment brief is updated identically in `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` (new epic regeneration allowance, regeneration merge-gate check, integration-tip CI dispatch), so that the listed copies remain byte-identical to one another and every existing test that compares them passes.
- [x] [AC6] The portable handoff projection holds none of `regeneration_events`, `integration_regenerations`, and `review_kind`, shown by a test appended to `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py`, and the rules section discloses that the review/verdict status names the last full review's audit file.
- [x] [AC6] Codex scope: `.agents/skills/orchestrate/SKILL.md` and `.agents/skills/epic-orchestrate/SKILL.md` contain no reference to `Invoke-RegenerationPath`, asserted by the skill-contract test.

### Regression (issue AC7)

- [x] [AC7] For checkpoints without `regeneration_events`, `review_kind`, and `integration_regenerations`, existing merge-gate decisions are unchanged: green-CI standalone merge (issue #997), epic-child CI verification (issue #1130), the concurrent review guard, and the fan-in and merged-feature follow-up allowances of the preimplementation gate, proven by the existing suites `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.ReviewGuard.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCi.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`, and `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1` passing in the single parallel Pester gate.
- [x] [AC7] New regression cases appended to `tests/scripts/claude-hooks/enforce-epic-merge-gate.ReviewGuard.Tests.ps1` show that a checkpoint carrying `regeneration_events` but no `review_kind` on its last outcome receives the same decision as the same checkpoint without `regeneration_events`, and that sequential (no `review_mode`) child-CI and green-CI decisions are unchanged.
- [x] [AC7] New regression cases appended to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1` show that, with no regeneration config in the integration worktree, every command and tool denied or allowed today on the integration branch receives the same decision.
- [x] [AC7] The three-attempt limit is unchanged for checkpoints without the new keys: the existing remediation-loop corpus fixtures and parity suites pass unmodified.

## Non-Functional Requirements

- Language: pushed-down logic is PowerShell 7. No new Python file is added; editing `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` in place is permitted. Enforcement hooks invoke no Python.
- Separation: classification, validation, confinement, idempotency, delta, and builders are pure functions in host-neutral modules with unit tests; all I/O is in `Invoke-RegenerationPath.ps1` behind the injected git, process, config-reader, and clock seams.
- Tests: no temporary files, no real git repositories, no wall-clock waits; mocks on wrapper functions only; module import and removal paired in `BeforeAll` and `AfterAll`.
- Test gates are parallel-only: one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, and Jest through its normal parallel workers. No serial, shuffled, or reversed runs.
- Coverage: the new lib and hook files meet the repository line-coverage threshold, read from the single parallel gate's coverage output.
- Evidence is append-only and written under the feature folder's `evidence/` subdirectories.
- File size: no file above 800 lines; new logic in new files; `.claude/hooks/enforce-epic-merge-gate-review.ps1` and `.claude/hooks/hook-epic-fan-in.ps1` are not edited.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (skills, agents, rules file, execution-environment brief, bundle mirrors)
- [ ] Telemetry/logging added or updated (JSON result, checkpoint lists, evidence file)
- [ ] Toolchain pass completed (format → lint → type-check → test)
