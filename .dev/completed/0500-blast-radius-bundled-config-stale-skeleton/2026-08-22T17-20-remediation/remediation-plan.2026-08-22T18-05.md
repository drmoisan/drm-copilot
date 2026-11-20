# Remediation Plan: blast-radius bundled truth-table correction (#500) — Cycle 4 (final)

**Timestamp:** 2026-08-22T18-05 (UTC)
**Authored by:** atomic-planner
**Feature Folder:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`
**Base Branch:** `main`, merge-base reported by the orchestrator as `bee15c0660d382ed74c642d2e028fd136051046f`
after a rebase onto the issue-501 fix (PR #504). This plan does not take that SHA on faith: every
diff-range acceptance below resolves the merge-base **dynamically** at execution time via
`git merge-base main HEAD` rather than citing a literal commit, so the plan cannot go stale the way
the artifact this cycle exists to fix went stale.
**Head:** reported by the orchestrator as `627c45d1`. Not independently verified in this planning
session (no shell/`git` tool was available to this agent); the executor must re-resolve `HEAD` at
run time rather than trust this citation, for the same reason.
**Work Mode:** `full-bug`; acceptance-criteria source is `spec.md` only. Only AC11 is touched, under
R2, and only after its corrected text is verified.
**Remediation Cycle:** 4 of 4 (final; user-authorized cap). No fifth cycle is anticipated; every
acceptance condition below is designed to close, not merely narrow, the finding it addresses.
**Source:** `remediation-inputs.2026-08-22T17-20.md`, present in **two** locations — the
feature-folder root and `2026-08-22T17-20-remediation/` — byte-identical (see the Pre-Flight Tree
Verification section below for the recommended canonical copy), and the sibling `policy-audit`,
`code-review`, and `feature-audit` dated `2026-08-22T17-20`, at the feature-folder root.
**Prior cycle plans:** `remediation-plan.2026-08-22T01-10.md`, `remediation-plan.2026-08-22T03-15.md`,
and `remediation-plan.2026-08-22T13-25.md` are the completed records of cycles 1 through 3, and are
**present** in the working tree, each inside its own per-cycle subfolder
(`2026-08-22T00-52-remediation/`, `2026-08-22T02-58-remediation/`, and
`2026-08-22T13-25-remediation/` respectively) — confirmed by direct `Read`, not by `Glob`, after an
initial `Glob`-based sweep incorrectly reported them absent (see the Pre-Flight Tree Verification
section). Nothing was discarded by the rebase. This plan uses a new timestamp regardless, per the
plan-path continuity contract.

---

## Pre-Flight Tree Verification (corrected after the orchestrator's follow-up; supersedes the version
first shipped in this file)

The first version of this section reported, based on repeated `Glob` searches returning zero
matches, that no subfolder reorganization existed and that cycles 1 through 3's artifacts were
absent from the tree. The orchestrator's follow-up measured the same tree with `find` and flagged
both conclusions as false. Direct `Read` calls against the exact paths the orchestrator named
confirm the orchestrator's measurement in every particular; `Glob`, not the tree, was the source of
the error, and the corrected facts below replace the earlier ones rather than supplementing them.

1. **The subfolder reorganization exists.** Eight per-cycle subfolders sit at the top of the
   feature folder: `2026-08-22T00-52-audit/`, `2026-08-22T00-52-remediation/`,
   `2026-08-22T02-58-audit/`, `2026-08-22T02-58-remediation/`, `2026-08-22T04-46-audit/`,
   `2026-08-22T13-25-remediation/`, `2026-08-22T17-20-audit/`, and `2026-08-22T17-20-remediation/`.
   Confirmed by direct `Read` of a file inside each of the six populated ones.
2. **Cycles 1 through 3's plans and audit trios are present, not lost.**
   `2026-08-22T00-52-remediation/remediation-plan.2026-08-22T01-10.md`,
   `2026-08-22T02-58-remediation/remediation-plan.2026-08-22T03-15.md`, and
   `2026-08-22T13-25-remediation/remediation-plan.2026-08-22T13-25.md` all read successfully, with
   content matching each cycle's own title line. The `2026-08-22T00-52-audit/`,
   `2026-08-22T02-58-audit/`, and `2026-08-22T04-46-audit/` folders each contain that cycle's
   `code-review`, confirmed by direct read of one file per folder. Nothing was discarded by the
   rebase; the prior statement that these files were "absent from the entire repository" was
   incorrect and is withdrawn.
3. **The duplicate `remediation-inputs.2026-08-22T17-20.md` is real.** It exists at both the
   feature-folder root and inside `2026-08-22T17-20-remediation/`, confirmed by direct read of both
   paths; the orchestrator additionally reports both hash to the same SHA-256, so the two copies
   are byte-identical today. See the re-reached disposition below — this is not moot.
4. **`2026-08-22T17-20-audit/` exists and is empty.** A direct `Read` of
   `2026-08-22T17-20-audit/code-review.2026-08-22T17-20.md` returns a file-not-found error, while
   the same file at the feature-folder root reads successfully. The folder was created — matching
   the per-cycle convention the three earlier `-audit/` folders establish — but the cycle-4 audit
   trio was never moved or copied into it. `remediation-inputs.2026-08-22T17-20.md`'s citation of
   `.../2026-08-22T17-20-audit/policy-audit.2026-08-22T17-20.md` (and its `code-review` and
   `feature-audit` siblings) is therefore a real dangling pointer to an empty folder, not a
   reference to a folder that does not exist. See the re-reached disposition below.
5. **`spec.md`, `issue.md`, and both `.claude/rules/parallel-orchestration.md` copies were swept for
   a citation of any subfolder or of the literal strings `remediation-plan.` or
   `remediation-inputs.`.** Zero matches in all three files. This part of the original sweep is
   unaffected by the `Glob` failure, because it was performed by reading each of the three files at
   its known, fixed path rather than by globbing for it. None of the three documents this plan is
   authorized to edit cites a prior audit or plan artifact by path, in a subfolder or otherwise.

### Re-reached disposition: the duplicate `remediation-inputs.2026-08-22T17-20.md`

**Not moot.** Recommendation: **the `2026-08-22T17-20-remediation/` copy is canonical going
forward; the feature-folder-root copy is the residual to retire.** Reasoning: every populated
`-remediation/` subfolder in this tree (`2026-08-22T00-52-remediation/`,
`2026-08-22T02-58-remediation/`, `2026-08-22T13-25-remediation/`) holds that cycle's own
remediation-plan record, and `2026-08-22T17-20-remediation/` already holds this cycle's
remediation-inputs alongside them — it is the one populated `-remediation/` folder whose plan has
not yet been written, and this document is that plan. Placing cycle 4's inputs-and-plan pair
together in `2026-08-22T17-20-remediation/` completes the same one-folder-per-cycle shape the other
three already have. The root copy predates that convention and is left over from before the
reorganization.

The orchestrator's own point sharpens why this matters going forward rather than today: two
byte-identical copies at one timestamp are unambiguous by content, but "highest timestamp within
the feature folder" is a selection rule over a **set of candidate locations**, and this tree now has
at least two (root and a `-remediation/` subfolder) that can each carry a same-named,
same-timestamped file. A future cycle in which the two copies are edited independently and diverge
would make "highest timestamp" pick between two different, equally-timestamped answers by
directory-scan order rather than by content — silently. Recommendation: retire the root copy in a
follow-up (not by this plan; deleting an artifact is an implementation action, and this duplicate is
not one of R1 through R6), and treat `<feature>/<timestamp>-remediation/` as the canonical location
for a remediation-inputs artifact from this point forward.

This plan itself is **not** relocated into `2026-08-22T17-20-remediation/` to match: the delegating
instruction for this cycle named the flat root path
`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/remediation-plan.2026-08-22T18-05.md`
explicitly, and neither that instruction nor the orchestrator's follow-up rescinded it. Moving this
file was not asked for, and "do not silently move files" was stated for the audit-folder question
in terms general enough to apply here too. The recommendation above is therefore a recommendation
for a **future** cycle's artifact placement, not an action this plan takes on its own plan file.

### Re-reached disposition: the empty `2026-08-22T17-20-audit/` folder

**Not spurious — the trio belongs in it, matching every other cycle.** The three earlier `-audit/`
folders are each populated with that cycle's own `code-review`, `policy-audit`, and `feature-audit`;
`2026-08-22T17-20-audit/` is the one `-audit/` folder that was created but left empty, which is more
consistent with an interrupted or partial migration step than with a deliberate decision to stop
using per-cycle audit folders (nothing in this tree suggests the convention was abandoned as of the
`2026-08-22T17-20` cycle — the matching `-remediation/` folder for the same timestamp was populated
normally). Recommendation: move `code-review.2026-08-22T17-20.md`, `policy-audit.2026-08-22T17-20.md`,
and `feature-audit.2026-08-22T17-20.md` from the feature-folder root into
`2026-08-22T17-20-audit/`, which also resolves `remediation-inputs.2026-08-22T17-20.md`'s dangling
citation without editing that citation at all. This plan does not perform that move: it is a
`feature-review`-artifact placement question, the three files belong to a prior workflow step, and
"do not silently move files" applies here as directly as it does to the duplicate-copy question
above. The recommendation is offered for the orchestrator or a follow-up step to act on.

---

## Scope Statement (using the source document's own R1–R6 numbering)

- **R1 (Major).** Close, not merely narrow, the CR-3 residual: a key added to a class constant and
  to both committed copies, with no consuming assertion, currently passes silently in Python and has
  no PowerShell binding at all. Assert *consumption*, not membership, in both languages.
- **R2 (Major, the trigger).** `spec.md` AC11 is checked and its text is false for the file it
  names, because the cycle-3 Pester split moved the Class 1 case out of
  `BlastRadius.TruthTable.Tests.ps1` into `BlastRadius.KeyPartition.Tests.ps1`. Correct the text to
  attribute each mirror to the file that actually carries it; do not simply re-check the box.
- **R3, source document's numbering (Major).** Retire the four stale pointers the cycle-3 split
  left in both `.claude/rules/parallel-orchestration.md` copies.
- **R4 (Minor).** Correct the KeyPartition file's header, which claims all four moved cases are
  verbatim when one was renamed and rewritten.
- **R5, source document's numbering (Minor).** Give `BlastRadius.KeyPartition.Tests.ps1` its own
  `Describe` name so a failure path identifies the file.
- **R6 (Minor).** Record, in the Python non-vacuity floor's docstring, that most of its sixteen
  tested cells are pre-empted upstream by `require_string_list` and `load_module_globs` raising
  `TypeError` rather than reaching the floor's own assertion.

**Languages touched this cycle:** Python (`blast_radius_parity_test_support.py`,
`test_blast_radius_config_parity.py`) and PowerShell
(`BlastRadius.KeyPartition.Tests.ps1`). Markdown is touched (`spec.md`, both
`parallel-orchestration.md` copies).

**TypeScript is excluded this cycle, and here is why:** R1 is confined to the Python and PowerShell
test sources (the class-constant registries and their consuming assertions); it does not touch
`SOURCE_BLAST_RADIUS` or any file under `extensions/drm-copilot`. R2 through R6 touch only Markdown
and the two PowerShell Pester files. No TypeScript file is read, let alone written, by any task in
this plan, so no TypeScript regression is possible and no TypeScript baseline or final-QA rerun is
needed. (The reviewer's own R1 verification did additionally perturb `SOURCE_BLAST_RADIUS` to
confirm Jest stays green under the same residual; that is a property of TypeScript's own,
already-closed CR-4 fixture-fidelity gate, which has no class-partition concept and is not reopened
by this cycle.)

**Do Not Do (binding, from `remediation-inputs.2026-08-22T17-20.md`):**

- Do not touch any acceptance criterion other than AC11, and do not re-check AC11's box without the
  verification R2 requires.
- Do not touch `scripts/dev_tools/` or any production Python, TypeScript, or PowerShell file. This
  cycle is confined to test files, `.claude/rules/parallel-orchestration.md` (plus its byte-identical
  bundled mirror), and `spec.md`.
- Do not weaken, delete, or narrow any existing assertion. The three existing
  `assert "<key>" in CLASS_TWO_KEYS` / `CLASS_THREE_KEYS` membership lines stay; R1 in this plan is
  option A ("close it"), not option B ("withdraw it"), so nothing is removed.
- Do not amend `.claude/rules/` beyond the two pointer strings named in R3 (source numbering).
- Do not rename any existing evidence artifact.
- Do not use a multi-line `poetry run python -c "..."` for any perturbation; it is a silent no-op
  under `poetry run` and exits 0 without executing. Use a script file, and confirm the perturbation
  landed with `git diff --stat` before running the gate.
- Do not restore a perturbed file with `git checkout --` when that file carries legitimate
  uncommitted in-cycle work; a checkout would discard that work rather than the perturbation. Prove
  every restore with a `Get-FileHash` / `sha256sum` captured **before** the perturbation and
  re-compared **after** the restore, not an in-process diff.
- File `PRE-1` (a `test_fix_all_failure_paths.py` thread-ordering race, unrelated to this branch)
  separately; do not fold it into this cycle.

---

### Phase 0 — Policy Reads and Toolchain Baselines (Python, PowerShell)

- [x] [P0-T1] Read `CLAUDE.md` in full.
- [x] [P0-T2] Read `.claude/rules/general-code-change.md` in full.
- [x] [P0-T3] Read `.claude/rules/general-unit-test.md` in full.
- [x] [P0-T4] Read `.claude/rules/python.md` in full.
- [x] [P0-T5] Read `.claude/rules/python-suppressions.md` in full.
- [x] [P0-T6] Read `.claude/rules/powershell.md` in full.
- [x] [P0-T7] Read `.claude/rules/quality-tiers.md` in full.
- [x] [P0-T8] Read `.claude/rules/plan-acceptance-gates.md` in full.
- [x] [P0-T9] Read `.claude/rules/self-explanatory-code-commenting.md` in full.
- [x] [P0-T10] Read `.claude/rules/tonality.md` in full.
- [x] [P0-T11] Write the Phase 0 policy-read evidence artifact to
      `evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md` (UTC,
      `yyyy-MM-ddTHH-mm` form), recording `Timestamp:`, `Policy Order:`, and the ten files read in
      P0-T1 through P0-T10, in that order.
      Acceptance: the artifact file exists and lists all ten files in order.
- [x] [P0-T12] From the worktree root, run `poetry run black --check .` and record the artifact at
      `evidence/remediation-baseline/python-black.<timestamp>.md` with `Timestamp:`, `Command:`,
      `EXIT_CODE:`, `Output Summary:`.
      Acceptance: `EXIT_CODE: 0` is recorded.
- [x] [P0-T13] From the worktree root, run `poetry run ruff check .` and record the artifact at
      `evidence/remediation-baseline/python-ruff.<timestamp>.md` with the same four fields.
      Acceptance: `EXIT_CODE: 0` is recorded.
- [x] [P0-T14] From the worktree root, run `poetry run pyright` and record the artifact at
      `evidence/remediation-baseline/python-pyright.<timestamp>.md` with the same four fields,
      `Output Summary:` naming the error and warning counts.
      Acceptance: `EXIT_CODE: 0` and `0 errors, 0 warnings` are recorded.
- [x] [P0-T15] From the worktree root, run
      `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`
      and record the artifact at `evidence/remediation-baseline/python-pytest-coverage.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the pass/fail/skip
      counts, the statement percentage as `(Stmts - Miss) / Stmts` from the `TOTAL` row, and the
      branch percentage from `totals.percent_branches_covered` in `artifacts/python/coverage.json`.
      Acceptance: `EXIT_CODE: 0`; both coverage figures recorded, each >= the
      `.claude/rules/quality-tiers.md` thresholds (85% statements, 75% branches).
