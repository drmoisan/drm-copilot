# Research: Issue #791 — parallel skill CLI port follow-ups (FU-763-1, -2, -3, -5)

- **Issue:** #791 (bug, work mode `full-bug`)
- **Branch:** `bug/issue-763-parallel-skill-cli-port-follow-ups-791`
- **Feature folder:** `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791`
- **Researched:** 2026-10-08T14-00
- **Out of scope:** FU-763-4 (`quality-tiers.yml` absent; tracked by #734).

All paths are repository-relative. "Verified" means confirmed by reading the file or by a recorded search in this session. "Inferred" marks conclusions drawn by reasoning that has not been executed.

## Inputs Read

- `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/issue.md` (FU-763-1..5 text).
- `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/spec.md` and `plan.2026-10-08T13-56.md` — both are unfilled templates (verified by reading).
- Prior spec `docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/spec.md` exists on this tree (found with Glob `docs/features/**/*763*/spec.md`). Relevant decisions, verified at lines 89-97:
  - D4 (line 89): the `Bash(poetry run python -m *)` entry in `parallel-orchestrator.md` was deliberately left unchanged; removal deferred.
  - D6 (line 93): `.claude/settings.json` not modified; no allow entry for the abandon script.
  - D7 (line 95): `parallel-remove` steps 2, 3, 6 (`decide_removal`, `recolor_unstarted`, `build_remove_entry`) deferred; "they have no invocation form, the skill-bundle guard does not detect them".
  - D8 (line 97): new modules classified T3 for gate purposes because `quality-tiers.yml` is absent.

## Current State Analysis

### FU-763-5 — skill-bundle guard regex

File: `scripts/dev_tools/skill_bundle_contract.py` (486 lines, verified by reading to the final line and by a Grep line count). Headroom to the 500-line limit: 14 lines.

Exact patterns (lines 49-52 and 64):

```python
_CANDIDATE = r"(?P<path>[^\s'\"`()]+)"
re.compile(r"(?<![A-Za-z0-9_-])(?:bash|sh|source)\s+" + _CANDIDATE)          # line 52
_PYTHON_PATH_PATTERN = re.compile(r"(?<![A-Za-z0-9_-])python3?\s+" + _CANDIDATE)  # line 64
```

Regex analysis (verified by reading the pattern and the extraction loop at lines 275-300; not executed):

1. Input text: ` ```bash\nbash .claude/lib/bash/x.sh --flag`.
2. At the fence word `bash`, the look-behind `(?<![A-Za-z0-9_-])` sees a backtick, which is not in the excluded class, so the match starts.
3. `\s+` matches the `\n` (Python `\s` includes newline and carriage return).
4. `_CANDIDATE` (`[^\s'"`()]+`) captures the next token, which is the invocation's own interpreter word `bash`.
5. `_normalize_candidate("bash")` returns `None` because `bash` does not satisfy `_PATH_TOKEN` (no script suffix), so nothing is recorded.
6. `re.finditer` resumes after the consumed `bash`. The remaining text ` .claude/lib/bash/x.sh --flag` contains `bash` only after `/` (look-behind passes) followed by `/`, so `\s+` fails; `sh` in `.sh` is followed by a space and then `--flag`, which fails `_PATH_TOKEN`. The script path is never recorded.

Result: the defect is **confirmed** for fence info strings `bash` and `sh` (and a prose line ending in the words `bash`, `sh`, or `source` directly followed by an invocation line). A ` ```shell` fence is not affected because `shell` is not in the alternation and `sh` inside `shell` fails `\s+`. Each pattern runs its own `finditer`, so only same-pattern consumption matters: a `pwsh` line under a bash fence is still extracted by the `pwsh` pattern.

