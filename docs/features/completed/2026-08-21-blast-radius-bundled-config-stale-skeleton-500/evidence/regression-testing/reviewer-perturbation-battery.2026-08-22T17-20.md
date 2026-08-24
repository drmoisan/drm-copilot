Timestamp: 2026-08-22T17-20

# Reviewer perturbation battery, remediation cycle 3 re-audit (branch head `0610037b`)

Every perturbation was applied to a clean working tree and reverted with
`git checkout -- <path>`. `git status --porcelain` was empty before the battery, between each
group, and after the battery. No file in this battery carried an uncommitted edit at any point,
so the reviewer restore mechanism was `git checkout --` throughout and needed no in-memory
backup.

## Method note: a silent-no-op trap that invalidated one draft run

An initial CR-4 battery used multi-line `poetry run python -c "..."` to rewrite the bundled JSON.
Under `poetry run` a multi-line `-c` string produces no output and exits 0 without executing, so
the file was never perturbed and all five cells reported a spurious pass. The trap was caught by
printing the file and running `git diff --stat` after the supposed perturbation, which showed no
change. Every result below was produced by a script FILE (`perturb.py`, `perturb2.py`,
`perturb3.py`, `addkey.py`) invoked as `poetry run python <file> <args>`, and each perturbation
was confirmed to have landed via `git diff --stat` before the gate was run.

## Group A — repaired non-vacuity floor, PowerShell (CR-1, CR-2)

Gate: `BlastRadius.KeyPartition.Tests.ps1`, case
`requires a populated shared-surface list and module map in both copies`, run with
`Filter.FullName` scoped to that case and code coverage disabled.

Command (per cell): `poetry run python perturb.py <copy> <key> <mode>` then
`pwsh -NoProfile -File run-floor.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`

| Cell | Copy | Key | State | Result | Message |
|---|---|---|---|---|---|
| A0 | — | — | unperturbed | Passed=1 Failed=0 | — |
| A1 | bundled | `shared_surfaces` | absent | Passed=0 Failed=1 | `bundled shared_surfaces: shared_surfaces key absent` |
| A2 | bundled | `shared_surfaces` | null | Passed=0 Failed=1 | `bundled shared_surfaces: shared_surfaces is null` |
| A3 | bundled | `shared_surfaces` | empty | Passed=0 Failed=1 | `bundled shared_surfaces: shared_surfaces is empty` |
| A4 | bundled | `modules` | absent | Passed=0 Failed=1 | `bundled modules: modules key absent` |
| A5 | bundled | `modules` | null | Passed=0 Failed=1 | `bundled modules: modules is null` |
| A6 | bundled | `modules` | empty | Passed=0 Failed=1 | `bundled modules: modules is empty` |
| A7 | self-hosted | `shared_surfaces` | absent | Passed=0 Failed=1 | `self-hosted shared_surfaces: shared_surfaces key absent` |
| A8 | self-hosted | `shared_surfaces` | null | Passed=0 Failed=1 | `self-hosted shared_surfaces: shared_surfaces is null` |
| A9 | self-hosted | `shared_surfaces` | empty | Passed=0 Failed=1 | `self-hosted shared_surfaces: shared_surfaces is empty` |
| A10 | self-hosted | `modules` | absent | Passed=0 Failed=1 | `self-hosted modules: modules key absent` |
| A11 | self-hosted | `modules` | null | Passed=0 Failed=1 | `self-hosted modules: modules is null` |
| A12 | self-hosted | `modules` | empty | Passed=0 Failed=1 | `self-hosted modules: modules is empty` |

All twelve failing states fire the floor and each names its own state and its own
copy/key label. The unperturbed state is the only passing state. CR-1 and CR-2 are verified
against behaviour, not against the source text.

A wider run of the whole `BlastRadius.KeyPartition.Tests.ps1` file (no filter) under six of the
same perturbations produced, respectively, Failed=3, 2, 2, 2, 1, 1 of 4, with the floor case
among the failures in every one.

## Group B — Python companion under the same twelve states, plus rename

Gate: `poetry run pytest -q --no-cov tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_the_gate_compares_non_empty_collections`