- [x] [P0-T16] Run `mcp__drm-copilot__run_poshqc_format` and record the artifact at
      `evidence/remediation-baseline/powershell-poshqc-format.<timestamp>.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`.
      Acceptance: `EXIT_CODE: 0` and zero files rewritten are recorded.
- [x] [P0-T17] Run `mcp__drm-copilot__run_poshqc_analyze` and record the artifact at
      `evidence/remediation-baseline/powershell-poshqc-analyze.<timestamp>.md` with the same four
      fields.
      Acceptance: `EXIT_CODE: 0` and zero findings are recorded.
- [x] [P0-T18] Run `mcp__drm-copilot__run_poshqc_test` and record the artifact at
      `evidence/remediation-baseline/powershell-poshqc-test.<timestamp>.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the pass/fail/skip counts and the line
      coverage percentage from the JaCoCo root `LINE` counter as `covered / (covered + missed)`.
      Acceptance: `EXIT_CODE: 0` and a recorded line coverage >= 85%.
- [x] [P0-T19] Write a scope note at `evidence/remediation-baseline/typescript-out-of-scope.<timestamp>.md`
      stating that no TypeScript file is touched by R1 through R6 this cycle (R1 is confined to the
      Python and PowerShell test sources; R2 through R6 touch only Markdown and the two Pester
      files), so no TypeScript baseline is captured and none is required in Final QA.
      Acceptance: the artifact file exists and names the reason above.
- [x] [P0-T20] Confirm file sizes before any edit: from the worktree root, run
      `wc -l tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/dev_tools/blast_radius_parity_test_support.py tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
      and record the artifact at `evidence/remediation-baseline/edit-target-line-counts.<timestamp>.md`.
      Acceptance: the artifact records four counts, each less than 500 (measured at plan-authoring
      time: approximately 470, 190, 217, 325 — the executor's own measurement is authoritative).

---

### Phase 1 — R1: Close the CR-3 residual by asserting consumption, not membership (Major)

- [x] [P1-T1] In `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, replace the
      standalone `CLASS_TWO_KEYS = ("shared_surfaces", "shared_surface_globs")` and
      `CLASS_THREE_KEYS = ("modules",)` declarations with two registries mapping each key name to
      the name of the test function that is supposed to consume it:
      `CLASS_TWO_KEY_ASSERTIONS = {"shared_surfaces": "test_class_two_bundled_shared_surfaces_are_the_portable_set", "shared_surface_globs": "test_class_two_bundled_shared_surface_globs_are_empty"}`
      and
      `CLASS_THREE_KEY_ASSERTIONS = {"modules": "test_class_three_bundled_modules_are_payload_modules_only"}`,
      then derive `CLASS_TWO_KEYS = tuple(CLASS_TWO_KEY_ASSERTIONS)` and
      `CLASS_THREE_KEYS = tuple(CLASS_THREE_KEY_ASSERTIONS)` so every existing consumer of
      `CLASS_TWO_KEYS` / `CLASS_THREE_KEYS` (the three membership asserts and
      `DECLARED_TOP_LEVEL_KEYS`) is unaffected. Add a module-level helper
      `unconsumed_class_keys(registry, namespace)` that, for each `(key, assertion_name)` pair,
      resolves `assertion_name` in `namespace` and reports the pair as unresolved if the name is not
      callable there or if `key` does not appear in `inspect.getsource(callable)` — so a registry
      entry whose named assertion does not exist, or whose named assertion exists but never
      references the key, is reported.
      Acceptance: from the worktree root,
      `git grep -c -F "CLASS_TWO_KEY_ASSERTIONS = {" -- tests/scripts/dev_tools/blast_radius_parity_test_support.py`
      reports `1` after the edit (measured before the edit: `0`, this literal is absent from the
      file today).
- [x] [P1-T2] In `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, import
      `CLASS_TWO_KEY_ASSERTIONS`, `CLASS_THREE_KEY_ASSERTIONS`, and `unconsumed_class_keys` from the
      support module, and add a new test function
      `test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion` that calls
      `unconsumed_class_keys` against both registries with `globals()` as the namespace and asserts
      the combined result is empty, naming any unresolved `key -> assertion_name` pair on failure.
      This is the assertion that closes the addition direction: the existing three membership lines
      (`assert "shared_surfaces" in CLASS_TWO_KEYS` and its two siblings) are left exactly as they
      are, per the Do-Not-Do constraint against narrowing an existing assertion.
      Acceptance:
      `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion`
      exits `0` with `1 passed`, run from the worktree root.
- [x] [P1-T3] Confirm file sizes: from the worktree root, run
      `wc -l tests/scripts/dev_tools/blast_radius_parity_test_support.py tests/scripts/dev_tools/test_blast_radius_config_parity.py`.
      Acceptance: both reported counts are less than 500.
- [x] [P1-T4] In `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`, in the
      file-level `BeforeAll`, replace the `$script:ClassTwoKeys` and `$script:ClassThreeKeys` literal
      arrays with two registries mapping each key name to the sibling file that actually indexes it
      via the PowerShell indexer syntax (both Class 2 keys and the Class 3 key are read by
      `$script:CommittedConfig['<key>']` / `$script:BundledConfig['<key>']` inside
      `BlastRadius.TruthTable.Tests.ps1`, not in this file):
      `$script:ClassTwoKeyConsumerFile = @{ 'shared_surfaces' = 'BlastRadius.TruthTable.Tests.ps1'; 'shared_surface_globs' = 'BlastRadius.TruthTable.Tests.ps1' }`
      and
      `$script:ClassThreeKeyConsumerFile = @{ 'modules' = 'BlastRadius.TruthTable.Tests.ps1' }`,
      then derive `$script:ClassTwoKeys = @($script:ClassTwoKeyConsumerFile.Keys)` and
      `$script:ClassThreeKeys = @($script:ClassThreeKeyConsumerFile.Keys)` so the existing
      exhaustiveness case, which builds `$declaredTopLevelKey` from
      `$script:ClassOneKeys + $script:ClassTwoKeys + $script:ClassThreeKeys`, is unaffected.
      Acceptance: from the worktree root,
      `git grep -c -F "ClassTwoKeyConsumerFile = @{" -- tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`
      reports `1` after the edit (measured before the edit: `0`).
- [x] [P1-T5] In the same file, add a new `It` case to the `Cross-copy key partition` `Context`,
      titled `requires every Class 2 and Class 3 key to be indexed by name in its registered
      consumer file`, that reads each distinct consumer file named in the two registries once (via
      `Get-Content -Raw`, resolved with `Join-Path $PSScriptRoot <file>`), and for every
      `(key, fileName)` pair in either registry asserts the file's raw text contains the literal
      substring `['<key>']`; it accumulates every unresolved pair into a list and asserts the list
      `Should -BeNullOrEmpty`.
      Acceptance: a targeted `Invoke-Pester` run against
      `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` reports the new
      `It` block passing with 0 failed, run from the worktree root.
- [x] [P1-T6] Confirm file size: from the worktree root, run
      `(Get-Content tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1).Count`.
      Acceptance: the reported count is less than 500.
- [x] [P1-T7] Capture pre-perturbation hashes of the two files just edited, per the Do-Not-Do
      restore-mechanism requirement: from the worktree root, run
      `Get-FileHash tests/scripts/dev_tools/blast_radius_parity_test_support.py, tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`
      (or the `sha256sum` equivalent) and record both SHA-256 values in an evidence artifact at
      `evidence/other/r1-pre-perturbation-hashes.<timestamp>.md`. These are the hashes of the
      **fixed** state (after P1-T1 through P1-T6, before any perturbation), so the later restore is
      checked against this recorded fix, not against `git checkout --`, which would discard it.
      Acceptance: the artifact records two distinct SHA-256 values, one per file.
- [x] [P1-T8] [expect-fail] Demonstrate the repair with the reviewer's own residual, adapted to the
      registry shape this task introduces (a bare string append to a tuple is no longer meaningful;
      the equivalent perturbation is a registry entry with no real consuming assertion). Using a
      script **file** (not a multi-line `poetry run python -c`, per the Do-Not-Do constraint),
      perform all of the following, then confirm with `git diff --stat` that all four files changed
      before running any gate:
      1. Add `"invented_key": []` to `config/blast-radius.json`.
      2. Add `"invented_key": []` to `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`.
      3. Add `"invented_key": "test_class_two_bundled_shared_surfaces_are_the_portable_set"` to
         `CLASS_TWO_KEY_ASSERTIONS` in `blast_radius_parity_test_support.py` — reusing an existing,
         unrelated test's name, which is the more adversarial shape of "no real consuming assertion"
         and is exactly what `unconsumed_class_keys`'s source-text check exists to catch.
      4. Add `'invented_key' = 'BlastRadius.TruthTable.Tests.ps1'` to
         `$script:ClassTwoKeyConsumerFile` in `BlastRadius.KeyPartition.Tests.ps1`.
      Then run, from the worktree root,
      `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion`
      and a name-filtered Pester run:
      ```powershell
      $pesterConfig = New-PesterConfiguration
      $pesterConfig.Run.Path = 'tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1'
      $pesterConfig.Run.PassThru = $true
      $pesterConfig.Filter.FullName = '*requires every Class 2 and Class 3 key to be indexed by name in its registered consumer file*'
      $result = Invoke-Pester -Configuration $pesterConfig
      ```
      Record the fail-before evidence artifact at
      `evidence/regression-testing/python-class-consumption-fail-before.<timestamp>.md` and
      `evidence/regression-testing/powershell-class-consumption-fail-before.<timestamp>.md`, each
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary:` quoting
      the failure message and the `git diff --stat` output confirming all four files changed.
      Acceptance: the Python node ID exits `1` with `1 failed`, naming
      `invented_key -> test_class_two_bundled_shared_surfaces_are_the_portable_set`; the filtered
      Pester run reports `Passed=0 Failed=1`, naming
      `invented_key -> BlastRadius.TruthTable.Tests.ps1`. Neither the exhaustiveness case nor any of
      the three pre-existing membership asserts fires, because `invented_key` is present in both
      copies and is present in the derived `CLASS_TWO_KEYS`/`DECLARED_TOP_LEVEL_KEYS` — the failure
      is isolated to the new consumption check, which is the property under demonstration. This is
      the state the pre-fix registry passed on silently in all three languages (recorded in
      `evidence/regression-testing/reviewer-perturbation-battery.2026-08-22T17-20.md` Group D2), and
      it is not the current, unperturbed state.
- [x] [P1-T9] Restore without `git checkout --` on the two files carrying in-cycle work: for
      `config/blast-radius.json` and its bundled copy (which carry no other in-cycle edit), run
      `git checkout --` on both from the worktree root — safe here, since nothing else in this cycle
      touches either JSON file. For `blast_radius_parity_test_support.py` and
      `BlastRadius.KeyPartition.Tests.ps1`, manually remove only the `invented_key` line added in
      P1-T8 from each (leaving every other cycle-4 edit intact), then re-run
      `Get-FileHash`/`sha256sum` on both and compare the result against the pre-perturbation hashes
      recorded in P1-T7. Record the pass-after evidence artifact at
      `evidence/qa-gates/r1-post-restore-hash-verification.<timestamp>.md` with the before and after
      hash pairs. Then rerun the Python node ID and the identical filtered Pester configuration from
      P1-T8.
      Acceptance: both restored files' SHA-256 hashes exactly match the P1-T7 pre-perturbation
      values; `git status --short` produces no output for `config/blast-radius.json` and its bundled
      copy; the Python node ID exits `0` with `1 passed`; the filtered Pester rerun reports
      `Passed=1 Failed=0`.

---

### Phase 2 — R2 & R3 (source numbering): Correct AC11 and the four stale rule-file pointers (Major)

- [x] [P2-T1] Re-run the reference sweep to confirm it is unchanged at execution time. **Scope of
      this sweep, stated explicitly so it cannot be misread as repo-wide: `spec.md` and the two
      `parallel-orchestration.md` copies only** — the three documents this plan is authorized to
      edit. The literal `BlastRadius.KeyPartition.Tests.ps1` is known to appear in ten other
      documents across the feature folder (test-file comments and prior audit artifacts that
      already describe the cycle-3 split); this sweep does not touch, and makes no claim about,
      those ten. From the worktree root, run
      `grep -rn "BlastRadius.TruthTable.Tests.ps1" .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`,
      `grep -n "BlastRadius.TruthTable.Tests.ps1" docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`,
      and confirm no occurrence of the literal `BlastRadius.KeyPartition.Tests.ps1` exists yet in
      any of these three files specifically.
      Acceptance: the rule-file grep reports exactly `4` matches (2 per copy, at the paragraph
      recording the directional invariant and the paragraph recording the exhaustiveness gate); the
      `spec.md` grep reports exactly `4` matches, at: the `## Root Cause Analysis` narrative citing
      the file's pre-cycle-3 comment location (no fix — historical, predates and is unrelated to the
      split), the `## Implementation strategy` narrative "mirror the gate" (no fix — pre-PD-1
      planning intent, not a live verification claim), AC11 (fix required — R2), and AC12 (no fix —
      the comment AC12 describes still lives in `BlastRadius.TruthTable.Tests.ps1` after the split,
      confirmed by reading the file). If any of these four counts differs, halt and re-disposition
      every reference before proceeding.
