# Phase 3 — Gap 1 Python Fail-Before (new positive tests against the unmodified implementation)

Timestamp: 2026-08-08T11-30
Task: [P3-T1] [expect-fail]

A failing result is the expected and required outcome of this task. The three new positive tests
are written before the `root_surfaces` parameter exists, so they must fail against the unmodified
`classify_path_token`.

Command:
`poetry run pytest tests/scripts/dev_tools/test_blast_radius_extraction.py -k "configured_separator_free_root_surface" -v`

EXIT_CODE: 1

## Test added

`test_classify_path_token_accepts_a_configured_separator_free_root_surface`, parametrized over the
module-level constant `CONFIGURED_ROOT_SURFACES = ("package-lock.json", "poetry.lock",
"quality-tiers.yml")` — the three separator-free entries of the committed `shared_surfaces` list.
Each case asserts
`classify_path_token(token, root_surfaces=CONFIGURED_ROOT_SURFACES) == PATH_KIND_CONCRETE`.

## Raw failure output

```
E       TypeError: classify_path_token() got an unexpected keyword argument 'root_surfaces'
tests\scripts\dev_tools\test_blast_radius_extraction.py:251: TypeError

FAILED ...::test_classify_path_token_accepts_a_configured_separator_free_root_surface[package-lock.json]
FAILED ...::test_classify_path_token_accepts_a_configured_separator_free_root_surface[poetry.lock]
FAILED ...::test_classify_path_token_accepts_a_configured_separator_free_root_surface[quality-tiers.yml]
3 failed, 77 deselected in 0.13s
```

Output Summary: All three new positive tests FAIL against the unmodified implementation, one per
configured separator-free surface, each with
`TypeError: classify_path_token() got an unexpected keyword argument 'root_surfaces'`. This is the
required fail-before state: the keyword-only parameter does not yet exist, so the three configured
root surfaces remain unreachable. The 77 deselected tests are the rest of the extraction suite and
are unaffected. The pass-after run is recorded at [P3-T12].
