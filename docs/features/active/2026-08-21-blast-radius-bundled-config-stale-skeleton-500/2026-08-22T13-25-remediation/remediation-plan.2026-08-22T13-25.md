# Remediation Plan: blast-radius bundled truth-table correction (#500) — Cycle 3 (elective)

**Timestamp:** 2026-08-22T13-25 (UTC)
**Authored by:** atomic-planner
**Feature Folder:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`
**Base Branch:** `main` @ `fb30a9a58b8422e610a09b07361421e97367807a`
**Head:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `a9b0484d`
**Work Mode:** `full-bug`; acceptance-criteria source is `spec.md` only. No acceptance criterion is
touched this cycle — all 17 already pass, and none of CR-1 through CR-6 falls inside
`## Acceptance Criteria`.
**Remediation Cycle:** 3 (elective, user-directed; cap authorization covers cycles 3 and 4)
**Source:** `code-review.2026-08-22T04-46.md`, `policy-audit.2026-08-22T04-46.md`,
`feature-audit.2026-08-22T04-46.md`, and `artifacts/orchestration/orchestrator-state.json`
`remediation_loop.cycles[2].findings`. No `remediation-inputs` artifact exists for this cycle
because the cycle-2 re-audit raised zero blocking findings.
**Prior cycle plans (do not overwrite):** `remediation-plan.2026-08-22T01-10.md` (cycle 1),
`remediation-plan.2026-08-22T03-15.md` (cycle 2).

---

## Scope Statement

- CR-1 (Major) — the R12 Pester non-vacuity floor cannot fail for the condition it guards
  (`@($null).Count` is `1` in PowerShell). Repair it.
- CR-2 (Major) — the Pester mirror has no non-vacuity floor for the bundled `modules` map. Extend
  the same repaired floor to cover it.
- CR-4 (Major, new) — `SOURCE_BLAST_RADIUS` in `config-carriage.test-helpers.ts` claims to mirror
  the bundled resource key for key and nothing enforces it. Add the assertion. **This brings
  TypeScript back into scope** for baseline and final QA.
- CR-3 (Minor) — `DECLARED_TOP_LEVEL_KEYS` is only one-third derived. Bind the Class 2 and Class 3
  key names to the assertions that consume them, in both languages.
- CR-5 (Minor) — two pre-PD-1 pointers to `test_blast_radius_config.py` survive in `spec.md` at
  lines 388 and 412, outside the acceptance criteria.
- CR-6 (Minor) — none of the 18 local-time-stamped artifacts points at the clock-convention note
  that explains their timestamps. Add a one-line pointer to each, without renaming any of them.

**Languages touched this cycle:** Python, PowerShell, and **TypeScript** (reintroduced by CR-4).
Markdown is touched (`spec.md`, 18 evidence artifacts) but carries no toolchain obligation.

**Falsifiability discipline (binding for every task in this plan):** every new or repaired
assertion is demonstrated by perturbing the exact input state the assertion must reject, observing
the failure name the witness, restoring the perturbed file, proving the restore with
`git status --short` producing no output for that path, and rerunning to green. Every Pester
demonstration uses a `Filter.FullName` name-filtered `New-PesterConfiguration` run so the
perturbation's other failures do not bury the signal, per the cycle 1/2 precedent.

**Do Not Do:**

- Do not touch any acceptance criterion; none of CR-1 through CR-6 falls inside
  `## Acceptance Criteria`, and this plan adds, removes, checks, or unchecks none.
- Do not rename any of the 18 timestamped artifacts (CR-6 adds a pointer line only).
- Do not weaken the directional invariant, the exhaustiveness gate, or any existing assertion to
  accommodate a fix in this plan.
- Do not add a coverage `exclude`/`omit` entry.
- Do not author, import, or read a JSON Schema.
- Do not modify any file under `.claude/rules/` or `.github/instructions/` in this cycle; none of
  CR-1 through CR-6 requires a rule amendment, so none is made.
- Do not write evidence anywhere but `<FEATURE>/evidence/<kind>/`.
- Do not edit `tests/scripts/dev_tools/test_blast_radius_config.py` (499 of 500 lines).

---

### Phase 0 — Policy Reads and Toolchain Baselines (Python, PowerShell, TypeScript)