- [x] [P2-T2] In `spec.md`, `## Acceptance Criteria`, uncheck AC11's box, changing `- [x]` to
      `- [ ]` on the line beginning `` `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` mirrors the Class 1 ``.
      The text is left unchanged in this task; only the checkbox marker changes, because the
      criterion is currently checked while its text is false for the file it names, and it must not
      be re-checked before the correction in P2-T3 is verified.
      Acceptance: from the worktree root,
      `git grep -c -P "^- \[ \] \`tests/scripts/claude-lib/blast-radius/BlastRadius\.TruthTable\.Tests\.ps1\` mirrors the Class 1" -- docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
      reports `1` after the edit (measured before the edit: `0`, since AC11's line currently begins
      `- [x] ` rather than `- [ ] `).
- [x] [P2-T3] In the same file, rewrite AC11's text so it attributes each mirror to the file that
      actually carries it: `` `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` mirrors the Class 1 equality; ``
      on one line, followed by
      `` `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` mirrors the Class 3
      subset, the five-name umbrella denylist applied to both copies, and the
      separator-free-wildcard-free assertion; and both files stay under the 500-line limit. ``,
      keeping "BlastRadius.KeyPartition.Tests.ps1` mirrors the Class 1 equality;" contiguous on a
      single line so a line-oriented search matches it. Verified by
      `mcp__drm-copilot__run_poshqc_test` (unchanged from the prior text).
      Acceptance, both run from the worktree root against
      `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`: (a)
      `git grep -c -F "BlastRadius.TruthTable.Tests.ps1\` mirrors the Class 1" -- docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
      reports `0` after the edit (measured before the edit: `1`); (b)
      `git grep -c -F "BlastRadius.KeyPartition.Tests.ps1\` mirrors the Class 1 equality" -- docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
      reports at least `1` after the edit (measured before the edit: `0`, this literal is absent
      from `spec.md` today).
