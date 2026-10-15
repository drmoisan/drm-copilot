# Coverage Delta and Changed-Line Coverage

Timestamp: 2026-09-30T10-05

Plan task: [P2-T16]

Command: git diff --merge-base -U0 origin/main -- scripts/dev_tools/validate_epic_orchestrator_state.py extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts; git status --porcelain -- scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py; git diff --merge-base --name-status origin/main -- scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py (three separate Bash calls), then intersection of added line numbers with `DA:` records

EXIT_CODE: 0

Output Summary: Changed-line coverage 100.00% for all three production files (validator 2/2, new helper module 35/35, TypeScript core 40/40). The new module is reported as `A` in the name-status output (committed in Phase 1). Validator line 96.64 -> 96.85, branch 93.06 -> 93.55; TypeScript core line 97.79 -> 97.96, branch 89.87 -> 91.11; helper 100.00 / 100.00 (new).

## Coverage sources

- Python: `artifacts/python/lcov.info` written by [P2-T4] (a byte copy was taken immediately after [P2-T4] and used here, so that later pytest runs could not replace the data).
- TypeScript: `extensions/drm-copilot/coverage/lcov.info` written by [P2-T8] (modified 2026-09-30T09:55, the [P2-T8] run; a byte copy was taken immediately after the run).
- `SF:` paths normalized by replacing `\` with `/`. Python: `SF:scripts\dev_tools\validate_epic_orchestrator_state.py` -> `scripts/dev_tools/validate_epic_orchestrator_state.py`; `SF:scripts\dev_tools\_epic_orchestrator_state_wave_barrier.py` -> `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`. TypeScript: `SF:src\lib\validate\epic-orchestrator-state-core.ts` -> `src/lib/validate/epic-orchestrator-state-core.ts`, which is the repository-relative path `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` relative to the Jest root `extensions/drm-copilot`.

## New-module status

- `git status --porcelain -- scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`: empty (the module is committed).
- `git diff --merge-base --name-status origin/main -- scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`:

```text
A	scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py
```

## Added-line hunks (from `git diff --merge-base -U0 origin/main`)

`scripts/dev_tools/validate_epic_orchestrator_state.py`:

```text
@@ -28,0 +29,4 @@   (import of MERGED_STATUSES, validate_wave_barrier_ordering)
@@ -60 +63,0 @@     (deletion only)
@@ -243,67 +245,0 @@ (deletion only: old _validate_wave_barrier_ordering)
@@ -455 +391 @@     (call site renamed)
```

Added lines: 29, 30, 31, 32, 391.

`extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`:

```text
@@ -75,0 +76,2 @@
@@ -234,0 +237,18 @@
@@ -237,0 +258,9 @@
@@ -262,0 +292,5 @@
@@ -283 +317,5 @@
@@ -285 +323 @@
```

Added lines: 76-77, 237-254, 258-266, 292-296, 317-321, 323.

## Per-file changed-line coverage

### scripts/dev_tools/validate_epic_orchestrator_state.py

`DA:` records on added lines: `29,1` and `391,1`. Lines 30-32 are continuation lines of the multi-line import statement and carry no `DA:` record.

CHANGED_EXECUTABLE_LINES: 2

CHANGED_COVERED_LINES: 2

CHANGED_LINE_PCT: 100.00

Uncovered changed lines: none

### scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py (new; every `DA:` line counts as changed)

`DA:` line numbers (all with hit count 1): 24, 26, 28, 33, 34, 37, 73, 74, 75, 78, 107, 108, 116, 118, 119, 120, 121, 122, 125, 126, 127, 131, 132, 135, 138, 139, 140, 141, 144, 148, 153, 154, 158, 159, 163.

CHANGED_EXECUTABLE_LINES: 35

CHANGED_COVERED_LINES: 35

CHANGED_LINE_PCT: 100.00

Uncovered changed lines: none

### extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts

`DA:` records on added lines (line hit-count): 76 1, 77 1, 237 1, 238 1, 239 1, 240 1, 241 1, 242 1, 243 1, 244 1, 245 1, 246 1, 247 1, 248 147, 249 147, 250 147, 251 63, 252 147, 253 147, 254 1, 258 1, 259 1, 260 1, 261 1, 262 1, 263 1, 264 1, 265 1, 266 1, 292 147, 293 147, 294 147, 295 17, 296 17, 317 53, 318 12, 319 12, 320 12, 321 53, 323 2.

(The v8 coverage provider emits `DA:` records for comment and blank lines as well; all 40 added lines carry a record and all have a non-zero hit count.)

CHANGED_EXECUTABLE_LINES: 40

CHANGED_COVERED_LINES: 40

CHANGED_LINE_PCT: 100.00

Uncovered changed lines: none

## Baseline versus final

| Module | Baseline line % | Baseline branch % | Final line % | Final branch % | Sources |
|---|---|---|---|---|---|
| `scripts/dev_tools/validate_epic_orchestrator_state.py` | 96.64 | 93.06 | 96.85 | 93.55 | [P0-T9], [P2-T4] |
| `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` | new | new | 100.00 | 100.00 | [P2-T4] |
| `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` | 97.79 | 89.87 | 97.96 | 91.11 | [P0-T13], [P2-T8] |

## Result

PASS: the new module is reported as `A` in the name-status output; every `CHANGED_LINE_PCT` is 100.00 (>= 85); every non-`new` table cell is numeric; no module regressed.
