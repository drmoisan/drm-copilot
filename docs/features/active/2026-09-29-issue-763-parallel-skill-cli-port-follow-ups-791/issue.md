# Potential: follow-ups surfaced by issue #763 preparation

- Date captured: 2026-09-29
- Author: epic-planner (epic #770, `push-down-payload-correctness`)
- Source: preparation of issue #763. See `docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/spec.md` (decisions D4, D6, D7, D8) and the #763 preflight round 2.
- Status: Draft. Not promoted. Each entry below can be promoted on its own. FU-763-4 is already tracked by issue #734 and is listed here only for completeness.

---

- Work Mode: full-bug

## FU-763-1: Unused `Bash(poetry run python -m *)` grant after the port (spec D4)

After #763 ports `parallel_drift_detection_cli` to a destination-runtime script, none of the named callers use the `Bash(poetry run python -m *)` grant in `.claude/agents/parallel-orchestrator.md`. Remove it, or confirm that another caller needs it.

## FU-763-2: No settings allow entry for the ported abandon script (spec D6)

`.claude/settings.json` has no allow entry for the ported abandon script. The old invocation matched `Bash(poetry run *)`. The new script now prompts for permission. Add a narrowly scoped allow entry.

## FU-763-3: `parallel-remove` still calls Python in steps 2, 3 and 6 (spec D7)

`parallel-remove` steps 2, 3 and 6 still call Python in `parallel_mutation_protocol.py`, and the skill-bundle guard does not detect those calls. In a consumer repository without Poetry, those steps are unbundled in the same way #763 addresses for the abandon CLI.

## FU-763-4: `quality-tiers.yml` does not exist in the tree (spec D8)

Already tracked by issue #734. Do not promote separately.

## FU-763-5: The skill-bundle guard misses invocations directly under a bash fence

The invocation pattern in `scripts/dev_tools/skill_bundle_contract.py` (line 52) can match across the newline after a `bash` fence info string. When it does, it consumes the invocation's own interpreter word, so the guard does not extract a bash invocation that sits directly under a bash code fence. #763 works around this with a `shell` fence and leaves the regex defect unfixed. Any skill that uses a bash fence can bypass the guard without anyone noticing.

---

## Suggested promotion grouping

- **Promote first:** FU-763-5 and FU-763-3. Both let unbundled invocations bypass the guard.
- **Promote together:** FU-763-1 and FU-763-2. Both are permission-surface cleanup after the port.
- **Do not promote:** FU-763-4 (#734).
