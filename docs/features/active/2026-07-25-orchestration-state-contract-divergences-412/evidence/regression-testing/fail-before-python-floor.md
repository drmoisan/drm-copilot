# Fail-Before — Divergence 2 (Python), Pre-Fix Reproduction (Issue #412)

Task: [P0-T14] `[expect-fail]`

Timestamp: 2026-07-25T17-38

Command:

```
poetry run python -c "from scripts.dev_tools.compute_complexity_floor import compute_complexity_floor as f; print(f([]), f(['docs_or_comment_only']), f(['not_a_real_signal']))"
```

Run from the repo root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`.

EXIT_CODE: 0

Output Summary:

Observed output, verbatim, exactly three tokens:

```
C1 C3 C3
```

This matches the documented pre-fix expectation `C1 C3 C3` and demonstrates the defect.

| Input `signals_present` | Observed floor | Correct floor | Defective? |
|---|---|---|---|
| `[]` | `C1` | `C1` | no |
| `['docs_or_comment_only']` | `C3` | `C1` | **yes** — `docs_or_comment_only` is flagged `"floor": false` in `config/orchestration-routing.json`, so it must contribute nothing to the floor |
| `['not_a_real_signal']` | `C3` | `C1` | **yes** — an unknown signal name must contribute nothing to the floor |

`compute_complexity_floor` currently returns `C3` whenever `signals_present` is non-empty,
regardless of whether the named signals are floor-forcing. Per
`.claude/rules/orchestrator-state.md`, each `complexity_assessments[]` entry's `floor` must
equal `compute_complexity_floor(signals_present)`, so this defect propagates into checkpoint
validation.

The exit code is 0 because the defect is an incorrect return value, not an exception. The
`[expect-fail]` outcome for this task is the buggy output above, which is what was observed.

Phase 2 ([P2-T9]) verifies the post-fix behavior with the same call plus a floor-forcing
signal; the expected post-fix output there is `C1 C1 C1 C3`.
