# Digest Re-Baseline — Frozen Epic Surface

Timestamp: 2026-10-12T23-44
Command: poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -k frozen_epic_surface -v -p no:cacheprovider; sha256sum .claude/skills/epic-orchestrate/SKILL.md
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `1 failed, 1 passed, 34 deselected in 0.15s`.
- PASSED: `test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/agents/epic-orchestrator.md-d5e5e3b015c810fd12911e0ecffee38e12122bcdf667683778c7bd6cbdf6f538]` (persona digest unchanged).
- FAILED: `test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-66c7baa9b6fe4340a479d7de62d73fbdf57dbf6c96aa6c747456ef9d425e1326]`.
- `found` digest from the failure message: `0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2`.
- `sha256sum` first field: `0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2`.
- The two values are equal. Worktree file is `w/lf` (P1-T8).

Verbatim lines:

```text
...::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/agents/epic-orchestrator.md-d5e5e3b015c810fd12911e0ecffee38e12122bcdf667683778c7bd6cbdf6f538] PASSED [ 50%]
...::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-66c7baa9b6fe4340a479d7de62d73fbdf57dbf6c96aa6c747456ef9d425e1326] FAILED [100%]
E       AssertionError: .claude/skills/epic-orchestrate/SKILL.md must be byte-identical to its pre-feature state; expected SHA-256 66c7baa9b6fe4340a479d7de62d73fbdf57dbf6c96aa6c747456ef9d425e1326, found 0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2
================= 1 failed, 1 passed, 34 deselected in 0.15s ==================
0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2 *.claude/skills/epic-orchestrate/SKILL.md
```
