# Pin Site Survey (remediation cycle 3)

Timestamp: 2026-10-16T07-19
Command: git ls-files -- '*parallel_orchestrator_surface_expectations*'
EXIT_CODE: 0
Output Summary:
- `git ls-files -- '*parallel_orchestrator_surface_expectations*'` -> EXIT 0
  - `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (one path; no bundle mirror)
- `git grep -l -F -e "d5e5e3b015c810fd12911e0ecffee38e12122bcdf667683778c7bd6cbdf6f538" -- . ':(exclude)docs'` -> EXIT 0
  - `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- `git grep -l -F -e "0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2" -- . ':(exclude)docs'` -> EXIT 0
  - `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- `wc -l tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` -> `381` (EXIT 0)
- N_PIN: 381
- `grep -c -F "RE-BASELINED by issue #" PIN` -> `8` (EXIT 0)
- `grep -c -F "RE-BASELINED by issue #928" PIN` -> `0` (EXIT 1, expected for a zero count)
- `sed -n 164,165p PIN` (EXIT 0):
  - `# agent digest is unchanged and the pin stays live for both entries.`
  - `PINNED_FROZEN_SURFACE_HASHES: tuple[tuple[str, str], ...] = (`
- `sed -n 167,168p PIN` (EXIT 0):
  - `        ".claude/agents/epic-orchestrator.md",`
  - `        "d5e5e3b015c810fd12911e0ecffee38e12122bcdf667683778c7bd6cbdf6f538",`
- `sed -n 171,172p PIN` (EXIT 0):
  - `        ".claude/skills/epic-orchestrate/SKILL.md",`
  - `        "0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2",`
- Result: single carrier of both old digests; no stop condition.
