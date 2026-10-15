# Baseline TypeScript coverage readout (P0-T26)

Timestamp: 2026-10-09T20-11
Command: poetry run python -c "import json, pathlib; d = json.loads(pathlib.Path('extensions/drm-copilot/coverage/coverage-summary.json').read_text(encoding='utf-8')); k = [x for x in d if x.endswith('parallel-planner-state-routing.ts')]; print(len(k), d[k[0]]['lines']['pct'], d[k[0]]['branches']['pct'], d[k[0]]['branches']['covered'], d[k[0]]['branches']['total'])"
EXIT_CODE: 0
Output Summary: 1 100 92.59 25 27
BaselineTsLinePercent: 100
BaselineTsBranchPercent: 92.59
BaselineTsBranchesCovered: 25
BaselineTsBranchesTotal: 27
