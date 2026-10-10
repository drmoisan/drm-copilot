# QA gate: AC-2 no remaining comparator copies (P4-T8, pass 2)

Timestamp: 2026-10-09T23-17
Command: Grep tool pattern `(\?\s*1\s*:\s*-1|return\s+-1|\?\s*-1\b)` path extensions/drm-copilot/src, content mode; Grep tool pattern `if\s*\([^()]*\s<\s[^()]*\)\s*\{?\s*return\s+-1` path extensions/drm-copilot/src, multiline, content mode
EXIT_CODE: 0
Output Summary:
- Primary query: 4 lines (baseline P0-T17: 32 lines in 18 files). Every line is classified as allowed:
  1. `extensions\drm-copilot\src\lib\string-ordering.ts:59:      return rankCodeUnit(leftUnit) < rankCodeUnit(rightUnit) ? -1 : 1;` - in the shared module (allowed).
  2. `extensions\drm-copilot\src\lib\string-ordering.ts:65:  return left.length < right.length ? -1 : 1;` - in the shared module (allowed).
  3. `extensions\drm-copilot\src\lib\validate\orchestration-handoff-contract.ts:149:        position > 0 && index <= (indexes[position - 1] ?? -1),` - D6 nullish-coalescing default, not a comparator (expected residual).
  4. `extensions\drm-copilot\src\lib\subagent-tree\quick-pick-labels.ts:130:      return -1;` - the numeric `rightMs === undefined` branch of `compareCandidates` (research section 1.5; expected residual).
- Multiline query: no matches (baseline P0-T17: 2 lines, tree-assembler.ts 98-99).
- Result: PASS.
