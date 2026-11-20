# Research — Issue #890: Parallel skills' remaining Python-engine calls and the `UnknownEnumMemberError` member list

- **Issue:** #890 (bug, work mode `minor-audit`)
- **Branch:** `bug/parallel-skills-python-engine-calls-and-enum-error-members-890` (based on `origin/main` 2ef8d361e)
- **Parallel run:** `bug-burndown-2026-10-11` (preparation run)
- **Researched:** 2026-10-11T12-35
- **Precedent:** #791 (`docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/`)

All line numbers below were re-derived against the current worktree tree with Read and Grep. No command was executed; toolchain commands are reported as shapes only.

## Findings Summary

1. Eleven lines in the three repository skills still name the Python engine as the means of execution: `parallel-add` 100, 101, 108, 150; `parallel-close` 48, 49, 55, 65; `parallel-orchestrate` 666, 821, 829. The bundled mirrors carry the same eleven lines at the same numbers. `parallel-remove/SKILL.md:152` is a permitted parity citation (already asserted by `test_skill_bundle_contract_repo.py:132-135`) and is out of scope.
2. Of the six Python functions the skills call, only `recolor_unstarted` has a bash port today (`pm_recolor_unstarted`, `.claude/lib/bash/parallel-mutation.sh:210-269`, exposed as `remove-parallel-item.sh recolor`). `decide_admission`, `build_add_entry`, `decide_close`, `build_close_entry`, and `build_requeue_entry` have no bash equivalent.
3. `.claude/agents/parallel-orchestrator.md:16` grants `"Bash(poetry run python -c *)"`, and its prose at lines 98-102 justifies the grant solely by the engine calls in `parallel-add`, `parallel-close`, and `parallel-orchestrate`. No file under `.claude/` prescribes a `python -c` invocation. No test pins the `-c` grant. Removal is safe once the three skills are ported.
4. FU-791-2 is confirmed: `_parallel_mutation_errors.py:192` selects `VALID_MERGE_STATUS` for every field other than `state`; the only non-`state`/`merge_status` raise site is `parallel_mutation_protocol.py:412` (`"disposition"`). No Python test asserts the message text. The bash library reproduces the same defect at `.claude/lib/bash/parallel-mutation.sh:143` (prints `$PC_VALID_MERGE_STATUS` for a disposition). That branch is unreachable through the CLI (the CLI raises a usage error first, declared divergence 1) and is not exercised by any bats case.
5. Mirror/bundle parity is enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (every `.claude` file) and, for `.claude/lib/bash/*.sh`, by `tests/shell/parallel_bash_manifest_membership.bats` (byte identity + `core.json` membership). New `.claude/lib/bash` files must be registered in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
6. The residual risks accepted under #791 (`spec.md:282`; `feature-audit.2026-10-10T09-05.md:74`) are unaffected by the recommended change and must be carried forward unchanged.

## 1. Remaining Python-engine references (current text and line numbers)

### 1.1 Repository skills

`.claude/skills/parallel-add/SKILL.md`:

| Line | Text |
| --- | --- |
| 99-101 | ``4. **Decide admission.** Call`` / `` `decide_admission(candidate, conflict_edges, in_flight, current_cohort_members=current_cohort_members)` `` / ``from `scripts/dev_tools/parallel_mutation_protocol.py`.`` |
| 102, 106 | Outcome names `ADMIT_CURRENT_COHORT` and `DEFER_AND_RECOLOR` (Python enum member names; values are `admit_current_cohort` / `defer_and_recolor`, `_parallel_mutation_models.py:135-136`). |
| 107-108 | ``cohort, pinned or not-yet-launched. Defer it to a future cohort and recolor by calling`` / `` `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort, highest_pinned_cohort=highest_pinned_cohort)`. `` |
| 133-134 | ``Write `RecolorResult.cohort_assignments` into `cohorts[]` and set the top-level `recolor_generation` to `RecolorResult.generation`.`` (Python value-object names) |
| 149-150 | ``6. **Append exactly one `mutations[]` entry**, at admission-decision time, built by`` / `` `build_add_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`: `` |
| 160 | ```at` timestamp comes from the engine's injected clock seam.`` |

`.claude/skills/parallel-close/SKILL.md`:

| Line | Text |
| --- | --- |
| 48-52 | ``2. **Gate the close on no item being in flight.** Call `decide_close(items)` from`` / `` `scripts/dev_tools/parallel_mutation_protocol.py`. It raises the dedicated rejection exception `` / ``carrying EVERY in-flight key, ...`` |
| 54-55 | ``3. **Append exactly one run-scoped `mutations[]` entry** for a successful close, built by`` / `` `build_close_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`: `` |
| 62 | ```at` timestamp comes from the engine's injected clock seam.`` |
| 65 | ``UNCHANGED and `cohorts[]` is not rewritten. Do not call `recolor_unstarted` as part of a close.`` |

`.claude/skills/parallel-orchestrate/SKILL.md`:

