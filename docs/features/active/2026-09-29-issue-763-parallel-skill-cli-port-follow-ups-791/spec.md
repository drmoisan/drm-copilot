# 2026-09-29-issue-763-parallel-skill-cli-port-follow-ups (Spec)

- **Issue:** #791
- **Parent (optional):** #763 (follow-ups FU-763-1, FU-763-2, FU-763-3, FU-763-5)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-10
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md` is produced)
- **Research:** `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/research/research.2026-10-08T14-00.md`

All paths are repository-relative. Line numbers refer to the tree at the start of this work and are taken from the research note; the lines cited for `scripts/dev_tools/skill_bundle_contract.py:52,64` and `.claude/agents/parallel-orchestrator.md:16-17` were re-read while this spec was written.

## Context

- Issue #763 ported the parallel abandon and drift-detection CLIs to destination-runtime scripts and deferred four related items (#763 spec decisions D4, D6, D7) plus one guard defect discovered during its preparation. Issue #791 promotes those items as a single bug.
- Observed environment: repository runtime (`.claude/`) and the bundled push-down payload (`extensions/drm-copilot/resources/claude-customizations/.claude/`) delivered to consumer repositories.
- Impact:
  - FU-763-5: any skill that places a `bash`/`sh`/`source` invocation directly under a ` ```bash ` or ` ```sh ` fence (or a `python <path>.py` invocation under a ` ```python ` fence) bypasses the skill-bundle guard. An unbundled script reference can then ship without a test failure.
  - FU-763-3: `parallel-remove` steps 2, 3 and 6 can only be executed through the repository-local Python engine. In a consumer repository without Poetry or the `scripts/` tree, those steps cannot run, and the guard does not report the gap.
  - FU-763-2: invoking the ported abandon script prompts for permission because no allow entry matches it.
  - FU-763-1: the parallel-orchestrator agent carries an unused `Bash(poetry run python -m *)` grant, which widens its permission surface without a consumer.
- Severity: medium. No data loss; the defects affect guard coverage, consumer-workspace operability of one skill, and permission surface.
- First observed: 2026-09-29, during #763 preparation (preflight round 2).

## Repro & Evidence

### FU-763-5 (deterministic)

