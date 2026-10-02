# Research: parallel skills invoke unbundled Python CLIs (Issue #763)

- Issue: #763
- Branch: `bug/parallel-skills-invoke-unbundled-python-clis-763`
- Epic: `push-down-payload-correctness` (preparation mode)
- Date: 2026-09-29
- Requirements source: `issue.md` and `spec.md` in this feature folder (spec is an unfilled template at
  version 0.1).

All line citations below were re-derived against the current worktree tree. Line counts were taken
with a ripgrep `^` count per file (one match per line).

## 1. Current State

### 1.1 The two invocation sites

| Site | Repo line | Bundle mirror line |
| --- | --- | --- |
| Drift detection | `.claude/skills/parallel-orchestrate/SKILL.md:884` (`poetry run python -m scripts.dev_tools.parallel_drift_detection_cli \`, fenced block 883-890) | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md:884` |
| Abandon disposition | `.claude/skills/parallel-remove/SKILL.md:112` (`poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py --item <key> --disposition abandon --confirm-abandon --pr <pr-number> --worktree <worktree-path>`) | bundle `.../parallel-remove/SKILL.md:112` |

Prose citations of the same files (not invocations) exist at `parallel-orchestrate/SKILL.md:733`,
`:881`, `:961`, `parallel-remove/SKILL.md:150`, and `.claude/hooks/enforce-parallel-abandon-gate.ps1:29`,
each with a byte-identical bundle mirror.

No `.github/**`, `.agents/**`, or `.codex/**` mirror of either skill exists (Glob for
`**/{parallel-orchestrate,parallel-remove}/SKILL.md` returns only the repo and bundle copies).
`tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:389-396` asserts that
`.agents/skills/parallel-orchestrate/SKILL.md` and the Codex parallel agents do not exist.

### 1.2 Drift-detection CLI contract (`scripts/dev_tools/parallel_drift_detection_cli.py`, 473 lines)

- Arguments (`build_parser`, 163-225): positional variadic `CHANGED_PATH...` (may be empty);
  `--item-key` (int, required); `--checkpoint` (default
  `artifacts/orchestration/parallel-orchestrator-state.json`, 132); `--config` (default
  `config/blast-radius.json`, 133); `--at`; `--computed-at`.
- Timestamps (`main`, 348-349): `--at` defaults to `default_timestamp()` (UTC,
  `%Y-%m-%dT%H-%M`, 141, 147-160), the only clock read; `--computed-at` defaults to the resolved `at`.
- Inputs read: the checkpoint JSON and the blast-radius JSON, through `load_mapping`
  (`_parallel_drift_cli_io.py:101-122`, root must be an object). Only `items[]` and
  `conflict_edges[]` are read from the checkpoint. No git command is executed; the caller supplies
  the `git diff --name-only <merge-base> HEAD` listing (docstring 16-20; SKILL 898-903).
- Output: one JSON object on stdout, `json.dumps(result, indent=2, sort_keys=True)` (370). Keys
  (314-324): `result` (`no_escape` | `no_new_conflict` | `halt_required`), `item_key`, `at`,
  `computed_at`, `escaped_paths`, `newly_conflicting_pairs`, `halted_item_keys`, `drift_event`
  (null iff `no_escape`), `observed_radius` (null iff `no_escape`).
- Exit codes: 0 success; 1 on `OSError`/`ValueError`/`TypeError` with stderr line
  `parallel drift detection failed: <error>` (366-368); 2 from argparse usage errors.
- Files mutated: none. The checkpoint is read only (`evaluate_drift` docstring 244-245).
- Algorithm (`evaluate_drift`, 267-312): escape detection against declared
  `blast_radius.paths`; when non-empty, recompute conflicts with the observed radius, select halted
  keys excluding the drifting item (`halted_item_keys`, 406-469), build the observed radius through
  `request_resolution_write`, and build one drift event whose action is
  `halted_later_started_item` when pairs exist, otherwise `raised_blocking_finding`.

### 1.3 Abandon CLI contract (`scripts/dev_tools/parallel_mutation_abandon_cli.py`, 362 lines)

- Arguments (`build_parser`, 201-261): `--item` (int, required); `--disposition` (choices
  `VALID_DISPOSITIONS` = `("detach", "abandon")`, required); `--confirm-abandon` (flag); `--pr`
  (int, required); `--worktree` (required).
- Tokens (61-73): `ABANDON_DISPOSITION_TOKEN = "--disposition abandon"`,
  `CONFIRM_ABANDON_TOKEN = "--confirm-abandon"`, both composed from `OPTION_PREFIX` and the option
  names so the parser and tokens share one spelling.
- Behavior (`main`, 302-358): disposition other than `abandon` -> exit 2 with
  `PARALLEL_ABANDON_ERROR: this CLI executes the 'abandon' disposition only; got '<value>'.`;
  missing `--confirm-abandon` -> exit 2 with
  `PARALLEL_ABANDON_ERROR: refusing to abandon item <n> without the explicit --confirm-abandon confirmation marker; no side effect was performed.`;
  otherwise runs `gh pr close <pr>` then `git worktree remove <path>` in that order, stopping at
  the first non-zero exit (`execute_abandon`, 264-299) -> exit 1 with
  `PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code <n>: <argv joined by spaces>`
  (119-122, 354-356). An executable not on PATH reports exit code -1 (148-150). Success -> exit 0,
  no stdout.
- Argparse usage errors also exit 2 (argparse's own contract, not intercepted, 324-325).
- Files mutated: none directly; the side effects close a remote PR and remove a git worktree.
- Import closure: `_parallel_state_common.VALID_DISPOSITIONS` only (52). This is a two-member tuple
  (`_parallel_state_common.py:68`).

### 1.4 Drift import closure and exercised surface

| Module | Lines | Exercised by the CLI entry point | Not exercised |
| --- | --- | --- | --- |
| `parallel_drift_detection_cli.py` | 473 | all | - |
| `_parallel_drift_cli_io.py` | 248 | all six readers | - |
| `parallel_drift_detection.py` | 460 | `detect_escaped_paths` (107-142), `build_drift_event` (145-193), `recompute_conflicts_with_observed` (274-354) | `unresolved_drift_item_keys`, `has_unresolved_drift`, `_latest_events_by_item`, `_radii_by_item_key`, `_is_drift_resolved` (196-271, 357-460) |
| `parallel_drift_halt.py` | 289 | `ItemStart` (72-123), `select_halted_item` (167-201), `_start_rank` (273-289), `ITEM_STATE_IN_FLIGHT` | `RequeueRequest`, `request_requeue_via_recolor` (126-164, 204-270) |
| `parallel_drift_resolution.py` | 180 | all (`build_observed_radius`, `request_resolution_write`) | - |
| `_parallel_drift_scheduling.py` | 143 | all (`existing_edge_pairs`, `item_band`, `observed_pair_is_edge`) | - |
| `_parallel_drift_shape.py` | 286 | `require_item_key`, `require_text`, `require_paths`, `require_enum_member`, `as_item_key`, `canonical_pair` | `require_generation`, `record_paths`, `is_later_canonical_timestamp` |
| `_parallel_state_common.py` | 495 | `VALID_ITEM_STATES`, `VALID_DRIFT_ACTIONS`, `is_non_empty_string`, `is_positive_integer` | validators and remaining enums (lines ~187-495) |
| Blast-radius library: `compute_blast_radius.py` (473), `_blast_radius_conflicts.py` (257), `_blast_radius_scheduling.py` (495), `_blast_radius_glob.py` (316), `_blast_radius_mergeable.py` (160), `_blast_radius_validation.py` (468), `_blast_radius_normalization.py` (107), `_blast_radius_extraction.py` (475), `_blast_radius_write_intent.py` (421), `_blast_radius_token_shapes.py` (144), `_blast_radius_thresholds.py` (73), `_blast_radius_guards.py` (96) | 3,485 | `radius_from_observed_paths`, `BlastRadius.from_dict`/`to_dict`, `conflicts`, `decide_pair`, `is_path_subsumed`, module and shared-surface resolution, mergeable exclusion | plan-text extraction, validation findings |

The total closure is 21 files and 6,421 lines. Most of it is docstrings or code the CLI does not
run.

Every blast-radius primitive the CLI uses already has a parity-tested destination-runtime
PowerShell port under `.claude/lib/blast-radius/`:

- `Test-PathSubsumed` (`BlastRadiusGlob.psm1:183`)
- `Get-BlastRadiusFromObservedPaths` (`BlastRadius.psm1:317-369`)
- `Test-BlastRadiusConflict` (`BlastRadius.psm1:371-459`)
- `Get-BlastRadiusPairDecision`, the port of `decide_pair` (`BlastRadiusScheduling.psm1:319-390`)
- `ConvertTo-NormalizedBlastRadius`, the equivalent of `from_dict` (`BlastRadiusValidation.psm1:73`)
- `Get-OrdinalSortedEntry` (`BlastRadiusGlob.psm1:350`)

These functions are pinned to the Python reference by a shared corpus:
`tests/scripts/dev_tools/test_blast_radius_parity.py` and
`tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`. The Python drift modules must
stay in any case, because `scripts/dev_tools/_parallel_orchestrator_state_drift.py:61` imports
`parallel_drift_detection`.

### 1.5 Consumers of CLI output

- Drift stdout: the `parallel-orchestrator` agent, per `parallel-orchestrate/SKILL.md:905-933`
  (writes `drift_events[]`, halts, and applies `observed_radius` in step 7, 849-860). No hook parses
  the CLI stdout. `.claude/hooks/enforce-parallel-drift-gate.ps1` and its helpers read the
  checkpoint the orchestrator writes (helpers header 21-31), so they are indirect consumers of the
  record shapes.
- Python tests importing the drift CLI: `test_parallel_drift_detection_cli.py` (401 lines),
  `test_parallel_drift_detection_cli_halt.py` (140), `parallel_drift_test_support.py` (187),
  `test_parallel_drift_resolution.py:21`, `test_parallel_drift_detection_conflicts.py:29`,
  `test_parallel_drift_timestamps.py:26`.
- Abandon: the parallel-remove completion report records the exit code
  (`parallel-remove/SKILL.md:179`). The hook consumes command text only.
- Python tests importing the abandon CLI: `test_parallel_mutation_abandon_cli.py` (370),
  `test_parallel_abandon_token_seam.py` (330), and `test_parallel_mutation_protocol.py:44`
  (`ABANDON_DISPOSITION`).
- Pester hook suites use the Python command string as input data only:
  `enforce-parallel-abandon-gate.Tests.ps1:24-25` and
  `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1:48,56,75,82,89`.

### 1.6 Agent allowlist dependency

`.claude/agents/parallel-orchestrator.md:16-17` grants `Bash(poetry run python -c *)` and
`Bash(poetry run python -m *)`. The prose at 96-102 states that the drift-detection CLI is the one
remaining named consumer. `.claude/settings.json:6` allows `Bash(poetry run *)` and `:7` allows
`Bash(pwsh *)`. No test pins the orchestrator's `poetry` grants (grep of `tests/` for
`python -m \*` returns no match). `parallel-planner.md:16` retains `Bash(poetry run *)`, and
`test_parallel_planner_surface_contracts.py:180` pins it; this feature does not affect that grant.

Two prior decisions deferred these two sites:

- `docs/features/epics/claude-runtime-portability/epic.md:201-233,250` recorded the drift CLI port as
  an explicit non-goal "pending a separate decision".
- `docs/features/completed/2026-08-29-remove-remaining-python-invocations-599/spec.md:67-69,487-508`
  declared both sites non-goals.

Issue #763 is that separate decision.

## 2. Destination-Runtime Port Precedents

### 2.1 Features

- Bash ports `compute-cohorts.sh`, `compute-concurrency-batches.sh`, and
  `validate-parallel-manifest.sh`: issue #462,
  `docs/features/completed/2026-08-10-parallel-surface-destination-portability-bash-462/`.
  `report-lane-assertion.sh` came from #599.
- PowerShell blast-radius library: issue #447, `docs/features/completed/2026-08-07-parallel-blast-radius-447/`.
- PowerShell entry-point script under `.claude/lib/`: issue #643,
  `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1`
  (`docs/features/completed/2026-09-07-mergeable-project-file-overlaps-643/`). It is invoked from
  `parallel-orchestrate/SKILL.md:387` as `pwsh -NoProfile -File ...`, has one mocked executable seam
  (`Invoke-GitExe`, 48-69), a dot-source guard (224-229), and emits one JSON object on stdout.

### 2.2 How the bash precedent is tested

- Unit tests: `tests/shell/parallel_cohorts.bats`.
- Behavioral parity: `tests/shell/parallel_cohorts_parity.bats` iterates the committed corpus
  `tests/fixtures/parallel_cohorts/*.json`, with a floor of 20 fixtures (38-101). The Python lane
  `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` asserts the same corpus. Declared
  divergence classes are listed in the suite headers (12-29). python3 is a harness dependency only.
- Payload-only proof: `tests/shell/parallel_payload_only.bats` runs the bundle copy with
  `PATH=tests/fixtures/parallel_payload_path` (checked-in shims, no interpreter) and `env -i`
  (24-43).
- Membership and dual-home parity: `tests/shell/parallel_bash_manifest_membership.bats`. Every
  `.claude/lib/bash/*.sh` needs a `core.json` entry and a byte-identical bundle copy (43-71); the
  floor is 11 files (21). A pinned list of four entry points is at 84-89.
- Coverage: kcov through `scripts/bash/shell-qc.sh test --coverage`. The include pattern covers
  `.claude/lib/bash` by directory (`scripts/bash/shell_qc_lib.sh:335`), so no per-file
  registration exists. CI runs this in `.github/workflows/_shell-coverage.yml`. `.claude/rules/shell.md:91-92`
  prohibits temporary files and directs checked-in fixtures and stubs.

### 2.3 How the PowerShell precedent is tested

- Corpus parity: `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` together with
  `tests/scripts/dev_tools/test_blast_radius_parity.py`, over `tests/fixtures/blast_radius/*.json`.
  The floor is 30 (`test_blast_radius_parity.py:60`).
- Manifest membership: `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`
  discovers modules from disk and requires `core.json` entries and bundle counterparts.
- Coverage: `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  is an explicit per-file allow-list (157-201). The bundled copy
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` must match
  it (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py:16,63`). Pester discovers tests under
  `tests/scripts` (`Run.Path`, line 3).
- Python-free guard: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
  scans every `*.ps1`/`*.psm1` under `.claude/hooks` and `.claude/lib`, excluding `.claude/lib/bash`
  (39-72).

### 2.4 Registration points for a new `.claude/lib/bash/*.sh` (worked example: `compute-cohorts.sh`)

A search of every non-`docs/` reference to `compute-cohorts.sh` returns these required
registrations:

1. The script itself, `.claude/lib/bash/compute-cohorts.sh`.
2. The byte-identical bundle copy
   `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/compute-cohorts.sh`.
   It is enforced by `parallel_bash_manifest_membership.bats:56-71` and
   `test_push_down_claude_resource_contracts.py:118-143`.
3. The pack manifest `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:163`.
   Membership is enforced generically by `claude-pack-manifest-completeness.test.ts:200-213` and
   by the bats membership suite.
4. The agent tool allowlists `.claude/agents/parallel-orchestrator.md:18` and
   `.claude/agents/parallel-planner.md:17`, plus their bundle mirrors.
5. The settings allow entry `.claude/settings.json:8`, plus its bundle mirror.
6. The skill invocation lines `parallel-plan/SKILL.md:285` and `parallel-orchestrate/SKILL.md:636`,
   plus their bundle mirrors. `skill_bundle_contract.py` detects the `bash <path>` form (52).
7. Tests: `tests/shell/parallel_cohorts.bats`, `parallel_cohorts_parity.bats`,
   `parallel_payload_only.bats`, and `parallel_bash_manifest_membership.bats:85`.

The TypeScript tests `claude-pack-manifest-completeness.test.ts:242`,
`claude-config-carriage.test.ts:451`, and `config-carriage.test-helpers.ts:171,187` hold issue-#462
pins. They are optional for new files. Coverage (kcov) and lint/format (`shell_qc_lib.sh:85`) find
the script by directory.

For a new `.claude/lib/<area>/*.ps1|*.psm1`, the equivalent list (worked example:
`Resolve-MergeableConflict.ps1`) is:

- the script and its bundle copy;
- `core.json:159`;
- both `pester.runsettings.psd1` copies (line 201);
- the agent allowlist (`parallel-orchestrator.md:21`);
- the skill line (`parallel-orchestrate/SKILL.md:387`, detected by the `pwsh ... -File <path>`
  pattern, `skill_bundle_contract.py:54`);
- a Pester suite under `tests/scripts/claude-lib/<area>/`.

`settings.json:7` already allows `Bash(pwsh *)`.

### 2.5 JSON handling constraints

- The bash library has no JSON parser. A case-insensitive search for `jq`, `python`, and `json` in
  `.claude/lib/bash/**` finds only emission of compact JSON arrays and comments that name the
  Python authority. `compute-cohorts.sh` takes all input as command-line strings (`--keys`,
  `--edges`, header 8-21), and the manifest validator uses a bash YAML-subset scanner
  (`parallel-yaml-scan.sh`). jq is not assumed.
- PowerShell `ConvertFrom-Json` (PS 6+) converts timestamp-shaped strings to `DateTime`. Only
  PS 7.5+ offers `-DateKind String`. This is from the Microsoft Learn ConvertFrom-Json 7.5
  reference, Notes section. The repo already records the hazard in
  `.claude/lib/orchestrator-state/OrchestratorState.psm1:145-152`, which also names the
  `[string] $ComputedAt` binding in `BlastRadius.psm1` as exposed. `ConvertFrom-Json` also does
  not keep the JSON distinction between integer and boolean in the way Python's `is_positive_integer`
  requires, unless each value is type-checked.

## 3. Abandon-Gate Token Seam

- Hook tokens: `enforce-parallel-abandon-gate.ps1:41` `$script:AbandonDispositionToken = '--disposition abandon'`
  and `:42` `$script:AbandonConfirmToken = '--confirm-abandon'`. Matching is per segment:
  adjacent tokens `--disposition` `abandon` or the joined form `--disposition=abandon`, plus a
  raw-scan leg for wrapper arguments (95-156). The confirmation marker must be in the same segment
  (192-233). The deny reason prefix is `PARALLEL_ABANDON_BLOCKED` (45).
- The gate matches the command text, not the program being invoked. Any producer whose documented
  invocation keeps the GNU-style tokens `--disposition abandon` and `--confirm-abandon` needs no
  hook logic change.
- Seam test (`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`):
  - The producer tokens are read from the Python CLI constants (37, 81-93) and the live argparse
    surface (96-148).
  - The hook tokens are read by regex from the two named assignments (53-58, 151-172), and each
    literal must appear exactly once in the hook (285-294).
  - The SKILL line is located by `INVOCATION_ANCHOR = "parallel_mutation_abandon_cli.py"` (49). It
    must be the only line containing the anchor plus `--` (175-201), and it must carry both tokens
    (297-310).
- Effect of a port:
  - The anchor must become the new script's basename.
  - A new producer-side extraction must read the port's declared tokens.
  - The hook's two assignments and the rule that each token appears once must not change.
  - The hook's docstring (27-31) names the Python producer. A comment-only edit is permitted, must
    not add a token literal, and must be mirrored into the bundle copy.
  - The hook stays PowerShell with no Python leg; the Python-free guard (section 2.3) continues to
    apply.

## 4. `KNOWN_UNBUNDLED_REFERENCES`

- Registry: `scripts/dev_tools/skill_bundle_contract.py:132-145` holds two entries,
  `("parallel-orchestrate", "scripts/dev_tools/parallel_drift_detection_cli.py", "#763")` and
  `("parallel-remove", "scripts/dev_tools/parallel_mutation_abandon_cli.py", "#763")`. It is the
  default for `find_violations` (446-468) and `find_stale_exceptions` (471-495).
- Tests that depend on it:
  - `test_skill_bundle_contract_evaluation.py:247-268` asserts the registry equals exactly those two
    entries. It must be changed to assert an empty registry.
  - `test_skill_bundle_contract_repo.py:90-100` requires no stale exception. After the SKILL
    invocations change, both entries become stale and the test fails, so they must be removed
    together with the SKILL change. With an empty registry the test passes trivially.
  - `test_skill_bundle_contract_repo.py:29-43` requires zero unregistered violations. The new entry
    points must therefore be in the bundle and in `core.json`.
  - `test_skill_bundle_contract_cli.py:52-136`: `_clean_inputs` relies on the two default entries,
    so `test_main_returns_zero_when_clean` would return 1 with an empty registry. The stale test
    depends on a registered entry. `main` (`skill_bundle_contract_cli.py:168-215`) has no
    `exceptions` parameter. Options:
    - (i) remove the two parallel skills from `_clean_inputs` and delete or rewrite the stale test;
    - (ii) add a keyword-only `exceptions` parameter to `main`, forwarded to both finders, so the
      stale branch (207-211) stays covered.

    Option (ii) is recommended to preserve coverage of the stale-reporting lines.

## 5. Mirrors and Sync

- The only mirrors are the bundle copies under
  `extensions/drm-copilot/resources/claude-customizations/.claude/**`. There is no sync script
  (Glob for `*sync*` under `scripts/` finds only unrelated tools), so each mirror is updated by a
  manual byte copy.
- Parity is enforced by:
  - `test_push_down_claude_resource_contracts.py:118-143`, for every non-memory `.claude` file;
  - `parallel_bash_manifest_membership.bats`, for `.claude/lib/bash`;
  - the per-library Pester `*.Manifest.Tests.ps1` suites.
- `pack-manifests/*.json` are bundle-only and outside the parity scope (resource contracts test,
  177).

## 6. Options Analysis

### Selected approach: PowerShell port for drift detection, bash port for abandon

**Drift detection: PowerShell entry point reusing `.claude/lib/blast-radius/`.**

- Rationale:
  - Every blast-radius operation the CLI needs is already ported and corpus-bound (section 1.4).
  - `parallel-plan/SKILL.md:180-209` already requires `pwsh` for this library on the destination
    path and states that the Python modules "remain the repository authority and the parity
    reference ... not invoked on the destination-runtime path".
  - `parallel_drift_detection.py:20-24` and `parallel_drift_resolution.py:20-27` forbid
    re-implementing subsumption, contention, or observed-radius construction. A PowerShell port that
    calls the existing PowerShell library satisfies that rule, because it adds no third
    implementation.
- New logic to port:
  - the CLI boundary: argument handling, file reads, clock, stdout;
  - the reader accessors;
  - `detect_escaped_paths`, `build_drift_event`, `recompute_conflicts_with_observed` (with the
    fail-closed peer-radius rule of `_parallel_drift_scheduling.py:128-134`),
    `existing_edge_pairs`, `item_band`;
  - `halted_item_keys` / `select_halted_item` / `_start_rank`;
  - the used shape guards.

  Estimate (not measured): roughly 400-700 PowerShell lines including comment-based help, split
  across a pure module and an entry script so that each stays under 500 lines.
- Proposed layout (names are proposals):
  - `.claude/lib/parallel-drift/ParallelDrift.psm1` (pure; imports `../blast-radius/BlastRadius.psm1`);
  - `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` (entry; dot-source guard, file
    and clock seams, following `Resolve-MergeableConflict.ps1`).
- Proposed invocation:
  `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey <issue_num> [-CheckpointPath ...] [-ConfigPath ...] [-At ...] [-ComputedAt ...] <CHANGED_PATH>...`.
  The changed paths are bound through a `ValueFromRemainingArguments` parameter.
- Implementation constraints to record:
  1. Parse JSON with `System.Text.Json` (`JsonDocument`) into hashtables and lists, or verify that
     `-DateKind String` is available. This keeps timestamps as strings and separates integers from
     booleans (see section 2.5 and `_parallel_state_common.py:137-148`).
  2. Do not declare parameters `Mandatory`. Under `-File` a missing mandatory parameter can prompt;
     validate explicitly instead, and exit 2 for usage errors and 1 for data errors to preserve the
     0/1/2 contract.
  3. Emit JSON with sorted keys, explicit arrays (a one-element array must not unroll), and a
     `ConvertTo-Json -Depth` value large enough for the nested `observed_radius` and `drift_event`.
     The default depth is 2.
  4. Use ordinal string comparison for path sorting and for `worktree_created_at` in the halt rule.
  5. Read `conflict` and `edge` from the returned hashtables. Never test the returned object for
     truthiness (`BlastRadius.psm1:400-409`).
  6. Resolve relative `-CheckpointPath` and `-ConfigPath` against the caller's working directory.
- Parity scope: compare stdout as parsed JSON values, not bytes. Python's `ensure_ascii` and
  indentation details are not reproduced. Compare error cases on exit code and the stderr prefix
  `parallel drift detection failed: ` only, because Python messages embed `repr()` text. Declare
  both as divergence classes, following the #462 header practice.

**Abandon: bash entry point under `.claude/lib/bash/`.**

- Rationale:
  - The logic is argument parsing, two refusals, and two ordered subprocess calls, with no JSON.
  - Bash parses the GNU-style `--disposition abandon` and `--confirm-abandon` tokens natively. The
    hook matches those tokens, so they stay identical and the hook needs no logic change.
  - The bash library, its bats/kcov pipeline, and the checked-in PATH-shim pattern already exist.
- Proposed name: `.claude/lib/bash/abandon-parallel-item.sh`. The name is a proposal.
- Proposed invocation:
  `bash .claude/lib/bash/abandon-parallel-item.sh --item <key> --disposition abandon --confirm-abandon --pr <pr-number> --worktree <worktree-path>`.
- Implementation constraints to record:
  1. Declare the option names and the `abandon` value once as named constants and match on those
     variables, so the seam test can extract them by regex.
  2. Reproduce the three `PARALLEL_ABANDON_ERROR:` messages and the exit codes 0/1/2, including -1
     for an unresolvable executable (`command -v`).
  3. Reject option abbreviations and unknown options with exit 2. Argparse accepts prefixes; this
     port is stricter, and the stricter behavior is fail-closed and should be declared as a
     divergence.
  4. Do not reproduce argparse usage text; match exit code 2 only.

### Rejected alternatives (brief)

- **Bash port of drift detection.**
  - Bash has no JSON parser, and jq is not guaranteed (section 2.5).
  - The port would need a third implementation of the blast-radius closure (3,485 Python lines),
    which conflicts with the no-reimplementation boundary.
- **PowerShell port of abandon.**
  - PowerShell parameters are single-dash (`-Disposition`), so keeping the hook's GNU-style tokens
    would require manual `$args` parsing.
  - How `--name` tokens bind under `pwsh -File` was not verified in this research.
  - Changing the tokens would require editing the hook's pinned assignments and the seam.
- **Bundling the Python scripts.**
  - Push-down publishes only `.claude` and `config` (`skill_bundle_contract.py:38`, pinned to the
    TypeScript `ROOT_FOLDERS` by `test_skill_bundle_contract_repo.py:103-117`). Shipping
    `scripts/**` would require changing `claude-customizations.ts`, which is a stated constraint.
  - Relocating the 21-file closure into `.claude/` would still require a Python interpreter in
    consumers, which contradicts the destination-runtime posture (issue #475 guard, #599).

### Retain or retire the Python CLIs

Retain both Python CLIs as the repository authority and parity reference, consistent with #447
(`BlastRadius.psm1:32-33`) and #462 (`parallel-orchestrator.md:90-92`).

- The drift CLI is the Python lane of the new parity corpus.
- The abandon CLI becomes one of four sides of the token seam: Python constants, bash constants, the
  hook, and the SKILL line.

Other in-repo dependencies after the port:

- the Python tests listed in section 1.5;
- the `Bash(poetry run python -m *)` grant in `parallel-orchestrator.md:17`, which will have no
  named consumer (see Open Questions).

Retiring the abandon CLI is a reasonable alternative. It would remove an unused destructive
executable path, but `test_parallel_mutation_protocol.py:44` would need a new import source.

## 7. Requirements Mapping and Expected File Changes

New files:

- `.claude/lib/parallel-drift/ParallelDrift.psm1`, `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`
  (names proposed), and their bundle copies.
- `.claude/lib/bash/abandon-parallel-item.sh` (name proposed) and its bundle copy.
- `tests/fixtures/parallel_drift/*.json` (a shared corpus with inline `state`, `config`, `item_key`,
  `changed_paths`, `at`, `computed_at`, and an expected payload or error).
- `tests/scripts/dev_tools/test_parallel_drift_parity.py` (Python lane, calls `evaluate_drift`).
- `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1`,
  `Invoke-ParallelDriftDetection.Tests.ps1`, `ParallelDrift.Parity.Tests.ps1`, and
  `ParallelDrift.Manifest.Tests.ps1`.
- `tests/fixtures/parallel_abandon/*.json` (corpus), `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py`
  (Python lane with an injected runner), `tests/shell/parallel_abandon.bats`,
  `tests/shell/parallel_abandon_parity.bats`, and checked-in `gh`/`git` shims under a new
  `tests/fixtures/<abandon-path>/` directory. The shims echo their argv and exit with a
  fixture-selected code.

Modified files:

- `.claude/skills/parallel-orchestrate/SKILL.md` (733-736, 876-933, 960-962) and its mirror. Do not
  add `##` headings: `test_parallel_orchestrator_surface_contracts.py:217` pins sixteen.
- `.claude/skills/parallel-remove/SKILL.md` (105-118, 149-156) and its mirror. Keep exactly one
  option-bearing invocation line.
- `.claude/agents/parallel-orchestrator.md` (tools 14-21; prose 76-102) and its mirror: add the
  `pwsh ... Invoke-ParallelDriftDetection.ps1*` and `bash ... abandon-parallel-item.sh*` entries.
- `.claude/hooks/enforce-parallel-abandon-gate.ps1` docstring 27-31 (comment only) and its mirror.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- `scripts/dev_tools/skill_bundle_contract.py` (empty the registry; update comment 132-133).
- `scripts/dev_tools/skill_bundle_contract_cli.py` (optional `exceptions` keyword; see section 4).
- `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py`,
  `test_skill_bundle_contract_cli.py`, and `test_parallel_abandon_token_seam.py`.
- `tests/shell/parallel_payload_only.bats` (add an abandon payload case using a separate shim PATH,
  so that the "no interpreter" shim directory stays unchanged).
- Optional: `tests/shell/parallel_bash_manifest_membership.bats:84-89` (entry-point list),
  `.claude/settings.json` and its mirror (abandon allow entry; see Open Questions), and the Pester
  hook suites' sample command strings.

Behavior semantics to preserve:

- Drift:
  - `drift_event` and `observed_radius` are null iff `result == no_escape`.
  - The drifting key is never halted.
  - Pairs are canonical and ascending, and halted keys are deduplicated and ascending.
  - An unreadable peer radius counts as conflicting.
  - A non-object `conflict_edges[]` entry is ignored, but a non-list collection is an error.
  - A missing item key is an error.
  - An empty changed-path list yields `no_escape`.
- Abandon:
  - The PR is closed before the worktree is removed.
  - The run stops at the first failure.
  - Both refusals occur before any side effect.

## 8. Testing Implications

- Test layout follows `general-unit-test.md`. No temporary files: use committed corpora and shims.
  Mock the clock and file-read seams in Pester by dot-sourcing the entry script behind its guard,
  as in the #643 precedent.
- Both corpora are asserted by two lanes (Python plus Pester for drift, Python plus bats for
  abandon), each with a fixture-count floor. Include these cases:
  - no escape;
  - escape with no conflict;
  - a halt with one pair and with several pairs;
  - the drifter-is-later case;
  - equal, one-absent, and both-absent start timestamps;
  - reversed and non-object edges;
  - a malformed peer radius;
  - a tolerated overlap under `conflict_tolerance`;
  - error cases: non-list `items`, missing key, non-object root.
- Coverage: the Pester per-file allow-list must list the new PowerShell files, and the line
  threshold is 85%. kcov measures the bash script automatically; its threshold is line coverage
  only, 85%.
- `quality-tiers.yml` does not exist in this tree (Glob `**/quality-tiers.y*ml` returns no file),
  so the new modules cannot be tier-classified. Property-test density therefore cannot be derived
  from a tier. See Open Questions.
- Toolchain:
  - PoshQC format, analyze, and test for the PowerShell files;
  - `scripts/bash/shell-qc.sh` format, check, and test `--coverage` for the bash files;
  - the Python toolchain for the edited Python tests and the contract module;
  - Jest for `claude-pack-manifest-completeness.test.ts`.

## 9. Constraints

- Do not modify `.claude/hooks/enforce-powershell-batch-budget.ps1` or its tests.
- Do not modify `scripts/dev_tools/push_down_claude_customizations.py` or
  `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`.
- The recommended option can be delivered without touching any of these files:
  - New `.claude/lib/**` files reach consumers by listing in `core.json`. `.claude` is already a
    published root (`skill_bundle_contract.py:38`).
  - The #462 and #643 plans added `.claude/lib` entry points without editing either push-down file.
    A grep of both plans for `claude-customizations.ts|push_down_claude_customizations.py` returns
    no match.
- Pushed-down enforcement hooks must not gain Python legs. The only hook change is a comment edit
  to `enforce-parallel-abandon-gate.ps1`.

## 10. Numeric Derivation Evidence

### N1. Executable invocations of the two Python CLIs in the pushed-down surface (current 2 per tree; target 0)

- Complete Family: executable command lines that invoke either CLI under `.claude/**` and the
  bundle `.claude/**`.
- Exhaustive Search Scope: `.claude/skills/**`, `.claude/agents/**`, `.claude/rules/**`, `.claude/hooks/**`,
  and `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
- Inclusion Rules: a line that starts a Python interpreter on either CLI in any spelling (path form or
  `-m` module form).
- Exclusion Rules:
  - backticked prose citations;
  - hook docstring text;
  - `DiscoveryValidation.psm1:7` (a historical comment for a different module).
- Primary Search Strategy or Query Expression: ripgrep `python3?\s+(-m\s+)?scripts[./]dev_tools`
  over skills, agents, rules, and the bundle `.claude/**`.
- Primary Member Set: `parallel-remove/SKILL.md:112`, `parallel-orchestrate/SKILL.md:884` (repo);
  the same two lines in the bundle. The `DiscoveryValidation.psm1:7` match is excluded.
- Primary Count: 2 repo + 2 bundle.
- Cross-check Search Strategy or Query Expression: two separate name-anchored searches over `.claude`:
  - (a) `dev_tools/parallel_(drift_detection|mutation_abandon)_cli\.py`, which returns 733, 881,
    961 (orchestrate), 112, 150 (remove), and hook:29;
  - (b) `scripts\.dev_tools\.parallel_(drift_detection|mutation_abandon)_cli`, which returns
    orchestrate:884.

  The union is filtered to lines containing an interpreter token.
- Cross-check Member Set: `parallel-remove/SKILL.md:112` and `parallel-orchestrate/SKILL.md:884`.
  The bundle search over `extensions/.../claude-customizations/**` returns the same lines.
- Cross-check Count: 2 repo + 2 bundle.
- Member-set Comparison: identical after normalization to `<file>:<line>`. The count is confirmed.

### N2. Non-invocation citations requiring a text update (5 per tree)

- Complete Family: prose lines under `.claude/**` that name either Python CLI file or module.
- Exhaustive Search Scope: `.claude/**` and its bundle mirror.
- Inclusion Rules: any line that names either CLI.
- Exclusion Rules: the invocation lines in N1.
- Primary Search Strategy or Query Expression: ripgrep
  `parallel_drift_detection_cli|parallel_mutation_abandon_cli` over `.claude/**` and the bundle.
  This returns 7 repo lines.
- Primary Member Set: orchestrate:733, :881, :961; remove:150; hook:29.
- Primary Count: 5.
- Cross-check Search Strategy or Query Expression: the union of the slash-path search and the dotted
  module search from N1(a) and N1(b), which is 7 lines, minus the N1 members.
- Cross-check Member Set: orchestrate:733, :881, :961; remove:150; hook:29.
- Cross-check Count: 5.
- Member-set Comparison: identical. The count is confirmed.

### N3. `KNOWN_UNBUNDLED_REFERENCES` entries (current 2; target 0)

- Complete Family: `KnownUnbundledReference` instances in the registry tuple.
- Exhaustive Search Scope: `scripts/dev_tools/skill_bundle_contract.py`.
- Inclusion Rules: tuple members at 134-145.
- Exclusion Rules: test fixtures that construct their own exceptions.
- Primary Search Strategy or Query Expression: a direct read of `skill_bundle_contract.py:134-145`.
- Primary Member Set: (parallel-orchestrate, drift CLI path, #763) and (parallel-remove, abandon CLI
  path, #763).
- Primary Count: 2.
- Cross-check Search Strategy or Query Expression: a read of the independent expected tuple in
  `test_skill_bundle_contract_evaluation.py:251-262`.
- Cross-check Member Set: the same two tuples.
- Cross-check Count: 2.
- Member-set Comparison: identical. The count is confirmed.

## 11. Automation Feasibility

No step requires human interaction. Every change is a file edit, a byte copy into the bundle, or a
toolchain run (PoshQC, `shell-qc.sh`, pytest, Jest). The CI workflow `_shell-coverage.yml` runs bats
and kcov. Project memory records that agent worktrees may refuse command text containing
`bash`/`pwsh`; this was not re-verified here. Local bats execution may therefore need the recorded
workaround (`sh <file>`), and CI remains the authoritative bats/kcov gate. No live `gh` or `git`
side effect is needed in any test.

## 12. Open Questions

1. Retain or retire `parallel_mutation_abandon_cli.py`. The recommendation is to retain it as the
   parity reference; retiring it is the alternative (section 6).
2. Whether to remove `Bash(poetry run python -m *)` from `parallel-orchestrator.md:17`, which loses
   its only named consumer. Leaving it in place with updated prose carries lower risk.
3. Whether to add the abandon entry point to `.claude/settings.json` `allow`. Today the Python route
   is allowed through `Bash(poetry run *)`. Adding the entry keeps the current prompt-free behavior;
   omitting it adds a permission prompt in front of a destructive command that the hook already
   gates.
4. `parallel-remove/SKILL.md` steps 2, 3, and 6 still call Python library functions
   (`decide_removal`, `recolor_unstarted`, `build_remove_entry` in
   `scripts/dev_tools/parallel_mutation_protocol.py`) with no invocation form. The skill-bundle
   guard does not detect them. These are out of scope for #763 and are a candidate follow-up issue.
5. `quality-tiers.yml` is absent, so the new modules' tier, and with it property-test and mutation
   obligations, cannot be derived.
6. The minimum destination `pwsh` version. `-DateKind` requires 7.5. The recommended
   `System.Text.Json` route avoids depending on it. The discovery gate already requires 7.4+
   (`enforce-discovery-artifact-gate.ps1:28`).