- [x] [P0-T1] Read `CLAUDE.md` in full.
- [x] [P0-T2] Read `.claude/rules/general-code-change.md` in full.
- [x] [P0-T3] Read `.claude/rules/general-unit-test.md` in full.
- [x] [P0-T4] Read `.claude/rules/python.md` in full.
- [x] [P0-T5] Read `.claude/rules/python-suppressions.md` in full.
- [x] [P0-T6] Read `.claude/rules/powershell.md` in full.
- [x] [P0-T7] Read `.claude/rules/typescript.md` in full.
- [x] [P0-T8] Read `.claude/rules/typescript-suppressions.md` in full.
- [x] [P0-T9] Read `.claude/rules/quality-tiers.md` in full.
- [x] [P0-T10] Read `.claude/rules/plan-acceptance-gates.md` in full.
- [x] [P0-T11] Read `.claude/rules/tonality.md` in full.
- [x] [P0-T12] Write the Phase 0 policy-read evidence artifact to
      `evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md` (UTC,
      `yyyy-MM-ddTHH-mm` form), recording `Timestamp:`, `Policy Order:`, and the eleven files read
      in P0-T1 through P0-T11, in that order.
      Acceptance: the artifact file exists and lists all eleven files in order.
- [x] [P0-T13] Write a scope note at `evidence/remediation-baseline/typescript-back-in-scope.<timestamp>.md`
      stating that CR-4 adds a TypeScript assertion reading a real file from disk, which reverses
      the cycle-1/cycle-2 TypeScript exclusion, so TypeScript is baselined and re-run in Final QA
      this cycle.
      Acceptance: the artifact file exists and names CR-4 as the reason.
- [x] [P0-T14] From the worktree root, run `poetry run black --check .` and record the artifact at
      `evidence/remediation-baseline/python-black.<timestamp>.md` with `Timestamp:`, `Command:`,
      `EXIT_CODE:`, `Output Summary:`.
      Acceptance: `EXIT_CODE: 0` is recorded.
- [x] [P0-T15] From the worktree root, run `poetry run ruff check .` and record the artifact at
      `evidence/remediation-baseline/python-ruff.<timestamp>.md` with the same four fields.
      Acceptance: `EXIT_CODE: 0` is recorded.
- [x] [P0-T16] From the worktree root, run `poetry run pyright` and record the artifact at
      `evidence/remediation-baseline/python-pyright.<timestamp>.md` with the same four fields,
      `Output Summary:` naming the error and warning counts.
      Acceptance: `EXIT_CODE: 0` and `0 errors, 0 warnings` are recorded.
- [x] [P0-T17] From the worktree root, run
      `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`
      and record the artifact at `evidence/remediation-baseline/python-pytest-coverage.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the pass/fail/skip
      counts, the statement percentage as `(Stmts - Miss) / Stmts` from the `TOTAL` row, and the
      branch percentage from `totals.percent_branches_covered` in `artifacts/python/coverage.json`.
      Acceptance: `EXIT_CODE: 0`; both coverage figures recorded, each >= the
      `.claude/rules/quality-tiers.md` thresholds (85% statements, 75% branches).
- [x] [P0-T18] Run `mcp__drm-copilot__run_poshqc_format` and record the artifact at
      `evidence/remediation-baseline/powershell-poshqc-format.<timestamp>.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`.
      Acceptance: `EXIT_CODE: 0` and zero files rewritten are recorded.
- [x] [P0-T19] Run `mcp__drm-copilot__run_poshqc_analyze` and record the artifact at
      `evidence/remediation-baseline/powershell-poshqc-analyze.<timestamp>.md` with the same four
      fields.
      Acceptance: `EXIT_CODE: 0` and zero findings are recorded.
- [x] [P0-T20] Run `mcp__drm-copilot__run_poshqc_test` and record the artifact at
      `evidence/remediation-baseline/powershell-poshqc-test.<timestamp>.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the pass/fail/skip counts and the line
      coverage percentage from the JaCoCo root `LINE` counter as `covered / (covered + missed)`.
      Acceptance: `EXIT_CODE: 0` and a recorded line coverage >= 85%.
- [x] [P0-T21] From `extensions/drm-copilot`, run `npm run format` and record the artifact at
      `evidence/remediation-baseline/typescript-prettier.<timestamp>.md` with the same four fields.
      Acceptance: `EXIT_CODE: 0` and zero files rewritten are recorded.
- [x] [P0-T22] From `extensions/drm-copilot`, run `npm run lint` and record the artifact at
      `evidence/remediation-baseline/typescript-eslint.<timestamp>.md` with the same four fields.
      Acceptance: `EXIT_CODE: 0` is recorded.
- [x] [P0-T23] From `extensions/drm-copilot`, run `npm run typecheck` and record the artifact at
      `evidence/remediation-baseline/typescript-typecheck.<timestamp>.md` with the same four
      fields.
      Acceptance: `EXIT_CODE: 0` is recorded.
