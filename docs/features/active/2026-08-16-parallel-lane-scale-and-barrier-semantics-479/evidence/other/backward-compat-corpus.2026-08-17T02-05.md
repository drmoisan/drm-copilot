# Backward-Compatibility Corpus Itemization (Issue #479, [P3-T13], AC38)

Timestamp: 2026-08-17T02-05

Command: `git diff --name-only $(git merge-base origin/main HEAD) -- tests/fixtures/`

EXIT_CODE: 0

## Output Summary

Exactly **19** files under `tests/fixtures/` appear in the diff: **6 changed** and **13 added**.
Every one is itemized below with its reason. No unexplained fixture appears.

### Changed fixtures (6) — all AC22 migrations or error-text bound updates from [P2-T8]

| Fixture | What changed | Why |
|---|---|---|
| `manifest_m4_above_upper_bound.json` | `max_concurrency` value `9` -> `33`; `expected_errors` bound `8` -> `32` and `found: 9.` -> `found: 33.`; `expected_max_concurrency` `9` -> `33`; `notes` "the inclusive upper bound is 8" -> "32" | AC22 migration: `9` is IN range at ceiling 32, so this out-of-range exemplar had to move above the new ceiling or it would stop being a negative case. |
| `manifest_multiple_identity_errors_in_field_order.json` | `max_concurrency` value `12` -> `33`; `expected_errors` bound and `found:` value updated; `expected_max_concurrency` `12` -> `33` | AC22 migration: identical reason; `12` is in range at 32. |
| `manifest_m4_below_lower_bound.json` | `expected_errors` bound `8` -> `32` only | The value `0` stays out of range; only the interpolated bound in the message text changed. |
| `manifest_m4_boolean_rejected.json` | `expected_errors` bound `8` -> `32` only | Boolean rejection is unchanged (AC23); only the interpolated bound changed. |
| `manifest_m4_non_integer.json` | `expected_errors` bound `8` -> `32` only | String rejection unchanged; only the interpolated bound changed. |
| `manifest_accessor_open_mode_max_cap.json` | `max_concurrency` value `8` -> `32`; `expected_max_concurrency` `8` -> `32`; `notes` "the upper-bound cap of 8" -> "32" | The accessor's present-value case is re-pointed at the NEW upper bound so the corpus exercises 32 as a valid ceiling value. `expected_errors` stays `[]`. |

The bound change appears only because all five validator messages INTERPOLATE the constant
(`{MIN_CONCURRENCY} through {MAX_CONCURRENCY}`); no message text was hand-edited in any runtime.

### Added fixtures (13) — the [P3-T7] M8 set

Two positive (`manifest_m8_valid_named_component`, `manifest_m8_valid_unnamed_component`) and
eleven negative, one per M8 error class: `not_a_list`, `entry_not_an_object`, `missing_members`,
`empty_members`, `members_not_a_list`, `non_positive_member`, `boolean_member`,
`non_integer_member`, `member_resolves_to_no_item`,
`duplicate_membership_across_components`, `empty_string_name`.

Deliberate omission: no fixture uses a FLOAT member. The bash YAML subset parser refuses float
scalars outright (`yp_classify_scalar` -> `numeric, float, or timestamp scalar outside the
subset`), returning exit 2 rather than an error list, so such a fixture could not be shared by
both lanes. The Python-only float case is covered in
`tests/scripts/dev_tools/test_parallel_manifest_contract_m8.py`. This mirrors the existing
precedent whereby `manifest_m4_non_integer.json` uses a string rather than the `1.5` the Python
suite uses. No fixture added or changed by this feature exercises an integral-float,
quote-divergent, or boolean-equality value beyond the pre-existing boolean-rejection cases
(AC39).

### Unchanged fixtures

All **35** other corpus fixtures are byte-unchanged, and every checkpoint and cohort fixture
outside `tests/fixtures/parallel_manifest_bash/` is untouched — including
`tests/fixtures/parallel_cohorts/batches_cap_exceeds_cohort_size.json`, which remains valid at
the widened bound and needed no edit.

## The corpus test demonstrating byte-identical validation

- **Python lane** — `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py`, run in
  `[P3-T12]`: `104 passed, 5 skipped`. It runs every corpus fixture through the updated Python
  validator and compares against the recorded `expected_errors` element for element, plus both
  accessor results where declared. Every unmigrated fixture's expectation is unchanged, so its
  passing IS the byte-identical backward-compatibility demonstration.
- **bash lane** — `tests/shell/parallel_manifest_parity.bats`, executed by the `[P7-T12]` CI
  dispatch.

## Local verification of the bash lane (exceeds the planned deferral)

`[P3-T6]`'s acceptance anticipated that bash-lane byte-identity against the fixtures could not
be verified locally, because `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py`
imports the Python module and invokes no bash, and the bats runner is unavailable on this
Windows host.

That limitation was narrower than expected. The `.claude/lib/bash/` library is plain, portable
bash and is sourceable under the Git Bash shell available here. A local probe sourced
`.claude/lib/bash/parallel-manifest-validate.sh`, ran `pm_validate_text` over **all 54** corpus
fixtures, and compared the emitted `PC_ERRORS` list — and, where declared, both accessor
results — against each fixture record:

```
corpus fixtures compared: 54; mismatches: 0
```

An earlier, narrower probe over the 13 M8 fixtures alone reported `MATCH` for each and
`mismatches: 0`. The one declared-divergence fixture (`manifest_m1_yaml_parse_failure`) matched
on its recorded prefix, as its contract specifies.

Residual limitation: the probe exercises the LIBRARY, not the bats harness, the CLI entry point
under `bats run`, shfmt formatting, or shellcheck. Those remain discharged only by the
`[P7-T12]` CI dispatch of `.github/workflows/_shell-coverage.yml`.
