# parallel-skills-invoke-unbundled-python-clis (Issue #763)

- Date captured: 2026-09-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-skills-invoke-unbundled-python-clis/ (Issue #763)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #763
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/763
- Last Updated: 2026-09-28
## Summary

Two pushed-down skills invoke Python CLIs that are not bundled with them: `parallel-orchestrate` runs `poetry run python -m scripts.dev_tools.parallel_drift_detection_cli` and `parallel-remove` runs `poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py`. Neither the CLIs, their `scripts.dev_tools` import closure, nor a Poetry environment ship in the push-down payload, so both steps fail in consumer repositories. Found by the skill-bundle audit for issue #762, which registers both references as tracked exceptions in the new guard until this issue is fixed.

## Environment

- OS/version: any consumer repository that receives the Claude push-down
- Python version: n/a in consumers (no Poetry project)
- Command/flags used: the two invocations quoted above
- Data source or fixture: `.claude/skills/parallel-orchestrate/SKILL.md` (CLI Invocation section), `.claude/skills/parallel-remove/SKILL.md` (step 5)

## Steps to Reproduce

1. Push down the Claude customizations into a consumer repository.
2. Run a parallel item that reaches drift detection, or remove an in-flight item with the `abandon` disposition.
3. The Python module is not present in the consumer, so the command fails.

## Expected Behavior

Each script the skills invoke is part of the push-down bundle (for example a destination-runtime bash or PowerShell port under `.claude/lib/`, as was done for cohort computation and manifest validation), and the guard exception entries for issue #762 are removed.

## Actual Behavior

Both commands depend on `scripts/dev_tools/**` and Poetry, which consumers do not receive.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: n/a

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Relocating the files is not sufficient: `parallel_drift_detection_cli.py` imports `scripts.dev_tools.parallel_drift_detection`, `_parallel_drift_cli_io`, and `parallel_drift_resolution`; `parallel_mutation_abandon_cli.py` imports `scripts.dev_tools._parallel_state_common`, and its tokens are pinned by `.claude/hooks/enforce-parallel-abandon-gate.ps1` and `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`. A port to the Python-free destination runtime is required.

## Proposed Fix / Validation Ideas

- [ ] Port both CLIs to `.claude/lib/` (bash or PowerShell) with parity tests against the Python reference.
- [ ] Update both SKILL.md invocations and the abandon-gate token seam.
- [ ] Remove the two entries from `KNOWN_UNBUNDLED_REFERENCES` in `scripts/dev_tools/skill_bundle_contract.py`.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