- [x] [P0-T24] From `extensions/drm-copilot`, run `npm run test:coverage` (resolves to
      `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`;
      `test:unit:coverage` does not exist in this package's manifest, which declares exactly
      `test`, `test:unit`, and `test:coverage`) and record the artifact at
      `evidence/remediation-baseline/typescript-jest-coverage.<timestamp>.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the pass/fail counts and the line and
      branch coverage percentages Jest reports.
      Acceptance: `EXIT_CODE: 0`; both coverage figures recorded, each >= the
      `.claude/rules/quality-tiers.md` thresholds (85% lines, 75% branches).
- [x] [P0-T25] Confirm file sizes before any edit: from the worktree root, run
      `wc -l tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/dev_tools/blast_radius_parity_test_support.py tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`
      and record the artifact at `evidence/remediation-baseline/edit-target-line-counts.<timestamp>.md`.
      Acceptance: the artifact records five counts, each less than 500 (measured at plan-authoring
      time: 461, 180, 446, 224, 434 — the executor's own measurement is authoritative).

---

### Phase 1 — CR-1 & CR-2: Repair and extend the Pester non-vacuity floor

- [x] [P1-T1] In `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, replace
      the `It 'requires the shared-surface lists compared by the directional invariant to be
      non-empty'` block (in the `Cross-copy key partition` `Context`) with a repaired and extended
      case titled `requires a populated shared-surface list and module map in both copies` that,
      for each of the four `(label, config, key)` combinations
      `('self-hosted shared_surfaces', $script:CommittedConfig, 'shared_surfaces')`,
      `('bundled shared_surfaces', $script:BundledConfig, 'shared_surfaces')`,
      `('self-hosted modules', $script:CommittedConfig, 'modules')`, and
      `('bundled modules', $script:BundledConfig, 'modules')`, discriminates in this order so the
      genuinely ambiguous `@($null).Count` idiom is never reached for the absent-key or null-value
      states:
      1. If `-not $config.ContainsKey($key)`, record `"$label`: `$key` key absent"`.
      2. Else if `$null -eq $config[$key]`, record `"$label`: `$key` is null"`.
      3. Else measure the count (`@($config[$key]).Count` for `shared_surfaces`,
         `@($config[$key].Keys).Count` for `modules` — safe here because `$null` was already
         excluded by step 2, so `@()` wrapping cannot misclassify it), and if the count is `0`,
         record `"$label`: `$key` is empty"`.
      Accumulate every offending combination into a list and assert it `Should -BeNullOrEmpty`, so
      one run names every failing combination rather than the first.
      Acceptance: a targeted `Invoke-Pester` run against
      `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` reports the new `It`
      block passing with 0 failed, run from the worktree root.
- [x] [P1-T2] Confirm file size and headroom: from the worktree root, run
      `(Get-Content tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1).Count`.
      Acceptance: the reported count is less than 500. If the count is 480 or more, stop and split
      the `Cross-copy key partition` `Context` into a sibling file
      `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` before continuing
      to Phase 3 (which adds further lines to this file), rather than proceeding past the ceiling.
