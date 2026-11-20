# Phase 0 Python Runtime Verdicts (P0-T30, P0-T31)

Timestamp: 2026-09-27T14-56

## P0-T30 case table

Command: poetry run python -c "import json, pathlib, sys; d = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding='utf-8')); print('CASES=' + str(len(d['cases'])))" `<scratchpad>`/phase0-cases.json

EXIT_CODE: 0

Output: CASES=17

## P0-T31 runtime verification

Command: poetry run python `<scratchpad>`/phase0_python_verdicts.py `<scratchpad>`/phase0-cases.json (output saved to `<scratchpad>`/phase0-python-output.txt)

EXIT_CODE: 0

Full output:

```
MODULE_UNDER_ROOT=True
ROOT_SURFACES_SELF_HOSTED=package-lock.json,poetry.lock,quality-tiers.yml
ROOT_SURFACES_BUNDLED=package-lock.json,poetry.lock,quality-tiers.yml
TOKEN poetry.lock with_roots=concrete without_roots=None
TOKEN package-lock.json with_roots=concrete without_roots=None
TOKEN quality-tiers.yml with_roots=concrete without_roots=None
TOKEN Poetry.lock with_roots=None without_roots=None
TOKEN pyproject.toml with_roots=None without_roots=None
EXTRACT poetry.lock with_roots=('poetry.lock',) without_roots=()
EXTRACT package-lock.json with_roots=('package-lock.json',) without_roots=()
EXTRACT pyproject.toml with_roots=() without_roots=()
ENTRY scripts/dev_tools | scripts/dev_tools/** forward=True reverse=True
ENTRY scripts/dev_tools | scripts/dev_tools_extra/** forward=False reverse=False
ENTRY artifacts/orchestration | artifacts/orchestration/** forward=True reverse=True
ENTRY artifacts/orchestration | artifacts/orchestration-archive/** forward=False reverse=False
ENTRY scripts/powershell/PoshQC | scripts/powershell/PoshQC/** forward=True reverse=True
ENTRY scripts/powershell/PoshQC | scripts/powershell/PoshQCExtra/** forward=False reverse=False
RADIUS g1-plan-poetry-lock A paths=docs/features/active/2026-09-27-regression-452-left/**,poetry.lock surfaces=poetry.lock B paths=docs/features/active/2026-09-27-regression-452-right/**,poetry.lock surfaces=poetry.lock
CASE g1-plan-poetry-lock conflict=True reasons=[path_overlap|poetry.lock ~ poetry.lock; shared_surface_overlap|poetry.lock]
RADIUS g1-plan-package-lock A paths=docs/features/active/2026-09-27-regression-452-left/**,package-lock.json surfaces=package-lock.json B paths=docs/features/active/2026-09-27-regression-452-right/**,package-lock.json surfaces=package-lock.json
CASE g1-plan-package-lock conflict=True reasons=[path_overlap|package-lock.json ~ package-lock.json; shared_surface_overlap|package-lock.json]
RADIUS g1-plan-different-surfaces A paths=docs/features/active/2026-09-27-regression-452-left/**,poetry.lock surfaces=poetry.lock B paths=docs/features/active/2026-09-27-regression-452-right/**,package-lock.json surfaces=package-lock.json
CASE g1-plan-different-surfaces conflict=False reasons=[]
RADIUS g1-plan-unconfigured-root-file A paths=docs/features/active/2026-09-27-regression-452-left/** surfaces= B paths=docs/features/active/2026-09-27-regression-452-right/** surfaces=
CASE g1-plan-unconfigured-root-file conflict=False reasons=[]
RADIUS g1-plan-quality-tiers-mandate-read A paths=docs/features/active/2026-09-27-regression-452-left/** surfaces= B paths=docs/features/active/2026-09-27-regression-452-right/** surfaces=
CASE g1-plan-quality-tiers-mandate-read conflict=False reasons=[]
CASE g1-radius-quality-tiers conflict=True reasons=[path_overlap|quality-tiers.yml ~ quality-tiers.yml; shared_surface_overlap|quality-tiers.yml]
CASE g1-radius-quality-tiers-vs-poetry-lock conflict=False reasons=[]
CASE g2-dir-vs-glob conflict=True reasons=[path_overlap|scripts/dev_tools ~ scripts/dev_tools/**]
CASE g2-glob-vs-dir conflict=True reasons=[path_overlap|scripts/dev_tools ~ scripts/dev_tools/**]
CASE g2-dir-vs-sibling-glob conflict=False reasons=[]
CASE g2-sibling-glob-vs-dir conflict=False reasons=[]
CASE g2-artifacts-dir-vs-glob conflict=True reasons=[path_overlap|artifacts/orchestration ~ artifacts/orchestration/**]
CASE g2-artifacts-glob-vs-dir conflict=True reasons=[path_overlap|artifacts/orchestration ~ artifacts/orchestration/**]
CASE g2-artifacts-dir-vs-sibling-glob conflict=False reasons=[]
CASE g2-artifacts-sibling-glob-vs-dir conflict=False reasons=[]
CASE g2-empty-modules-dir-vs-glob conflict=True reasons=[path_overlap|scripts/powershell/PoshQC ~ scripts/powershell/PoshQC/**]
CASE g2-empty-modules-dir-vs-sibling-glob conflict=False reasons=[]
```

Output Summary:
- EXIT_CODE 0; MODULE_UNDER_ROOT=True; 17 CASE lines.
- TOKEN: concrete for poetry.lock, package-lock.json, quality-tiers.yml with roots; None for every token without roots and for Poetry.lock and pyproject.toml with roots.
- EXTRACT: one-element tuple for poetry.lock and package-lock.json with roots, empty tuple without roots, empty tuple for pyproject.toml.
- ENTRY: True/True for the three directory-versus-own-glob pairs; False/False for the three sibling controls.
- RADIUS: g1-plan-poetry-lock lists poetry.lock in both paths and surfaces; g1-plan-quality-tiers-mandate-read lists no quality-tiers.yml entry (mandate-read removal).
- No deviation from any expectation; the SIGNATURE-CHANGED branch did not fire.