1. Call `extract_script_references` on the text ` ```bash\nbash .claude/lib/bash/x.sh --flag\n``` `.
2. Expected: the result contains `.claude/lib/bash/x.sh`. Actual: the path is not extracted (research, regex analysis steps 1-6).
3. Live instance: `.claude/skills/parallel-plan/SKILL.md:322-323` (` ```bash ` followed by `bash .claude/lib/bash/compute-cohorts.sh ...`). The guard does not extract `compute-cohorts.sh` for `parallel-plan` through that line. No violation is hidden today because the script is bundled and listed in `core.json:172`.

### FU-763-3 (deterministic)

1. Read `.claude/skills/parallel-remove/SKILL.md` steps 2 (lines 76-78), 3 (lines 80-96), and 6 (lines 120-130).
2. Expected: each step invokes a bundled, destination-runtime script. Actual: each step instructs the agent to call `decide_removal`, `recolor_unstarted`, or `build_remove_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`, which is not part of the bundle.
3. The guard reports nothing because the path is a backticked citation without an invocation verb, which the guard intentionally ignores (`extract_script_references` docstring lines 307-308).

### FU-763-2 (deterministic)

1. Search `.claude/settings.json` `permissions.allow` (lines 4-67) for `abandon-parallel-item.sh`.
2. Expected: a narrow allow entry. Actual: none. The bash entry points at lines 8-10 (`compute-cohorts.sh`, `compute-concurrency-batches.sh`, `validate-parallel-manifest.sh`) have entries; the abandon script does not.

### FU-763-1 (deterministic)

1. Read `.claude/agents/parallel-orchestrator.md:16-17` and prose lines 98-107.
2. Expected: every `tools` grant has a consumer in the agent's caller set. Actual: `Bash(poetry run python -m *)` (line 17) has no consumer (research, FU-763-1 searches 1-3).

## Problem Statements and Root Cause

### FU-763-5: skill-bundle guard misses invocations directly under a bash or python fence

- File: `scripts/dev_tools/skill_bundle_contract.py` (486 lines; 14 lines of headroom to the 500-line limit).
- Root cause (confirmed by pattern analysis in the research): the invocation pattern at line 52, `(?<![A-Za-z0-9_-])(?:bash|sh|source)\s+` followed by `_CANDIDATE` (line 49), uses `\s+`, which matches a newline. For a fence info string `bash` or `sh`, the pattern starts at the fence word, crosses the newline, and captures the next line's interpreter word (`bash`) as the candidate. `_normalize_candidate("bash")` returns `None`, and `re.finditer` resumes after the consumed word, so the script path on that line is never matched. A prose line ending in `bash`, `sh`, or `source` followed by an invocation line has the same effect.
- The same defect class applies to `_PYTHON_PATH_PATTERN` at line 64 (`python3?\s+`) for a ` ```python ` fence followed by `python <path>.py` (inferred by the same analysis). `_PYTHON_MODULE_PATTERN` (lines 65-68) is not affected because it requires `-m` after the whitespace.
- A ` ```shell ` fence is not affected; #763 used it as a workaround at `.claude/skills/parallel-remove/SKILL.md:111`.

### FU-763-3: `parallel-remove` steps 2, 3 and 6 call the unbundled Python engine

- File: `.claude/skills/parallel-remove/SKILL.md`, steps 2 (lines 76-78), 3 (lines 80-96), 6 (lines 120-130).
- Root cause: #763 D7 deferred the port of `decide_removal` (`scripts/dev_tools/parallel_mutation_protocol.py:338-426`), `recolor_unstarted` (`parallel_mutation_protocol.py:200-335`), and `build_remove_entry` (`scripts/dev_tools/_parallel_mutation_entries.py:133-175`). The skill text names these as prose calls without an invocation verb, so (a) the steps have no runnable form in a consumer repository and (b) the skill-bundle guard does not detect them. `scripts/` is outside `PUBLISHED_ROOT_FOLDERS = (".claude", "config")`, so the module is never bundled.

### FU-763-2: no settings allow entry for the ported abandon script

- File: `.claude/settings.json` (`permissions.allow`, lines 4-67) and its bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`.
- Root cause: #763 D6 left `settings.json` unmodified. The previous invocation matched `Bash(poetry run *)`; the ported `bash .claude/lib/bash/abandon-parallel-item.sh ...` invocation matches no allow entry. The abandon gate hook remains registered under `PreToolUse` (`.claude/settings.json:123`).

### FU-763-1: unused `Bash(poetry run python -m *)` grant

- File: `.claude/agents/parallel-orchestrator.md:17` and its bundled copy at the same line; explanatory prose at lines 98-107 (the `poetry run python` grants are described at lines 104-105).
- Root cause: #763 D4 deliberately left the grant unchanged pending a separate decision. The research searched the agent's preloaded skills, the skills that fork into the agent (`parallel-add`, `parallel-close`, `parallel-orchestrate`, `parallel-remove`, `parallel-run`), and `.claude/rules/parallel-orchestration.md`, and found no `python -m` consumer. The only `python -m` documentation that can load in a parallel-orchestrator session (`.claude/rules/orchestrator-state.md:173`) describes the single-item checkpoint validator; the parallel surface validates through `mcp__drm-copilot__validate_orchestration_artifacts` instead.

## Decisions

The operator asked not to be consulted on these resolutions. Each decision below is recorded with its rationale and is an **assumption** that the operator may revisit.

- **D1 (assumption): fix both guard patterns with horizontal whitespace.** Replace `\s+` with `[ \t]+` after the verb in the `bash|sh|source` pattern (`scripts/dev_tools/skill_bundle_contract.py:52`) and in `_PYTHON_PATH_PATTERN` (line 64). Update the line-51 comment to state that the separator is horizontal whitespace so a fence info string cannot consume the next line's interpreter word. Add regression tests for an invocation directly under a ` ```bash `/` ```sh ` fence and directly under a ` ```python ` fence. Rationale: zero net line change in a file with 14 lines of headroom; the research's multiline search found no `SKILL.md` that relies on a cross-newline match to extract a reference, and no line-continuation backslash after a verb. Rejected alternatives: anchoring the verb to a line start (drops mid-sentence and `&&` invocations) and stripping fence info lines (fixes fences only and adds lines).
- **D2 (assumption): port `parallel-remove` steps 2, 3 and 6 to bash.** Add a sourceable library `.claude/lib/bash/parallel-mutation.sh` (functions `pm_decide_removal`, `pm_recolor_unstarted`, `pm_build_remove_entry`; results in `PM_RESULT`/`PM_ERROR`) that sources `parallel-common.sh` and reuses `pcoh_compute_cohorts` from `parallel-cohorts.sh`, and an entry script `.claude/lib/bash/remove-parallel-item.sh` with subcommands `decide`, `recolor`, and `entry` mapping one-to-one to the Python functions. The skill text invokes the bundled entry script so the guard extracts and checks it. The Python module `scripts/dev_tools/parallel_mutation_protocol.py` is retained, not deleted, because `parallel-add`, `parallel-close`, and `parallel-orchestrate` still reference it, and it remains the parity reference. The disposition option is named `--removal-disposition`; the name `--disposition` is not used because the abandon-gate hook (`.claude/hooks/enforce-parallel-abandon-gate.ps1`, with the wrapper substring scan in `.claude/hooks/hook-command-scanner.ps1`) treats `--disposition abandon` as in scope and would deny the command. Rationale: aligns with the #462/#763 bash library, needs no interpreter, adds no third coloring implementation. Rejected alternatives: a PowerShell port (no PowerShell coloring port exists) and extending the guard to detect prose calls (false positives on legitimate parity citations).
- **D3 (assumption): add narrow settings allow entries.** Add `"Bash(bash .claude/lib/bash/abandon-parallel-item.sh*)"` and `"Bash(bash .claude/lib/bash/remove-parallel-item.sh*)"` to `.claude/settings.json` `permissions.allow`, keeping the bash entries in alphabetical order, and apply the identical edit to the bundled copy so the two files stay byte-identical. Rationale: matches the existing `Bash(bash .claude/lib/bash/<script>.sh*)` form at lines 8-10. Rejected alternative: a library wildcard `Bash(bash .claude/lib/bash/*)`, which would pre-approve future scripts without review. The abandon command remains gated by the `PreToolUse` hook (see Risks for the unverified precedence point).
- **D4 (assumption): remove the unused `-m` grant.** Delete `"Bash(poetry run python -m *)"` from `.claude/agents/parallel-orchestrator.md` and its bundled copy, rewrite the prose at lines 98-107 to state that the `-m` grant was removed under #791 because no caller uses it and that the `-c` grant remains for the repository-local engine calls in `parallel-add`, `parallel-close`, and `parallel-orchestrate`. Keep `"Bash(poetry run python -c *)"` unchanged. Also add `"Bash(bash .claude/lib/bash/remove-parallel-item.sh*)"` to the agent `tools` list because `parallel-remove` forks into this agent. Rationale: no caller in the agent's caller set uses `python -m` (research searches 1-3).
- **D5 (assumption): out-of-scope items become follow-ups.** The same unbundled-call prose in `.claude/skills/parallel-add/SKILL.md:99,106,148`, `.claude/skills/parallel-close/SKILL.md:49,55,65`, and `.claude/skills/parallel-orchestrate/SKILL.md:634,789,797`, and the `UnknownEnumMemberError` member-list defect at `scripts/dev_tools/_parallel_mutation_errors.py:192` (it lists merge-status members for a non-`state` field), are out of scope and recorded under Rollout & Follow-up. Rationale: #791 scope is `parallel-remove` only; the error-message defect is in the retained Python engine and is independent of the port.
- **D6 (assumption): tier classification.** The new bash files are classified T3 for gate purposes because `quality-tiers.yml` does not exist (FU-763-4, tracked by #734), following #763 D8.
- **D7 (assumption): `--at` default.** `entry` accepts `--at <timestamp>`; when omitted it defaults to `date -u +%Y-%m-%dT%H-%M`, following the drift entry point's `-At` default (#763 spec line 111). The skill text passes `--at` explicitly where the clock seam value is known.

## Scope & Non-Goals

- In scope: FU-763-5, FU-763-3, FU-763-2, FU-763-1 as resolved by D1-D4 and D6-D7.
- Out of scope / non-goals:
  - FU-763-4 (`quality-tiers.yml` absent), tracked by #734.
  - Porting `parallel-add`, `parallel-close`, or `parallel-orchestrate` engine calls (D5).
  - Fixing `_parallel_mutation_errors.py:192` (D5).
  - Removing or changing the `Bash(poetry run python -c *)` grant.
  - Deleting `scripts/dev_tools/parallel_mutation_protocol.py` or its helper modules.
  - Changing the abandon-gate hook logic.
  - Switching `parallel-remove/SKILL.md:111` from ` ```shell ` to ` ```bash ` (permitted after D1 but not required).
- Explicitly excluded systems: `.github/` Copilot surface and `.codex/` (no settings or agent copies exist there for these files).

## Proposed Fix

### Design summary

| Follow-up | Change |
| --- | --- |
| FU-763-5 | `skill_bundle_contract.py:52,64`: `\s+` after the verb becomes `[ \t]+`; comment at line 51 updated. |
| FU-763-3 | New `parallel-mutation.sh` library and `remove-parallel-item.sh` entry script; `parallel-remove/SKILL.md` steps 2, 3, 6 invoke the entry script; bundle copies and `core.json` registration. |
| FU-763-2 | Two allow entries in both `settings.json` copies. |
| FU-763-1 | `-m` grant removed from both agent copies; prose updated; remove-script tool grant added. |

### Boundaries and invariants to preserve

- `scripts/dev_tools/skill_bundle_contract.py` remains under 500 lines (target: unchanged at 486).
- Every `.claude` file changed has a byte-identical bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`.
- `parallel-remove/SKILL.md` keeps exactly one line containing both `abandon-parallel-item.sh` and `--` (`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py:53,215-241`). The new script name does not contain `abandon-parallel-item.sh`, and new invocation lines do not mention it.
- No new invocation passes the token pair `--disposition abandon` or `--disposition=abandon`.
- The new bash files contain no Python invocation (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans `.claude/lib`).
- The Python engine's observable behavior is unchanged.

### Dependencies or blocked work

- None blocking. The bash port depends on the existing `parallel-common.sh` and `parallel-cohorts.sh` libraries.

### Implementation strategy

#### Files/modules to change

See "Files Expected to Be Written" below.

#### Functions/classes/CLI commands impacted

- `scripts/dev_tools/skill_bundle_contract.py`: `_INVOCATION_PATTERNS[0]`, `_PYTHON_PATH_PATTERN`; indirectly `_references_in_chunk` and `extract_script_references`.
- New bash functions: `pm_decide_removal`, `pm_recolor_unstarted`, `pm_build_remove_entry`.
- New CLI: `bash .claude/lib/bash/remove-parallel-item.sh decide|recolor|entry`.

#### Data flow and validation changes

- The skill supplies scalar inputs already available in the checkpoint (item key, item state, unstarted keys, edges, pinned keys, generation, cohort values). The script performs no file I/O, no network access, and has no side effects; the only clock read is the default for `--at`.
- Ordering inside each subcommand: argument validation, then rule rejection, then output.

#### Error handling and logging updates

- Success: exit 0, one compact JSON object on stdout.
- Rule rejection: exit 1, one stderr line equal to the Python exception message, including the `Parallel mutation rejected:` prefix (formats in `_parallel_mutation_errors.py`).
- Usage error: exit 2, one stderr line prefixed `PARALLEL_MUTATION_ERROR: usage error:`.

#### Rollback/feature-flag considerations

- No feature flag. Rollback is a revert of the change set; the Python engine remains in place, so reverting the skill text restores the previous behavior.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

```shell
bash .claude/lib/bash/remove-parallel-item.sh decide --item <key> [--state <state>] [--removal-disposition detach|abandon]
bash .claude/lib/bash/remove-parallel-item.sh recolor --unstarted "<k> ..." [--edges "<a>:<b> ..."] --pinned "<k> ..." --generation <g> --current-cohort <c> --highest-pinned-cohort <h>
bash .claude/lib/bash/remove-parallel-item.sh entry --item <key> --prior-state <state> [--removal-disposition detach|abandon] --recompute true|false --generation <g> [--at <timestamp>]
```

- `decide` stdout: `{"item_key":<k>,"prior_state":"<s>","new_state":"withdrawn","disposition":<"d"|null>,"triggers_recompute":<bool>}`.
  - Omitted `--state` means the key resolves to no `items[]` entry and yields the `UnknownItemError` rejection.
  - `--state` outside `PC_VALID_ITEM_STATES` is a usage error.
  - Unstarted states (`proposed`, `admitted`, `prepared`, `scheduled`): disposition recorded as null even when supplied; `triggers_recompute` true.
  - `in_flight`: disposition required (`InFlightRemovalRequiresDispositionError` text otherwise); `triggers_recompute` false.
  - `withdrawn`, `blocked`: `UnknownItemError` text. `merged`: `MergedItemRemovalRejectedError` text.
- `recolor` stdout: `{"cohort_assignments":{"<k>":<index>,...},"generation":<g+1>}`, keys in ascending numeric order.
  - Coloring of the induced subgraph (edges with both ends unstarted) uses `pcoh_compute_cohorts`.
  - Offset is `highest_pinned_cohort + 1` if any edge joins an unstarted key to a pinned key, otherwise `current_cohort`; index is offset plus the local color index.
  - A key in both unstarted and pinned yields the `UnknownItemError` text for the smallest overlapping key. A negative `current_cohort` yields `current_cohort must be >= 0 per F3 invariant 12; received {n}.`. A duplicate unstarted key yields the `compute_cohorts` error text. An empty unstarted set yields `{}` assignments and generation `g+1`.
- `entry` stdout: the `mutations[]` object in F3 field order `op`, `item_key`, `at`, `prior_state`, `new_state`, `disposition`, `recolor_generation`, with `op` `"remove"` and `recolor_generation` equal to `g+1` when `--recompute true`, otherwise `g`. Rejections follow `MutationEntry.__post_init__` (`_parallel_mutation_models.py:385-472`): negative generation, non-positive key, out-of-enum state, missing or invalid disposition on an in-flight remove, any disposition on a non-in-flight remove.
- Declared divergences (stated in the script header and in both parity lanes):
  - A disposition outside `detach abandon` is a usage error (exit 2) instead of the Python `UnknownEnumMemberError` text, which lists merge-status members (D5 defect).
  - `at` is a caller-supplied string instead of a `datetime`.
  - Option abbreviations are rejected.

#### Required configuration keys and defaults

- `.claude/settings.json` `permissions.allow`: the two entries named in D3.
- `--at` default per D7.

#### Backward-compatibility expectations

- The guard extracts a superset of the references it extracted before for same-line invocations and stops matching across newlines. No current `SKILL.md` depends on a cross-newline match (research search).
- The Python engine API is unchanged.

#### Performance constraints

- No measurable constraint. Each subcommand runs in a single bash process without external network or file access.

## Functional Requirements

- FR-1: `extract_script_references` extracts a `bash`/`sh`/`source <path>` invocation that is the first line inside a ` ```bash ` or ` ```sh ` fence.
- FR-2: `extract_script_references` extracts a `python <path>.py` invocation that is the first line inside a ` ```python ` fence.
- FR-3: The verb and the path must be separated by horizontal whitespace only; a verb at the end of a line followed by a path on the next line yields no reference.
- FR-4: `remove-parallel-item.sh decide` reproduces `decide_removal` outputs and rejection messages for every item state and disposition combination, subject to the declared divergences.
- FR-5: `remove-parallel-item.sh recolor` reproduces `recolor_unstarted` outputs and rejection messages, including both offset rules and the empty-set case.
- FR-6: `remove-parallel-item.sh entry` reproduces `build_remove_entry` field values (other than `at`, which echoes `--at`) and `MutationEntry` rejection conditions.
- FR-7: `parallel-remove/SKILL.md` steps 2, 3 and 6 invoke the bundled entry script and name `parallel_mutation_protocol.py` at most as a parity citation without an invocation verb.
- FR-8: Settings and agent permission surfaces match D3 and D4.

## Non-Functional Requirements

- NFR-1 (parity): bash behavior matches the Python functions for outputs, exit status classes, and rejection message text, verified by a shared fixture corpus run through a bats parity lane and a Python parity lane; each lane fails on an empty corpus and enforces a fixture-count floor.
- NFR-2 (file size): every new or changed production, test, or script file stays at or below 500 lines.
- NFR-3 (bundle parity): every changed `.claude` file and every new `.claude/lib/bash` file has a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and new library files are registered in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- NFR-4 (test hygiene): no test creates or uses temporary files; no test uses real wall-clock waits; the `--at` default is tested through a checked-in `date` shim directory or by asserting format only.
- NFR-5 (coverage): Python line coverage >= 85% and branch coverage >= 75% for changed Python modules; bash line coverage >= 85% for `parallel-mutation.sh` and `remove-parallel-item.sh` measured by kcov in CI (`.github/workflows/_shell-coverage.yml`). No branch threshold applies to bash.
- NFR-6 (payload portability): the bundled entry script runs with the restricted shim PATH `tests/fixtures/parallel_payload_path/` when `--at` is supplied.
- NFR-7 (shell standards): new bash files pass `scripts/bash/shell-qc.sh format` and `check` (shfmt and shellcheck).

## Assumptions, Constraints, Dependencies

- Assumptions:
  - D1-D7 are operator-delegated decisions recorded as assumptions.
  - `issue.md` in this feature folder is the unpromoted draft potential file that `new_active_feature_folder` moved into the folder; its "Status: Draft. Not promoted." line and the FU-763-4 entry are historical text, and the scope of #791 is FU-763-1, -2, -3, -5.
  - A `PreToolUse` hook `deny` takes precedence over a project allow rule. The fetched Claude Code hooks documentation did not state this explicitly (research, FU-763-2); #763 D6 relied on the same assumption. The hook decision is independent of settings, so the existing abandon-gate Pester suites remain the evidence.
  - `--removal-disposition abandon` does not contain the substring `--disposition abandon` and is outside the abandon gate (string reasoning; verified by the hook test in AC-13).
- Constraints:
  - `skill_bundle_contract.py` has 14 lines of headroom.
  - Command text containing `bash`, `pwsh`, or `wsl` may be refused by the worktree isolation guard in a local agent worktree; local execution uses `sh <file>`, and the CI shell-coverage workflow is the authoritative bats/kcov gate.
  - Bundle mirrors are maintained by hand; no sync script exists.
- External dependencies: none new. Bash, bats, kcov, shfmt, shellcheck, pytest, Pester, and Jest are already used.

## Data / API / Config Impact

- User-facing: `parallel-remove` steps 2, 3 and 6 become runnable in a consumer repository without Poetry. The abandon and remove scripts no longer prompt for permission.
- Data: no checkpoint schema change. The JSON emitted by the new script mirrors existing Python result fields.
- Logging: none beyond the stderr lines defined above.
- Compatibility: the agent loses the `poetry run python -m` grant; no caller uses it.

## Test Strategy

- Python regression tests (`tests/scripts/dev_tools/test_skill_bundle_contract.py`):
  - Parametrized over fence words `bash`/`sh` and verbs `bash`/`sh`/`source`, text ` ```<fence>\n<verb> scripts/tools/example.sh --flag\n``` ` yields `("scripts/tools/example.sh",)`. Must fail against the pre-fix pattern.
  - ` ```python\npython scripts/tools/example.py\n``` ` yields `("scripts/tools/example.py",)`. Must fail against the pre-fix pattern.
  - Negative: `Use bash\nscripts/tools/example.sh` yields `()`.
- Real-repository tests (`tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`): `parallel-plan` extracts `.claude/lib/bash/compute-cohorts.sh`; `parallel-remove` extracts `.claude/lib/bash/remove-parallel-item.sh` and contains no `parallel_mutation_protocol` text other than a permitted citation (see AC-5).
- Bash unit tests (`tests/shell/parallel_mutation_remove.bats`): every subcommand, every rejection row, every usage error, the `--at` default, and function-level cases by sourcing the library.
- Parity: `tests/shell/parallel_mutation_remove_parity.bats` and `tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py` over `tests/fixtures/parallel_mutation_remove/*.json`.
- Payload-only: one case in `tests/shell/parallel_payload_only.bats`.
- Manifest membership: `tests/shell/parallel_bash_manifest_membership.bats` entry-point list includes `remove-parallel-item.sh`.
- Hook scoping: `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` case for `--removal-disposition abandon`.
- Toolchain commands:
  - Python: `poetry run black`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest ... --cov --cov-branch` (bare `--cov`; coverage source is configured in `pyproject.toml:119-120`).
  - Bash: `scripts/bash/shell-qc.sh format`, `check`, `test --coverage`.
  - PowerShell: Pester for the hook test.
  - TypeScript (only if the optional Jest list is edited): format, lint, type-check, Jest.
- Manual validation: none required.

## Acceptance Criteria

- [ ] AC-1: A new parametrized test in `tests/scripts/dev_tools/test_skill_bundle_contract.py` asserts that a `bash`, `sh`, or `source` invocation of `scripts/tools/example.sh` placed on the first line inside a ` ```bash ` or ` ```sh ` fence is returned by `extract_script_references`; evidence shows the test failing against the unmodified line-52 pattern and passing after the change to `[ \t]+`.
- [ ] AC-2: A new test in `tests/scripts/dev_tools/test_skill_bundle_contract.py` asserts that `python scripts/tools/example.py` on the first line inside a ` ```python ` fence is returned by `extract_script_references`; evidence shows it failing against the unmodified line-64 pattern and passing after the change to `[ \t]+`.
- [ ] AC-3: A new negative test asserts that a verb at the end of one line followed by a script path on the next line (`Use bash\nscripts/tools/example.sh`) yields no reference.
- [ ] AC-4: All pre-existing tests in `tests/scripts/dev_tools/test_skill_bundle_contract.py`, `test_skill_bundle_contract_repo.py`, `test_skill_bundle_contract_evaluation.py`, `test_skill_bundle_contract_cli.py`, and `test_parallel_abandon_token_seam.py` pass unmodified, and `scripts/dev_tools/skill_bundle_contract.py` remains at or below 500 lines.
- [ ] AC-5: `.claude/skills/parallel-remove/SKILL.md` steps 2, 3 and 6 contain no call instruction for `decide_removal`, `recolor_unstarted`, or `build_remove_entry` and do not name `scripts/dev_tools/parallel_mutation_protocol.py` as the means of executing those steps; each of those steps contains a `bash .claude/lib/bash/remove-parallel-item.sh` invocation (subcommands `decide`, `recolor`, and `entry` respectively); any remaining mention of the Python module is a parity citation without an invocation verb.
- [ ] AC-6: A real-repository test in `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` asserts that `extract_script_references` on `parallel-remove/SKILL.md` contains `.claude/lib/bash/remove-parallel-item.sh` and on `parallel-plan/SKILL.md` contains `.claude/lib/bash/compute-cohorts.sh`.
- [ ] AC-7: `parallel-remove/SKILL.md` keeps exactly one line containing both `abandon-parallel-item.sh` and `--`, and no line in any changed file passes `--disposition abandon` or `--disposition=abandon` to `remove-parallel-item.sh`; `test_parallel_abandon_token_seam.py` passes.
- [ ] AC-8: `tests/shell/parallel_mutation_remove.bats` covers, for `decide`: each unstarted state, `in_flight` with `detach` and with `abandon`, `in_flight` without a disposition, `withdrawn`, `blocked`, `merged`, omitted `--state`, a disposition supplied for an unstarted item, an out-of-enum state, and an out-of-enum disposition; each case asserts exit status and the exact stdout or stderr line.
- [ ] AC-9: `tests/shell/parallel_mutation_remove.bats` covers, for `recolor`: an empty unstarted set, no unstarted-to-pinned edge (offset `current_cohort`), at least one unstarted-to-pinned edge (offset `highest_pinned_cohort + 1`), a key in both unstarted and pinned, a negative `current_cohort`, a duplicate unstarted key, and malformed edge or key input; and for `entry`: recompute true and false, an in-flight remove with and without a disposition, a disposition on a non-in-flight remove, a negative generation, a non-positive key, an explicit `--at`, and the default `--at` format; and for the CLI: a missing subcommand, an unknown subcommand, an unknown option, and an abbreviated option each exit 2 with a `PARALLEL_MUTATION_ERROR: usage error:` line.
- [ ] AC-10: The parity lanes `tests/shell/parallel_mutation_remove_parity.bats` and `tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py` run the same corpus `tests/fixtures/parallel_mutation_remove/*.json` against the bash script and the Python functions `decide_removal`, `recolor_unstarted`, and `build_remove_entry`; both pass, both fail on an empty corpus, both enforce a fixture-count floor, the corpus contains at least one success and one rejection fixture for each subcommand, and the declared divergences are listed in the script header and in both lanes.
- [ ] AC-11: `.claude/lib/bash/parallel-mutation.sh` and `.claude/lib/bash/remove-parallel-item.sh` exist, each at or below 500 lines, contain no Python invocation, pass `scripts/bash/shell-qc.sh format` and `check`, have byte-identical copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/`, are registered in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and `tests/shell/parallel_bash_manifest_membership.bats` (with `remove-parallel-item.sh` added to its entry-point list) passes.
- [ ] AC-12: `tests/shell/parallel_payload_only.bats` contains a case that runs the bundled `remove-parallel-item.sh` with `PATH=tests/fixtures/parallel_payload_path` and an explicit `--at`, and the case passes.
- [ ] AC-13: A case in `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` asserts that `bash .claude/lib/bash/remove-parallel-item.sh decide --item 5 --state in_flight --removal-disposition abandon` is out of scope for the abandon gate, and the existing abandon-gate Pester suites pass.
- [ ] AC-14: `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled` and `::test_known_unbundled_references_are_not_stale` pass for all skills.
- [ ] AC-15: `.claude/settings.json` `permissions.allow` contains `"Bash(bash .claude/lib/bash/abandon-parallel-item.sh*)"` and `"Bash(bash .claude/lib/bash/remove-parallel-item.sh*)"`, contains no `Bash(bash .claude/lib/bash/*)` wildcard entry, the bundled `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` is byte-identical to it, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
- [ ] AC-16: Neither `.claude/agents/parallel-orchestrator.md` nor its bundled copy contains the text `poetry run python -m`; both still contain `"Bash(poetry run python -c *)"` and contain `"Bash(bash .claude/lib/bash/remove-parallel-item.sh*)"`; the explanatory prose states that the `-m` grant was removed under #791 and why the `-c` grant remains; the two files are byte-identical; and `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` passes.
- [ ] AC-17: The Python toolchain loop (black, ruff, pyright, pytest with `--cov --cov-branch`) passes in a single pass for all changed Python files, with line coverage >= 85% and branch coverage >= 75% for `scripts/dev_tools/skill_bundle_contract.py` and no coverage regression on changed lines.
- [ ] AC-18: The bash toolchain loop (`scripts/bash/shell-qc.sh format`, `check`, `test --coverage`) passes in CI (`.github/workflows/_shell-coverage.yml`), with kcov line coverage >= 85% for `.claude/lib/bash/parallel-mutation.sh` and `.claude/lib/bash/remove-parallel-item.sh`.
- [ ] AC-19: No new or changed test creates or uses a temporary file or a real wall-clock wait.
- [ ] AC-20: Follow-ups for the D5 items (`parallel-add`, `parallel-close`, `parallel-orchestrate` engine-call prose, and the `_parallel_mutation_errors.py:192` member-list defect) are recorded in the feature folder or as promoted potentials, each citing the file and lines listed in D5.

## Risks & Mitigations

- Risk: restricting the guard whitespace drops a reference that relied on a cross-newline match. Mitigation: the research search found none in `SKILL.md` files; AC-4 and AC-14 run the full real-repository guard.
- Risk: bash parity drift from the Python engine. Mitigation: shared fixture corpus with two lanes and count floors (AC-10).
- Risk: the new option name enters the abandon gate. Mitigation: `--removal-disposition` naming and the hook scoping test (AC-13).
- Risk: an allow entry for the abandon script bypasses the abandon gate if allow rules outrank hook denials. Mitigation: the hook decision is computed independently of settings and the gate's Pester suites remain green; precedence is recorded as an unverified assumption.
- Risk: bundle mirrors diverge because they are maintained by hand. Mitigation: byte-identity tests (AC-11, AC-15, AC-16).
- Risk: local bats/kcov execution is blocked in an agent worktree. Mitigation: `sh <file>` locally; CI shell-coverage workflow is the authoritative gate (AC-18).
- Rollback: revert the change set; the Python engine and previous skill text are restorable from history.

## Files Expected to Be Written

FU-763-5:
- `scripts/dev_tools/skill_bundle_contract.py`
- `tests/scripts/dev_tools/test_skill_bundle_contract.py`
- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`

FU-763-3:
- `.claude/lib/bash/parallel-mutation.sh` (new)
- `.claude/lib/bash/remove-parallel-item.sh` (new)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-mutation.sh` (new, byte-identical)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/remove-parallel-item.sh` (new, byte-identical)
- `.claude/skills/parallel-remove/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-remove/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `tests/shell/parallel_mutation_remove.bats` (new)
- `tests/shell/parallel_mutation_remove_parity.bats` (new)
- `tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py` (new)
- `tests/fixtures/parallel_mutation_remove/*.json` (new corpus)
- `tests/fixtures/parallel_mutation_remove_date_path/date` (new shim, only if the `--at` default is tested through a shim)
- `tests/shell/parallel_payload_only.bats`
- `tests/shell/parallel_bash_manifest_membership.bats`
- `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`
- Optional: `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`

FU-763-2 (plus the remove entry from FU-763-3):
- `.claude/settings.json`
- `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`

FU-763-1 (plus the remove tool entry from FU-763-3):
- `.claude/agents/parallel-orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md`

Feature documents: `spec.md`, `plan.*.md`, and evidence under `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/evidence/<kind>/`.

## Rollout & Follow-up

- Release: ships with the next extension package that includes the bundled `.claude` payload; no migration.
- Follow-ups to record (D5):
  - Port the engine calls in `.claude/skills/parallel-add/SKILL.md:99,106,148`, `.claude/skills/parallel-close/SKILL.md:49,55,65`, and `.claude/skills/parallel-orchestrate/SKILL.md:634,789,797` to bash, reusing `parallel-mutation.sh`; reassess the `Bash(poetry run python -c *)` grant afterwards.
  - Fix `UnknownEnumMemberError` at `scripts/dev_tools/_parallel_mutation_errors.py:192` so a non-`state` field lists its own members.
  - FU-763-4 remains with #734.
- Links: issue #791; parent issue #763 and its spec `docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/spec.md` (D4, D6, D7, D8); research note listed in the header.
