# parallel-skills-invoke-unbundled-python-clis (Spec)

- **Issue:** #763
- **Parent (optional):** epic `push-down-payload-correctness`
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md`)
- **Research:** `research/2026-09-29-unbundled-python-clis-research.md`

## Context
Two pushed-down skills invoke Python CLIs that are not bundled with them: `parallel-orchestrate` runs `poetry run python -m scripts.dev_tools.parallel_drift_detection_cli` and `parallel-remove` runs `poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py`. Neither the CLIs, their `scripts.dev_tools` import closure, nor a Poetry environment ship in the push-down payload, so both steps fail in consumer repositories. The skill-bundle audit for issue #762 found both references and registered them as tracked exceptions in the new guard until this issue is fixed.

Environment:
- OS/version: any consumer repository that receives the Claude push-down
- Python version: n/a in consumers (no Poetry project)
- Command/flags used: the two invocations quoted above
- Data source or fixture: `.claude/skills/parallel-orchestrate/SKILL.md` (CLI Invocation section), `.claude/skills/parallel-remove/SKILL.md` (step 5)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Push down the Claude customizations into a consumer repository.
2. Run a parallel item that reaches drift detection, or remove an in-flight item with the `abandon` disposition.
3. The Python module is not present in the consumer, so the command fails.

Expected:
Every script the skills invoke is part of the push-down bundle as a destination-runtime port under `.claude/lib/`, as was done for cohort computation (#462) and the blast-radius library (#447), and the guard exception entries registered for issue #762 are removed.

Actual:
Both commands depend on `scripts/dev_tools/**` and Poetry, which consumers do not receive.

Evidence (research section 1.1):
- `.claude/skills/parallel-orchestrate/SKILL.md:884` and its bundle mirror invoke the drift CLI in module form.
- `.claude/skills/parallel-remove/SKILL.md:112` and its bundle mirror invoke the abandon CLI in path form.
- `scripts/dev_tools/skill_bundle_contract.py:134-145` registers both references in `KNOWN_UNBUNDLED_REFERENCES` against `#763`.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: n/a


## Scope & Non-Goals
- In scope:
  - A PowerShell port of drift detection under `.claude/lib/parallel-drift/` (pure module plus entry script) that reuses `.claude/lib/blast-radius/`.
  - A bash port of the abandon disposition at `.claude/lib/bash/abandon-parallel-item.sh`.
  - Committed shared fixture corpora and two-lane parity tests (Python reference lane plus Pester or bats lane) for both ports.
  - Updates to both SKILL.md files, `.claude/agents/parallel-orchestrator.md`, their bundle mirrors, and `pack-manifests/core.json`.
  - A comment-only edit to `.claude/hooks/enforce-parallel-abandon-gate.ps1` (and its mirror) that names the new producer.
  - Updates to the abandon token seam test so the bash script is a producer side of the seam.
  - Removal of the `#763` entries from `KNOWN_UNBUNDLED_REFERENCES` and the related test updates.
  - Registration of the new PowerShell files in both `pester.runsettings.psd1` coverage allow-lists.
- Out of scope / non-goals:
  - Retiring or relocating the Python CLIs or their import closure (retained as the parity reference; D3).
  - Removing `Bash(poetry run python -m *)` or `Bash(poetry run python -c *)` from `parallel-orchestrator.md` (follow-up; D4).
  - Adding an allow entry for the abandon script to `.claude/settings.json` (follow-up; D6).
  - The Python library calls in `parallel-remove/SKILL.md` steps 2, 3, and 6 (`decide_removal`, `recolor_unstarted`, `build_remove_entry` in `scripts/dev_tools/parallel_mutation_protocol.py`) (follow-up; D7).
  - Creating `quality-tiers.yml` (D8).
- Explicitly excluded systems, integrations, or datasets:
  - `.claude/hooks/enforce-powershell-batch-budget.ps1` and its tests (owned by issue #769 in another session).
  - `scripts/dev_tools/push_down_claude_customizations.py` and `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (owned by sibling features #507, #508, #621).
  - `.github/**`, `.agents/**`, and `.codex/**` surfaces (no mirror of either skill exists there; research section 1.1).

## Root Cause Analysis
Relocating the files is not sufficient: `parallel_drift_detection_cli.py` imports `scripts.dev_tools.parallel_drift_detection`, `_parallel_drift_cli_io`, and `parallel_drift_resolution`; `parallel_mutation_abandon_cli.py` imports `scripts.dev_tools._parallel_state_common`, and its tokens are pinned by `.claude/hooks/enforce-parallel-abandon-gate.ps1` and `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`. The push-down publishes only the `.claude` and `config` roots, and consumers have no Python interpreter guarantee. A port to the Python-free destination runtime is required.

Both sites were previously deferred as explicit non-goals (`docs/features/epics/claude-runtime-portability/epic.md` and `docs/features/completed/2026-08-29-remove-remaining-python-invocations-599/spec.md`). This issue is the pending decision those documents referenced.


## Proposed Fix

### Design summary (what changes where):

Design decisions recorded by the orchestrator:

- **D1 — Drift detection is ported to PowerShell.** A pure module `.claude/lib/parallel-drift/ParallelDrift.psm1` and an entry script `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`. The module imports `.claude/lib/blast-radius/` and calls its existing functions (`Test-PathSubsumed`, `Get-BlastRadiusFromObservedPaths`, `Test-BlastRadiusConflict`, `Get-BlastRadiusPairDecision`, `ConvertTo-NormalizedBlastRadius`, `Get-OrdinalSortedEntry`) rather than re-implementing blast-radius logic. JSON is read with `System.Text.Json` (`JsonDocument`), not `ConvertFrom-Json`. Parameters are not `Mandatory`; missing inputs are validated explicitly and produce a deterministic non-zero exit. Parity against the Python reference compares parsed JSON values, not bytes.
  - Rationale: every blast-radius primitive the CLI uses already has a corpus-bound PowerShell port, and `parallel-plan/SKILL.md` already requires `pwsh` for that library on the destination path. Reusing it adds no third implementation, which the Python drift modules forbid. `ConvertFrom-Json` converts timestamp-shaped strings to `DateTime` and does not preserve the integer/boolean distinction that `is_positive_integer` relies on. `Mandatory` parameters can prompt under `pwsh -File`. Byte parity would require reproducing Python's `ensure_ascii` and indentation, which carries no behavioral value.
- **D2 — Mutation abandon is ported to bash** as `.claude/lib/bash/abandon-parallel-item.sh`. The literal tokens `--disposition abandon` and `--confirm-abandon` are preserved, so the logic and token declarations of `.claude/hooks/enforce-parallel-abandon-gate.ps1` are unchanged (comment-only edit permitted). Preserved behavior: the PR is closed before the worktree is removed; the run stops at the first failure; both refusals occur before any side effect.
  - Rationale: the logic is argument parsing, two refusals, and two ordered subprocess calls with no JSON. Bash parses GNU-style long options natively, and the hook matches command text, so identical tokens need no hook logic change. A PowerShell port would require single-dash parameters or manual `$args` parsing.
- **D3 — The Python CLIs are retained.** `scripts/dev_tools/parallel_drift_detection_cli.py`, `scripts/dev_tools/parallel_mutation_abandon_cli.py`, and their modules stay in the repository as the behavioral-parity reference, following the #447 and #462 precedent. No pushed-down skill invokes them after this change.
  - Rationale: they are the Python lane of the new parity corpora, `_parallel_orchestrator_state_drift.py` imports `parallel_drift_detection`, and `test_parallel_mutation_protocol.py` imports the abandon disposition constant.
- **D4 — Surface updates ship the new scripts.** Both SKILL.md files, their bundle mirrors, `.claude/agents/parallel-orchestrator.md` (tool allowlist gains the new `pwsh` and `bash` entry points) and its mirror, and `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` are updated. No `##` heading is added to `parallel-orchestrate/SKILL.md`, because `test_parallel_orchestrator_surface_contracts.py` pins the heading count. The existing `Bash(poetry run python -m *)` allowlist entry is left unchanged.
  - Rationale: these are the registration points identified by the #462 and #643 precedents (research section 2.4). Removing the `poetry` grant is a separate risk decision and is recorded as a follow-up.
- **D5 — The `#763` entries are removed from `KNOWN_UNBUNDLED_REFERENCES`** in `scripts/dev_tools/skill_bundle_contract.py`, so the guard enforces both references. The stale-exception reporting branch of `skill_bundle_contract_cli.py` remains covered by tests. A keyword-only `exceptions` parameter on `skill_bundle_contract_cli.main`, forwarded to both finders, is adopted only if it is needed to keep that branch covered.
  - Rationale: once the SKILL lines change, the entries become stale and `test_known_unbundled_references_are_not_stale` fails, so the entries and the SKILL change must land together. `test_main_returns_one_for_stale_exception` currently depends on a registered default entry.
- **D6 — `.claude/settings.json` is not modified.** No allow entry is added for the abandon script. The resulting permission prompt before the abandon command is recorded as a follow-up.
  - Rationale: limits the change to the defect; the hook already gates the destructive command.
- **D7 — The remaining Python calls in `parallel-remove` steps 2, 3, and 6** (`parallel_mutation_protocol.py`) are out of scope and recorded as a follow-up.
  - Rationale: they have no invocation form, the skill-bundle guard does not detect them, and porting them is a separate design question.
- **D8 — Tier classification.** `quality-tiers.yml` does not exist in this tree (research section 8). For gate purposes the new modules are classified T3 (adapters and orchestration glue). Uniform gates apply: line coverage >= 85%, branch coverage >= 75% where the tooling measures it (Pester and kcov do not; no branch threshold applies to them), and no coverage regression on changed lines. T3 imposes no property-test or mutation obligation and allows at most 5 justified untyped escape hatches per file.
- **D9 — Consumer `pwsh` baseline is PowerShell 7.x**, matching the existing `.claude/lib/blast-radius/` requirement documented in `parallel-plan/SKILL.md`. D1's `System.Text.Json` route avoids depending on the 7.5-only `ConvertFrom-Json -DateKind`.

### Boundaries and invariants to preserve:

Drift detection (port must match the Python reference):
- `drift_event` and `observed_radius` are `null` if and only if `result` is `no_escape`.
- The drifting item key is never in `halted_item_keys`.
- `newly_conflicting_pairs` are canonical (lower key first) and ascending; `halted_item_keys` are deduplicated and ascending.
- An unreadable or malformed peer radius counts as conflicting (fail closed; `_parallel_drift_scheduling.py:128-134`).
- A non-object `conflict_edges[]` entry is ignored; a non-list `items` or `conflict_edges` collection is an error.
- An item key absent from the checkpoint is an error.
- An empty changed-path list yields `no_escape`.
- The checkpoint and config files are read only; no file is mutated.
- `--at`/`-At` defaults to the current UTC time formatted `yyyy-MM-ddTHH-mm` (the only clock read); `computed_at` defaults to the resolved `at`.
- Timestamp strings round-trip unchanged; ordinal string comparison is used for path sorting and for `worktree_created_at` in the halt rule.

Abandon disposition:
- A disposition other than `abandon` exits 2 with `PARALLEL_ABANDON_ERROR: this CLI executes the 'abandon' disposition only; got '<value>'.` before any side effect.
- A missing `--confirm-abandon` exits 2 with `PARALLEL_ABANDON_ERROR: refusing to abandon item <n> without the explicit --confirm-abandon confirmation marker; no side effect was performed.` before any side effect.
- `gh pr close <pr>` runs before `git worktree remove <path>`; execution stops at the first non-zero exit and exits 1 with `PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code <n>: <argv joined by spaces>`. An executable not on `PATH` reports exit code `-1`.
- Success exits 0 with no stdout.

Hook and guard:
- `$script:AbandonDispositionToken = '--disposition abandon'` and `$script:AbandonConfirmToken = '--confirm-abandon'` in the hook are unchanged, and each literal still appears exactly once in the hook.
- Pushed-down enforcement hooks gain no Python leg; `enforcement-hooks-no-python-invocation.Tests.ps1` continues to scan `.claude/hooks` and `.claude/lib`.

### Dependencies or blocked work:
- Depends on the existing `.claude/lib/blast-radius/` PowerShell library and its parity corpus (#447).
- Depends on the #762 skill-bundle guard (`skill_bundle_contract.py`, `skill_bundle_contract_cli.py`) already merged.
- Must not conflict with #769 (batch-budget hook) or #507/#508/#621 (push-down transport files); none of those files is edited.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

New files:
- `.claude/lib/parallel-drift/ParallelDrift.psm1` and `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`, with byte-identical bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-drift/`.
- `.claude/lib/bash/abandon-parallel-item.sh`, with a byte-identical bundle copy.
- `tests/fixtures/parallel_drift/*.json` (shared corpus: inline `state`, `config`, `item_key`, `changed_paths`, `at`, `computed_at`, and an expected payload or expected error).
- `tests/fixtures/parallel_abandon/*.json` (shared corpus) and a checked-in `gh`/`git` shim directory under `tests/fixtures/` whose shims record argv and exit with a fixture-selected code.
- `tests/scripts/dev_tools/test_parallel_drift_parity.py` and `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py` (Python lanes).
- `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1`, `Invoke-ParallelDriftDetection.Tests.ps1`, `ParallelDrift.Parity.Tests.ps1`, `ParallelDrift.Manifest.Tests.ps1`.
- `tests/shell/parallel_abandon.bats` and `tests/shell/parallel_abandon_parity.bats`.

Modified files:
- `.claude/skills/parallel-orchestrate/SKILL.md` (CLI invocation and prose citations) and its bundle mirror.
- `.claude/skills/parallel-remove/SKILL.md` (step 5 invocation and prose citation) and its bundle mirror.
- `.claude/agents/parallel-orchestrator.md` (tool allowlist and prose) and its bundle mirror.
- `.claude/hooks/enforce-parallel-abandon-gate.ps1` (docstring comment only) and its bundle mirror.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- `scripts/dev_tools/skill_bundle_contract.py` (empty registry; comment update).
- `scripts/dev_tools/skill_bundle_contract_cli.py` (only if D5's optional `exceptions` parameter is adopted).
- `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py`, `test_skill_bundle_contract_cli.py`, `test_parallel_abandon_token_seam.py`.
- `tests/shell/parallel_payload_only.bats` (abandon payload case with a separate shim `PATH`).
- Optional: `tests/shell/parallel_bash_manifest_membership.bats` entry-point list; sample command strings in the Pester abandon-gate hook suites.

#### Functions/classes/CLI commands impacted:
- New CLI: `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey <issue_num> [-CheckpointPath <path>] [-ConfigPath <path>] [-At <ts>] [-ComputedAt <ts>] <CHANGED_PATH>...` (changed paths bound through `ValueFromRemainingArguments`).
- New CLI: `bash .claude/lib/bash/abandon-parallel-item.sh --item <key> --disposition abandon --confirm-abandon --pr <pr-number> --worktree <worktree-path>`.
- New PowerShell functions in `ParallelDrift.psm1` porting `detect_escaped_paths`, `build_drift_event`, `recompute_conflicts_with_observed`, `existing_edge_pairs`, `item_band`, `observed_pair_is_edge`, `halted_item_keys`/`select_halted_item`/`_start_rank`, `build_observed_radius`/`request_resolution_write`, and the used shape guards (final names chosen during implementation).
- `skill_bundle_contract.KNOWN_UNBUNDLED_REFERENCES` becomes an empty tuple.

#### Data flow and validation changes:
- Drift: the orchestrator supplies `git diff --name-only <merge-base> HEAD` output as positional paths; the entry script reads the checkpoint (`items[]`, `conflict_edges[]`) and blast-radius config through a file-read seam, evaluates drift in the pure module, and writes one JSON object to stdout. No git command is executed by the script.
- Abandon: the script validates arguments, applies both refusals, then invokes `gh` and `git` in order through `PATH` resolution.

#### Error handling and logging updates:
- Drift: exit 0 on success; exit 1 on data errors with a stderr line prefixed `parallel drift detection failed: `; exit 2 on usage errors (missing or invalid `-ItemKey`, unknown parameters). No interactive prompt on missing input.
- Abandon: exit codes and messages as listed under invariants; unknown options and option abbreviations exit 2 (stricter than argparse prefix matching; declared divergence).

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the SKILL, agent, manifest, and registry changes; the Python CLIs remain in place (D3), so a revert restores the prior invocation without file restoration.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Drift stdout: one JSON object with keys `result` (`no_escape` | `no_new_conflict` | `halt_required`), `item_key`, `at`, `computed_at`, `escaped_paths`, `newly_conflicting_pairs`, `halted_item_keys`, `drift_event`, `observed_radius`. Keys sorted; arrays always emitted as arrays (a one-element array does not unroll); serialization depth sufficient for nested `drift_event` and `observed_radius`.
- Abandon: no stdout on success; single `PARALLEL_ABANDON_ERROR:` stderr line on failure.

#### Required configuration keys and defaults:
- Drift `-CheckpointPath` default `artifacts/orchestration/parallel-orchestrator-state.json`; `-ConfigPath` default `config/blast-radius.json`; relative paths resolve against the caller's working directory.

#### Backward-compatibility expectations:
- Drift output is value-equal to the Python CLI output for every corpus fixture. Declared divergence classes (documented in the parity suite headers): JSON byte formatting (`ensure_ascii`, indentation) and error-message text after the `parallel drift detection failed: ` prefix (Python embeds `repr()` text).
- Abandon: declared divergence classes are argparse usage text (only exit code 2 is matched) and rejection of option abbreviations.
- The abandon command text retains both hook tokens, so the hook gate behavior is unchanged.

#### Performance constraints (latency/throughput/memory):
- No new constraint. Both scripts run once per orchestrator step on small inputs.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - Consumers have PowerShell 7.x (D9), bash, `gh`, and `git` on `PATH`.
  - The orchestrator continues to supply the changed-path listing.
- Constraints (budget, performance, compatibility):
  - Do not modify `.claude/hooks/enforce-powershell-batch-budget.ps1` or its tests (issue #769).
  - Pushed-down enforcement hooks must not gain Python legs.
  - Do not modify `scripts/dev_tools/push_down_claude_customizations.py` or `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (#507/#508/#621).
  - Do not modify `.claude/settings.json` (D6).
  - Tests use committed fixtures and shims only; no temporary files.
  - No production, test, or script file exceeds 500 lines.
- External dependencies (services, libraries, releases):
  - `System.Text.Json` from the .NET runtime bundled with PowerShell 7.x. No new package dependency.

## Data / API / Config Impact
- User-facing or API changes: the two skill invocations change to bundled `pwsh` and `bash` entry points; the `parallel-orchestrator` agent tool allowlist gains two entries.
- Data or migration considerations: none; checkpoint and config schemas are unchanged.
- Logging/telemetry updates (if any): none beyond the stderr contracts above.
- Compatibility notes (CLI flags, config schemas, versioning): the drift entry point uses PowerShell parameter names (`-ItemKey`, `-CheckpointPath`, `-ConfigPath`, `-At`, `-ComputedAt`) in place of the Python long options; the abandon entry point keeps the Python option names.

## Test Strategy
Seeded from issue:

- [ ] Port both CLIs to `.claude/lib/` (bash or PowerShell) with parity tests against the Python reference.
- [ ] Update both SKILL.md invocations and the abandon-gate token seam.
- [ ] Remove the two entries from `KNOWN_UNBUNDLED_REFERENCES` in `scripts/dev_tools/skill_bundle_contract.py`.

- Regression tests to add or update:
  - Drift: `test_parallel_drift_parity.py` (Python lane calling `evaluate_drift`) and `ParallelDrift.Parity.Tests.ps1` (Pester lane invoking the entry script) over `tests/fixtures/parallel_drift/*.json`; each lane fails when the corpus is empty.
  - Abandon: `test_parallel_abandon_bash_parity.py` (Python lane with an injected runner) and `parallel_abandon_parity.bats` over `tests/fixtures/parallel_abandon/*.json`, comparing exit code, stderr line, and the ordered side-effect argv.
  - Seam: `test_parallel_abandon_token_seam.py` with the invocation anchor set to `abandon-parallel-item.sh` and a bash-constant extraction added as a producer side.
  - Guard: `test_skill_bundle_contract_evaluation.py` asserts an empty registry; `test_skill_bundle_contract_cli.py` keeps the stale-exception branch covered.
  - Payload-only: `parallel_payload_only.bats` runs the bundle copy of the abandon script with a shim-only `PATH`.
- Unit tests for the fixed behavior and boundaries: `ParallelDrift.Tests.ps1` (pure functions), `Invoke-ParallelDriftDetection.Tests.ps1` (entry script dot-sourced behind its guard with mocked clock and file-read seams, per the #643 precedent), `parallel_abandon.bats` (checked-in shims).
- Edge cases and negative scenarios (drift corpus must include at least one fixture for each):
  - no escape (including an empty changed-path list);
  - escape with no conflict;
  - halt with one conflicting pair;
  - halt with several conflicting pairs;
  - the drifting item started later than its peer;
  - equal start timestamps, one start timestamp absent, both start timestamps absent;
  - a reversed conflict edge and a non-object conflict edge;
  - a malformed peer radius;
  - an overlap tolerated under `conflict_tolerance`;
  - error: non-list `items`;
  - error: item key missing from the checkpoint;
  - error: non-object JSON root.
- Edge cases and negative scenarios (abandon corpus and bats suite must include at least one case for each): success; non-`abandon` disposition; missing `--confirm-abandon`; `gh pr close` failure (worktree removal not attempted); `git worktree remove` failure; executable not on `PATH` (exit code `-1` in the message); unknown option; option abbreviation.
- Error handling and logging verification: exit codes and stderr prefixes asserted in both lanes; missing `-ItemKey` asserted to exit 2 without prompting.
- Coverage impact and targets for changed lines/modules: new PowerShell files registered in both `pester.runsettings.psd1` allow-lists with line coverage >= 85%; the bash script measured by kcov (`scripts/bash/shell-qc.sh test --coverage`) with line coverage >= 85%; changed Python lines show no coverage regression and the Python modules stay at >= 85% line and >= 75% branch.
- Toolchain commands to run (format → lint → type-check → test): PoshQC format, analyze, and test for PowerShell files; `scripts/bash/shell-qc.sh` format, check, and `test --coverage` for bash files; the Python toolchain (Black, Ruff, Pyright, pytest) for changed Python files; Jest for `claude-pack-manifest-completeness.test.ts`.
- Manual validation steps (if required): none. Agent worktrees may refuse command text containing `bash`/`pwsh`; local bats execution may use `sh <file>`, and the CI `_shell-coverage.yml` workflow is the authoritative bats/kcov gate.


## Acceptance Criteria
- [x] `.claude/lib/parallel-drift/ParallelDrift.psm1` and `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` exist, each at or under 500 lines, and `ParallelDrift.psm1` imports `.claude/lib/blast-radius/` and calls its subsumption, observed-radius, conflict, and pair-decision functions instead of defining equivalents; verified by `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1` and by `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passing with the new files in scope.
- [x] A committed corpus `tests/fixtures/parallel_drift/*.json` contains at least one fixture for every drift case listed under Test Strategy (no escape, escape without conflict, one-pair halt, several-pair halt, drifter-is-later, equal/one-absent/both-absent start timestamps, reversed and non-object edges, malformed peer radius, tolerated overlap under `conflict_tolerance`, non-list `items`, missing item key, non-object root); `tests/scripts/dev_tools/test_parallel_drift_parity.py` asserts that the Python `evaluate_drift` reference matches each fixture's expected payload or error, and `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1` asserts that the parsed JSON stdout (or exit code and `parallel drift detection failed: ` stderr prefix for error fixtures) of `Invoke-ParallelDriftDetection.ps1` matches the same expectation; both lanes fail on an empty corpus and both pass.
- [x] `tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1` passes and asserts: no parameter is declared `Mandatory`; a missing or invalid `-ItemKey` exits 2 without prompting; a data error exits 1 with the `parallel drift detection failed: ` stderr prefix; success exits 0 with one JSON object on stdout; timestamp-shaped strings in the checkpoint round-trip unchanged (JSON read through `System.Text.Json`); a one-element `escaped_paths` or `halted_item_keys` is emitted as a JSON array; `-At` defaults to the mocked UTC clock formatted `yyyy-MM-ddTHH-mm` and `-ComputedAt` defaults to the resolved `-At`; the checkpoint and config files are not written.
- [x] `.claude/lib/bash/abandon-parallel-item.sh` exists and `tests/shell/parallel_abandon.bats` passes using only checked-in `gh`/`git` shims, asserting: a non-`abandon` disposition and a missing `--confirm-abandon` each exit 2 with the reference `PARALLEL_ABANDON_ERROR:` message and invoke neither shim; on success `gh pr close <pr>` is invoked before `git worktree remove <path>` and the script exits 0 with no stdout; a `gh` failure exits 1 and `git` is not invoked; a `git` failure exits 1 with the reference message; an executable absent from `PATH` reports exit code `-1`; unknown options and option abbreviations exit 2.
- [x] A committed corpus `tests/fixtures/parallel_abandon/*.json` covers every abandon case listed under Test Strategy, and both `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py` (Python reference with an injected runner) and `tests/shell/parallel_abandon_parity.bats` (bash port with shims) pass, each asserting the same exit code, stderr line, and ordered side-effect argv per fixture, and each failing on an empty corpus.
- [x] `tests/shell/parallel_payload_only.bats` includes a case that runs the bundle copy of `abandon-parallel-item.sh` with a shim-only `PATH` containing no Python interpreter, and the suite passes.
- [x] `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` passes with its invocation anchor set to `abandon-parallel-item.sh`, and asserts that the option tokens declared as named constants in the bash script equal the Python CLI constants and the hook's `$script:AbandonDispositionToken`/`$script:AbandonConfirmToken` values, and that the `parallel-remove/SKILL.md` invocation line carrying the anchor is the only option-bearing anchor line and contains both `--disposition abandon` and `--confirm-abandon`.
- [x] `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` and `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` pass, and `git diff main -- .claude/hooks/enforce-parallel-abandon-gate.ps1` shows changes only to comment lines, with the `$script:AbandonDispositionToken` and `$script:AbandonConfirmToken` assignment lines unchanged.
- [x] `.claude/skills/parallel-orchestrate/SKILL.md` invokes drift detection as `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 ...`, `.claude/skills/parallel-remove/SKILL.md` step 5 invokes `bash .claude/lib/bash/abandon-parallel-item.sh --item <key> --disposition abandon --confirm-abandon --pr <pr-number> --worktree <worktree-path>`, and `rg -n "python3?\s+(-m\s+)?scripts[./]dev_tools[./]parallel_(drift_detection|mutation_abandon)_cli" .claude extensions/drm-copilot/resources/claude-customizations/.claude` returns no match.
- [x] `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` passes, confirming the pinned `##` heading count of `parallel-orchestrate/SKILL.md` is unchanged.
- [x] `.claude/agents/parallel-orchestrator.md` tool allowlist contains entries for the `Invoke-ParallelDriftDetection.ps1` `pwsh` entry point and the `abandon-parallel-item.sh` `bash` entry point, and its `Bash(poetry run python -m *)` entry is unchanged; verified by inspection of the frontmatter and by `git diff main -- .claude/agents/parallel-orchestrator.md`.
- [x] `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `ParallelDrift.psm1`, `Invoke-ParallelDriftDetection.ps1`, and `abandon-parallel-item.sh`, and every new or edited `.claude/**` file has a byte-identical bundle copy; verified by `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, `tests/shell/parallel_bash_manifest_membership.bats`, `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` all passing.
- [x] `KNOWN_UNBUNDLED_REFERENCES` in `scripts/dev_tools/skill_bundle_contract.py` is an empty tuple with no `#763` entry; `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py` asserts the empty registry; `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` passes (including `test_every_skill_script_reference_is_bundled` and `test_known_unbundled_references_are_not_stale`); and `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py` passes, including `test_main_returns_one_for_stale_exception`, with the stale-exception branch of `skill_bundle_contract_cli.py` still executed by tests.
- [x] Both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` list the new PowerShell files in `CodeCoverage.Path` (verified by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`), and the Pester coverage report shows line coverage >= 85% for each new PowerShell file.
- [x] The kcov report from `scripts/bash/shell-qc.sh test --coverage` (or the CI `_shell-coverage.yml` run) shows line coverage >= 85% for `.claude/lib/bash/abandon-parallel-item.sh`, and pytest coverage shows no regression on changed lines in `scripts/dev_tools/skill_bundle_contract.py` and `scripts/dev_tools/skill_bundle_contract_cli.py`, with each at >= 85% line and >= 75% branch coverage.
- [x] `scripts/dev_tools/parallel_drift_detection_cli.py`, `scripts/dev_tools/parallel_mutation_abandon_cli.py`, and their imported modules remain present, and `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py`, `tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py`, `tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py`, and `tests/scripts/dev_tools/test_parallel_mutation_protocol.py` pass.
- [x] `git diff main --name-only` lists none of `.claude/hooks/enforce-powershell-batch-budget.ps1`, its test files, `scripts/dev_tools/push_down_claude_customizations.py`, `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, or `.claude/settings.json`, and no new or changed test creates a temporary file or directory.
- [x] The full toolchain passes in a single pass for every changed language: PoshQC format, analyze, and test; `scripts/bash/shell-qc.sh` format, check, and test; Black, Ruff, Pyright, and pytest; Jest for the pack-manifest completeness suite.

## Risks & Mitigations
- Technical or operational risks:
  - Semantic drift between the PowerShell port and the Python reference. Mitigation: shared corpus asserted by both lanes; the port reuses the already corpus-bound blast-radius library.
  - `ConvertTo-Json` array unrolling or insufficient depth produces a structurally different payload. Mitigation: explicit array emission and depth, asserted by unit and parity tests.
  - The abandon script performs destructive side effects. Mitigation: refusals precede side effects; the hook gate is unchanged; tests use shims only.
  - Consumers receive a new permission prompt for the abandon command because `.claude/settings.json` is unchanged (D6). Mitigation: recorded as a follow-up; the prompt is fail-safe.
  - Agent worktrees may refuse command text containing `bash`/`pwsh`. Mitigation: `sh <file>` for local bats runs; CI is the authoritative bats/kcov gate.
- Mitigations and rollbacks: revert the SKILL, agent, manifest, and registry changes; the retained Python CLIs (D3) keep the prior path available in this repository.

## Rollout & Follow-up
- Release/rollout steps: ship with the next extension release; the push-down carries the new `.claude/lib` files through `core.json`.
- Post-fix monitoring or clean-up tasks (follow-ups, not fixed here):
  - Decide whether to remove `Bash(poetry run python -m *)` from `parallel-orchestrator.md`, which no longer has a named consumer (D4).
  - Decide whether to add an allow entry for `abandon-parallel-item.sh` to `.claude/settings.json` (D6).
  - Port or replace the Python library calls in `parallel-remove/SKILL.md` steps 2, 3, and 6 (`parallel_mutation_protocol.py`) (D7).
  - Create `quality-tiers.yml` and classify the new modules (D8).
- Links: issue https://github.com/drmoisan/drm-copilot/issues/763; research `research/2026-09-29-unbundled-python-clis-research.md`; precedents #447, #462, #599, #643, #762.
