# parallel-skills-python-engine-calls-and-enum-error-members (Issue #890)

- Work Mode: minor-audit
- Issue: #890
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/890
- Type: bug
- Lifecycle record: `origin/docs/followups-2026-10-11:docs/features/potential/promoted/2026-10-11-parallel-skills-python-engine-calls-and-enum-error-members.md` (unmerged branch; cited by ref)
- Research: `research/2026-10-11T12-35-parallel-skills-python-engine-calls-research.md`

## Problem / Why

Three items remain after #791 (PR #875):

1. FU-791-1. The `parallel-add`, `parallel-close`, and `parallel-orchestrate` skills, and their bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`, still instruct the agent to call functions of the repository-local Python engine `scripts/dev_tools/parallel_mutation_protocol.py` (`decide_admission`, `recolor_unstarted`, `build_add_entry`, `decide_close`, `build_close_entry`, `build_requeue_entry`). That engine does not exist in a pushed-down destination workspace, so `/parallel-add` and `/parallel-close` cannot perform their decision step there. `.claude/agents/parallel-orchestrator.md` still grants `Bash(poetry run python -c *)`.
2. FU-791-2. `UnknownEnumMemberError` in `scripts/dev_tools/_parallel_mutation_errors.py` selects `VALID_ITEM_STATES` for `state` and `VALID_MERGE_STATUS` for every other field, so a rejected `disposition` (raised from `parallel_mutation_protocol.py`) lists merge-status values. The docstring says the field is "Either `state` or `merge_status`". The bash library `.claude/lib/bash/parallel-mutation.sh` carries the same selection.
3. Two residual risks were accepted by the operator for #791 and must stay visible (see `## Operator-Accepted Residual Risks`).

## Implementation Intent

- Port every remaining Python-engine call instruction in the three skills to the bash engine under `.claude/lib/bash/`, reusing existing entry points (for example `remove-parallel-item.sh recolor`) and adding bash entry points, with bats tests and a parity corpus against the Python engine, for the functions that have no bash equivalent. Update the bundled mirrors and the core pack manifest.
- Remove `Bash(poetry run python -c *)` from `.claude/agents/parallel-orchestrator.md` only when nothing in the persona's caller set depends on it, and update the surrounding prose.
- Make `UnknownEnumMemberError` list the allowed members of the rejected field, with a test per field, and update the docstring; align the bash message selection and the comments describing the former divergence.

## Acceptance Criteria

- [x] AC-1: No line in `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-close/SKILL.md`, or `.claude/skills/parallel-orchestrate/SKILL.md`, or in their bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`, instructs the agent to call `scripts/dev_tools/parallel_mutation_protocol.py` or any of `decide_admission`, `recolor_unstarted`, `build_add_entry`, `decide_close`, `build_close_entry`, `build_requeue_entry`; each former call site names a bash entry point under `.claude/lib/bash/`.
- [x] AC-2: Every bash entry point the rewritten skill text names exists under `.claude/lib/bash/`, is mirrored byte-identically into the bundled payload and listed in the core pack manifest, and is covered by bats tests that include a parity corpus shared with a Python test against the Python engine; every new or edited file stays at or under 500 lines.
- [x] AC-3: `Bash(poetry run python -c *)` is removed from `.claude/agents/parallel-orchestrator.md` (and its bundled mirror, if one exists) only if no skill or agent the persona uses still depends on it; the decision and its evidence are recorded in the feature folder, and every new command line added to `parallel-orchestrate` has a matching `Bash(...)` grant so `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py` passes.
- [x] AC-4: `UnknownEnumMemberError` lists the allowed members of the rejected field for `state`, `merge_status`, and `disposition` (and any other field passed by a raise site), proven by one unit test per field; the docstring no longer restricts the field to `state` or `merge_status`; the bash message selection in `.claude/lib/bash/parallel-mutation.sh` and the comments describing the former divergence are aligned.
- [x] AC-5: The two operator-accepted residual risks from #791 are recorded unchanged in this feature folder under `## Operator-Accepted Residual Risks`, with their acceptance status unchanged, for carry-forward into the PR body.
- [x] AC-6: Python toolchain (black, ruff, pyright, pytest) passes on the changed Python files with line coverage >= 85% and branch coverage >= 75% for each changed Python production module; PoshQC analysis is clean for any changed PowerShell file; the PR CI `shell-coverage` job (Bats + kcov) passes with the new bats tests included.
- [x] AC-7: The overlap zones owned by other items in run bug-burndown-2026-10-11 are not rewritten: `parallel-add` step 2 (#885) and the child-DONE CI acceptance passage of `parallel-orchestrate` (#899).

## Operator-Accepted Residual Risks

Source: `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/spec.md` (around line 282), restated in PR #875 under "Operator-accepted residual risks" and in that folder's `feature-audit.2026-10-10T09-05.md` (around line 74). Acceptance status: accepted by the operator for #791; unchanged by #890. The operator may revisit this acceptance.

- (a) A timed-out hook does not block, and the call continues through the normal permission flow, where the abandon allow entry would then skip the prompt.
- (b) An installed plugin mod that handles `tool.check` can approve a hook-blocked call regardless of the allow entries.

## Dependencies / Risks

- Concurrent items in run bug-burndown-2026-10-11 edit the same skill files: #885 (parallel-add step 2) and #899 (parallel-orchestrate child-DONE CI acceptance passage). Edits stay local to the engine-call lines.
- Bats and kcov results come only from PR CI; local verification of shell and PowerShell code uses PoshQC MCP tools only.
- Out of scope, recorded for a later follow-up (no new issue is filed by this run): `parallel-orchestrate/SKILL.md` names two further Python-only functions, `has_unresolved_drift` and `request_requeue_via_recolor`, which are not invoked through the `python -c` grant.

## Operator Approvals

- 2026-10-12: the operator approved adding the allow entry `"Bash(bash .claude/lib/bash/mutate-parallel-run.sh*)"` to `.claude/settings.json` and its bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (precedent: #791). No other permission change beyond the plan is approved. Evidence: `evidence/other/operator-approval-settings-allow-890.md`.

## Verification Steps

- Search the three skills and mirrors for the six function names and `parallel_mutation_protocol`.
- Run the bundled-payload contract test and the parallel-orchestrator permission-contract test.
- Run the new Python parity test and the FU-791-2 unit tests with coverage.
- Read the PR CI `shell-coverage` job result for the new bats suites.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
