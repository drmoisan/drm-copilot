# parallel-skills-python-engine-calls-and-enum-error-members (Issue #890)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-skills-python-engine-calls-and-enum-error-members/ (Issue #890)
- Origin: issue #791 (PR #875), `follow-ups.md` items FU-791-1 and FU-791-2 and the spec's accepted residual risks; parallel run bug-burndown-2026-10-08

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #890
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/890
- Last Updated: 2026-10-11
## Summary

Three items remain after #791: (1) FU-791-1, the `parallel-add`, `parallel-close` and `parallel-orchestrate` skills still instruct the agent to call functions of the repository-local Python engine `scripts/dev_tools/parallel_mutation_protocol.py`, which does not exist in a pushed-down destination workspace; (2) FU-791-2, `UnknownEnumMemberError` lists merge-status members for any rejected field other than `state`; (3) two residual risks accepted by the operator for #791 that should stay visible.

## Environment

- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: `/parallel-add`, `/parallel-close`, `/parallel-orchestrate` in a pushed-down destination workspace; `parallel_mutation_protocol` with an invalid `disposition`
- Data source or fixture: main at 2ef8d361

## Steps to Reproduce

1. Push the Claude customizations down into a workspace that does not contain `scripts/dev_tools/`.
2. Run `/parallel-close` (or `/parallel-add`) and follow the skill text.
3. Separately, call the parallel mutation protocol with an invalid `disposition` value and read the error message.

## Expected Behavior

- The parallel skills use only the bash engine under `.claude/lib/bash/` (as #763 and #791 did for the other call sites) and work in a destination workspace.
- `UnknownEnumMemberError` lists the allowed members of the field that was rejected.

## Actual Behavior

- Engine-call text remaining on main:
  - `.claude/skills/parallel-add/SKILL.md:100-101` `decide_admission(...)`, `:108` `recolor_unstarted(...)`, `:150` `build_add_entry`
  - `.claude/skills/parallel-close/SKILL.md:48-49` "Call `decide_close(items)` from `scripts/dev_tools/parallel_mutation_protocol.py`", `:55` `build_close_entry`
  - `.claude/skills/parallel-orchestrate/SKILL.md:665-666` "The decision logic for all three commands is the pure engine `scripts/dev_tools/parallel_mutation_protocol.py`.", `:821` `build_requeue_entry`, `:829` `recolor_unstarted(...)`
  - The bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-{add,close,orchestrate}/SKILL.md` carry the same text.
  - `.claude/agents/parallel-orchestrator.md:16` still grants `Bash(poetry run python -c *)`.
- `scripts/dev_tools/_parallel_mutation_errors.py:192`: `allowed = VALID_ITEM_STATES if field_name == "state" else VALID_MERGE_STATUS`. `scripts/dev_tools/parallel_mutation_protocol.py:412` raises `UnknownEnumMemberError(item_key, "disposition", disposition)`, so a rejected disposition reports merge-status values. The docstring at line 182 says the field is "Either ``state`` or ``merge_status``".

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/follow-ups.md:30-38` (FU-791-1): "The `parallel-add`, `parallel-close`, and `parallel-orchestrate` skills still instruct the agent to call functions of the repository-local Python engine, which does not exist in a pushed-down destination workspace." Line numbers there ("current 658, 813, 821") have moved to 666, 821, 829.
- Snippet: same file, lines 46-49 (FU-791-2): "A rejected value for a field such as `disposition` therefore produces a message listing merge-status values".
- Residual risks, `spec.md:282`: "(a) a timed-out hook does not block, and the call continues through the normal permission flow, where the abandon allow entry would then skip the prompt; ... (b) an installed plugin mod that handles `tool.check` can approve a hook-blocked call regardless of the allow entries. These residual risks are accepted for this issue ... The operator may revisit this acceptance." Restated in PR #875 under "Operator-accepted residual risks" and in `feature-audit.2026-10-10T09-05.md:74`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. In destination workspaces `/parallel-add` and `/parallel-close` cannot perform their decision step as written. The enum message defect misleads diagnosis only. The residual risks are accepted, not defects, and are recorded so they can be revisited.

## Suspected Cause / Notes

- #791 ported the abandon path and some call sites to bash but deferred admission, close, add-entry and requeue-entry functions.
- `.claude/lib/bash/parallel-mutation.sh` is the reuse point named by FU-791-1.
- Residual-risk sources: `research/research-addendum.2026-10-08T17-10.md:118-119` (citations 4 and 8).

## Proposed Fix / Validation Ideas

- [ ] Add bash admission, close, add-entry and requeue-entry functions to `.claude/lib/bash/parallel-mutation.sh` with parity corpora against the Python engine, and rewrite the skill text to call them; update the bundled mirrors.
- [ ] Once no skill in the persona's caller set invokes the Python engine, reassess removing `Bash(poetry run python -c *)` from `.claude/agents/parallel-orchestrator.md`.
- [ ] Select the allowed-member list per field in `UnknownEnumMemberError` (including `disposition`), with a unit test per field.
- [ ] Manual verification notes: record whether the operator still accepts the hook-timeout and plugin-approval residual risks.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch