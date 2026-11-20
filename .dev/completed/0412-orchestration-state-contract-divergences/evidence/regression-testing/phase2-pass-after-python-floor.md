# Phase 2 — Pass-After Evidence (Divergence 2, Python CLI)

Timestamp: 2026-07-25T17-45

Command: `poetry run python -c "from scripts.dev_tools.compute_complexity_floor import compute_complexity_floor as f; print(f([]), f(['docs_or_comment_only']), f(['not_a_real_signal']), f(['cross_module_contract_change']))"`

EXIT_CODE: 0

Output Summary:

Exact stdout, run from the repo root:

```
C1 C1 C1 C3
```

This matches the expected post-fix output in [P2-T9] token for token:

| Input | Signal class | Pre-fix ([P0-T14]) | Post-fix | Expected |
|---|---|---|---|---|
| `[]` | no signals | `C1` | `C1` | `C1` |
| `['docs_or_comment_only']` | `"floor": false` | `C3` | `C1` | `C1` |
| `['not_a_real_signal']` | not in catalog | `C3` | `C1` | `C1` |
| `['cross_module_contract_change']` | `"floor": true` | (n/a) | `C3` | `C3` |

The first three tokens of the [P0-T14] fail-before artifact were `C1 C3 C3`;
they are now `C1 C1 C1`, and the added fourth case confirms a genuine
`"floor": true` signal still raises the floor to `C3`. The `"floor": false`
flag and the unknown-signal case are no longer dead configuration.
