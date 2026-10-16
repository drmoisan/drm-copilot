# Commit Order and NB-4 Isolation (P9-T18)

Timestamp: 2026-10-16T05-17

## Gate 1

Command: git log --reverse --format=%H%x20%s origin/main..HEAD
EXIT_CODE: 0
Output:
```
46338ecda9148426ee25d4cc0ac4b0070467e10f docs(929): initialize active bug folder for SubagentStop artifact-gate review notes
c16a0e86b990470423eca27da066311ebc7c8949 docs(929): add research for SubagentStop artifact-gate review notes
bd404f3c08daa72e72bc2af9655e50e1215c931b docs(929): add bug spec for SubagentStop artifact-gate review notes
d490466fa8797e6758d61885a192158fe9c5ffa3 docs(929): add atomic plan for SubagentStop artifact-gate review notes
51830a80db38293caf8e017684e561b8b62394b1 docs(929): revise atomic plan after executor preflight round 1
93a868f8d405eb7ff5108969e318c5c07a31ab75 docs(929): revise atomic plan after executor preflight round 2
ac9df3ed9f4b029b11f7ea307a3c9fda91bad09c docs(929): revise atomic plan after executor preflight round 3
44fd115766ad8064d518c979407894e7a3a90a17 docs(929): record phase 0 baseline evidence
61e07a80c2903bef6ddbdf4b65828fec8df01e5d test(929): add R3 characterization rows (NB-1, NB-2)
c363c61d0e31c78916d5ba9ebfd550375ff6b1d1 test(929): add R4 trim-only token cases (NB-3)
9be5b637ea9f91726d670b0a21e284be0228e15a test(929): add discovery validator dispatch suite (NB-9)
0564d4a5bc352b28989088354e48713cc0366b66 test(929): pin in-process dependency-decision return (NB-11)
337071aa44410495ebacc4743c89dff67a5040fc docs(929): check off P4-T4 (Phase 4 commit 0564d4a5 pushed)
392e43e1c4e3720f4c0f17ade9c64fc69d5eebe7 Merge remote-tracking branch 'origin/main' into bug/subagentstop-artifact-gates-review-notes-929
82f10e0dd116f548d4f4f15e00b8ad1929919bdd fix(929): remove redundant agentOutput alias (NB-5)
2a67e63d887ff50f5aad317344bf3ff23d7c9749 docs(929): add E3 post-review clarifications (NB-7, NB-8)
471dbcd3fb364aef98ee8bbd3e97164eff0c8b12 docs(929): record issue 928 sequencing check
93a06a8cbbc908b5dadc96649fbe48acc0b27c15 test(929): extract shared SubagentStop envelope helper (NB-4)
dc91a92d58c8d2aa1ad99bcc86ad2f25dd604138 chore(929): merge origin/main after NB-4 conversion
e0e3d76136c2fd62db41c723f0d76159bf5bc689 test(929): convert call sites merged from main (NB-4 follow-up)
```

## Gate 2

Command: git log --format=%H --fixed-strings --grep='(NB-4)' origin/main..HEAD
EXIT_CODE: 0
Output:
```
93a06a8cbbc908b5dadc96649fbe48acc0b27c15
```

## Gate 3

Command: git diff --name-only 93a06a8cbbc908b5dadc96649fbe48acc0b27c15..HEAD
EXIT_CODE: 0
Output (40 paths):
```
docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/... (35 paths; the full list equals the 35 docs paths of Gate 4)
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/other/e3-folder-location-follow-up.2026-10-16T04-24.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/nb4-follow-up.2026-10-16T04-25.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/plan.2026-10-15T15-44.md
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1
tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
```

## Gate 4

Command: git diff --name-only dc91a92d58c8d2aa1ad99bcc86ad2f25dd604138^1 dc91a92d58c8d2aa1ad99bcc86ad2f25dd604138
EXIT_CODE: 0
Output (37 paths): 35 paths under `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/` and
```
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1
tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
```

## Gate 5

Command: git status --porcelain -- tests .claude extensions
EXIT_CODE: 0
Output:
```
```

No `git diff-tree` command was run: the QA-loop commit set is empty.

Output Summary:
- Exactly one commit carries `(NB-4)`: `93a06a8cbbc908b5dadc96649fbe48acc0b27c15`, equal to the hash recorded at P8-T16.
- Every implementation commit of Phases 1 to 6 (`61e07a80c`, `c363c61d0`, `9be5b637e`, `0564d4a5b`, `82f10e0dd`, `2a67e63d8`) precedes it in the reverse log.
- QA-LOOP-COMMITS: NONE.
- Every path in the post-NB-4 name-only diff is in the allowed path set, by source: the 3 `docs/features/active/subagentstop-artifact-gates-review-notes-929/` paths (feature folder); the 35 `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/` paths and the 2 `tests/scripts/codex-hooks/` paths (P8-T17 merge `dc91a92d5`, each present in the Gate 4 list). No P8-T17 `ADDITIONAL:` path and no `E3_SPEC` re-insertion occurred.
- The porcelain command prints nothing.
- Restated: P7-T1 classified #928 as `NOT-MERGED`; P8-T15 recorded `MAIN-MOVED` (followed by the P8-T17 merge) (AC-10).