- [x] [P1-T3] [expect-fail] Demonstrate CR-1 falsifiability — the absent-key state the old floor
      missed: from the worktree root, run
      `python -c "import json;p='extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json';d=json.load(open(p,encoding='utf-8'));del d['shared_surfaces'];open(p,'w',encoding='utf-8').write(json.dumps(d,indent=2)+chr(10))"`,
      deleting the `shared_surfaces` key from the bundled copy so it is absent (not empty). Then run
      the filtered Pester case:
      ```powershell
      $pesterConfig = New-PesterConfiguration
      $pesterConfig.Run.Path = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
      $pesterConfig.Run.PassThru = $true
      $pesterConfig.Filter.FullName = '*requires a populated shared-surface list and module map in both copies*'
      $result = Invoke-Pester -Configuration $pesterConfig
      ```
      and, in the same perturbed state, run
      `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_the_gate_compares_non_empty_collections`
      to confirm the Python floor responds to the same input the same way. Record the fail-before
      evidence artifact at
      `evidence/regression-testing/powershell-non-vacuity-floor-fail-before.<timestamp>.md` with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary:` quoting
      `$result.FailedCount` and the failure message, plus the Python companion result.
      Acceptance: the filtered Pester run reports `Passed=0 Failed=1`, naming
      `bundled shared_surfaces: shared_surfaces key absent`; the Python node ID exits `1`, `1
      failed`. This is the state the pre-repair floor passed on (state under test: absent key,
      which the unrepaired `@($null).Count` idiom could not distinguish from a populated list).
- [x] [P1-T4] Restore and confirm both floors pass again: from the worktree root, run
      `git checkout -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`,
      then
      `git status --short -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`
      (expect no output), then rerun the identical filtered Pester configuration from P1-T3 and the
      identical Python node ID. Record the pass-after evidence artifact at
      `evidence/qa-gates/powershell-non-vacuity-floor-pass-after.<timestamp>.md` with the same
      fields.
      Acceptance: `git status --short` produces no output for that path; the filtered Pester rerun
      reports `Passed=1 Failed=0`; the Python node ID exits `0`, `1 passed`.
- [x] [P1-T5] [expect-fail] Demonstrate CR-2 falsifiability — the emptied-map state the Pester
      mirror never covered: from the worktree root, run
      `python -c "import json;p='extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json';d=json.load(open(p,encoding='utf-8'));d['modules']={};open(p,'w',encoding='utf-8').write(json.dumps(d,indent=2)+chr(10))"`,
      emptying the bundled `modules` map to `{}`. Then rerun the identical filtered Pester
      configuration from P1-T3, and in the same perturbed state run
      `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_the_gate_compares_non_empty_collections`.
      Record the fail-before evidence artifact at
      `evidence/regression-testing/powershell-non-vacuity-floor-modules-fail-before.<timestamp>.md`
      with the same required fields.
      Acceptance: the filtered Pester run reports `Passed=0 Failed=1`, naming
      `bundled modules: modules is empty`; the Python node ID exits `1`, `1 failed` (matching the
      cycle-2 re-audit's Perturbation P5, `assert ()`). This is the emptied-map state the
      unrepaired Pester file passed on at `20 passed, 0 failed`.
- [x] [P1-T6] Restore and confirm both floors pass again: from the worktree root, run
      `git checkout -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`,
      then `git status --short` on the same path (expect no output), then rerun the filtered Pester
      configuration and the Python node ID. Record the pass-after evidence artifact at
      `evidence/qa-gates/powershell-non-vacuity-floor-modules-pass-after.<timestamp>.md`.
      Acceptance: `git status --short` produces no output; the filtered Pester rerun reports
      `Passed=1 Failed=0`; the Python node ID exits `0`, `1 passed`.

---

### Phase 2 — CR-4: Bind `SOURCE_BLAST_RADIUS` to the committed bundled resource (TypeScript)

- [x] [P2-T1] In `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`, in the
      `describe("issue #462 AC6: the Claude push-down publishes the config tree", ...)` block,
      immediately after the existing case
      `it("pins the bundled routing source byte-identical to the repo-root file", ...)`, add a new
      case `it("keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius
      resource", ...)` that builds `bundledPath` via `path.join(REPO_ROOT, "extensions",
      "drm-copilot", "resources", "claude-customizations", "config", "blast-radius.json")` (the
      same join style as the existing routing pin), reads it with
      `fs.readFileSync(bundledPath, "utf8")`, parses both that text and `SOURCE_BLAST_RADIUS` with
      `JSON.parse`, and asserts `expect(fixture).toEqual(committed)`. No existing case, import, or
      constant is modified.
      Acceptance:
      `node run-jest.cjs -t "keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource"`,
      run from `extensions/drm-copilot`, reports `Tests: 1 passed, 1 total`. The exit code alone
      does not discriminate here: measured before this task, the same command exits `0` today with
      `Tests: 2656 skipped, 2656 total` and `0 passed` — a name filter matching nothing discovers
      every test, skips all of them, and Jest reports success (`run-jest.cjs` blocks
      `--passWithNoTests`, `--onlyChanged`, and `--lastCommit`, but that guard does not cover a
      name-filter miss). The state that would make this acceptance pass wrongly is exactly that
      zero-discovery state, and it is the current one, which is why the passed count, not the exit
      code, is the assertion.
- [x] [P2-T2] Confirm file size: from `extensions/drm-copilot`, run
      `(Get-Content test/lib/push-down/claude-config-carriage.test.ts).Count` or the shell
      equivalent `wc -l`.
      Acceptance: the reported count is less than 500 (measured before: 434).
- [x] [P2-T3] [expect-fail] Demonstrate falsifiability: from the worktree root, run
      `python -c "import json;p='extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json';d=json.load(open(p,encoding='utf-8'));d['shared_surfaces'].append('injected-witness.lock');open(p,'w',encoding='utf-8').write(json.dumps(d,indent=2)+chr(10))"`,
      appending a witness entry the fixture does not carry — the exact perturbation the cycle-3
      audit used to show the whole 2656-test Jest suite passing. Then, from `extensions/drm-copilot`,
      run
      `node run-jest.cjs -t "keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource"`.
      Record the fail-before evidence artifact at
      `evidence/regression-testing/typescript-source-blast-radius-fidelity-fail-before.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary:` quoting
      the Jest diff naming `injected-witness.lock`.
      Acceptance: `EXIT_CODE: 1`, `1 failed`, with the failure diff naming `injected-witness.lock`.
- [x] [P2-T4] Restore and confirm the case passes again: from the worktree root, run
      `git checkout -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`,
      then
      `git status --short -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`
      (expect no output), then from `extensions/drm-copilot` rerun
      `node run-jest.cjs -t "keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource"`.
      Record the pass-after evidence artifact at
      `evidence/qa-gates/typescript-source-blast-radius-fidelity-pass-after.<timestamp>.md`.
      Acceptance: `git status --short` produces no output; the rerun reports `Tests: 1 passed, 1
      total`. As in P2-T1, the exit code alone would not discriminate a genuine pass from a
      zero-discovery no-op; the passed count is the assertion.

---

### Phase 3 — CR-3: Bind the Class 2 and Class 3 key names to their consuming assertions

- [x] [P3-T1] In `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, replace the inline
      literal set in `DECLARED_TOP_LEVEL_KEYS` with two new module-level tuples,
      `CLASS_TWO_KEYS = ("shared_surfaces", "shared_surface_globs")` and
      `CLASS_THREE_KEYS = ("modules",)`, each with a one-line comment naming the test function(s)
      that consume it, and rebuild `DECLARED_TOP_LEVEL_KEYS` as
      `frozenset(BYTE_EQUAL_KEYS) | frozenset(CLASS_TWO_KEYS) | frozenset(CLASS_THREE_KEYS)`.
      Acceptance: from the worktree root,
      `git grep -c -F "CLASS_TWO_KEYS = (" -- tests/scripts/dev_tools/blast_radius_parity_test_support.py`
      reports `1` after the edit (measured before the edit: `0`, this literal is absent from the
      file today).