| Cell | Copy | Key | State | Result | Mechanism |
|---|---|---|---|---|---|
| B0 | — | — | unperturbed | `1 passed` | — |
| B1 | bundled | `shared_surfaces` | absent | `1 failed` | floor assertion, `shared_surfaces must be non-empty` |
| B2 | bundled | `shared_surfaces` | null | `1 failed` | floor assertion |
| B3 | bundled | `shared_surfaces` | empty | `1 failed` | floor assertion |
| B4 | bundled | `shared_surfaces` | renamed | `1 failed` | floor assertion |
| B5 | bundled | `modules` | absent | `1 failed` | `TypeError: config["modules"] must be a JSON object.` |
| B6 | bundled | `modules` | null | `1 failed` | `TypeError` |
| B7 | bundled | `modules` | empty | `1 failed` | floor assertion, `modules must be non-empty` |
| B8 | bundled | `modules` | renamed | `1 failed` | `TypeError` |
| B9 | self-hosted | `shared_surfaces` | absent | `1 error` | `TypeError: config["shared_surfaces"] must be a list, got NoneType.` raised at module import (collection error) |
| B10 | self-hosted | `shared_surfaces` | null | `1 error` | collection `TypeError` |
| B11 | self-hosted | `shared_surfaces` | empty | `1 failed` | floor assertion |
| B12 | self-hosted | `shared_surfaces` | renamed | `1 error` | collection `TypeError` |
| B13 | self-hosted | `modules` | absent | `1 error` | collection `TypeError` |
| B14 | self-hosted | `modules` | null | `1 error` | collection `TypeError` |
| B15 | self-hosted | `modules` | empty | `1 failed` | floor assertion |
| B16 | self-hosted | `modules` | renamed | `1 error` | collection `TypeError` |

No cell passes. The verdict is identical to the PowerShell side in all sixteen cells. The
mechanism is not identical: only 7 of 16 are caught by the Python floor's own assertion; the
other 9 are pre-empted by a `TypeError` raised in `require_string_list` or `load_module_globs`,
6 of which surface as a module-level collection error rather than as a floor failure.

## Group C — `SOURCE_BLAST_RADIUS` fixture binding (CR-4)

Gate: `node run-jest.cjs test/lib/push-down/claude-config-carriage.test.ts -t "keeps SOURCE_BLAST_RADIUS in step"`,
run from `extensions/drm-copilot`. Every perturbation targets the real committed resource
`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`.

| Cell | Perturbation | Result |
|---|---|---|
| C0 | unperturbed | `16 skipped, 1 passed, 17 total` |
| C1 | append `injected-witness.lock` to `shared_surfaces` | `1 failed, 16 skipped, 17 total` |
| C2 | reverse the `shared_surfaces` order | `1 failed, 16 skipped, 17 total` |
| C3 | change `over_breadth_fraction` to `0.5` | `1 failed, 16 skipped, 17 total` |
| C4 | append `.claude/witness/**` to `mandate_reads` | `1 failed, 16 skipped, 17 total` |
| C5 | add module `witness: ["witness/**"]` | `1 failed, 16 skipped, 17 total` |

The case discriminates array order as well as membership, because `toEqual` on parsed arrays is
order sensitive. Direction 18 of the divergence enumeration is closed.

## Group D — the CR-3 residual, tested end to end

The residual the cycle-2 review recorded as CR-3 is: a maintainer adds a key to
`CLASS_TWO_KEYS` or `CLASS_THREE_KEYS` (and to its PowerShell counterpart) with no assertion
consuming it. Two perturbations were run.

D1 — partial path. `invented_key: []` added to BOTH committed copies;
`"invented_key"` appended to `CLASS_TWO_KEYS` in `blast_radius_parity_test_support.py` and to
`$script:ClassTwoKeys` in `BlastRadius.KeyPartition.Tests.ps1`.

- `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py` -> `16 passed`
- `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py` -> `32 passed`
- Pester over `tests/scripts/claude-lib/blast-radius` -> `Passed=383 Failed=0 Total=383`
- Jest `claude-config-carriage.test.ts` -> `1 failed, 16 passed, 17 total` (the CR-4 fixture
  binding fires, because the bundled copy changed and `SOURCE_BLAST_RADIUS` did not)

D2 — complete path. D1 plus `invented_key: [],` added to `SOURCE_BLAST_RADIUS` in
`config-carriage.test-helpers.ts`.

