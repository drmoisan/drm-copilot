# orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails (Issue #798)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails/ (Issue #798)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #798
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/798
- Last Updated: 2026-09-30
- Work Mode: full-bug

## Summary

Two usability defects in the orchestration artifact validator. First, the orchestrator-state check requires a top-level `last_updated` key that neither the orchestrate skill nor `.claude/rules/orchestrator-state.md` documents, so a checkpoint written from those documents fails validation. Second, running `scripts/dev_tools/validate_orchestration_artifacts.py` by file path fails with `ModuleNotFoundError: No module named 'scripts'`; only the `-m` form works.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `validate_orchestration_artifacts orchestrator-state --require-pr-creation-ready <checkpoint>`; `python scripts/dev_tools/validate_orchestration_artifacts.py --help`
- Data source or fixture: any orchestrator checkpoint written from the documented schema

## Steps to Reproduce

1. From the repository root, run `python scripts/dev_tools/validate_orchestration_artifacts.py --help`.
2. Run `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state --help`.
3. Validate an orchestrator checkpoint that contains every key listed in `.claude/rules/orchestrator-state.md` and the orchestrate skill but no `last_updated`, using `orchestrator-state --require-pr-creation-ready`.
4. Search `.claude/skills/orchestrate/SKILL.md` and `.claude/rules/orchestrator-state.md` for `last_updated`.

## Expected Behavior

Both invocation forms run. Every key the validator requires is documented in the checkpoint contract that authors follow.

## Actual Behavior

- Step 1 fails: `File ".../validate_orchestration_artifacts.py", line 16, in <module> from scripts.dev_tools.epic_planner_readiness import ...` then `ModuleNotFoundError: No module named 'scripts'`. The script imports `scripts.dev_tools.*` at lines 16-40 and does not add the repository root to `sys.path`. Step 2 works.
- Step 3 fails with `Checkpoint missing required key: last_updated`. `REQUIRED_STATE_KEYS` contains `last_updated` (`scripts/dev_tools/validate_orchestrator_state.py:63`) and the loop at lines 401-403 reports it. The requirement is unconditional, not specific to `--require-pr-creation-ready`.
- Step 4 finds no match in either file. `last_updated` is documented only in other skills (`csharp-orchestration-state-machine`, `powershell-orchestration-state-machine`, `epic-orchestrate`, `parallel-orchestrate`, `parallel-plan`).

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: reproduced step 1 and step 2 on main at ae7c7779. The validator CLI help for `orchestrator-state` lists `--require-complete`, `--require-pr-creation-ready`, `--require-model-routing`, `--require-codex-model-routing`, and `--require-codex-topology`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Each defect costs an agent one failed round before it finds the workaround; the missing key is encountered at the point where PR creation is gated.

## Suspected Cause / Notes

The key list in the validator grew after the skill and rule text were written. The file-path invocation has never been supported because the script relies on the repository root being importable.

## Proposed Fix / Validation Ideas

- [ ] Document `last_updated` (format and when it is refreshed) in `.claude/rules/orchestrator-state.md` and the orchestrate skill, and add a documentation-parity check between `REQUIRED_STATE_KEYS` and the rule.
- [ ] Either make the file-path invocation work (insert the repository root in `sys.path` in a thin `__main__` guard) or state in the skill and rule text that only `python -m scripts.dev_tools.validate_orchestration_artifacts` is supported and fail with a clear message otherwise.
- [ ] Add a test covering the chosen invocation contract.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