- [x] [P3-T2] In `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, import
      `CLASS_TWO_KEYS` and `CLASS_THREE_KEYS` from the support module, and add one assertion line
      to each of the three consuming test functions binding the class tuple to the key it
      exercises: `assert "shared_surfaces" in CLASS_TWO_KEYS` at the top of
      `test_class_two_bundled_shared_surfaces_are_the_portable_set`,
      `assert "shared_surface_globs" in CLASS_TWO_KEYS` at the top of
      `test_class_two_bundled_shared_surface_globs_are_empty`, and
      `assert "modules" in CLASS_THREE_KEYS` at the top of
      `test_class_three_bundled_modules_are_payload_modules_only`. This makes each name in
      `DECLARED_TOP_LEVEL_KEYS`'s Class 2 and Class 3 contribution provably read by the assertion
      that is supposed to consume it, rather than merely restated.
      Acceptance:
      `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_two_bundled_shared_surfaces_are_the_portable_set tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_two_bundled_shared_surface_globs_are_empty tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_three_bundled_modules_are_payload_modules_only`
      exits `0` with `3 passed`, run from the worktree root.
- [x] [P3-T3] Confirm file sizes: from the worktree root, run
      `wc -l tests/scripts/dev_tools/blast_radius_parity_test_support.py tests/scripts/dev_tools/test_blast_radius_config_parity.py`.
      Acceptance: both reported counts are less than 500.
- [x] [P3-T4] [expect-fail] Demonstrate Python falsifiability: temporarily edit
      `tests/scripts/dev_tools/blast_radius_parity_test_support.py` so `CLASS_THREE_KEYS = ()`
      (removing `"modules"`, leaving the tuple empty), leaving `config/blast-radius.json` and the
      bundled copy untouched. Run
      `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_three_bundled_modules_are_payload_modules_only tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_top_level_key_is_classified_and_shared_by_both_copies`.
      Record the fail-before evidence artifact at
      `evidence/regression-testing/python-class-key-binding-fail-before.<timestamp>.md` with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary:` quoting both
      failure messages.
      Acceptance: `EXIT_CODE: 1`, `2 failed`: the class-3 membership assertion fails because
      `"modules" not in ()`, and the exhaustiveness case fails naming `modules` as unclassified in
      both copies, because `DECLARED_TOP_LEVEL_KEYS` no longer includes it. Both cases pass on the
      unperturbed file (measured in P3-T2), so this is a genuine before/after distinction on the
      support module's own source, not on the committed configuration data.
- [x] [P3-T5] Restore and confirm both cases pass again: from the worktree root, run
      `git checkout -- tests/scripts/dev_tools/blast_radius_parity_test_support.py`, then
      `git status --short -- tests/scripts/dev_tools/blast_radius_parity_test_support.py` (expect
      no output), then rerun the same two node IDs from P3-T4.
      Acceptance: `git status --short` produces no output; `EXIT_CODE: 0`, `2 passed`.
