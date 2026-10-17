# Final TypeScript coverage readout, loop pass 3 (P2-T14)

Timestamp: 2026-10-09T20-20
Command: poetry run python -c "import json, pathlib; d = json.loads(pathlib.Path('extensions/drm-copilot/coverage/coverage-summary.json').read_text(encoding='utf-8')); k = [x for x in d if x.endswith('parallel-planner-state-routing.ts')]; print(len(k), d[k[0]]['lines']['pct'], d[k[0]]['branches']['pct'], d[k[0]]['branches']['covered'], d[k[0]]['branches']['total'])"
EXIT_CODE: 0
Output Summary: 1 100 100 27 27
PostChangeTsLinePercent: 100
PostChangeTsBranchPercent: 100
PostChangeTsBranchesCovered: 27
PostChangeTsBranchesTotal: 27
Comparison: BaselineTsLinePercent 100, BaselineTsBranchPercent 92.59, BaselineTsBranchesCovered 25, BaselineTsBranchesTotal 27 (P0-T26). Branches total unchanged (27); the two previously uncovered branch arms are now covered.
