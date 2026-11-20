# P3-T9 — Both lane-assertion parity lanes over the shared corpus

Timestamp: 2026-08-30T11-39

## Lane 1 — Python

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py -q -p no:cacheprovider`

EXIT_CODE: 0

Output Summary:

```
.........................                                                [100%]
25 passed in 0.13s
```

Pytest pass count: 25. That is 1 corpus-floor test, 23 parametrized
`test_reference_reproduces_every_corpus_fixture` cases (one per corpus record),
and 1 `test_manifest_text_matches_manifest_path` test. The plan's floor for this
task is a pass count of at least 22.

## Lane 2 — bash

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion_parity.bats'`

EXIT_CODE: 0

Output Summary:

```
1..8
ok 1 the lane-assertion parity corpus meets the declared floor
ok 2 python3 is available to read the corpus
ok 3 the bash lane reproduces every lane-assertion corpus fixture
ok 4 every finding class appears in the corpus
ok 5 at least one corpus fixture carries an ADVISORY line and status 0
ok 6 every corpus record's manifest_text matches its manifest_path
ok 7 the whitespace endpoint fixture converges with the empty-edges fixture
ok 8 no corpus fixture carries an excluded edges endpoint form
```

Bats case count: 8, read from the TAP plan line `1..8`. No line begins `not ok`.
A captured bats run emits TAP and prints no `N tests, 0 failures` summary line,
so the plan line and the absence of `not ok` are the assertion.

## Agreement

Both lanes pass over the same 23 records at
`tests/fixtures/parallel_lane_assertion/*.json`. The two lanes agree on every
record: there is no record on which one lane passes and the other fails, and no
record carries a `divergence` marker that scopes its comparison to a prefix. The
only `divergence` key present in the corpus is
`edges_endpoint_interior_whitespace`'s explicit `null`, which records that the
record is a convergence case rather than a divergence one.

## Derivation provenance

Every `expected_stdout` value in the corpus was derived by running the Python
reference CLI as a subprocess:

```
python -m scripts.dev_tools.parallel_lane_assertion --manifest <manifest_path> --edges <edges>
```

with the worktree root as the working directory, then stripping the single
trailing newline the reference's `print` emits. No expected value was hand
authored and then reconciled against the two lanes.

## Non-vacuity checks performed

Each check mutated one corpus record, observed the failure, restored the record
byte-identically from a scratch backup, and observed the pass again.

- Bash lane, case 3: `edges_empty.json` `expected_stdout` altered from
  `0 disagreement(s).` to `9 disagreement(s).` produced
  `not ok 3 the bash lane reproduces every lane-assertion corpus fixture`.
- Python lane: the same mutation produced
  `FAILED ...::test_reference_reproduces_every_corpus_fixture[edges_empty]`,
  `1 failed, 24 passed`, EXIT_CODE 1.
- Bash lane, case 8: `edges_non_integer_endpoint.json` `edges` set in turn to
  `0101:202`, `+101:202`, `1_01:202`, and `١٠١:202` each produced
  `not ok 1 no corpus fixture carries an excluded edges endpoint form` with a
  diagnostic naming the specific excluded form. All four members of divergence
  class 3 are therefore detected, not just the first.
