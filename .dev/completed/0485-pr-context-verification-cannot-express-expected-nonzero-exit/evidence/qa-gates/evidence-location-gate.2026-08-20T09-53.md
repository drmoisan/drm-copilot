# Gate — evidence-location invariant across everything this plan produced

Timestamp: 2026-08-20T09-53

Task: [P9-T4]

Command: git status --porcelain ; ls artifacts/ ; ls artifacts/python artifacts/orchestration ; find docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence -type f
EXIT_CODE: 0

## Every artifact this plan produced lives under the canonical scheme

The directory walk of this feature's `evidence/` tree returned **52 files**, distributed as:

| Canonical location | Files |
| --- | --- |
| `<FEATURE>/evidence/baseline/` | 15 |
| `<FEATURE>/evidence/regression-testing/` | 7 |
| `<FEATURE>/evidence/qa-gates/` | 26 |
| `<FEATURE>/evidence/other/` | 3 |
| `<FEATURE>/evidence/issue-updates/` | 1 (written at [P9-T6]) |

Every one resolves under
`docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/<kind>/`.
No artifact was written anywhere else.

## No forbidden `artifacts/`-rooted evidence path exists

`ls artifacts/` returns exactly two entries:

```
orchestration/
python/
```

- `artifacts/orchestration/orchestrator-state.json` — the orchestration checkpoint, an ALLOWED
  non-evidence `artifacts/` sub-path, not written by this plan.
- `artifacts/python/lcov.info` — the coverage report the pytest `addopts` at `pyproject.toml:116`
  writes automatically on every coverage run. It is tool output consumed as an input by the coverage
  derivations, not an evidence artifact, and its path is fixed by pre-existing repository
  configuration that this change does not touch ([P7-T12]).

None of the forbidden evidence sub-paths exists: `artifacts/baselines/`, `artifacts/baseline/`,
`artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, `artifacts/regression-testing/`,
`artifacts/post-change/`, and `artifacts/evidence/` are all absent, as the two-entry listing above
shows directly.

## Working-tree status corroboration

`git status --porcelain` lists, besides the modified source and documentation files, exactly one
untracked directory for evidence:
`docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/`.
No untracked or modified path under `artifacts/` other than the two entries above appears.

Output Summary: All 52 evidence artifacts produced by this plan live under
`<FEATURE>/evidence/{baseline,regression-testing,qa-gates,other,issue-updates}/`. Zero artifacts were
written outside the canonical scheme; `artifacts/` contains only `orchestration/` (an allowed
non-evidence path) and `python/lcov.info` (pre-configured coverage tool output), and every forbidden
`artifacts/`-rooted evidence sub-path is absent.