- [x] [P2-T4] In `.claude/rules/parallel-orchestration.md`, replace both occurrences of
      `` `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, closes that gap ``
      (the directional-invariant paragraph and the exhaustiveness-gate paragraph) with
      `` `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`, closes that gap ``,
      changing only the filename in each.
      Acceptance: from the worktree root,
      `git grep -c -F "BlastRadius.KeyPartition.Tests.ps1\`, closes that gap" -- .claude/rules/parallel-orchestration.md`
      reports `2` after the edit (measured before the edit: `0`); and
      `git grep -c -F "BlastRadius.TruthTable.Tests.ps1\`, closes that gap" -- .claude/rules/parallel-orchestration.md`
      reports `0` after the edit (measured before the edit: `2`).
- [x] [P2-T5] Mirror the P2-T4 amendment byte-identically into
      `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`,
      in the same commit.
      Acceptance: from the worktree root,
      `diff .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
      produces no output and exits 0.
- [x] [P2-T6] Confirm the mirrored-resource contract is unaffected: from the worktree root, run
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
      Acceptance: `EXIT_CODE: 0`.

*(AC11's checkbox is re-checked in Phase 5, Final QA, after P2-T3's corrected file attributions are
independently reverified against both Pester files' actual `It` inventories.)*

---

### Phase 3 — R4 & R5 (source numbering): Correct the KeyPartition header and give it its own `Describe` name (Minor)

- [x] [P3-T1] In `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`, in the
      `.DESCRIPTION` block (lines 5-14), replace "carries the 'Cross-copy key partition' Context
      verbatim" with a statement that three cases moved unchanged and the fourth — originally
      `requires the shared-surface lists compared by the directional invariant to be non-empty` —
      was renamed to `requires a populated shared-surface list and module map in both copies` and
      rewritten as the cycle-3 CR-1/CR-2 repair.
      Acceptance: from the worktree root,
      `git grep -c -F "verbatim" -- tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`
      reports `0` after the edit (measured before the edit: `1`, at the current header sentence).
- [x] [P3-T2] In the same file, rename its `Describe 'Committed blast-radius truth table shape'` to
      `Describe 'Committed blast-radius truth table cross-copy key partition'`, leaving
      `BlastRadius.TruthTable.Tests.ps1`'s `Describe` name unchanged.
      Acceptance: from the worktree root,
      `grep -n "^Describe " tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`
      reports two lines whose quoted `Describe` strings differ (measured before the edit: the two
      strings are identical, both `Committed blast-radius truth table shape`).
- [x] [P3-T3] Confirm the directory run is unaffected in count: from the worktree root, run
      `mcp__drm-copilot__run_poshqc_test`.
      Acceptance: `EXIT_CODE: 0`; the `tests/scripts/claude-lib/blast-radius` directory total is
      the pre-cycle-4 value (383, per `evidence/regression-testing/reviewer-perturbation-battery.2026-08-22T17-20.md`,
      Group D) plus the one case added in Phase 1 (P1-T5), for a total of 384, with 0 failed.

---

### Phase 4 — R6 (source numbering): Document the Python floor's actual mechanism (Minor)

- [x] [P4-T1] In `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, extend
      `test_the_gate_compares_non_empty_collections`'s docstring to state that an absent, null, or
      renamed `shared_surfaces` in the self-hosted copy, and an absent, null, or renamed `modules` in
      either copy, are caught upstream — most as a module-level collection error — by
      `require_string_list` and `load_module_globs` raising `TypeError`, both imported from
      `tests/scripts/dev_tools/test_blast_radius_config.py`, and that only the remaining states
      reach this assertion directly. No code changes; docstring only.
      Acceptance: from the worktree root,
      `git grep -c -F "require_string_list" -- tests/scripts/dev_tools/test_blast_radius_config_parity.py`
      reports at least `1` after the edit (measured before the edit: `0`, this literal is absent
      from the file today, since the function is currently imported only inside
      `blast_radius_parity_test_support.py` and `test_blast_radius_config.py`, not named in this
      file's own docstrings).
- [x] [P4-T2] Confirm file size: from the worktree root, run
      `wc -l tests/scripts/dev_tools/test_blast_radius_config_parity.py`.
      Acceptance: the reported count is less than 500.

---

### Phase 5 — Final QA Loop (Python, PowerShell) and Acceptance-Criteria Reconciliation

- [x] [P5-T1] From the worktree root, run `poetry run black --check .`.
      Acceptance: `EXIT_CODE: 0`.
- [x] [P5-T2] From the worktree root, run `poetry run ruff check .`.
      Acceptance: `EXIT_CODE: 0`, zero new `noqa` present.
- [x] [P5-T3] From the worktree root, run `poetry run pyright`.
      Acceptance: `EXIT_CODE: 0`, `0 errors, 0 warnings`.
- [x] [P5-T4] From the worktree root, run
      `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`
      and record the final-QC artifact at
      `evidence/qa-gates/final-python-pytest-coverage.<timestamp>.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the pass/fail/skip counts, the
      statement percentage from the `TOTAL` row, and the branch percentage from
      `totals.percent_branches_covered` in `artifacts/python/coverage.json`.
      Acceptance: `EXIT_CODE: 0`, with both coverage figures at or above the P0-T15 baseline figures
      (no regression).
- [x] [P5-T5] Re-verify the parity module's collected count: from the worktree root, run
      `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py`.
      Acceptance: `EXIT_CODE: 0` and `17 passed` (the 16 present at the start of this cycle plus the
      one consumption test added in Phase 1).
- [x] [P5-T6] Run `mcp__drm-copilot__run_poshqc_format`.
      Acceptance: `EXIT_CODE: 0`, zero files rewritten (a clean tree after the run).
- [x] [P5-T7] Run `mcp__drm-copilot__run_poshqc_analyze`.
      Acceptance: `EXIT_CODE: 0`, zero findings.
- [x] [P5-T8] Run `mcp__drm-copilot__run_poshqc_test` and record the final-QC artifact at
      `evidence/qa-gates/final-powershell-poshqc-test.<timestamp>.md` with the same four required
      fields, `Output Summary:` naming the pass/fail/skip counts and the line coverage percentage
      from the JaCoCo root `LINE` counter.
      Acceptance: `EXIT_CODE: 0` and the recorded line coverage at or above the P0-T18 baseline
      figure (no regression).
- [x] [P5-T9] Write the coverage delta-verification artifact at
      `evidence/qa-gates/coverage-delta-verification.<timestamp>.md` reporting, for Python and
      PowerShell: baseline coverage (Phase 0), post-change coverage (P5-T4 / P5-T8), and
      new/changed-code coverage. No production file is touched by R1 through R6, so the
      new/changed-code coverage figure for both languages is 100% of changed production lines, of
      which there are zero.
      Acceptance: the artifact records both baseline and post-change figures for both languages with
      a delta of 0.00 or better on every figure.
- [x] [P5-T10] Confirm no coverage `exclude`/`omit` entry was added: from the worktree root, run
      `git diff "$(git merge-base main HEAD)"...HEAD -- pyproject.toml`, resolving the merge-base
      dynamically rather than citing a fixed commit.
      Acceptance: the diff produces no output.
- [x] [P5-T11] Confirm the file-size ceiling holds for every file touched this cycle: from the
      worktree root, run
      `wc -l tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/dev_tools/blast_radius_parity_test_support.py tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`.
      Acceptance: all three reported counts are less than 500.
- [ ] [P5-T12] Confirm no production file, and no file outside the declared scope, was touched: from
      the worktree root, run
      `git diff "$(git merge-base main HEAD)"...HEAD --stat -- scripts/dev_tools/ extensions/drm-copilot/src/ tests/scripts/dev_tools/test_blast_radius_config.py`,
      resolving the merge-base dynamically.
      Acceptance: the command produces no output (no changed lines under `scripts/dev_tools/` or
      `extensions/drm-copilot/src/`, and no change to the untouched
      `test_blast_radius_config.py`).
- [x] [P5-T13] Re-verify AC11's two named cases each resolve in the file the corrected text now
      attributes them to: from the worktree root, run
      `grep -nE "^\s*It " tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`
      and confirm `declares equal values for the runtime-describing keys in both copies` appears in
      that list, and run
      `grep -nE "^\s*It " tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` and
      confirm `declares only payload modules in the bundled copy`,
      `declares no removed umbrella module in either committed copy`, and
      `gives every separator-free bundled shared surface no wildcard` all appear in that list.
      Acceptance: all four named cases are present in their respectively attributed file's `It`
      list.
- [x] [P5-T14] Re-check AC11's checkbox: in `spec.md`, `## Acceptance Criteria`, change AC11's
      checkbox from `- [ ]` (set in P2-T2) to `- [x]` (text unchanged from P2-T3). This task depends
      on P5-T13 passing.
      Acceptance: from the worktree root,
      `git grep -c -P "^- \[x\] \`tests/scripts/claude-lib/blast-radius/BlastRadius\.KeyPartition\.Tests\.ps1\` mirrors the Class 1 equality;" -- docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
      reports `1` after the edit (measured before this task: `0`, since AC11's line reads `- [ ] `
      after P2-T2 and P2-T3).
- [x] [P5-T15] Confirm the acceptance-criteria count and full-checked state are unchanged at 17:
      from the worktree root, run
      `sed -n '/^## Acceptance Criteria$/,/^## Out of Scope$/p' docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md | grep -c -E "^- \[[ x]\]"`
      and
      `sed -n '/^## Acceptance Criteria$/,/^## Out of Scope$/p' docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md | grep -c -E "^- \[x\]"`.
      Acceptance: both commands report `17`, meaning the total count is unchanged and every
      criterion is checked.
- [x] [P5-T16] Write the final single-pass confirmation artifact at
      `evidence/qa-gates/remediation-toolchain-single-pass.<timestamp>.md` recording that P5-T1
      through P5-T8 executed in one uninterrupted sequence with no restart and no file rewritten by
      any stage.
      Acceptance: the artifact records all eight exit codes as 0 with no intervening restart.
- [x] [P5-T17] Write the updated AC status summary at
      `evidence/issue-updates/ac-status-summary.<timestamp>.md` stating 17 of 17 acceptance criteria
      checked, with a one-line note that AC11 was unchecked by this cycle's P2-T2, corrected by
      P2-T3, and re-checked by P5-T14 after P5-T13's file-attribution reverification.
      Acceptance: the artifact states `17 of 17 checked`.

---

## Exit Condition for Cycle 4 (final)

This cycle exits when a reaudit confirms all of the following:

1. A key added to a class-key registry and to both committed copies, with no assertion that
   genuinely references it, fails in both Python and PowerShell — demonstrated by perturbation,
   restored with an externally-captured hash rather than `git checkout --` on any file carrying
   in-cycle work, and reproven green (R1).
2. `spec.md` AC11 names both Pester files and attributes each mirror to the file that actually
   carries it, both files are confirmed under 500 lines, and the checkbox is `[x]` only after that
   attribution was independently reverified (R2).
3. Zero references to `BlastRadius.TruthTable.Tests.ps1` remain in either
   `parallel-orchestration.md` copy where the case now lives in `BlastRadius.KeyPartition.Tests.ps1`,
   both copies stay byte-identical, and the push-down resource-contract suite passes (R3, source
   numbering).
4. The KeyPartition file's header no longer claims a verbatim move, and its `Describe` name differs
   from `BlastRadius.TruthTable.Tests.ps1`'s (R4, R5, source numbering).
5. The Python floor's docstring names `require_string_list` and `load_module_globs` as the upstream
   functions that pre-empt most of its tested cells (R6).
6. All 17 acceptance criteria are checked; none other than AC11 was modified this cycle.
7. The full toolchain passes in a single pass for Python and PowerShell, and coverage is unchanged or
   improved in both.
8. `blocking_count == 0`.