- Jest over `test/lib/push-down/` -> `Tests: 223 passed, 223 total`
- `poetry run pytest` over both blast-radius modules -> `48 passed`
- Pester over `tests/scripts/claude-lib/blast-radius` -> `Passed=383 Failed=0 Total=383`

D2 passes silently in all three languages. The CR-3 residual is unchanged by cycle 3.

## Group E — divergence-direction sweep

Gates run per cell: `poetry run pytest -q --no-cov tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/dev_tools/test_blast_radius_config.py`
and Pester over `tests/scripts/claude-lib/blast-radius` (383 cases at baseline), plus Jest
`claude-config-carriage.test.ts` (17 cases) where noted.

| Cell | Perturbation | pytest | Pester | Jest |
|---|---|---|---|---|
| E1 | self-hosted `shared_surfaces` gains `config/new-portable-surface.json` (separator bearing) | `49 passed` | 383/383 | 17 passed |
| E2 | self-hosted `shared_surfaces` gains `witness.lock` (separator free) | `1 failed, 49 passed` | Failed=1 | 17 passed |
| E3 | self-hosted `shared_surface_globs` gains `witness/**` | `49 passed` | 383/383 | 17 passed |
| E4 | self-hosted `modules` gains `newsub` | `49 passed` | Failed=2 | not run |
| E5 | self-hosted gains unclassified key `unclassified_witness` | `1 failed, 47 passed` | Failed=1 | not run |
| E6 | bundled gains unclassified key `unclassified_witness` | `1 failed, 47 passed` | Failed=1 | not run |
| E7 | self-hosted `version` set to 2 | `3 failed, 45 passed` | Failed=2 | not run |
| E8 | bundled `version` set to 2 | `2 failed, 46 passed` | Failed=1 | not run |

E1 and E3 confirm the two deliberately uncovered directions are still uncovered. E4 confirms
the self-hosted module-map direction is covered on the PowerShell side only.

## Group F — split-preservation inventory (text comparison, no execution)

`git show a9b0484d:tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
declares 20 `It` cases. At head, `BlastRadius.TruthTable.Tests.ps1` declares 16 and
`BlastRadius.KeyPartition.Tests.ps1` declares 4, total 20. No case name appears in both files.
The `Cross-copy key partition` Context moved whole. One case was renamed and rewritten in the
move: `requires the shared-surface lists compared by the directional invariant to be non-empty`
became `requires a populated shared-surface list and module map in both copies` (the CR-1/CR-2
repair, which the file header discloses).

Isolation runs:

- `pwsh -File run-br.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` -> `Passed=4 Failed=0 Total=4`
- `pwsh -File run-br.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` -> `Passed=16 Failed=0 Total=16`
- `pwsh -File run-br.ps1 -Path tests/scripts/claude-lib/blast-radius` -> `Passed=383 Failed=0 Total=383`

Each file resolves its own `$script:RepoRoot`, `$script:ConfigPath`, `$script:CommittedConfig`,
and `$script:BundledConfig` in its own `BeforeAll` blocks and passes standalone.

## Group G — pre-existing intermittent failure `PRE-1`

Command: `poetry run pytest -q -p no:cacheprovider --no-cov tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result`,
run in a loop.
EXIT_CODE: mixed
Output Summary: 13 failures observed across the first 19 iterations of a 25-iteration loop
(iterations 2-8, 10, 12, 13, 15, 16, 19 failed; the loop was cut off by a 10-minute harness
timeout at iteration 19). The same test passed inside the full-suite run recorded in
`reviewer-toolchain-rerun.2026-08-22T17-20.md` (`4078 passed, 5 skipped`).

Attribution evidence gathered independently:

- `git diff --name-status <merge-base>...HEAD` lists 13 files; none is under `scripts/`, and
  the only `dev_tools` paths are the two new files under `tests/scripts/dev_tools/`.
- `grep -rn "blast" scripts/dev_tools/fix_all.py` exits 1 with no match.
- The race lives in `scripts/dev_tools/fix_all_runtime.py`, which spawns one
  `threading.Thread` per branch (line 148) and signals `cancel_event.set()` (line 145). The
  assertion under test depends on the Python branch setting the cancel event before the JSON
  thread reaches its validate step. That file is untouched by the branch.

Conclusion: not attributable to this branch. It is a genuine cross-thread ordering race in
repository code that predates the branch.