The same self-consumption applies to `_PYTHON_PATH_PATTERN` (line 64) for a ` ```python` fence followed by `python <path>.py` (inferred by the same analysis). `_PYTHON_MODULE_PATTERN` (lines 65-68) is not affected: after the fence `python\s+` it requires `-m`, fails, and the engine retries at the next position.

Live instance in the repository (verified with multiline Grep `(?:bash|sh|source)[ \t]*\r?\n[ \t]*(?:bash|sh|source)[ \t]` over `.claude/skills`):

- `.claude/skills/parallel-plan/SKILL.md:322-323` — ` ```bash` then `bash .claude/lib/bash/compute-cohorts.sh ...`. This is the only `compute-cohorts.sh` invocation with a verb in that skill (line 352 is a backticked citation), so the guard currently does not extract `compute-cohorts.sh` for `parallel-plan` (inferred from the analysis; the reference is bundled and listed in `core.json:172`, so no violation is hidden today).
- `.claude/skills/parallel-plan/SKILL.md:456-457` and `464-465` — same shape for `validate-parallel-manifest.sh`; that path is still extracted through line 466, which is the second line of the fence.
- `.claude/skills/parallel-remove/SKILL.md:111` uses a ` ```shell` fence, which is the #763 workaround named in the issue.

Behavior change check for the fix (verified with multiline Grep `(?:^|[^A-Za-z0-9_-])(?:bash|sh|source|python3?)[ \t]*\r?\n\s*[^\s'"`()]+` over `.claude/skills`): among `SKILL.md` files, the only matches are the three `parallel-plan` fences above and `.claude/skills/cleanup-merged-worktrees/SKILL.md:501-502` (`bash\n<file>`), whose candidate `<file>` is a placeholder and is discarded either way. No skill relies on a cross-newline match to extract a reference, so restricting the whitespace removes no current reference. A Grep for a verb followed by a line-continuation backslash (`(bash|sh|source|python3?)[ \t]+\\$`) in `SKILL.md` files returned no match.

Callers of `_INVOCATION_PATTERNS` (verified with Grep over the repository excluding `docs/`): used only in `_references_in_chunk` (`skill_bundle_contract.py:287`). `_references_in_chunk` is called only by `extract_script_references` (line 329). `extract_script_references` is called by `skill_bundle_contract.py:432` (`_all_violations`), `scripts/dev_tools/skill_bundle_contract_cli.py:153`, `tests/scripts/dev_tools/test_skill_bundle_contract.py`, `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py:54`, and `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py:408`.

Ports or mirrors of the regex: none. A Grep for `bash\|sh\|source|skill_bundle_contract|SkillBundle|skill-bundle` over `.claude/**`, `extensions/drm-copilot/src/**`, `scripts/**`, `.github/workflows/**`, and `tests/**` matched only the Python module, its CLI, the four Python test files, the seam test, and a prose line in `.claude/rules/shell.md:67` (not a regex). `skill_bundle_contract.py` lives under `scripts/`, which is not a published root (`PUBLISHED_ROOT_FOLDERS = (".claude", "config")`), so it has no bundle mirror. No `.github/workflows` file names `skill_bundle_contract`; enforcement runs through pytest (`test_skill_bundle_contract_repo.py`).

Existing tests closest to the change (verified by reading):

- `tests/scripts/dev_tools/test_skill_bundle_contract.py` (282 lines): `test_extract_reads_bash_sh_and_source_forms` (lines 118-129, parametrized over `bash`, `sh`, `source`), `test_extract_reads_python_path_form` (lines 185-195), `test_extract_ignores_backticked_citation_without_invocation` (lines 253-263), `test_extract_deduplicates_and_sorts_references` (lines 266-282). Every path in this file is fictitious by convention (module docstring lines 5-6).
- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` (117 lines): `test_every_skill_script_reference_is_bundled` (line 29), `test_ci_gate_parser_skills_invoke_bundled_parser` (line 46, the precedent for a skill-specific real-repository assertion), `test_known_unbundled_references_are_not_stale` (line 90).
- `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py::test_bundle_guard_extracts_the_skill_invocation` (lines 401-414); it asserts membership (`in`), so an additional reference does not break it.

### FU-763-3 — `parallel-remove` Python library calls

Skill text (verified by reading `.claude/skills/parallel-remove/SKILL.md`):

- Step 2 (lines 76-78): "calling `decide_removal(item_key, items, disposition)` from `scripts/dev_tools/parallel_mutation_protocol.py`".
- Step 3 (lines 80-96): "calling `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort, highest_pinned_cohort=highest_pinned_cohort)`"; writes `RecolorResult.cohort_assignments` verbatim into `cohorts[]` and sets `recolor_generation` to `RecolorResult.generation`.
- Step 6 (lines 120-130): "built by `build_remove_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`"; `at` "comes from the engine's injected clock seam".

Why the guard does not detect these (verified): none of the three lines carries an invocation verb recognized by `_INVOCATION_PATTERNS`, `_PYTHON_PATH_PATTERN`, or `_PYTHON_MODULE_PATTERN`; the path is a backticked citation, which the guard intentionally ignores (`extract_script_references` docstring lines 307-308; test `test_extract_ignores_backticked_citation_without_invocation`). Even if extracted, `scripts/...` is outside `PUBLISHED_ROOT_FOLDERS` and would be reported `not-in-bundle`.

Function semantics (verified by reading `scripts/dev_tools/parallel_mutation_protocol.py`, `_parallel_mutation_entries.py`, `_parallel_mutation_models.py`, `_parallel_mutation_errors.py`, `_parallel_state_common.py:64-68`):

| Function | Inputs | Output | Rejections |
| --- | --- | --- | --- |
| `decide_removal(item_key, items, disposition=None)` (`parallel_mutation_protocol.py:338-426`) | int key; `Mapping[int, ItemRecord]` (only the target's `state` is read); `detach`/`abandon`/None | `RemovalDecision(item_key, prior_state, new_state="withdrawn", disposition, triggers_recompute)`. Unstarted states (`proposed`, `admitted`, `prepared`, `scheduled`): disposition forced to None, recompute True. `in_flight`: prior_state `in_flight`, the given disposition, recompute False. | `UnknownItemError` (key absent, or state `withdrawn`/`blocked`); `InFlightRemovalRequiresDispositionError` (in_flight, no disposition); `UnknownEnumMemberError` (in_flight, disposition not in `("detach","abandon")`); `MergedItemRemovalRejectedError` (`merged`). |
| `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, *, current_cohort, highest_pinned_cohort)` (lines 200-335) | unstarted keys; all edges; pinned keys; ints | `RecolorResult(cohort_assignments={key: absolute_index}, generation=current_generation+1)`. Induced subgraph (edges with both ends unstarted) is colored by `compute_cohorts`; offset = `highest_pinned_cohort + 1` if any edge joins an unstarted key to a pinned key, else `current_cohort`; index = offset + local color index. | `UnknownItemError(min(overlap))` if a key is both unstarted and pinned; `ParallelCohortInputError` if `current_cohort < 0` (message `current_cohort must be >= 0 per F3 invariant 12; received {n}.`) or propagated from `compute_cohorts` (duplicate key). |
| `build_remove_entry(decision, *, current_generation, clock)` (`_parallel_mutation_entries.py:133-175`) | a `RemovalDecision`; int; clock | `MutationEntry(op="remove", item_key, at=clock(), prior_state, new_state, disposition, recolor_generation = g+1 if triggers_recompute else g)` | `MutationEntryContractError` / `UnknownEnumMemberError` from `MutationEntry.__post_init__` (`_parallel_mutation_models.py:385-472`): negative generation, non-positive key, out-of-enum state, disposition not in the two members on an in-flight remove, any disposition elsewhere. |

Rejection message formats (verified, `_parallel_mutation_errors.py`): prefix `Parallel mutation rejected:`; `UnknownItemError` → `item key {repr} does not resolve to a tracked items[].issue_num.`; `InFlightRemovalRequiresDispositionError` → `removal of in-flight item {repr} requires an explicit disposition, one of detach, abandon; no default is inferred.`; `MergedItemRemovalRejectedError` → `item {repr} is already merged into main and cannot be removed.`

Observed latent defect (verified by reading `_parallel_mutation_errors.py:192`): `UnknownEnumMemberError` lists `VALID_MERGE_STATUS` for any `field_name` other than `state`, so `decide_removal(k, items, "foo")` for an in-flight item reports the merge-status member list rather than the disposition members. It is out of scope; the port should not reproduce it (see design).

#763 precedent (verified by reading):

- `.claude/lib/bash/abandon-parallel-item.sh` (176 lines): standalone entry point; `readonly` option constants; usage errors exit 2 with a `PARALLEL_ABANDON_ERROR: usage error:` line; refusals before side effects; declared divergences listed in the header.
- Sourceable libraries: `parallel-common.sh` (238 lines; enums such as `PC_VALID_ITEM_STATES`, `pc_enforce_c_locale`, `pc_repr`), `parallel-cohorts.sh` (330 lines; `pcoh_compute_cohorts`, `PCOH_RESULT`, `PCOH_ERROR`, byte-identical Python error messages per its header lines 15-16). `compute-cohorts.sh` (143 lines) shows the entry-point pattern: resolve `$(dirname "${BASH_SOURCE[0]}")`, `source` the library, `pc_enforce_c_locale`, `main` guard at lines 139-143. `parallel-yaml-scan.sh`/`parallel-yaml-emit.sh` serve manifest YAML and are not needed here.
- No JSON parser exists in `.claude/lib/bash` (verified by the file list); the drift port went to PowerShell for JSON reasons (#763 D1). Welsh-Powell coloring exists only in Python and in `parallel-cohorts.sh` (verified with Grep `Welsh|compute_cohorts|Get-ParallelCohort` over `.claude/lib`: matches only `parallel-lane-assertion.sh`, `parallel-cohorts.sh`, `compute-cohorts.sh`).
- Tests: `tests/shell/parallel_abandon.bats`, `tests/shell/parallel_abandon_parity.bats` (reads `tests/fixtures/parallel_abandon/*.json` through `${PARALLEL_PARITY_PYTHON:-python3}`, floor `MINIMUM_FIXTURE_COUNT=9`), Python lane `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py` (235 lines; calls the reference in-process with an injected runner), payload proof `tests/shell/parallel_payload_only.bats` (restricted shim PATH `tests/fixtures/parallel_payload_path/` = `cat`, `cut`, `dirname`, `sort`), membership/parity `tests/shell/parallel_bash_manifest_membership.bats` (core.json entry and byte identity for every `.claude/lib/bash/*.sh`; line 85 enumerates the five entry points). The cohort port's Python lane is `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` with corpus `tests/fixtures/parallel_cohorts/`.

Hook interaction (verified by reading `.claude/hooks/enforce-parallel-abandon-gate.ps1:41,95-156` and `.claude/hooks/hook-command-scanner.ps1:21-24,147,165-196`): the gate is in scope when a segment carries the token pair `--disposition` `abandon` (adjacent tokens) or `--disposition=abandon`. `bash` is in `$script:CommandLineWrapperNames`, so every `bash <script> ...` segment is wrapper-led and also receives a case-insensitive raw substring scan for `--disposition abandon` and `--disposition=abandon`. A new command that passed `--disposition abandon` to a decision or entry step would be denied with `PARALLEL_ABANDON_BLOCKED` unless it also carried `--confirm-abandon`. The new interface must therefore not use the option name `--disposition`. `--removal-disposition abandon` does not contain the substring `--disposition abandon` (the character before `disposition` is a single `-` preceded by `l`), so it is outside the gate (string reasoning; a hook test is proposed below to verify it).

Seam-test constraints (verified, `test_parallel_abandon_token_seam.py:53,215-241`): `parallel-remove/SKILL.md` must keep exactly one line containing both `abandon-parallel-item.sh` and `--`. A new script name must not contain `abandon-parallel-item.sh`, and new invocation lines must not mention it.

Sibling skills with the same unbundled-call pattern (verified with Grep `parallel_mutation_protocol|decide_removal|recolor_unstarted|build_remove_entry` over `.claude`): `.claude/skills/parallel-add/SKILL.md:99,106,148`, `.claude/skills/parallel-close/SKILL.md:49,55,65`, `.claude/skills/parallel-orchestrate/SKILL.md:634,789,797`. These are outside #791's stated scope (parallel-remove only) and should be recorded as a follow-up.

### FU-763-2 — settings allow entry

`.claude/settings.json` `permissions.allow` (verified, lines 4-67): `Bash(git *)`, `Bash(poetry run *)`, `Bash(pwsh *)`, then the three bash entry points at lines 8-10 in alphabetical order:

```json
"Bash(bash .claude/lib/bash/compute-cohorts.sh*)",
"Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*)",
"Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)",
```

No entry matches `abandon-parallel-item.sh`. The abandon gate hook is registered under `PreToolUse` (`.claude/settings.json:123`). The same form already appears in the agent allowlist (`.claude/agents/parallel-orchestrator.md:21`).

Bundled mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (verified present; lines 4-10 match). Byte-identity enforcement: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 89-110, compares every distributable `.claude` file; `settings.json` is also in `REQUIRED_BUNDLED_FILES` at line 31). No test pins the allow-list contents for the bash entries (Grep for `compute-concurrency-batches\.sh\*` outside `docs/` matched only the two `settings.json` copies and the agent files). `tests/scripts/claude-runtime/claude-settings.Tests.ps1` has no match for `allow`, `lib/bash`, or `poetry`. No `.codex/**` settings file exists (Glob returned nothing).

Precedence of a PreToolUse deny over an allow rule: the Claude Code hooks documentation (fetched from `https://code.claude.com/docs/en/hooks`, first 100,000 characters) states that `permissionDecision: "deny"` blocks the tool call, but the fetched portion did not state precedence over project allow rules explicitly. #763 D6 assumed the hook remains the gate. This is unverified in this session; the implementation should confirm it with the existing hook tests (the hook decision is independent of settings, so the gate's own Pester suites remain the evidence).

### FU-763-1 — `Bash(poetry run python -m *)` grant

Grant location (verified): `.claude/agents/parallel-orchestrator.md:17`, with `Bash(poetry run python -c *)` at line 16 and prose at lines 98-107 stating that "no skill step names a `poetry run` consumer" and that both grants are "left unchanged pending a separate removal decision". Bundle mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md:16-17` (verified). No `.github` or `.codex` copy (Glob `**/*parallel-orchestrator*` matched only these two agent files plus TypeScript validators, tests, and docs).

Caller set: the agent's preloaded `skills:` (lines 29-35: `policy-compliance-order`, `parallel-orchestrate`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `evidence-and-timestamp-conventions`) plus the skills that fork into it with `agent: parallel-orchestrator` (`parallel-add`, `parallel-close`, `parallel-orchestrate`, `parallel-remove`, `parallel-run`), plus `.claude/rules/parallel-orchestration.md`.

Searches (all verified):

1. Grep `python3? -[mc] |poetry run` over all of `.claude/skills`: matches only `.claude/skills/feature-review-workflow/SKILL.md:108` and `.claude/skills/python-qa-gate/SKILL.md:30-33` (pytest/black/ruff/pyright; neither skill is in the caller set).
2. Grep `-m scripts\.|python -m|python3 -m` over `.claude` (excluding `worktrees/`): matches `.claude/agents/parallel-orchestrator.md:17` (the grant itself), two hook comments, `.claude/lib/discovery-validation/DiscoveryValidation.psm1:7` (comment), and `.claude/rules/orchestrator-state.md:173`.
3. Grep `python3? -[mc] |poetry run` over `.claude/rules/parallel-orchestration.md`: no match.

`.claude/rules/orchestrator-state.md:173` documents `python -m scripts.dev_tools.validate_orchestrator_state` for the single-item orchestrator checkpoint. Its `paths:` glob `artifacts/orchestration/*orchestrator-state.json` (line 3) also matches `parallel-orchestrator-state.json`, so the rule can load in a parallel-orchestrator session. The parallel surface validates its checkpoint through `mcp__drm-copilot__validate_orchestration_artifacts` (agent lines 99-100, 245-246; `parallel-remove/SKILL.md:132-135`), so this documented CLI is not a step of any caller. Conclusion: no caller in the set needs `Bash(poetry run python -m *)`.

The `-c` grant (line 16) is not in #791's stated scope. Inference (not verified by an explicit command in any skill): the prose "call `fn(...)` from `scripts/dev_tools/parallel_mutation_protocol.py`" in `parallel-add`, `parallel-close`, and `parallel-orchestrate` can only be executed in practice through `poetry run python -c`, so the `-c` grant should stay until those skills are ported.

Tests asserting the agent's tools: `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:79-96` (non-empty `tools`; no `pr-author` entry). No test pins either `poetry run python` entry (Grep `poetry run python -m \*|poetry run python -c \*` outside `docs/` matched only the two agent copies). Pester sample strings mentioning `poetry run python -m` exist in `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1:56`; they are command-text fixtures and are unaffected.

## Candidate Approaches

### FU-763-5

- **A (selected): restrict the whitespace after the verb to horizontal whitespace.** Change `\s+` to `[ \t]+` at line 52 and, for the same defect class, at line 64. Zero net line change; behavior change limited to cross-newline matches, of which no current `SKILL.md` depends on one (search above).
- B: anchor the verb to a line start or inline-code start. Rejected: invocations occur mid-sentence in backticks (`Run \`bash x.sh\``) and after `&&`; anchoring would drop valid references.
- C: strip fence info lines before scanning. Rejected: fixes fences only, not a prose line ending in `bash`, and adds lines to a file with 14 lines of headroom.

### FU-763-3

- **A (selected): bash port as a sourceable library plus one subcommand entry point**, reusing `pcoh_compute_cohorts` for coloring. Aligns with the #462/#763 bash library, needs no interpreter, adds no third coloring implementation, and leaves the Python engine as the parity reference (#763 D3 precedent).
- B: PowerShell port reading the checkpoint JSON (drift precedent D1). Rejected: coloring has no PowerShell port, so this would add a third implementation or shell out to bash; the skill already supplies the scalar inputs, so JSON reading is unnecessary.
- C: change the guard to detect "call `fn` from `<path>.py`" prose. Rejected: the guard deliberately treats backticked paths as citations, and skills legitimately cite Python parity references (for example `parallel-orchestrate/SKILL.md:672,928`, `parallel-remove/SKILL.md:150`); a heuristic would produce false positives and still would not make the steps runnable in a consumer workspace.

### FU-763-1 / FU-763-2

Selected: remove the `-m` grant; add a settings allow entry in the existing `Bash(bash .claude/lib/bash/<script>.sh*)` form. Rejected alternative for FU-763-2: `Bash(bash .claude/lib/bash/*)` (a wildcard over the library), which would pre-approve future scripts without review.

## Behavior Semantics (port contract for FU-763-3)

- Success: exit 0, one compact JSON object on stdout.
- Rejection by the engine's rules: exit 1, one stderr line equal to the Python exception message.
- Usage error: exit 2, one stderr line prefixed `PARALLEL_MUTATION_ERROR: usage error:` (prefix name proposed; mirrors `PARALLEL_ABANDON_ERROR:`).
- Ordering: argument validation, then rule rejection, then output. No file I/O, no network, no side effect; the only clock read is the default for `--at`.
- Edge cases: key absent (`--state` omitted), states `withdrawn`/`blocked`/`merged`, in-flight without disposition, disposition supplied for an unstarted item (ignored, recorded null), empty unstarted set (`{}` assignments, generation g+1), key in both unstarted and pinned, negative `current_cohort`, duplicate unstarted key, no unstarted-to-pinned edge (offset `current_cohort`), at least one such edge (offset `highest_pinned_cohort + 1`), negative generation in `entry`.

## Recommended Fix Design

### FU-763-5

- `scripts/dev_tools/skill_bundle_contract.py:52`: `(?:bash|sh|source)\s+` becomes `(?:bash|sh|source)[ \t]+`; update the line-51 comment to state that the separator is horizontal whitespace so a fence info string cannot consume the next line's interpreter word.
- `scripts/dev_tools/skill_bundle_contract.py:64`: `python3?\s+` becomes `python3?[ \t]+` (same defect class for a ` ```python` fence). The module pattern (lines 65-68) is unchanged.
- Net line change: 0 (file stays at 486 lines).
- Optional follow-on after the fix: switch `parallel-remove/SKILL.md:111` from ` ```shell` to ` ```bash`. Not required.

### FU-763-3

New files (names proposed):

- `.claude/lib/bash/parallel-mutation.sh` — sourceable library, sources `parallel-common.sh` and `parallel-cohorts.sh`. Pure functions: `pm_decide_removal`, `pm_recolor_unstarted`, `pm_build_remove_entry`, with results in `PM_RESULT`/`PM_ERROR` (the `PCOH_*` convention). `pm_recolor_unstarted` computes the overlap check, the negative-`current_cohort` check, `crosses_pinned`, and the induced edge list, calls `pcoh_compute_cohorts`, and applies the uniform offset. The library is reusable by later ports of `parallel-add`, `parallel-close`, and the drift requeue.
- `.claude/lib/bash/remove-parallel-item.sh` — entry point with three subcommands that map one-to-one to the three Python functions:

```shell
bash .claude/lib/bash/remove-parallel-item.sh decide --item <key> [--state <state>] [--removal-disposition detach|abandon]
bash .claude/lib/bash/remove-parallel-item.sh recolor --unstarted "<k> ..." [--edges "<a>:<b> ..."] --pinned "<k> ..." --generation <g> --current-cohort <c> --highest-pinned-cohort <h>
bash .claude/lib/bash/remove-parallel-item.sh entry --item <key> --prior-state <state> [--removal-disposition detach|abandon] --recompute true|false --generation <g> [--at <timestamp>]
```

- `decide` stdout: `{"item_key":<k>,"prior_state":"<s>","new_state":"withdrawn","disposition":<"d"|null>,"triggers_recompute":<bool>}`. An omitted `--state` means the key resolves to no `items[]` entry (`UnknownItemError`). `--state` must be a member of `PC_VALID_ITEM_STATES`, otherwise usage error.
- `recolor` stdout: `{"cohort_assignments":{"<k>":<index>,...},"generation":<g+1>}`, keys in ascending numeric order. Edge and key lexis as in `compute-cohorts.sh`.
- `entry` stdout: the seven-field `mutations[]` object in F3 field order (`op`, `item_key`, `at`, `prior_state`, `new_state`, `disposition`, `recolor_generation`). `--at` defaults to `date -u +%Y-%m-%dT%H-%M`, following the drift entry point's `-At` default (#763 spec line 111).
- Option naming: use `--removal-disposition`, never `--disposition`, so neither `decide` nor `entry` enters the abandon gate (see Hook interaction).
- Declared divergences (header comment in both the script and the parity lanes): usage-level rejection of a disposition outside `detach abandon` (exit 2) instead of the Python `UnknownEnumMemberError` text, which lists merge-status members (latent Python defect above); `at` is a caller-supplied string instead of a `datetime`; option abbreviations are rejected.
- Estimated size: library about 200-260 lines, entry point about 150-200 lines (inferred from `abandon-parallel-item.sh` at 176 and `compute-cohorts.sh` at 143); both stay under 500.

Skill text (`.claude/skills/parallel-remove/SKILL.md`):

- Step 2: replace lines 76-78 with a fenced `decide` invocation; a non-zero exit is the rejection, surface the stderr line and stop.
- Step 3: replace the `recolor_unstarted(...)` call at lines 81-83 with a fenced `recolor` invocation; keep the normative paragraphs at lines 84-96 and rename `RecolorResult.cohort_assignments`/`.generation` to the JSON fields.
- Step 6: replace "built by `build_remove_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`" with a fenced `entry` invocation; keep the table at lines 123-127.
- Name the Python module once as the retained parity reference in prose, without an invocation verb, matching the existing citation at line 150.
- Use ` ```shell` fences unless FU-763-5 lands in the same change (then any fence works). The guard then extracts `.claude/lib/bash/remove-parallel-item.sh` and checks it against the bundle and `core.json`, which is sufficient; no guard change is needed.
- Keep step 5's abandon line as the file's only line containing both `abandon-parallel-item.sh` and `--`.

Registration: add the new two files to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (near lines 171-182), add byte-identical bundle copies, and add `"Bash(bash .claude/lib/bash/remove-parallel-item.sh*)"` to `.claude/agents/parallel-orchestrator.md` `tools` (the forked skill runs under that agent) and to `.claude/settings.json` (to avoid a permission prompt, consistent with FU-763-2).

### FU-763-2

Insert into `.claude/settings.json` `permissions.allow`, keeping alphabetical order of the bash entries (before line 8):

```json
"Bash(bash .claude/lib/bash/abandon-parallel-item.sh*)",
```

Also add `"Bash(bash .claude/lib/bash/remove-parallel-item.sh*)",` after `compute-concurrency-batches.sh*` (alphabetical). Apply the identical edit to `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`. The abandon command stays gated by the `PreToolUse` hook at `.claude/settings.json:123`.

### FU-763-1

- Delete `.claude/agents/parallel-orchestrator.md:17` (`"Bash(poetry run python -m *)"`) and the bundle copy line 17.
- Rewrite the prose at lines 98-107 to state that the `-m` grant was removed under #791 because no caller uses it, that the `-c` grant remains for the repository-local engine calls in `parallel-add`, `parallel-close`, and `parallel-orchestrate`, and that the grant stays scoped to `poetry run python -c`.
- Do not change line 16 (`-c`) in this issue.

## Requirements Mapping

| Follow-up | Acceptance evidence (proposed) |
| --- | --- |
| FU-763-5 | A ` ```bash`/` ```sh` fence followed by `bash`/`sh`/`source <path>` yields the path; a ` ```python` fence followed by `python <path>.py` yields the path; `extract_script_references(parallel-plan SKILL.md)` contains `.claude/lib/bash/compute-cohorts.sh`; `test_every_skill_script_reference_is_bundled` passes. |
| FU-763-3 | `parallel-remove/SKILL.md` names neither `parallel_mutation_protocol` nor the three function names; the guard extracts `.claude/lib/bash/remove-parallel-item.sh` from it; bats unit, parity, and payload-only suites pass; kcov line coverage >= 85% for both new files. |
| FU-763-2 | Both `settings.json` copies contain the abandon (and new remove) allow entries; bundle byte-identity test passes. |
| FU-763-1 | Neither agent copy contains `poetry run python -m`; the `-c` entry is unchanged; surface-contract tests pass. |

## Numeric Derivation Evidence

Claim 1: `.claude/lib/bash` contains five CLI entry points today (relevant if `parallel_bash_manifest_membership.bats:84-89` is extended to six).

- Complete Family: `*.sh` files directly under `.claude/lib/bash/`.
- Exhaustive Search Scope: all 12 files listed by Glob `.claude/lib/bash/**`.
- Inclusion Rules: file is executed directly (strict mode at top level and a usage block).
- Exclusion Rules: sourceable libraries without top-level `set -euo pipefail`.
- Primary Search Strategy: Grep `^set -euo pipefail` (files_with_matches) over `.claude/lib/bash`.
- Primary Member Set: `abandon-parallel-item.sh`, `compute-cohorts.sh`, `compute-concurrency-batches.sh`, `report-lane-assertion.sh`, `validate-parallel-manifest.sh`.
- Primary Count: 5.
- Cross-check Search Strategy: Grep `^#   bash \.claude/lib/bash/|^# Usage|^Usage: ` (files_with_matches) over `.claude/lib/bash`; independently, the literal list at `tests/shell/parallel_bash_manifest_membership.bats:85`.
- Cross-check Member Set: `abandon-parallel-item.sh`, `compute-cohorts.sh`, `compute-concurrency-batches.sh`, `report-lane-assertion.sh`, `validate-parallel-manifest.sh` (both cross-checks).
- Cross-check Count: 5.
- Member-set Comparison: identical normalized sets. After FU-763-3 the count becomes 6 (adding `remove-parallel-item.sh`) and the library file total becomes 14 (Glob currently lists 12; the membership floor `MINIMUM_LIB_FILE_COUNT=11` at line 21 remains satisfied).

Claim 2: five skills fork into `parallel-orchestrator`.

- Complete Family: every `.claude/skills/*/SKILL.md`.
- Exhaustive Search Scope: all skills under `.claude/skills`.
- Inclusion Rules: frontmatter `agent: parallel-orchestrator`.
- Exclusion Rules: other agents.
- Primary Search Strategy: Grep `agent: parallel-orchestrator` over `.claude`.
- Primary Member Set: `parallel-add`, `parallel-close`, `parallel-orchestrate`, `parallel-remove`, `parallel-run`.
- Primary Count: 5.
- Cross-check Search Strategy: Grep `^agent: ` over `.claude/skills` (all agents), filtered to the `parallel-orchestrator` value; plus Glob `.claude/skills/parallel-*/SKILL.md` (6 files, of which `parallel-plan` routes to `parallel-planner`).
- Cross-check Member Set: `parallel-add`, `parallel-close`, `parallel-orchestrate`, `parallel-remove`, `parallel-run`.
- Cross-check Count: 5.
- Member-set Comparison: identical.

## Testing Implications

Python (FU-763-5), in `tests/scripts/dev_tools/test_skill_bundle_contract.py` (282 lines; room for about 40 added lines):

- A parametrized test over fence words `bash`/`sh` and verbs `bash`/`sh`/`source` with text ` ```<fence>\n<verb> scripts/tools/example.sh --flag\n``` ` asserting `("scripts/tools/example.sh",)`. Must fail before the fix.
- A test for ` ```python\npython scripts/tools/example.py\n``` ` asserting `("scripts/tools/example.py",)`.
- A negative test: `Use bash\nscripts/tools/example.sh` (verb at line end, path on the next line) yields `()`, which pins the horizontal-whitespace rule.
- In `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`: `parallel-plan` extracts `.claude/lib/bash/compute-cohorts.sh` (real-repository regression, follows `test_ci_gate_parser_skills_invoke_bundled_parser`), and `parallel-remove` extracts `.claude/lib/bash/remove-parallel-item.sh` and contains no `parallel_mutation_protocol` text.

Bash (FU-763-3), mirroring the #763 abandon layout:

- `tests/shell/parallel_mutation_remove.bats`: every subcommand, each rejection row, each usage error, `--at` default through a checked-in `date` shim directory, sourcing the library for function-level cases. No temporary files.
- `tests/shell/parallel_mutation_remove_parity.bats` and `tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py` over a shared corpus `tests/fixtures/parallel_mutation_remove/*.json`, each lane failing on an empty corpus and enforcing a fixture-count floor. The Python lane calls `decide_removal`, `recolor_unstarted`, and `build_remove_entry` in-process with a fixed clock and compares all fields except `at`; the bats lane asserts `at` echoes `--at`.
- `tests/shell/parallel_payload_only.bats`: one case running the bundle copy with `PATH=tests/fixtures/parallel_payload_path` and an explicit `--at` (that PATH has no `date`).
- `tests/shell/parallel_bash_manifest_membership.bats:84-89`: add `remove-parallel-item.sh` to the entry-point list.
- `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`: a case asserting that `bash .claude/lib/bash/remove-parallel-item.sh decide --item 5 --state in_flight --removal-disposition abandon` is out of scope for the gate.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans `.claude/lib`; the new files must contain no Python invocation.

Toolchain facts:

- Python: `poetry run black <files>`, `poetry run ruff check <files>`, `poetry run pyright <files>`, `poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_parallel_abandon_token_seam.py --cov --cov-branch`. Coverage source is configured as `["src", "scripts/dev_tools"]` (`pyproject.toml:119-120`); `addopts` writes `artifacts/python/lcov.info` (line 116). Do not pass `--cov=<file>.py`, which measures nothing; use bare `--cov` or a dotted module.
- Key node IDs: `tests/scripts/dev_tools/test_skill_bundle_contract.py::test_extract_reads_bash_sh_and_source_forms`, `::test_extract_reads_python_path_form`, `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled`, `::test_known_unbundled_references_are_not_stale`, `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py::test_bundle_guard_extracts_the_skill_invocation`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`.
- Bash: `scripts/bash/shell-qc.sh format`, `check` (shfmt diff plus shellcheck), and `test [--coverage]` (bats over `tests/shell` and `tests/bash`; kcov with include pattern covering `.claude/lib/bash`, `scripts/bash/shell_qc_lib.sh:350`; output `artifacts/pester/kcov`). CI gate: `.github/workflows/_shell-coverage.yml:51-55`. kcov measures lines only; no branch threshold applies.
- Local execution on Windows in an agent worktree: command text containing `bash`, `pwsh`, or `wsl` may be refused by the worktree isolation guard; `sh <file>` runs scripts locally, and the CI `_shell-coverage.yml` run is the authoritative bats/kcov gate (#763 spec line 240).
- TypeScript: `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (Jest) checks manifest union membership; optionally add the new files to its `it.each` list at lines 237-246.

## Automation Feasibility

No step requires human interaction. All edits are file edits; all verification runs through pytest, bats/kcov (CI), Pester, and Jest. The only environment caveat is the local agent-worktree restriction on command text containing `bash`, which is handled by `sh <file>` locally and by the CI shell-coverage workflow.

## Files Likely Written

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

FU-763-2 (plus the new remove entry from FU-763-3):
- `.claude/settings.json`
- `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`

FU-763-1 (plus the new remove tool entry from FU-763-3):
- `.claude/agents/parallel-orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md`

Feature documents (orchestrator-owned): `spec.md`, `plan.*.md`, and evidence under `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/evidence/<kind>/`.

No sync script exists for the bundle (Grep `resources/claude-customizations` over `scripts/` matched only `skill_bundle_contract_cli.py`, `push_down_claude_pack_selection.py`, `push_down_claude_customizations.py`, none of which copies the repository tree into the bundle). Mirrors are maintained by hand and enforced by `test_push_down_claude_resource_contracts.py` and `parallel_bash_manifest_membership.bats`.

## Open Items for the Planner

- Confirm that #791's scope stops at `parallel-remove`; record `parallel-add`, `parallel-close`, and the `parallel-orchestrate` requeue/recolor calls as a follow-up that reuses `parallel-mutation.sh`.
- Decide whether the line-64 (`python`) fix is in scope; this research recommends including it because it is the same defect and adds no lines.
- Record the `UnknownEnumMemberError` member-list defect (`_parallel_mutation_errors.py:192`) as a separate follow-up.
- No `quality-tiers.yml` exists (#734); classify the new bash files T3 per #763 D8.