- [x] [P3-T6] In `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, in the
      file-level `BeforeAll` (before the `Describe` block), declare three script-scoped arrays,
      `$script:ClassOneKeys = @('version', 'over_breadth_fraction', 'mandate_reads')`,
      `$script:ClassTwoKeys = @('shared_surfaces', 'shared_surface_globs')`, and
      `$script:ClassThreeKeys = @('modules')`, each with a one-line comment naming the case(s) that
      read it. Update the `It 'declares equal values for the runtime-describing keys in both
      copies'` case to read `$script:ClassOneKeys` instead of its own locally re-typed
      `$byteEqualKey`, and update the `It 'requires every top-level key in both copies to be
      classified and shared'` case to build `$declaredTopLevelKey` as
      `$script:ClassOneKeys + $script:ClassTwoKeys + $script:ClassThreeKeys` instead of retyping
      all six names. No other case is modified.
      Acceptance: a targeted `Invoke-Pester` run against
      `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` reports both the
      `declares equal values for the runtime-describing keys in both copies` case and the
      `requires every top-level key in both copies to be classified and shared` case passing, run
      from the worktree root.
- [x] [P3-T7] Confirm file size and headroom: from the worktree root, run
      `(Get-Content tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1).Count`.
      Acceptance: the reported count is less than 500. If the count is 490 or more, split the
      `Cross-copy key partition` `Context` into the sibling file named in P1-T2 before proceeding
      to Phase 6.
- [x] [P3-T8] [expect-fail] Demonstrate Pester falsifiability: temporarily edit the same file so
      `$script:ClassThreeKeys = @()` in the `BeforeAll` (removing `'modules'`), leaving both
      committed configuration files untouched. Run the filtered configuration:
      ```powershell
      $pesterConfig = New-PesterConfiguration
      $pesterConfig.Run.Path = 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1'
      $pesterConfig.Run.PassThru = $true
      $pesterConfig.Filter.FullName = '*requires every top-level key in both copies to be classified and shared*'
      $result = Invoke-Pester -Configuration $pesterConfig
      ```
      Record the fail-before evidence artifact at
      `evidence/regression-testing/powershell-class-key-binding-fail-before.<timestamp>.md`.
      Acceptance: the filtered run reports `Passed=0 Failed=1`, naming `modules` as unclassified in
      both copies (present in both committed configs but absent from the now-shrunk declared set).
