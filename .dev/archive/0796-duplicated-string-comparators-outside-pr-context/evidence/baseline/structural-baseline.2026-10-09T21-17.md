# Baseline: Structural searches for AC-1 to AC-3 (P0-T17)

Timestamp: 2026-10-09T21-17
Command: (1) git grep --untracked -n -E "function compareCodePoint|const compareCodePoint" -- extensions/drm-copilot/src; (2) git grep --untracked -n -w -E "compareStrings|compareOrdinal" -- extensions/drm-copilot/src; (3) git grep --untracked -n -E "^[[:space:]]*import([^[:alnum:]_]|$)" -- extensions/drm-copilot/src/lib/pr-context/models.ts; (4) git grep --untracked -n -F "string-ordering" -- extensions/drm-copilot/src; (5) Grep tool pattern `(\?\s*1\s*:\s*-1|return\s+-1|\?\s*-1\b)` path extensions/drm-copilot/src content mode; (6) Grep tool pattern `if\s*\([^()]*\s<\s[^()]*\)\s*\{?\s*return\s+-1` path extensions/drm-copilot/src multiline content mode
EXIT_CODE: 0
Output Summary:
- (1) exit 0, exactly 1 line: `extensions/drm-copilot/src/lib/pr-context/models.ts:355:export function compareCodePoint(left: string, right: string): number {`
- (2) exit 0, 27 lines (matches plan expectation of 27): 2 `function compareStrings` definitions (engine-pipeline.ts:46, reporting-render.ts:36) and 18 reference lines; the `compareOrdinal` definition (claude-blast-radius-derive-manifests.ts:121) and 4 call lines (derive-manifests 199, derive-core 249 and 276, overlay 200); 2 import-member lines (derive-core 49, overlay 29).
- (3) exit 0, 1 line: `extensions/drm-copilot/src/lib/pr-context/models.ts:26:import { type CommandResult } from "../subprocess-runner";` (POSIX import pattern proven able to match).
- (4) exit 1, no match.
- (5) 32 lines in 18 files (matches plan).
- (6) 2 lines: tree-assembler.ts 98-99 (matches plan).
- These records prove the post-change checks of P4-T7 to P4-T9 can fail.

## (2) verbatim
```
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:46:function compareStrings(left: string, right: string): number {
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:88:    compareStrings(left.sourcePath, right.sourcePath),
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:148:    compareStrings,
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:183:  ].sort(compareStrings);
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:201:    compareStrings,
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:243:    const bySource = compareStrings(left.sourcePath, right.sourcePath);
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:247:    const bySection = compareStrings(left.sectionId, right.sectionId);
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:251:    return compareStrings(left.targetRole, right.targetRole);
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:304:  for (const targetPath of Object.keys(generatedOutput).sort(compareStrings)) {
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:36:function compareStrings(left: string, right: string): number {
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:71:    compareStrings(left.sourcePath, right.sourcePath),
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:74:    const bySource = compareStrings(left.sourcePath, right.sourcePath);
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:78:    return compareStrings(left.destinationPath, right.destinationPath);
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:81:    const bySource = compareStrings(left.sourcePath, right.sourcePath);
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:85:    const bySection = compareStrings(left.sectionId, right.sectionId);
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:89:    const byRole = compareStrings(left.targetRole, right.targetRole);
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:93:    return compareStrings(left.targetPath ?? "", right.targetPath ?? "");
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:188:      const byCode = compareStrings(left.code, right.code);
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:192:      const bySource = compareStrings(
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:199:      return compareStrings(left.targetPath ?? "", right.targetPath ?? "");
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:49:  compareOrdinal,
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:249:  return names.sort(compareOrdinal);
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:276:  for (const name of [...combined.keys()].sort(compareOrdinal)) {
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts:121:export function compareOrdinal(left: string, right: string): number {
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts:199:  return { modulePaths: modulePaths.sort(compareOrdinal), structureObserved };
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts:29:import { compareOrdinal } from "./claude-blast-radius-derive-manifests";
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts:200:  for (const name of Object.keys(merged).sort(compareOrdinal)) {
```

