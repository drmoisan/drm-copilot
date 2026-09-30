# Phase 0 Frozen-Surface Pin Baseline

Timestamp: 2026-09-30T09-38

Plan task: [P0-T14]

Command: poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -rf

EXIT_CODE: 0

Output Summary: 36 passed, 0 failed. `sha256sum .claude/skills/epic-orchestrate/SKILL.md` prints `4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8`, which equals the current pin at `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` line 150. It does not equal the planning-time literal `620183f57a337dedf6158d61264b2257d012762454a9af0b3b6f059ff79ab00b` that the plan's acceptance names. The pin and the skill were both changed upstream (commit 8ae639e3, #690, an ancestor of origin/main a24a1ce3) and entered this branch through merge commit 09750b68. Acceptance NOT MET on the digest-equality condition only.

## pytest summary line (verbatim)

```text
============================= 36 passed in 0.15s ==============================
```

## sha256sum

Command: sha256sum .claude/skills/epic-orchestrate/SKILL.md

EXIT_CODE: 0

```text
4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8 *.claude/skills/epic-orchestrate/SKILL.md
```

First whitespace-delimited field: `4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8`

## Acceptance evaluation

| Condition | Observed | Met |
|---|---|---|
| EXIT_CODE 0 | 0 | yes |
| Summary contains `36 passed`, no `failed` | `36 passed in 0.15s` | yes |
| sha256 first field equals `620183f57a337dedf6158d61264b2257d012762454a9af0b3b6f059ff79ab00b` | `4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8` | no |

## Discrepancy analysis (planning-time literal changed by upstream merge)

- Current pin, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` line 149-150: `.claude/skills/epic-orchestrate/SKILL.md` -> `4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8`. It matches the observed file digest, so the frozen-surface test passes.
- Agent pin line 145-146 is unchanged: `0d01e5484d63e418a6bc31f219aecaef7381cc439a4a796664006879f6a027ba`.
- Command: `git log --oneline -3 -- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (EXIT_CODE 0) lists `8ae639e3 test(690): re-baseline the frozen epic-surface digest pins` as the latest commit.
- Command: `git merge-base --is-ancestor 8ae639e3 origin/main` (EXIT_CODE 0): the re-baseline commit is on origin/main.
- Command: `git grep -n -F -e "620183f57a337dedf6158d61264b2257d012762454a9af0b3b6f059ff79ab00b" -- tests scripts extensions .claude` returned no matches: the planning-time digest is no longer present outside `docs/`.
- The same upstream change added two lines to the skill (323 -> 325; see `p0-line-counts.md`), which moved the Layer 2 bullet from lines 241-245 to lines 243-247.

Impact on later tasks: [P1-T15] re-baselines this digest and its comment block. It must now replace `4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8` rather than `620183f5...`. The file still has 359 lines with the pin at line 150. Its comment block carries RE-BASELINED paragraphs for #559 (line 108), #673 (line 124), #663 (line 131), and #762 (line 138), and none for #690. Commit 8ae639e3 therefore appears to have changed the digest literal without adding a comment paragraph. Whether [P1-T15] should also record #690 is a decision for the planner.

## Result

NOT GREEN - sha256 first field `4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8` does not equal planning-time literal `620183f5...ab00b`; the change comes from upstream re-baseline commit 8ae639e3 (#690) that arrived through the origin/main merge. The frozen-surface test itself passes (36 passed).
