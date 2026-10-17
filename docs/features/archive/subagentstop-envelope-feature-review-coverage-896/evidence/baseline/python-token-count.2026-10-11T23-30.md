# Baseline Python-Token Counts (P0-T22; AC-26 (c))

Timestamp: 2026-10-11T23-57
Command: CR-PY-TOKEN (scratchpad route) with $Mode = 'baseline', then with $Mode = 'final' (observation run; HEAD equals the merged base for the hook families)
EXIT_CODE: 0
Output Summary: baseline: claude-hooks base=5, codex-hooks base=5 (AnchorDrift did not touch H1/H4/H5, so the expected values hold); final-mode observation: both families NOT-INCREASED (head=5), PY-TOKEN-INCREASED-COUNT: 0, EXIT_CODE_COMPUTED: 0.

## Baseline mode

```
GREP-BASE: origin/epic/subagentstop-envelope-integration:.claude/hooks/validate-feature-review-coverage.ps1:5
PY-TOKEN: claude-hooks | base=5
GREP-BASE: origin/epic/subagentstop-envelope-integration:.codex/hooks/validate-feature-review-coverage.ps1:5
PY-TOKEN: codex-hooks | base=5
PY-TOKEN-INCREASED-COUNT: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```

## Final mode (observation)

```
GREP-BASE: origin/epic/subagentstop-envelope-integration:.claude/hooks/validate-feature-review-coverage.ps1:5
GREP-HEAD: HEAD:.claude/hooks/validate-feature-review-coverage.ps1:5
PY-TOKEN: claude-hooks | base=5 | head=5 | NOT-INCREASED
GREP-BASE: origin/epic/subagentstop-envelope-integration:.codex/hooks/validate-feature-review-coverage.ps1:5
GREP-HEAD: HEAD:.codex/hooks/validate-feature-review-coverage.ps1:5
PY-TOKEN: codex-hooks | base=5 | head=5 | NOT-INCREASED
PY-TOKEN-INCREASED-COUNT: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