- [x] [P3-T9] Restore and confirm the case passes again: from the worktree root, run
      `git checkout -- tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, then
      `git status --short` on the same path (expect no output), then rerun the identical filtered
      configuration from P3-T8.
      Acceptance: `git status --short` produces no output; the filtered rerun reports `Passed=1
      Failed=0`.

---

### Phase 4 — CR-5: Retire the two remaining pre-PD-1 pointers in `spec.md`

- [x] [P4-T1] In
      `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`,
      `## Test Strategy`, the regression-tests bullet at line 388, append
      "(pre-PD-1 intent; delivered under PD-1 in the sibling
      `tests/scripts/dev_tools/test_blast_radius_config_parity.py`)" immediately after "parametrized
      over both copies." so the sentence reads: "...second, `tests/scripts/dev_tools/test_blast_radius_config.py`
      parametrized over both copies. (pre-PD-1 intent; delivered under PD-1 in the sibling
      `tests/scripts/dev_tools/test_blast_radius_config_parity.py`)". The construct named is
      unchanged; only the disposition annotation is added.
      Acceptance: from the worktree root,
      `git grep -c -F "pre-PD-1 intent; delivered under PD-1" -- docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
      reports at least `1` after the edit (measured before the edit: `0`, this literal is absent
      from `spec.md` today).
- [x] [P4-T2] In the same file, `## Test Strategy`, the Python toolchain-command bullet at line
      412, insert `tests/scripts/dev_tools/test_blast_radius_config_parity.py` between
      `tests/scripts/dev_tools/test_blast_radius_config.py` and
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` in the `poetry run
      pytest` invocation, so the command collects the parity gate alongside the other two modules.
      Acceptance: (a), run from the worktree root against
      `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`,
      `git grep -c -F "test_blast_radius_config.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py" -- docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
      reports `0` after the edit (measured before the edit: `1` — the two filenames are adjacent
      today, and inserting the parity module between them breaks that exact adjacency).
      (b) replaces a phrase search with the node-ID-carrying check the plan's own guidance prefers,
      because CR-5's subject is exactly a stale pytest invocation and a text search for the
      corrected adjacency is absent from the tracked tree and unquoted, so it cannot fail either
      way (the validator's G5 warning on the prior draft). Run, from the worktree root,
      `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --collect-only -q | grep -c -F "test_blast_radius_config_parity.py"`
      — the exact three-module invocation the edit writes into `spec.md`, run for real rather than
      searched for as text. It reports `16` after the edit (measured before the edit: running the
      command as currently written, which omits the parity module entirely, so the same
      `grep -c -F` pipeline reports `0` today — the literal cannot appear in output from an
      invocation that never names the file). The state that would make this check pass wrongly is
      the parity module's file path appearing in `--collect-only -q` output for a reason other than
      genuine collection; that format prints exactly one line per collected node ID and no other
      line shape, so a nonzero count is collection, not coincidence, and confirming the count is
      `16` (not merely nonzero) additionally rules out a partial or accidental match. That state is
      not the current one: today the file is not named in the command at all, so the count is `0`.

---

### Phase 5 — CR-6: Point the 18 local-time artifacts at the clock-convention note

- [x] [P5-T1] Append one line to each of the 18 artifacts stamped `2026-08-21T21-49` under
      `evidence/remediation-baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, and
      `evidence/issue-updates/`: "Note: see `evidence/other/timestamp-clock-convention.2026-08-22T03-37.md`
      for why this artifact's local-time stamp sorts before the UTC-stamped Phase 0 baselines it
      postdates." No artifact is renamed and no existing field is altered.
      Acceptance: from the worktree root,
      `git grep -c -F "timestamp-clock-convention.2026-08-22T03-37.md" -- docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/*/*2026-08-21T21-49*`
      reports 18 output lines (one `path:count` line per matching file, `git grep -c` reporting a
      per-file count rather than a single integer) after the edit, versus 0 output lines before the
      edit — none of the 18 references the convention note today.

---

### Phase 6 — Final QA Loop (Python, PowerShell, TypeScript)

- [x] [P6-T1] From the worktree root, run `poetry run black --check .`.
      Acceptance: `EXIT_CODE: 0`.
- [x] [P6-T2] From the worktree root, run `poetry run ruff check .`.
      Acceptance: `EXIT_CODE: 0`, zero new `noqa` present.
- [x] [P6-T3] From the worktree root, run `poetry run pyright`.
      Acceptance: `EXIT_CODE: 0`, `0 errors, 0 warnings`.
- [x] [P6-T4] From the worktree root, run
      `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`
      and record the final-QC artifact at
      `evidence/qa-gates/final-python-pytest-coverage.<timestamp>.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the pass/fail/skip counts, the
      statement percentage from the `TOTAL` row, and the branch percentage from
      `totals.percent_branches_covered` in `artifacts/python/coverage.json`.
      Acceptance: `EXIT_CODE: 0`, with both coverage figures at or above the P0-T17 baseline
      figures (no regression).
- [x] [P6-T5] Confirm the parity module's node count grew by exactly one over this cycle: from the
      worktree root, run
      `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py`.
      Acceptance: `EXIT_CODE: 0` and `16 passed` (unchanged from the start of this cycle — CR-3
      added assertions to existing test bodies rather than new test functions, so the collected
      count is stable; this confirms no case was accidentally duplicated or dropped).
- [x] [P6-T6] Run `mcp__drm-copilot__run_poshqc_format`.
      Acceptance: `EXIT_CODE: 0`, zero files rewritten (a clean tree after the run).
- [x] [P6-T7] Run `mcp__drm-copilot__run_poshqc_analyze`.
      Acceptance: `EXIT_CODE: 0`, zero findings.
- [x] [P6-T8] Run `mcp__drm-copilot__run_poshqc_test` and record the final-QC artifact at
      `evidence/qa-gates/final-powershell-poshqc-test.<timestamp>.md` with the same four required
      fields, `Output Summary:` naming the pass/fail/skip counts and the line coverage percentage
      from the JaCoCo root `LINE` counter.
      Acceptance: `EXIT_CODE: 0` and the recorded line coverage at or above the P0-T20 baseline
      figure (no regression).
- [x] [P6-T9] From `extensions/drm-copilot`, run `npm run format`.
      Acceptance: `EXIT_CODE: 0`, zero files rewritten.
- [x] [P6-T10] From `extensions/drm-copilot`, run `npm run lint`.
      Acceptance: `EXIT_CODE: 0`.
- [x] [P6-T11] From `extensions/drm-copilot`, run `npm run typecheck`.
      Acceptance: `EXIT_CODE: 0`.
- [x] [P6-T12] From `extensions/drm-copilot`, run `npm run test:coverage` (resolves to
      `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`;
      `test:unit:coverage` does not exist, per P0-T24) and record the final-QC artifact at
      `evidence/qa-gates/final-typescript-jest-coverage.<timestamp>.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the pass/fail counts and the line and
      branch coverage percentages.
      Acceptance: `EXIT_CODE: 0`, with both coverage figures at or above the P0-T24 baseline
      figures (no regression), and the total test count at least 2657 (the 2656 present at the
      start of this cycle plus the one CR-4 case added).
- [x] [P6-T13] Write the coverage delta-verification artifact at
      `evidence/qa-gates/coverage-delta-verification.<timestamp>.md` reporting, for Python,
      PowerShell, and TypeScript: baseline coverage (Phase 0), post-change coverage (P6-T4 / P6-T8
      / P6-T12), and new/changed-code coverage. The one changed TypeScript production-adjacent test
      file (`claude-config-carriage.test.ts`) is test code and outside the coverage denominator by
      construction; no production file is touched by CR-1 through CR-6, so the new/changed-code
      coverage figure for all three languages is 100% of changed production lines, of which there
      are zero.
      Acceptance: the artifact records baseline and post-change figures for all three languages
      with a delta of 0.00 or better on every figure.
- [x] [P6-T14] Confirm no coverage `exclude`/`omit` entry was added: from the worktree root, run
      `git diff fb30a9a58b8422e610a09b07361421e97367807a...HEAD -- pyproject.toml extensions/drm-copilot/jest.config.cjs`.
      Acceptance: the diff produces no output.
- [x] [P6-T15] Confirm the file-size ceiling holds for every file touched this cycle: from the
      worktree root, run
      `wc -l tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/dev_tools/blast_radius_parity_test_support.py tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`.
      Acceptance: all four reported counts are less than 500.
- [x] [P6-T16] Confirm `tests/scripts/dev_tools/test_blast_radius_config.py` is untouched over the
      whole branch, and that `config-carriage.test-helpers.ts` is untouched by **this cycle**
      specifically (only the consuming test file changes for CR-4, not the fixture helper — the
      helper's `SOURCE_BLAST_RADIUS` and its doc comment were legitimately rewritten earlier in the
      branch, under the original plan's P4-T3/P4-T4, so the whole-branch range is the wrong range
      for this claim). Run two commands from the worktree root: (a)
      `git diff fb30a9a58b8422e610a09b07361421e97367807a...HEAD -- tests/scripts/dev_tools/test_blast_radius_config.py`,
      which must produce no output (measured: 0 diff lines over the whole branch); (b)
      `git diff a9b0484d...HEAD -- extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`,
      scoped to this cycle only, using `a9b0484d`, this plan's cycle-opening commit named in its
      header, as the base — which must also produce no output. The whole-branch diff for the helper
      is **not** asserted to be empty: it measures 65 lines, all pre-existing and legitimate, and
      would wrongly fail this task if used as the range for claim (b).
      Acceptance: command (a) produces no output; command (b) produces no output.
- [x] [P6-T17] Write the final single-pass confirmation artifact at
      `evidence/qa-gates/remediation-toolchain-single-pass.<timestamp>.md` recording that P6-T1
      through P6-T12 executed in one uninterrupted sequence across all three languages with no
      restart and no file rewritten by any stage.
      Acceptance: the artifact records all twelve exit codes as 0 with no intervening restart.
- [x] [P6-T18] Write the updated AC status summary at
      `evidence/issue-updates/ac-status-summary.<timestamp>.md` stating 17 of 17 acceptance
      criteria checked and unchanged by this cycle, with a one-line note that this cycle's six
      findings (CR-1 through CR-6) are code-review findings outside the acceptance-criteria section
      and required no checkbox change.
      Acceptance: the artifact states `17 of 17 checked` and names zero acceptance criteria
      modified this cycle.

---

## Exit Condition for Cycle 3

This cycle exits when a reaudit confirms all of the following:

1. The repaired Pester non-vacuity floor fails on an absent `shared_surfaces` key and on an emptied
   `modules` map in the bundled copy, in both cases restored and reproven green (CR-1, CR-2).
2. `SOURCE_BLAST_RADIUS` is bound to the real bundled resource by a passing Jest assertion that
   fails when the resource drifts, restored and reproven green (CR-4).
3. Each of the three Class 2/Class 3 key names is provably consumed by the assertion that reads it,
   in both languages, demonstrated by a failing-then-passing perturbation of the binding itself
   (CR-3).
4. `spec.md` carries no unannotated pre-PD-1 pointer to `test_blast_radius_config.py` outside the
   acceptance criteria (CR-5).
5. All 18 local-time-stamped artifacts point at the clock-convention note, none renamed (CR-6).
6. The full toolchain passes in a single pass for Python, PowerShell, and TypeScript, and coverage
   is unchanged or improved in all three.
7. All 17 acceptance criteria remain checked and unchanged.
8. `blocking_count == 0`.
