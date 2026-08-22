Timestamp: 2026-08-22T04-46

# Reviewer perturbation battery at branch head `fc9a3a26` (issue #500, cycle 2 re-audit)

Nine perturbations were applied to the two committed truth tables, each followed by a restore with
`git checkout -- <path>` and a `git status --porcelain` check that produced no output. The tree was
clean before the battery and clean after it. No test file, source file, or policy document was
edited at any point.

Baseline before the battery:
`poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/dev_tools/test_blast_radius_config.py -q`
-> EXIT_CODE 0, `48 passed in 0.08s`.
`Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 -PassThru`
-> `TOTAL=20 PASSED=20 FAILED=0`.

## P1 — new top-level key in the self-hosted copy only (R8, first relation)

Injection: `new_top_level_key` added to `config/blast-radius.json`.

- pytest -> EXIT_CODE 1, `1 failed, 47 passed`.
  `FAILED ...::test_every_top_level_key_is_classified_and_shared_by_both_copies`
  `AssertionError: config/blast-radius.json and extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json must declare the same top-level key set; symmetric difference ['new_top_level_key'].`
- Pester -> `PASSED=19 FAILED=1`.
  `FAILED: Committed blast-radius truth table shape.Cross-copy key partition.requires every top-level key in both copies to be classified and shared`
  `Expected $null or empty, but got 'new_top_level_key'.`

## P2 — the same new top-level key added to BOTH copies (R8, second relation)

Injection: `new_top_level_key` added to both files.

- pytest -> EXIT_CODE 1, `1 failed, 47 passed`. Same case, different assertion:
  `AssertionError: Every top-level key in either committed copy must be classified by DECLARED_TOP_LEVEL_KEYS; unclassified keys ['new_top_level_key'].`
- Pester -> `PASSED=19 FAILED=1`, same case, `Expected $null or empty, but got 'new_top_level_key'.`

Both halves of the R8 partition are independently falsifiable in both languages.

## P3 — `shared_surfaces` renamed in the self-hosted copy (vacuous-pass class)

Injection: key renamed to `shared_surfaces_renamed` in `config/blast-radius.json`.

- pytest -> EXIT_CODE 2. Collection error in both modules:
  `TypeError: config["shared_surfaces"] must be a list, got NoneType.` raised at
  `tests/scripts/dev_tools/test_blast_radius_config.py:71` during module import.
- Pester -> `PASSED=15 FAILED=5`: `lists every shared surface as a repo-relative path`,
  `gives every separator-free shared surface no wildcard`,
  `requires every separator-free self-hosted shared surface to reach the bundled copy`,
  `requires every top-level key in both copies to be classified and shared`,
  `lists quality-tiers.yml as both a shared surface and a mandate read`.

## P4 — `shared_surfaces` renamed in the BUNDLED copy (R12 floor under test)

Injection: key renamed to `shared_surfaces_renamed` in the bundled copy.

- Pester -> `PASSED=17 FAILED=3`: `gives every separator-free bundled shared surface no wildcard`,
  `requires every separator-free self-hosted shared surface to reach the bundled copy`,
  `requires every top-level key in both copies to be classified and shared`.
- The R12 non-vacuity floor `requires the shared-surface lists compared by the directional invariant
  to be non-empty` was among the 17 PASSING cases. It did not fire.

Root cause, measured directly under `pwsh -NoProfile` with `$h = @{ a = 1 }`:

- `@($h['shared_surfaces']).Count` returns `1`
- `@(@()).Count` returns `0`
- `@($null).Count` returns `1`

`@($null).Count` is `1`, so `Should -BeGreaterThan 0` holds for an absent or renamed key. The floor
can fail only for a key whose value is an explicitly empty list, not for the renamed-key condition
its own comment names.

## P5 — bundled `modules` emptied to an empty object (non-vacuity, second collection)

Injection: bundled `modules` replaced with an empty object.

- pytest -> EXIT_CODE 1, `1 failed, 15 passed`.
  `FAILED ...::test_the_gate_compares_non_empty_collections`, `assert ()`.
- Pester -> `PASSED=20 FAILED=0`. The mirror does not detect it.

## P6 — separator-BEARING portable surface added to the self-hosted copy only (direction 5)

Injection: `config/new-portable-surface.json` appended to self-hosted `shared_surfaces`.

- pytest -> EXIT_CODE 0, `49 passed`. Pester -> `PASSED=20 FAILED=0`.

Confirms the deliberate asymmetry: the directional invariant filters on entries containing no path
separator, so only a separator-free omission is detected. This matches the qualified wording R9
added to `spec.md`.

## P7 — self-hosted `shared_surface_globs` and `modules` grown (directions 8 and 10)

- Glob injection `scripts/dev_tools/newfam_*.py` -> pytest EXIT_CODE 0, Pester `PASSED=20 FAILED=0`.
  Direction 8 is uncovered in both languages, as designed.
- Module injection of a `newsub` module -> Pester `PASSED=19 FAILED=1`,
  `FAILED: retains exactly the seven ratified subsystem modules`,
  `Expected @('benchmarks', 'codex-runtime', 'config', 'mcp-server', 'poshqc', 'powershell-dev-tools', 'schemas'), but got @('benchmarks', 'codex-runtime', 'config', 'mcp-server', 'newsub', 'poshqc', 'powershell-dev-tools', 'schemas').`
  Direction 10 IS detected, by a pre-existing Pester pin. The cycle-1 re-audit recorded it as
  "No, by design"; that entry was inaccurate and is corrected here.

## P8 — bundled copy reverted to the merge-base state (AC13 and AC14 fail-before)

`git show fb30a9a5:extensions/.../config/blast-radius.json` written over the bundled copy.

- pytest on the parity module -> EXIT_CODE 1, `8 failed, 8 passed`. The two regression cases are
  among the failures: `test_unrelated_claude_citations_do_not_contend_under_the_bundled_table` and
  `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table`, alongside
  `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]`,
  `test_class_two_bundled_shared_surfaces_are_the_portable_set`,
  `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle`,
  `test_class_three_bundled_modules_are_payload_modules_only`,
  `test_no_committed_copy_declares_an_umbrella_module` for the bundled parameter, and
  `test_every_separator_free_bundled_shared_surface_is_wildcard_free`.
- `Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/` -> `PASSED=378 FAILED=5`:
  `declares no removed umbrella module in either committed copy`,
  `declares only payload modules in the bundled copy`,
  `gives every separator-free bundled shared surface no wildcard`,
  `declares equal values for the runtime-describing keys in both copies`,
  `requires every separator-free self-hosted shared surface to reach the bundled copy`.

Both regression directions are independently confirmed fail-before and pass-after.

## P9 — bundled `shared_surfaces` grown, TypeScript suite only (new direction 17)

Injection: `config/drifted-entry.json` appended to bundled `shared_surfaces`.

- `node run-jest.cjs test/lib/push-down` -> EXIT_CODE 0, `15 suites, 222 tests passed`.
- `node run-jest.cjs` for the full suite -> EXIT_CODE 0, `195 suites, 2656 tests passed`.

No TypeScript test reads the committed bundled resource. `SOURCE_BLAST_RADIUS` in
`extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` is a hand-maintained
duplicate whose doc comment states that it mirrors the corrected bundled copy key for key; nothing
enforces that statement.

## Restore proof

After every injection, `git checkout -- <path>` was followed by `git status --porcelain`, which
produced no output in every case. Final state after the battery: `git status --porcelain` produced
no output.