## (5) verbatim (32 lines, 18 files)
```
extensions\drm-copilot\src\lib\codex-native-converter\intermediate-state.ts:53:      (left, right) => (left < right ? -1 : left > right ? 1 : 0),
extensions\drm-copilot\src\lib\codex-native-converter\models.ts:259:    left < right ? -1 : left > right ? 1 : 0,
extensions\drm-copilot\src\lib\codex-native-converter\engine-pipeline.ts:47:  return left < right ? -1 : left > right ? 1 : 0;
extensions\drm-copilot\src\lib\codex-native-converter\inventory.ts:169:    left < right ? -1 : left > right ? 1 : 0,
extensions\drm-copilot\src\lib\codex-native-converter\inventory.ts:239:    left < right ? -1 : left > right ? 1 : 0,
extensions\drm-copilot\src\lib\codex-native-converter\inventory.ts:294:    left < right ? -1 : left > right ? 1 : 0,
extensions\drm-copilot\src\lib\codex-native-converter\pipeline.ts:57:    return left[1] < right[1] ? -1 : left[1] > right[1] ? 1 : 0;
extensions\drm-copilot\src\lib\codex-native-converter\pipeline.ts:93:  ].sort((left, right) => (left < right ? -1 : left > right ? 1 : 0));
extensions\drm-copilot\src\lib\codex-native-converter\pipeline.ts:148:      return left.sourcePath < right.sourcePath ? -1 : 1;
extensions\drm-copilot\src\lib\codex-native-converter\pipeline.ts:151:      return left.destinationPath < right.destinationPath ? -1 : 1;
extensions\drm-copilot\src\lib\codex-native-converter\reporting-render.ts:37:  return left < right ? -1 : left > right ? 1 : 0;
extensions\drm-copilot\src\lib\codex-native-converter\pipeline-traces.ts:112:      return left.sourcePath < right.sourcePath ? -1 : 1;
extensions\drm-copilot\src\lib\codex-native-converter\pipeline-traces.ts:115:      return left.sectionId < right.sectionId ? -1 : 1;
extensions\drm-copilot\src\lib\codex-native-converter\pipeline-traces.ts:118:      return left.targetRole < right.targetRole ? -1 : 1;
extensions\drm-copilot\src\lib\codex-native-converter\reporting.ts:54:      (left, right) => (left < right ? -1 : left > right ? 1 : 0),
extensions\drm-copilot\src\lib\codex-native-converter\reporting.ts:132:      ? -1
extensions\drm-copilot\src\lib\codex-native-converter\reporting.ts:149:    left < right ? -1 : left > right ? 1 : 0;
extensions\drm-copilot\src\lib\codex-native-converter\reporting.ts:230:    left < right ? -1 : left > right ? 1 : 0,
extensions\drm-copilot\src\lib\codex-native-converter\validation.ts:269:    left < right ? -1 : left > right ? 1 : 0,
extensions\drm-copilot\src\lib\codex-native-converter\validation.ts:360:    left < right ? -1 : left > right ? 1 : 0;
extensions\drm-copilot\src\lib\validate\orchestration-handoff-contract.ts:149:        position > 0 && index <= (indexes[position - 1] ?? -1),
extensions\drm-copilot\src\lib\push-down\claude-blast-radius-derive-manifests.ts:122:  return left < right ? -1 : left > right ? 1 : 0;
extensions\drm-copilot\src\lib\subagent-tree\quick-pick-labels.ts:128:      return -1;
extensions\drm-copilot\src\lib\subagent-tree\quick-pick-labels.ts:132:  return left.path < right.path ? -1 : left.path > right.path ? 1 : 0;
extensions\drm-copilot\src\lib\pr-context\collector-output.ts:114:      ? -1
extensions\drm-copilot\src\lib\subagent-tree\tree-assembler.ts:99:    return -1;
extensions\drm-copilot\src\lib\push-down\claude-blast-radius-derive.ts:126:      left.name < right.name ? -1 : left.name > right.name ? 1 : 0,
extensions\drm-copilot\src\lib\pr-context\models.ts:361:      return leftPoint < rightPoint ? -1 : 1;
extensions\drm-copilot\src\lib\pr-context\models.ts:367:  return left.length < right.length ? -1 : 1;
extensions\drm-copilot\src\lib\push-down\copilot-customizations-engine.ts:170:      return leftRel < rightRel ? -1 : leftRel > rightRel ? 1 : 0;
extensions\drm-copilot\src\lib\push-down\copilot-customizations-engine.ts:291:          leftKey < rightKey ? -1 : leftKey > rightKey ? 1 : 0,
extensions\drm-copilot\src\lib\push-down\filesystem-adapter.ts:142:      left < right ? -1 : left > right ? 1 : 0,
```

## (6) verbatim (multiline)
```
extensions\drm-copilot\src\lib\subagent-tree\tree-assembler.ts:98:  if (a.meta.agentId < b.meta.agentId) {
extensions\drm-copilot\src\lib\subagent-tree\tree-assembler.ts:99:    return -1;
```