| Line | Text |
| --- | --- |
| 665-667 | ``The decision logic for all three commands is the pure engine`` / `` `scripts/dev_tools/parallel_mutation_protocol.py`. It decides; it never applies. Item keys are `` / ``integers (`items[].issue_num`) everywhere on this surface.`` |
| 706-707 | ``the tie-break is reimplemented by the mutation engine, and the offset is applied entirely inside the mutation engine's own recolor function.`` (descriptive; no function name) |
| 771 | ``Every `at` timestamp comes from the engine's injected clock seam;`` |
| 785 | ``The predicate is `is_closed_mode_complete` in the mutation engine.`` (descriptive; not in the issue's list) |
| 820-821 | ``later-started item of a newly conflicting pair, the requeue is recorded through the mutation`` / ``engine's `build_requeue_entry` constructor and the recolor through `recolor_unstarted`:`` |
| 828-830 | ``shape is the six-argument form`` / `` `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort, highest_pinned_cohort=highest_pinned_cohort)`, `` / ``where `current_cohort` and `highest_pinned_cohort` are both required and keyword-only.`` |

Additional Python-only seam names in `parallel-orchestrate` that are not engine calls of `parallel_mutation_protocol.py` and are outside this issue: `has_unresolved_drift(events, items)` at line 1064 (`scripts/dev_tools/parallel_drift_detection.py:244`) and `request_requeue_via_recolor` at line 1072 (`scripts/dev_tools/parallel_drift_halt.py:204`). Neither has a PowerShell or bash port under `.claude/lib/` (Grep for `requeue`, `unresolved`, `quiesce` in `.claude/lib/` returned no match). See Open Risks.

### 1.2 Bundled mirrors

`extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-{add,close,orchestrate}/SKILL.md` carry the identical lines at identical numbers (Grep output: add 100, 101, 108, 150; close 48, 49, 55, 65; orchestrate 666, 821, 829). `test_bundled_claude_payload_contains_all_repo_runtime_contracts` currently passes on this identity.

### 1.3 Other `.claude` references

- `.claude/agents/parallel-orchestrator.md:16` — `  - "Bash(poetry run python -c *)"`; prose lines 98-102: "The inline-code (`-c`) grant remains for the repository-local engine calls that `parallel-add`, `parallel-close`, and `parallel-orchestrate` still make. ..." Bundled mirror: same line 16.
- `.claude/skills/parallel-remove/SKILL.md:152-153` — permitted parity citation ("retained as the parity reference for this entry point and is not invoked on this path"). Out of scope.
- `.claude/lib/bash/parallel-mutation.sh:9-13` and `.claude/lib/bash/remove-parallel-item.sh:30-32` — parity-reference header comments (not invocations).
- No match in `.claude/rules/`, `.github/`, or `.codex/` (Grep over the repository excluding `docs/`, `tests/`, `scripts/` returned only the files listed above plus `pyproject.toml:109`, a ruff per-file ignore for a test file).

### 1.4 Overlap zones to avoid

- `parallel-add` step 2 occupies lines 53-64 (#885 inserts text there). The edits for this issue start at step 4 (line 99). No textual overlap; line numbers after step 2 will shift if #885 merges first.
- `parallel-orchestrate` child-DONE CI acceptance passage is lines 371-385 (#899 edits it). The edits for this issue are at 665-667, 771, 785 (optional), 820-830. No textual overlap.

## 2. `.claude/lib/bash/` inventory and port gap

### 2.1 Files and public surface (current)

| File | Lines | Role / public functions or CLI |
| --- | --- | --- |
| `parallel-common.sh` | — | Shared constants and helpers: `PC_VALID_ITEM_STATES` (line 25, comma-space separated), `PC_VALID_MERGE_STATUS` (28), `PC_MERGED_MERGE_STATUSES` (40), `pc_enforce_c_locale`, `pc_repr`, `pc_contains_word`, `pc_enum_members_contains`, integer predicates. No disposition constant. |
| `parallel-cohorts.sh` | — | `pcoh_compute_cohorts`, `pcoh_compute_concurrency_batches`, `pcoh_split_words`; results in `PCOH_RESULT`/`PCOH_ERROR`. |
| `parallel-mutation.sh` | 319 | Sourceable library: `pm_decide_removal` (109-157), `pm_recolor_unstarted` (210-269), `pm_build_remove_entry` (271-318), helpers `pm_fail`, `pm_json_string`, `pm_json_nullable_string`, `pm_unknown_item_message`, `pm_entry_contract_message` (101-107, **hard-codes op `'remove'`**), `pm_smallest_overlap`, `pm_render_assignments`. Constants `PM_REJECTION_PREFIX`, `PM_UNSTARTED_STATES`, `PM_PINNED_STATE`, `PM_VALID_DISPOSITIONS="detach abandon"`. |
| `remove-parallel-item.sh` | 252 | CLI. `decide --item <key> [--state <state>] [--removal-disposition detach\|abandon]`; `recolor --unstarted "<k> ..." [--edges "<a>:<b> ..."] --pinned "<k> ..." --generation <g> --current-cohort <c> --highest-pinned-cohort <h>`; `entry --item <key> --prior-state <state> [--removal-disposition ...] --recompute true\|false --generation <g> [--at <timestamp>]`. Exit 0 = one JSON line on stdout; 1 = reference rejection message on stderr; 2 = `PARALLEL_MUTATION_ERROR: usage error: ...`. Parser helpers `rpi_parse_options`, `rpi_require`, `rpi_integer`, `rpi_integer_list`, `rpi_edge_list`, `rpi_disposition`, `rpi_emit` (56-164). Sourceable: main guarded at 247-251. |
| `abandon-parallel-item.sh` | — | CLI for the destructive abandon side effects (hook-gated). |
| `compute-cohorts.sh`, `compute-concurrency-batches.sh` | — | Welsh-Powell and batching CLIs. |
| `validate-parallel-manifest.sh`, `parallel-manifest-validate.sh`, `parallel-items-validate.sh`, `parallel-yaml-scan.sh`, `parallel-yaml-emit.sh` | — | Manifest validation. Note: `parallel-manifest-validate.sh` also uses a `pm_` function prefix (`pm_parse_manifest` etc.); it is not sourced alongside `parallel-mutation.sh` today. |
| `parallel-lane-assertion.sh`, `report-lane-assertion.sh` | — | Lane assertion. |

### 2.2 Equivalence matrix

| Python function | Bash equivalent today |
| --- | --- |
| `recolor_unstarted` | Yes — `pm_recolor_unstarted`; CLI `remove-parallel-item.sh recolor` |
| `decide_admission` | No |
| `build_add_entry` | No |
| `decide_close` | No |
| `build_close_entry` | No |
| `build_requeue_entry` | No |

### 2.3 Python semantics of the missing functions (port specification inputs)

Common rules (from `_parallel_mutation_models.py:385-472` `MutationEntry.__post_init__`, `_parallel_mutation_errors.py:199-229`, `_parallel_state_records.py:49-56`):

- Field order of every entry: `op, item_key, at, prior_state, new_state, disposition, recolor_generation` (rendered compact, as in the remove corpus).
- Validation order: `op` membership; then `recolor_generation` non-negative (computed **after** stamping, `_parallel_mutation_entries.py:58-77`); then `item_key` (null for `close`; positive int for `add`/`remove`/`requeue`); then state-field null rules; then disposition.
- Contract message: `Parallel mutation entry rejected: <field> <repr(value)> violates the F3 mutations[] contract for op '<op>'.` The bash helper `pm_entry_contract_message` must be generalized to take the op.
- `at` comes from the injected clock in Python; the bash port follows #791 divergence 2 (`--at` string, default current UTC minute `yyyy-MM-ddTHH-mm`).

`decide_admission(candidate, conflict_edges, in_flight, *, current_cohort_members)` (`parallel_mutation_protocol.py:121-197`):

- Inputs: candidate key (int); edges `(int, int)` over all items, direction irrelevant; `in_flight` set; `current_cohort_members` set (full current-cohort membership including scheduled members).
- Rule: `blocking = in_flight | current_cohort_members`. If any edge has one endpoint equal to `candidate` and the other in `blocking`, outcome `defer_and_recolor`; otherwise `admit_current_cohort`. A self-edge `(c, c)` with `c` in `blocking` defers. The scan stops at the first match; the result is order-independent.
- Output: `AdmissionDecision(candidate, outcome)`; `triggers_recompute` is True only for `defer_and_recolor` (`_parallel_mutation_models.py:237-246`). Proposed JSON: `{"candidate":<k>,"outcome":"admit_current_cohort"|"defer_and_recolor","triggers_recompute":false|true}`.
- Errors: none (docstring line 172-175). An unknown candidate simply admits. Consequence: the parity corpus cannot carry an exit-1 fixture for this subcommand; the #791 rule "one success and one rejection fixture per subcommand" must be scoped accordingly.

`build_add_entry(item_key, *, deferred, current_generation, clock)` (`_parallel_mutation_entries.py:80-130`):

- Output: `{"op":"add","item_key":<k>,"at":"<at>","prior_state":null,"new_state":"scheduled","disposition":null,"recolor_generation":<g or g+1>}`; `g+1` when `deferred` is true.
- Errors (in order): stamped generation `< 0` -> `... recolor_generation <n> violates ... for op 'add'.` (note `g = -1` with `deferred=true` stamps 0 and **passes**, as `pm_build_remove_entry` already reproduces for remove); `item_key <= 0` -> `... item_key <k> violates ... for op 'add'.`

`decide_close(items)` (`parallel_mutation_protocol.py:429-457`; `_parallel_mutation_errors.py:132-160`):

- Input: mapping `issue_num -> ItemRecord`. `ItemRecord` construction (`_parallel_mutation_models.py:166-187`) rejects `issue_num <= 0` (`UnknownItemError`: `Parallel mutation rejected: item key <k> does not resolve to a tracked items[].issue_num.`), a state outside `VALID_ITEM_STATES` (`UnknownEnumMemberError` `state`), and a merge status outside `VALID_MERGE_STATUS`.
- Rule: collect every key whose state is `in_flight`. Non-empty -> reject with `Parallel mutation rejected: close requires no item in flight; still in flight: [<k1>, <k2>].` (keys sorted ascending, Python list repr with `", "` separators, e.g. `[7]`, `[3, 7]`). Empty -> return None (close permitted).
- Proposed CLI input: `--items "<k>:<state> ..."` so the state-based gate stays inside the engine and state-enum validation is reproduced; a duplicate key should be a usage error (a Python mapping cannot hold duplicates). Proposed success JSON: `{"close_permitted":true}` (Python lane renders the same literal on a normal return).

`build_close_entry(*, current_generation, clock)` (`_parallel_mutation_entries.py:178-210`):

- Output: `{"op":"close","item_key":null,"at":"<at>","prior_state":null,"new_state":null,"disposition":null,"recolor_generation":<g>}`.
- Errors: `g < 0` -> `Parallel mutation entry rejected: recolor_generation <g> violates the F3 mutations[] contract for op 'close'.` The docstring's `Raises: None.` (line 198-199) is inaccurate for a negative generation; `MutationEntry` raises.

`build_requeue_entry(item_key, *, current_generation, clock)` (`_parallel_mutation_entries.py:213-250`):

- Output: `{"op":"requeue","item_key":<k>,"at":"<at>","prior_state":"in_flight","new_state":"blocked","disposition":null,"recolor_generation":<g+1>}`.
- Errors (in order): stamped `g+1 < 0` (i.e. `g <= -2`) -> `recolor_generation`; `item_key <= 0` -> `item_key`; both with op `'requeue'`.

`recolor_unstarted` is already specified and ported (`parallel-mutation.sh:210-269`); its check order is overlap -> negative `current_cohort` -> pinned barrier -> induced coloring, and its output is `{"cohort_assignments":{"<k>":<abs index>,...},"generation":<g+1>}` with keys ascending.

## 3. Existing bats tests, corpora, and CI

- Unit: `tests/shell/parallel_mutation_remove.bats` (sources `parallel-mutation.sh`; CLI and function-level cases, e.g. lines 269-287). No case exercises `pm_decide_removal` with an out-of-enum disposition at function level; the CLI case at line 113-114 asserts a usage error.
- Parity (bash lane): `tests/shell/parallel_mutation_remove_parity.bats` — iterates `tests/fixtures/parallel_mutation_remove/*.json`, floor 15, reads fixtures through `${PARALLEL_PARITY_PYTHON:-python3}` (harness-only dependency).
- Parity (Python lane): `tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py` — maps each fixture's `argv` to direct calls of `decide_removal`, `recolor_unstarted`, `build_remove_entry`; asserts floor 15, the exact stem set `REQUIRED_CASES` (lines 64-82), and one exit-0 and one exit-1 fixture per subcommand.
- Corpus: `tests/fixtures/parallel_mutation_remove/` — 15 JSON fixtures, shape `{"case","subcommand","argv":[...],"expected":{"exit_code","stdout","stderr"}}` (e.g. `entry-negative-generation.json`). No usage-error fixtures.
- Payload portability: `tests/shell/parallel_payload_only.bats` (`run_payload` helper, lines 49-55; remove cases at 156-163) runs bundled entry points with `PATH=tests/fixtures/parallel_payload_path` (shims `sort`, `cut`, `cat`, `dirname`; no interpreter).
- Membership/mirror: `tests/shell/parallel_bash_manifest_membership.bats` — discovery floor 11 (line 21), `core.json` membership (43-54), byte identity via `cmp -s` (56-71), no bundled-only file (73-82), and a fixed entry-point list "the six CLI entry points" (84-89).
- Other parallel bats suites: `parallel_abandon(.|_parity).bats`, `parallel_cohorts(.|_parity).bats`, `parallel_common.bats`, `parallel_items_validate.bats`, `parallel_lane_assertion(.|_parity).bats`, `parallel_manifest_(parity|validate).bats`, `parallel_yaml_subset.bats`.
- CI: `.github/workflows/ci.yml:26-27` job `shell-coverage` calls `.github/workflows/_shell-coverage.yml`, job name `Shell Coverage (Bats + kcov)`; steps `bash scripts/bash/shell-qc.sh check` (shfmt + shellcheck) and `bash scripts/bash/shell-qc.sh test --coverage` (kcov include pattern covers `.claude/lib/bash`, `scripts/bash/shell_qc_lib.sh:350`; artifact `shell-coverage` from `artifacts/pester/kcov/**`). kcov prints a summary; no per-file threshold is enforced in the script, so per-file >= 85% must be read from the CI artifact.
- Operator constraint: bats, kcov, shfmt, shellcheck, Pester, and PSScriptAnalyzer results come only from PR CI. The plan must not run `sh`/`bash`/`pwsh` wrapper scripts locally for those tools.

## 4. Bundled mirrors and parity enforcement

- Mirrors exist for every `.claude/lib/bash/*.sh` (`extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/`), for `.claude/agents/parallel-orchestrator.md`, for `.claude/settings.json`, and for all four parallel skills. Mirrors are maintained by hand; no sync script exists (#791 `spec.md:224`).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 89-110) asserts every distributable repo `.claude` file exists in the bundle with equal text. Run: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- `tests/shell/parallel_bash_manifest_membership.bats` (CI only) asserts byte identity and `core.json` membership for `.claude/lib/bash/*.sh`.
- `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` — "lists every bundled .claude agent, skill, and hook file in some pack manifest" (line 199) plus a fixed `it.each` list at 237-245 of four `lib/bash` paths. Run from `extensions/drm-copilot`: `npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts`. Adding to the fixed list is optional (the #791 plan treated it as optional).
- Manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lines 183-196 list `.claude/lib/bash/*.sh` in alphabetical order; a new library or entry-point file needs an entry there.
- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled` / `::test_known_unbundled_references_are_not_stale` — a new `bash .claude/lib/bash/<file>.sh` invocation in a skill is extracted (`skill_bundle_contract.py:52`) and must be bundled and carried by the skill's packs. `KNOWN_UNBUNDLED_REFERENCES` is empty (`skill_bundle_contract.py:136`), so no exception entry needs removal.

## 5. Dependence on `Bash(poetry run python -c *)` after the port

- Grep for `python -c` / `poetry run python -c` across `.claude/` returns only the grant line `.claude/agents/parallel-orchestrator.md:16`. Grep for `poetry` or `python` (case-insensitive) in the parallel skills returns no match. The persona's preloaded skills (`policy-compliance-order`, `parallel-orchestrate`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `evidence-and-timestamp-conventions`) contain no `python -c` prescription.
- The forked skills `parallel-add`, `parallel-close`, `parallel-remove` run as `agent: parallel-orchestrator`; after the port none of them requires a Python interpreter.
- Tests: no test pins the `-c` grant (Grep across `tests/`, `extensions/drm-copilot/test/`, `scripts/` for the grant text returned nothing). `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_command_invocation_has_a_persona_bash_grant` parses every backticked span and fenced line of `parallel-orchestrate/SKILL.md` whose first token matches `^[a-z][a-z0-9-]*$` (`parallel_orchestrator_permission_seam_support.py:457-496`) and requires a covering `Bash(...)` grant (prefix match on `*`-terminated grants). A new `bash .claude/lib/bash/<file>.sh ...` line in that skill therefore requires a matching `"Bash(bash .claude/lib/bash/<file>.sh*)"` grant. The Python call-shape spans (`recolor_unstarted(...)`) do not match the first-token pattern and are not counted today.
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:86-96` only forbids a `pr-author` grant.
- Conclusion: removing the `-c` grant is safe after the three skills are ported, provided the prose at `parallel-orchestrator.md:98-102` (and its mirror) is rewritten. The Python-only drift seams named at `parallel-orchestrate/SKILL.md:1064,1072` are not prescribed through `-c` today; see Open Risks.

## 6. FU-791-2 — `UnknownEnumMemberError`

Current code (`scripts/dev_tools/_parallel_mutation_errors.py:163-196`):

```python
class UnknownEnumMemberError(ParallelMutationError):
    def __init__(self, item_key: int | None, field_name: str, value: object) -> None:
        self.item_key = item_key
        self.field_name = field_name
        self.value = value
        allowed = VALID_ITEM_STATES if field_name == "state" else VALID_MERGE_STATUS
        super().__init__(
            f"{REJECTION_PREFIX} item {item_key!r} {field_name} {value!r} is "
            f"not one of {', '.join(allowed)}."
        )
```

Docstring line 182 states `field_name (str): Either ``state`` or ``merge_status``.`; class docstring lines 166-167 say it covers `state` and `merge_status`.

Raise sites (complete):

| Site | Field name | Allowed list today | Correct list |
| --- | --- | --- | --- |
| `_parallel_mutation_models.py:183` (`ItemRecord`) | `state` | item states | item states |
| `_parallel_mutation_models.py:185-187` (`ItemRecord`) | `merge_status` | merge statuses | merge statuses |
| `_parallel_mutation_models.py:448` (`MutationEntry._validate_state_fields`) | `state` | item states | item states |
| `parallel_mutation_protocol.py:412` (`decide_removal`) | `disposition` | merge statuses (defect) | `detach, abandon` |

Constants (`scripts/dev_tools/_parallel_state_common.py`): `VALID_ITEM_STATES` (39-41), `VALID_MERGE_STATUS` (46-50), `VALID_MUTATION_OPS` (64), `VALID_DISPOSITIONS = ("detach", "abandon")` (68), `MERGED_MERGE_STATUSES` (84). `VALID_DISPOSITIONS` is already imported into `_parallel_mutation_errors.py` (line 36).

Existing Python tests (type-only, none assert message text):

- `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py:193-199` `test_in_flight_removal_with_an_unknown_disposition_is_rejected` (`pytest.raises(UnknownEnumMemberError)`).
- `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py:488-500` `test_a_state_outside_the_item_state_enum_is_rejected`.
- `tests/scripts/dev_tools/test_parallel_mutation_protocol.py:110-130` `test_item_record_rejects_an_invalid_key_or_enum_value` (rows `"paused"` and `"landed"`).
- No `test_parallel_mutation_errors.py` exists. `test_parallel_mutation_protocol_ops.py` is close to the 500-line limit (line 499-500 observed), so new tests belong in a new file.

Bash coupling:

- The bash library mirrors the defective message at `.claude/lib/bash/parallel-mutation.sh:143`: `"$PM_REJECTION_PREFIX item $item_key disposition $(pc_repr str "$disposition") is not one of $PC_VALID_MERGE_STATUS."`.
- No corpus fixture or bats case carries this message: the CLI rejects an out-of-enum `--removal-disposition` with exit 2 before the library runs (`remove-parallel-item.sh:146-152`), which is declared divergence 1. The divergence text citing `_parallel_mutation_errors.py:192` and "lists merge-status members" appears in four places: `parallel-mutation.sh:16-18`, `remove-parallel-item.sh:35-37`, `tests/shell/parallel_mutation_remove_parity.bats:13-15`, `tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py:23-25` (plus the two bundled script mirrors).
- Therefore changing the Python message does not break any parity fixture, but leaves `parallel-mutation.sh:143` and the four divergence comments stale. For function-level parity, `parallel-mutation.sh:143` should list `detach, abandon` (e.g. `${PM_VALID_DISPOSITIONS// /, }`), with a bats function-level case added.

## 7. Toolchain commands (shapes; not executed)

Python (`.claude/rules/python.md` loop):

```text
poetry run black <changed .py files>
poetry run ruff check <changed .py files>
poetry run pyright <changed .py files>
poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_errors.py tests/scripts/dev_tools/test_parallel_mutation_protocol.py tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py --cov=scripts.dev_tools._parallel_mutation_errors --cov=scripts.dev_tools.parallel_mutation_protocol --cov=scripts.dev_tools._parallel_mutation_entries --cov-branch --cov-report=term-missing
```

Use the dotted-module `--cov=` form (a `--cov=<path>.py` value measures nothing). `pyproject.toml:119-120` sets `source = ["src", "scripts/dev_tools"]`, so bare `--cov` also works, as #791 used.

Contract/surface tests: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`.

TypeScript (only if the optional Jest list is edited): from `extensions/drm-copilot`, `npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts`.

Bash: `scripts/bash/shell-qc.sh format`, `check`, `test --coverage` — CI only (`shell-coverage` job).

Current coverage of `scripts.dev_tools._parallel_mutation_errors`: not determinable without running a command. By reading, every class constructor is reached by existing tests (`UnknownEnumMemberError` via the four raise sites, `CloseWhileInFlightRejectedError` via close tests, `MutationEntryContractError` via entry tests), so full line coverage is likely; the ternary at line 192 is not a branch arc under coverage.py. A baseline run is required to confirm.

## 8. Automation Feasibility

No automation-feasibility concern was identified. Every change is a file edit verifiable by pytest, Jest, or CI bats/kcov. The only non-local gate is the bats/kcov/shellcheck/shfmt result, which is obtained from PR CI per the operator constraint, as in #791.

## Candidate Approaches

### A (recommended). One new bash entry point plus library extension, reusing `pm_recolor_unstarted`

- Add the five missing pure functions to the bash library: `pm_decide_admission`, `pm_build_add_entry`, `pm_decide_close`, `pm_build_close_entry`, `pm_build_requeue_entry`, and generalize `pm_entry_contract_message` to take the op. To keep `parallel-mutation.sh` (319 lines) under 500 lines, place the new functions in a new sourceable sibling `.claude/lib/bash/parallel-mutation-ops.sh` that sources `parallel-mutation.sh`.
- Add one CLI entry point `.claude/lib/bash/mutate-parallel-run.sh` with subcommands `admit`, `recolor` (delegates to `pm_recolor_unstarted`), `add-entry`, `close`, `close-entry`, `requeue-entry`, using the same exit-code contract and option grammar as `remove-parallel-item.sh`. Move the `rpi_*` option-parsing helpers into a shared sourceable file (for example `.claude/lib/bash/parallel-mutation-cli.sh`) used by both entry points, rather than duplicating ~110 lines; the existing `parallel_mutation_remove.bats` cases continue to exercise the moved code.
- Port the skill prose to the new CLI; leave `parallel_mutation_protocol.py` as a parity citation without an invocation verb (the `parallel-remove` precedent).
- Advantages: one new grant, one new allow entry, one new manifest entry point; `parallel-remove` behavior unchanged; parity method identical to #791.
- Limitations: one more shared library file; the membership bats entry-point list and its "six" title change to seven.

### Rejected alternatives

- **Per-skill entry points** (`add-parallel-item.sh`, `close-parallel-run.sh`, `requeue-parallel-item.sh`): matches the verb-object naming precedent but triples the grant, allow-entry, payload-test, and manifest surface for no behavioral gain.
- **Extend `remove-parallel-item.sh` with add/close/requeue subcommands**: fewest files, but the script name and its declared divergences describe removal only, and add/close/requeue invocations through a "remove" script are misleading in skill prose and in permission review.
- **Call `remove-parallel-item.sh recolor` from `parallel-add` and `parallel-orchestrate`**: avoids a duplicate recolor subcommand but couples add/requeue prose to the remove script; rejected for clarity. (Acceptable fallback if the planner prefers not to expose `recolor` twice.)

## Recommended Implementation Approach

1. **FU-791-2 (Python, regression first).** New `tests/scripts/dev_tools/test_parallel_mutation_errors.py` with one test per field (`state`, `merge_status`, `disposition`) asserting the exact message, plus a test that an unmapped field fails explicitly; the `disposition` and unmapped-field tests fail before the fix. Fix `_parallel_mutation_errors.py:192` with an explicit `field_name -> members` mapping (`state` -> `VALID_ITEM_STATES`, `merge_status` -> `VALID_MERGE_STATUS`, `disposition` -> `VALID_DISPOSITIONS`) that raises a clear error for an unmapped field; update docstrings at 166-167 and 182. Expected new disposition message: `Parallel mutation rejected: item 21 disposition 'delete' is not one of detach, abandon.`
2. **FU-791-2 (bash alignment).** Change `parallel-mutation.sh:143` to list the dispositions; add a function-level bats case in `tests/shell/parallel_mutation_remove.bats`. Retain the CLI usage-error behavior (divergence 1) but reword its rationale in the four comment sites so it no longer claims the Python text lists merge-status members. Update both bundled script mirrors.
3. **FU-791-1 (bash port).** Implement Approach A with bats unit tests (every subcommand, every rejection, every usage-error class, explicit and default `--at` format-only) and a shared parity corpus `tests/fixtures/parallel_mutation_run/*.json` run by a bats lane and a Python lane, each with a fixture-count floor and an exact required-case set. Add payload-only cases and update the membership bats list.
4. **Skill prose.** Replace the eleven reference lines and the Python-ism lines (`parallel-add` 102/106 outcome names -> JSON `outcome` values, 133-134 `RecolorResult.*` -> output fields, 160 / `parallel-close` 62 / `parallel-orchestrate` 771 clock seam -> `--at`; `parallel-close` 49-51 "raises the dedicated rejection exception" -> exit 1 with the stderr line) with `bash .claude/lib/bash/mutate-parallel-run.sh <subcommand> ...` invocations in fenced blocks (one invocation per line). Keep at most a parity citation of `parallel_mutation_protocol.py`. Optionally reword `parallel-orchestrate:785` to cite the validator's `require_complete` gate.
5. **Permissions.** Add `"Bash(bash .claude/lib/bash/mutate-parallel-run.sh*)"` to the persona `tools` and to `.claude/settings.json` `permissions.allow` (no `lib/bash/*` wildcard), remove `"Bash(poetry run python -c *)"`, rewrite `parallel-orchestrator.md:98-102`. Update all mirrors.
6. **Residual risks.** Carry the two #791 residual risks forward verbatim and unchanged in the #890 spec's Risks section; the new allow entry is for a non-destructive script and does not alter either risk.

## Files a Plan Would Create or Edit

Python (FU-791-2):

- `scripts/dev_tools/_parallel_mutation_errors.py` (edit)
- `tests/scripts/dev_tools/test_parallel_mutation_errors.py` (new)

Bash library and entry point (FU-791-1):

- `.claude/lib/bash/parallel-mutation.sh` (edit: line 143, divergence comment, `pm_entry_contract_message` op parameter)
- `.claude/lib/bash/remove-parallel-item.sh` (edit: divergence comment; source the extracted CLI helpers)
- `.claude/lib/bash/parallel-mutation-ops.sh` (new)
- `.claude/lib/bash/parallel-mutation-cli.sh` (new, extracted option-parsing helpers)
- `.claude/lib/bash/mutate-parallel-run.sh` (new)
- Byte-identical mirrors of all five under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (three new entries)

Skills, persona, settings (and mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/`):

- `.claude/skills/parallel-add/SKILL.md`
- `.claude/skills/parallel-close/SKILL.md`
- `.claude/skills/parallel-orchestrate/SKILL.md`
- `.claude/agents/parallel-orchestrator.md`
- `.claude/settings.json`

Tests and fixtures:

- `tests/shell/parallel_mutation_run.bats` (new)
- `tests/shell/parallel_mutation_run_parity.bats` (new)
- `tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py` (new)
- `tests/fixtures/parallel_mutation_run/*.json` (new corpus)
- `tests/shell/parallel_mutation_remove.bats` (edit: disposition function-level case)
- `tests/shell/parallel_mutation_remove_parity.bats` (edit: divergence comment)
- `tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py` (edit: divergence comment)
- `tests/shell/parallel_payload_only.bats` (edit: new entry-point cases)
- `tests/shell/parallel_bash_manifest_membership.bats` (edit: entry-point list and title)
- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` (edit: regression tests that `parallel-add`, `parallel-close`, `parallel-orchestrate` extract `mutate-parallel-run.sh` and name no engine function)
- Optional: `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`; `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` (out-of-scope case for the new script)

Feature documents: `spec.md`, `user-story.md`, `plan.*.md`, and evidence under `docs/features/active/2026-10-11-parallel-skills-python-engine-calls-and-enum-error-members-890/evidence/<kind>/`.

## Testing Implications

- Regression-first for FU-791-2: the `disposition` message test fails against line 192 and passes after the fix.
- Parity: shared corpus, two lanes, floors, exact case sets; `admit` has no rejection fixture by design (Python has no rejection branch); the per-subcommand success/rejection rule applies to the other subcommands.
- Bash unit tests assert exact single-line output; usage errors assert the `PARALLEL_MUTATION_ERROR: usage error:` prefix; the default `--at` is checked by format only; no temporary files and no clock waits.
- kcov line coverage >= 85% for each new and changed bash file, read from the CI `shell-coverage` artifact; no branch threshold for bash.
- Python line >= 85% and branch >= 75% for changed modules; no regression on changed lines.
- Surface tests: resource-contract parity, skill-bundle contract, permission seam, and abandon token seam must pass.

## Numeric Derivation Evidence

### Claim N1: Python-engine reference lines in the three repository skills = 11 (and 11 in the mirrors)

- Complete Family: lines in `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-close/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md` that name `parallel_mutation_protocol` or any of `decide_admission`, `decide_close`, `recolor_unstarted`, `build_add_entry`, `build_close_entry`, `build_requeue_entry`.
- Exhaustive Search Scope: all of `.claude/skills/` (every skill file) and the mirror tree `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`.
- Inclusion Rules: a line containing the module name or one of the six function names.
- Exclusion Rules: the field name `recolor_generation`; `parallel-remove/SKILL.md:152` (permitted parity citation, out of scope); descriptive "mutation engine" prose without a function or module name; Python names outside the six (`is_closed_mode_complete`, `has_unresolved_drift`, `request_requeue_via_recolor`), listed separately.
- Primary Search Strategy or Query Expression: Grep `parallel_mutation_protocol|decide_admission|decide_close|recolor_unstarted|build_add_entry|build_close_entry|build_requeue_entry|poetry run python` over `.claude/`.
- Primary Member Set: add {100, 101, 108, 150}; close {48, 49, 55, 65}; orchestrate {666, 821, 829}.
- Primary Count: 11.
- Cross-check Search Strategy or Query Expression: Grep `decide_[a-z]+\(|recolor_[a-z]+|build_[a-z]+_entry|mutation_protocol` over `.claude/skills/`, then remove `recolor_generation`-only lines and the `parallel-remove`/`parallel-plan` lines; mirror tree checked by per-file counts with the same pattern (add 10, close 7, orchestrate 16 occurrences in both trees).
- Cross-check Member Set: add {100, 101, 108, 150}; close {48, 49, 55, 65}; orchestrate {666, 821, 829}.
- Cross-check Count: 11.
- Member-set Comparison: identical sets; mirror per-file counts equal the repository per-file counts.

### Claim N2: `UnknownEnumMemberError` raise sites = 4

- Complete Family: every construction of `UnknownEnumMemberError` in production code.
- Exhaustive Search Scope: entire worktree.
- Inclusion Rules: a call `UnknownEnumMemberError(`.
- Exclusion Rules: the class definition line `_parallel_mutation_errors.py:163`; test references.
- Primary Search Strategy or Query Expression: Grep `UnknownEnumMemberError\(` over the worktree.
- Primary Member Set: `parallel_mutation_protocol.py:412`, `_parallel_mutation_models.py:183`, `_parallel_mutation_models.py:185`, `_parallel_mutation_models.py:448`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: Grep `raise UnknownEnumMemberError` with two lines of trailing context over the worktree.
- Cross-check Member Set: `_parallel_mutation_models.py:183` (`state`), `:185` (`merge_status`), `:448` (`state`), `parallel_mutation_protocol.py:412` (`disposition`).
- Cross-check Count: 4.
- Member-set Comparison: identical.

### Claim N3: CLI entry points in `.claude/lib/bash/` today = 6 (becomes 7 under Approach A)

- Complete Family: `.claude/lib/bash/*.sh` files with a guarded `main` that are documented as command-line entry points.
- Exhaustive Search Scope: the 14 files returned by Glob `.claude/lib/bash/**`.
- Inclusion Rules: file named in `parallel_bash_manifest_membership.bats:85` or exposing a `*_main` CLI with usage errors.
- Exclusion Rules: sourceable libraries (`parallel-common.sh`, `parallel-cohorts.sh`, `parallel-mutation.sh`, `parallel-items-validate.sh`, `parallel-lane-assertion.sh`, `parallel-manifest-validate.sh`, `parallel-yaml-emit.sh`, `parallel-yaml-scan.sh`).
- Primary Search Strategy or Query Expression: the fixed list in `tests/shell/parallel_bash_manifest_membership.bats:85`.
- Primary Member Set: abandon-parallel-item.sh, compute-cohorts.sh, compute-concurrency-batches.sh, remove-parallel-item.sh, report-lane-assertion.sh, validate-parallel-manifest.sh.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: Grep `^[a-z_]+\(\) \{` over `.claude/lib/bash` for `*_main` / usage functions (`vm_main`, `rla_main`, `rpi_main`, `cb_main`, `cc_main`, `abandon_usage_error`).
- Cross-check Member Set: validate-parallel-manifest.sh, report-lane-assertion.sh, remove-parallel-item.sh, compute-concurrency-batches.sh, compute-cohorts.sh, abandon-parallel-item.sh.
- Cross-check Count: 6.
- Member-set Comparison: identical.

## Open Risks

- **Residual risks carried from #791 (must stay visible, unchanged):** (a) a timed-out PreToolUse hook does not block, so the call continues through the normal permission flow where the abandon allow entry skips the prompt; (b) an installed plugin mod handling `tool.check` can approve a hook-blocked call regardless of allow entries. Sources: #791 `spec.md:282`, `feature-audit.2026-10-10T09-05.md:74`.
- **Python-only drift seams remain in `parallel-orchestrate`:** `has_unresolved_drift` (line 1064, gates admission during quiesce) and `request_requeue_via_recolor` (line 1072) have no destination-runtime port. They are not prescribed through `-c` today, so removing the grant does not change their reachability, but a destination workspace cannot evaluate the quiesce predicate through an engine. Recommend a follow-up rather than widening #890.
- **Line drift from parallel siblings:** #885 (parallel-add step 2) and #899 (parallel-orchestrate 371-385) shift line numbers; the plan should anchor edits on text, not line numbers.
- **`pm_` prefix collision:** `parallel-manifest-validate.sh` also defines `pm_*` functions. The new library must not be sourced together with it, or should use a distinct prefix.
- **Permission seam test sensitivity:** every new command line in `parallel-orchestrate/SKILL.md` must be covered by a persona `Bash(...)` grant, or `test_every_prescribed_command_invocation_has_a_persona_bash_grant` fails.
- **Abandon gate:** new options must not contain the token `--disposition abandon`; Approach A's subcommands carry no disposition option.
- **CI-only bash evidence:** bats/kcov/shellcheck/shfmt verdicts are available only after PR CI; acceptance criteria depending on them are CI-dependent and must be checked off after S9.
- **Docstring inaccuracy:** `build_close_entry` documents `Raises: None.` while a negative generation raises `MutationEntryContractError`; the port should reproduce the actual behavior, and the docstring may be corrected in passing only if the plan scopes it.
