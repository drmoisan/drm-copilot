# Phase 0 baseline — guard inventory in the classifier library

Timestamp: 2026-09-08T07-30
Task: [P0-T7]
File measured: `scripts/bash/cleanup_worktrees_dirt_lib.sh` (463 lines at cycle start)
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d

## 1. Arithmetic guard-shaped line count

Command: grep -cE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)' scripts/bash/cleanup_worktrees_dirt_lib.sh
EXIT_CODE: 0
Output: 30

## 2. Marked guard count

Command: grep -c '# guard:' scripts/bash/cleanup_worktrees_dirt_lib.sh
EXIT_CODE: 1
Output: 0

Exit 1 is `grep`'s no-match status, which is the expected result at cycle start: no
`# guard:` marker exists yet. Phase 2 adds them.

## 3. Numbered list of the arithmetic guard-shaped lines

Command: grep -nE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)' scripts/bash/cleanup_worktrees_dirt_lib.sh
EXIT_CODE: 0

```
97:	if ((rc != 0)); then
102:		if ((first == 1)); then
109:		if ((drc == 0)); then
113:		if ((drc > 1)); then
167:	if ((rc != 0)); then
207:	((wrc == 2)) && return 2
208:	((wrc == 1)) && return 1
210:	((crc == 2)) && return 2
211:	((crc == 1)) && return 1
213:	((total == 0)) && return 1
280:	if ((untracked == 0)); then
282:		if ((brc == 0)); then
286:		if ((brc > 1)); then
294:	if ((untracked == 0)); then
297:		if ((drc == 0)); then
301:		if ((drc > 1)); then
311:	if ((hrc != 0)) || [[ -z $blob ]]; then
318:	if ((untracked == 1)); then
321:		if ((mrc == 0)) && [[ -n $mainblob && $mainblob == "$blob" ]]; then
333:	((vrc == 0)) && range="main~$CLEANUP_WT_HISTORY_SCAN_DEPTH..main"
336:	if ((lrc != 0)); then
371:	if ((srrc != 0)); then
385:	if ((any_staged == 1)); then
387:		((prc == 1)) && staged=""
388:		((prc > 1)) && staged="ERROR"
414:	((entry_count == 0)) && return 0
415:	if ((unique_count == 0)); then
444:	if ((crc == 0)); then
452:	if ((rrc != 0)); then
457:	if ((clrc != 0)); then
```

Thirty line numbers: 97, 102, 109, 113, 167, 207, 208, 210, 211, 213, 280, 282, 286, 294,
297, 301, 311, 318, 321, 333, 336, 371, 385, 387, 388, 414, 415, 444, 452, 457. This set is
identical, member for member, to the enumeration the remediation plan states in D2 part one.

## 4. The eight named non-arithmetic verdict-guard sites

Command: sed -n '172p;260p;311p;321p;341p;403p;410p;447p' scripts/bash/cleanup_worktrees_dirt_lib.sh
EXIT_CODE: 0

```
		"--- a/"* | "+++ b/"* | "--- /dev/null" | "+++ /dev/null") continue ;;
	if [[ $x != " " && $x != "?" && $x != "!" && $y == " " ]]; then
	if ((hrc != 0)) || [[ -z $blob ]]; then
		if ((mrc == 0)) && [[ -n $mainblob && $mainblob == "$blob" ]]; then
	if [[ -n $found ]]; then
		if [[ ${xy:0:1} == R || ${xy:0:1} == C ]]; then
		[[ $verdict == "UNIQUE" ]] && unique_count=$((unique_count + 1))
	if [[ $agg != "ALL_DISPOSABLE" ]]; then
```

In source order these are lines 172, 260, 311, 321, 341, 403, 410 and 447. Each matches the
`Source text` column of the plan's D2 part two table verbatim. Lines 311 and 321 appear in
both this list and the arithmetic list above, because each carries an arithmetic guard and
a named non-arithmetic guard on one physical line.

## 5. Derived end-state targets

| Quantity | Cycle start | End state | Arithmetic |
|---|---:|---:|---|
| Arithmetic guard-shaped lines | 30 | **31** | 30 measured above, plus the one `((erc == 0))` line decision D1 adds in Phase 1 |
| Marker lines (`# guard:` at end of line) | 0 | **37** | 31 arithmetic lines, plus the six lines that are non-arithmetic **only** — 172, 260, 341, 403, 410, 447. Lines 311 and 321 are not added again here; they are already counted among the 31 |
| Registry rows | 0 | **39** | 31 arithmetic rows, plus 8 named non-arithmetic rows (172, 260, 311, 321, 341, 403, 410, 447) |

The row count exceeds the marker count by exactly two because lines 311 and 321 each back
two registry rows from a single marker: one row mutating the arithmetic half and one row
mutating the named non-arithmetic half. Row identity is the pair (`id`, `mutation`), not
`id` alone.

EXIT_CODE: 0
Output Summary: 30 arithmetic guard-shaped lines measured; 0 `# guard:` markers present
(grep exit 1, no match, as expected at cycle start); the thirty line numbers listed match
the plan's D2 part one enumeration exactly; the eight named non-arithmetic verdict-guard
source lines match the plan's D2 part two table verbatim. Derived end-state targets: 31
arithmetic lines, 37 marker lines, 39 registry rows.
