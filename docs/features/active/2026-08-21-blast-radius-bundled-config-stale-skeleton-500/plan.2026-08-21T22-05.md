# Atomic Plan — blast-radius bundled config stale skeleton (Issue #500)

- **Issue:** #500
- **Feature folder:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`
- **Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500` (base `main`, merge-base `fb30a9a5`)
- **Work mode:** `full-bug`
- **AC source (sole):** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
- **Plan timestamp:** 2026-08-21T22-05
- **Repository root (worktree):** `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16`

Authoritative inputs, read in this order: `spec.md`; the research artifact
`research/2026-08-21T17-16-blast-radius-bundled-config-drift-research.md`; the discharged
divergence walk `evidence/other/divergence-commit-walk.2026-08-21T21-47.md`;
`artifacts/orchestration/orchestrator-state.json` (`research_findings`, `design_decisions`).

`design_decisions[0]` (DD-1) is settled. This plan implements it and does not re-open it: the
bundled portable `shared_surfaces` set carries all six entries including `package-lock.json` and
`poetry.lock`, and the AC8 forbidden-substring list is narrowed in the same change set.

Executor Verification Obligation 1 from the research artifact (the `git log --follow` divergence
walk) is already discharged at `evidence/other/divergence-commit-walk.2026-08-21T21-47.md`. No task
below re-runs it; tasks cite it.

---

## Binding Constraints Recorded Before the Phases

### C1 — Evidence location invariant (non-overridable)

Every evidence artifact resolves to `<FEATURE>/evidence/<kind>/` per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, where `<FEATURE>` is
`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`. Baselines go under
`evidence/baseline/`, fail-before runs under `evidence/regression-testing/`, QC and pass-after runs
under `evidence/qa-gates/`, everything else under `evidence/other/`. No `artifacts/`-rooted evidence
path appears anywhere in this plan.

`EVIDENCE_LOCATION_OVERRIDE_REJECTED: none. No non-canonical evidence path was supplied.`

Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
Baseline and final-QC test artifacts additionally carry numeric coverage headline values in
`Output Summary:`. A fail-before artifact carries `ExpectedExitCode:` set to the non-zero exit the
failing run is expected to produce.

### C2 — The 500-line ceiling forces a split, and AC9/AC10 are satisfied by a sibling module

`.claude/rules/general-code-change.md` sets a hard 500-line ceiling that explicitly covers test
code. Measured line counts at plan time:

| File | Lines | Headroom |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_config.py` | 499 | 1 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | 478 | 22 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | 476 | 24 |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | 452 | 48 |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 432 | 68 |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | 401 | 99 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | 269 | 231 |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | 198 | 302 |

`tests/scripts/dev_tools/test_blast_radius_config.py` cannot receive the three-class key-partition
gate: one added line breaches the ceiling. The gate therefore lands in a new sibling module
`tests/scripts/dev_tools/test_blast_radius_config_parity.py`, which imports the shared helpers
(`load_config_file`, `load_module_globs`, `COMMITTED_CONFIGS`, `CONFIG_PATH`,
`BUNDLED_CONFIG_PATH`, `BUNDLED_CONFIG_LABEL`) from the existing module rather than duplicating
them. The name mirrors the established two-copy config-parity convention already used by
`test_orchestration_routing_config_parity.py`, `test_codex_topology_policy_config_parity.py`, and
`test_codex_model_policy_config_parity.py`. Cross-importing a sibling test module is an established
pattern in this directory (for example
`tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py` imports from
`test_parallel_kickoff_contract`).

No test is moved out of `tests/scripts/dev_tools/test_blast_radius_config.py` and that file is not
edited by this plan at all, so no relocation task is required. Spec AC9 and AC10 name that file;
they are satisfied by the sibling module for the reason above, and P8-T15 records the substitution
when checking those two boxes.

`extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` gains one assertion
block and loses five `claude-runtime` lines; P2-T8 verifies it stays at or under 500 lines.
`extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` only loses four lines.

### C3 — npm dependency state

The root `package.json` declares no npm workspaces, so each location installs independently. State
observed at plan revision time: `npm ci` has been run and exited 0 at the repository root and at
`extensions/drm-copilot`, so `node_modules` exists at both. `packages/mcp-server/node_modules` is
deliberately absent, and no task in this plan uses `packages/mcp-server` as its working directory,
so that absence is not a gap.

The Prettier, ESLint, `tsc`, and Jest scripts this plan invokes are declared in
`extensions/drm-copilot/package.json` (`format`, `lint`, `typecheck`, `test:unit`,
`test:coverage`), so every TypeScript task below sets its working directory to
`extensions/drm-copilot`. The coverage script at that location is `test:coverage`; **there is no
`test:unit:coverage` script anywhere in that manifest**. `spec.md` AC15 originally named
`npm run test:unit:coverage` and has been corrected to `npm run test:coverage`; this plan uses the
corrected form throughout.

P0-T3 is therefore a verify-or-install task, not an unconditional install: reinstalling a working
tree would wipe and rebuild it for no benefit.

### C4 — Falsifiable acceptance conditions

Per `.claude/rules/plan-acceptance-gates.md`: coverage targets are importable dotted names with the
`=` form (`--cov=scripts.dev_tools`); every acceptance condition that can be carried by a named test
is carried by a named test and its node ID rather than by a phrase search.

Literals this plan instructs the executor to create, quoted here verbatim in prose so an assertion
naming one is exonerated: `PORTABLE_SHARED_SURFACES`, `UMBRELLA_MODULE_NAMES`,
`PAYLOAD_MODULE_NAMES`, `BYTE_EQUAL_KEYS`,
`test_unrelated_claude_citations_do_not_contend_under_the_bundled_table`,
`test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table`.

### C5 — Single change set

The five coordinated changes must land together because the parity and drift gates cross-check
them. Phases 2 through 6 are ordered so each is independently verifiable, but no phase commits
separately; committing, rebasing, pushing, and pull-request authoring are the orchestrator's and
`pr-author`'s steps and appear nowhere in this plan.

### C6 — Out of scope

The five items in the spec's `## Out of Scope` section are binding and no task below addresses any
of them: the `Get-PlanPaths` placeholder-extraction defect; the Python/TypeScript push-down
`ROOT_FOLDERS` divergence; the absence of `quality-tiers.yml` and `docs/ci.research.md`; the absent
merge decorator for `config/blast-radius.json`; parity coverage for the `.github/**` and `.mcp.json`
pairs. The rejected alternatives (extending `SCOPED_ROOTS`, an expected-delta manifest, a generator
script, a blanket skills mandate-read entry, a downstream destination fix) are not reintroduced.

---

## Acceptance-Criteria Traceability

`spec.md` carries 17 acceptance criteria, numbered here in document order.

| AC | Subject | Tasks |
| --- | --- | --- |
| AC1 | `PAYLOAD_MODULES` is `{ config: ["config/**"] }`; doc comment rewritten | P2-T1, P2-T2 |
| AC2 | `blast-radius-derive-core.test.ts` no longer pins `claude-runtime`; adds the negative assertion | P2-T3, P2-T4, P2-T5, P2-T6, P2-T8 |
| AC3 | `blast-radius-derive.test.ts` seeded expectations; `SOURCE_BLAST_RADIUS` and its comment | P2-T7, P4-T3, P4-T4 |
| AC4 | Bundled `blast-radius.json` corrected in all four keys | P3-T1, P3-T2, P3-T3, P3-T4, P6-T3, P6-T4 |
| AC5 | AC8 forbidden-substring list narrowed and its rationale rewritten (DD-1) | P4-T1, P4-T2, P4-T5 |
| AC6 | Self-hosted `mandate_reads` gains the four entries; other keys unchanged | P3-T5, P3-T6, P6-T2 |
| AC7 | `.claude/rules/parallel-orchestration.md` records (a), (b), (c) | P5-T1 |
| AC8 | Bundled rule mirror byte-identical in the same change set | P5-T2, P5-T3 |
| AC9 | Three-class key-partition gate (sibling module per C2) | P6-T1, P6-T2, P6-T3, P6-T4, P6-T8 |
| AC10 | Five-name umbrella denylist, separator-free wildcard-free, non-vacuity floor | P6-T5, P6-T6, P6-T7 |
| AC11 | PowerShell mirror of the gate, under 500 lines | P6-T9, P6-T10, P6-T11, P6-T13 |
| AC12 | `BlastRadius.TruthTable.Tests.ps1` comment corrected | P6-T12 |
| AC13 | Fail-closed regression, fail-before and pass-after | P1-T1, P1-T3, P1-T4, P1-T5, P1-T6, P7-T1, P7-T3, P7-T4 |
| AC14 | Fail-open regression, fail-before and pass-after | P1-T2, P1-T3, P1-T7, P7-T2, P7-T3 |
| AC15 | Coverage obligations met and recorded | P0-T8, P0-T11, P0-T14, P8-T4, P8-T8, P8-T11, P8-T12 |
| AC16 | Full toolchain pass in a single run for all three languages | P8-T1 through P8-T11, P8-T14 |
| AC17 | Divergence-walk evidence plus the routing byte compare | P0-T16, P7-T5 |

---

### Phase 0 — Policy reads, environment preparation, and baseline capture

- [ ] [P0-T1] Read the policy files in the order `CLAUDE.md` and `.claude/skills/policy-compliance-order/SKILL.md` mandate, and write the read record to `<FEATURE>/evidence/baseline/phase0-instructions-read.<ISO8601>.md` with fields `Timestamp:`, `Policy Order:`, and an explicit list of the files read. The list must contain, in order: `.github/copilot-instructions.md`; `.github/instructions/general-code-change.instructions.md`; `.github/instructions/general-unit-test.instructions.md`; `.github/instructions/python-code-change.instructions.md`; `.github/instructions/python-unit-test.instructions.md`; `.github/instructions/typescript-code-change.instructions.md`; `.github/instructions/typescript-unit-test.instructions.md`; `.github/instructions/powershell-code-change.instructions.md`; `.github/instructions/powershell-unit-test.instructions.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/quality-tiers.md`; `.claude/rules/parallel-orchestration.md`; `.claude/rules/plan-acceptance-gates.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`; `.claude/rules/typescript.md`; `.claude/rules/typescript-suppressions.md`; `.claude/rules/powershell.md`; `.claude/rules/self-explanatory-code-commenting.md`; `.claude/rules/tonality.md`. Acceptance: the artifact exists and names every file above.

- [ ] [P0-T2] Verify that the unfilled scaffold plan `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/plan.2026-08-21T17-26.md` created by the promotion tooling is absent. It was removed by the orchestrator in commit `cc55f24b` after this plan was authored, so this is a verification task and not a deletion task; do not remove any file. Record the verification at `<FEATURE>/evidence/other/stale-plan-removal.<ISO8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: a `Test-Path` probe on that exact path reports `False`, and an enumeration of `plan.*.md` in the feature folder returns exactly one entry, `plan.2026-08-21T22-05.md`. If either condition does not hold, stop and report rather than deleting anything.

- [ ] [P0-T3] Verify the npm dependency tree for the workspace that owns the Prettier, ESLint, `tsc`, and Jest scripts, and install it only if it is missing: probe for `extensions/drm-copilot/node_modules`, and run `npm ci` with the working directory set to `extensions/drm-copilot` only when that probe reports absent. The tree was installed by the orchestrator with `npm ci` exiting 0 after this plan was authored, so the expected outcome is that no install runs. Record the result at `<FEATURE>/evidence/baseline/npm-ci-extension.<ISO8601>.md` with the four required fields; when no install runs, `Command:` records the probe and `Output Summary:` states that the tree was already present and the install branch was not taken. Acceptance: `extensions/drm-copilot/node_modules` exists at the end of the task, and the artifact states explicitly which branch was taken.

- [ ] [P0-T4] Record the current line count of every file this plan edits at `<FEATURE>/evidence/baseline/edit-target-line-counts.<ISO8601>.md` with the four required fields. The measured set is `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`, `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts`, `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`, `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`, `tests/scripts/dev_tools/test_blast_radius_config.py`, and `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`. Acceptance: the artifact records one numeric count per path and states the 500-line headroom for each.

- [ ] [P0-T5] Capture the Python formatting baseline by running `poetry run black --check .` from the worktree root. Artifact: `<FEATURE>/evidence/baseline/python-black.<ISO8601>.md` with the four required fields. Acceptance: the artifact records the observed exit code and the count of files Black reports as needing reformatting.

- [ ] [P0-T6] Capture the Python lint baseline by running `poetry run ruff check .` from the worktree root. Artifact: `<FEATURE>/evidence/baseline/python-ruff.<ISO8601>.md` with the four required fields. Acceptance: the artifact records the observed exit code and the reported diagnostic count.

- [ ] [P0-T7] Capture the Python type-check baseline by running `poetry run pyright` from the worktree root. Artifact: `<FEATURE>/evidence/baseline/python-pyright.<ISO8601>.md` with the four required fields. Acceptance: the artifact records the observed exit code and the error and warning counts Pyright reports.

- [ ] [P0-T8] Capture the Python test and coverage baseline by running the whole suite from the worktree root: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`. The test selection must NOT be narrowed to named files. A narrowed selection measured against the whole `scripts.dev_tools` package yields roughly 3% and makes the threshold unreachable; the whole suite meets both thresholds. Artifact: `<FEATURE>/evidence/baseline/python-pytest-coverage.<ISO8601>.md` with the four required fields, and `Output Summary:` must carry the numeric passed, failed, and skipped counts plus **two separate numeric percentages: the statement-covered percentage and the branch-covered percentage**. Record the branch figure as covered branches divided by total branches from the `--cov-branch` report. Do NOT record the `TOTAL` row's single combined `Cover` cell as either figure: with `--cov-branch` that cell is the combined statements-plus-branches ratio and is not the quantity the 75% branch gate is written against. Acceptance: the artifact records two distinct numeric coverage values and names which is statements and which is branches; the literal string `UNVERIFIED` must not appear in the artifact.

- [ ] [P0-T9] Capture the TypeScript formatting baseline by running `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` with the working directory set to `extensions/drm-copilot`. Artifact: `<FEATURE>/evidence/baseline/typescript-prettier.<ISO8601>.md` with the four required fields. Acceptance: the artifact records the observed exit code and the count of files reported as not formatted.

- [ ] [P0-T10] Capture the TypeScript lint baseline by running `npm run lint` with the working directory set to `extensions/drm-copilot`. Artifact: `<FEATURE>/evidence/baseline/typescript-eslint.<ISO8601>.md` with the four required fields. Acceptance: the artifact records the observed exit code and the ESLint error and warning counts.

- [ ] [P0-T11] Capture the TypeScript type-check and test-coverage baseline by running `npm run typecheck` and then `npm run test:coverage` with the working directory set to `extensions/drm-copilot`. Write one artifact per command: `<FEATURE>/evidence/baseline/typescript-typecheck.<ISO8601>.md` and `<FEATURE>/evidence/baseline/typescript-jest-coverage.<ISO8601>.md`, each with the four required fields. The coverage artifact's `Output Summary:` must carry the numeric suite and test pass counts and the numeric statement, branch, function, and line coverage percentages from the text summary. Acceptance: both artifacts exist and the coverage artifact records numeric line and branch percentages.

- [ ] [P0-T12] Capture the PowerShell formatting baseline by invoking the `mcp__drm-copilot__run_poshqc_format` MCP function. Artifact: `<FEATURE>/evidence/baseline/powershell-poshqc-format.<ISO8601>.md` with the four required fields. Acceptance: the artifact records the observed exit code and the list of files the formatter rewrote, or states that no file was rewritten.

- [ ] [P0-T13] Capture the PowerShell analyzer baseline by invoking the `mcp__drm-copilot__run_poshqc_analyze` MCP function. Artifact: `<FEATURE>/evidence/baseline/powershell-poshqc-analyze.<ISO8601>.md` with the four required fields. Acceptance: the artifact records the observed exit code and the PSScriptAnalyzer diagnostic count by severity.

- [ ] [P0-T14] Capture the PowerShell test and coverage baseline by invoking the `mcp__drm-copilot__run_poshqc_test` MCP function with coverage enabled. Artifact: `<FEATURE>/evidence/baseline/powershell-poshqc-test.<ISO8601>.md` with the four required fields, and `Output Summary:` must carry the numeric passed and failed counts and the numeric line-coverage percentage. The artifact must also record that Pester measures no branch coverage, so the branch threshold does not apply per `.claude/rules/quality-tiers.md`. Acceptance: the artifact records a numeric line-coverage value.

- [ ] [P0-T15] Re-derive the `claude-runtime` occurrence inventory across the TypeScript push-down test tree so the edit set is planned against the actual tree rather than the research artifact's partial enumeration. Run `git grep -n -F "claude-runtime" -- extensions/drm-copilot/test/lib/push-down` from the worktree root. Artifact: `<FEATURE>/evidence/baseline/claude-runtime-occurrence-inventory.<ISO8601>.md` with the four required fields, listing every `file:line` hit. Acceptance: the artifact enumerates the hits and explicitly reconciles them against the twelve occurrences known at plan time — `blast-radius-derive-core.test.ts` lines 45, 137, 153, 240, 252, 338, 474; `blast-radius-derive.test.ts` lines 44, 122, 292, 387; and `config-carriage.test-helpers.ts` line 84 — recording any additional hit as an added edit target. The research artifact's enumeration omitted lines 45, 240, and 252 of `blast-radius-derive-core.test.ts`; this inventory supersedes it.

- [ ] [P0-T16] Record the already-discharged divergence walk as a plan input rather than re-running it. Write `<FEATURE>/evidence/other/divergence-walk-citation.<ISO8601>.md` citing `<FEATURE>/evidence/other/divergence-commit-walk.2026-08-21T21-47.md` and restating its two load-bearing findings: the bundled copy was born divergent at `944d58d3` and its `shared_surfaces` and `shared_surface_globs` were never a copy of the self-hosted set; and `mandate_reads` never diverged, so the four missing entries are a gap shared by both copies. Acceptance: the artifact exists and states that the drift gate must therefore assert portable-set equality for `shared_surfaces` and `shared_surface_globs`, never byte-equality against the self-hosted file.

### Phase 1 — Failing regression tests, both directions

Both directions must fail before the fix, per
`.github/instructions/general-code-change.instructions.md`. Every task in this phase is expected to
fail and is tagged accordingly.

- [ ] [P1-T1] [expect-fail] Create `tests/scripts/dev_tools/test_blast_radius_config_parity.py` with a module docstring stating its purpose (the two-copy key-partition contract for the blast-radius truth table), the repo-root and bundled path imports, and the fail-closed regression test named `test_unrelated_claude_citations_do_not_contend_under_the_bundled_table`. The test derives two radii with `derive_blast_radius` from plan text citing `.claude/hooks/enforce-mermaid-validation.ps1` for one item and `.claude/skills/parallel-add/SKILL.md` for the other, against the bundled truth table loaded via `load_config_file(BUNDLED_CONFIG_PATH)`, and asserts `conflicts(...).conflict is False`. Import the shared helpers from `tests.scripts.dev_tools.test_blast_radius_config`; do not duplicate them. Acceptance: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_unrelated_claude_citations_do_not_contend_under_the_bundled_table` fails with an assertion error naming the `module_overlap` reason.

- [ ] [P1-T2] [expect-fail] Add the fail-open regression test named `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` to `tests/scripts/dev_tools/test_blast_radius_config_parity.py`. The test derives two radii from plan text citing the separator-free root token `package-lock.json` against the bundled truth table, calls `conflicts` with the two radii and the bundled configuration as its third positional argument, and asserts `conflict is True` and that a `shared_surface_overlap` reason whose detail is `package-lock.json` is PRESENT among the reasons. The assertion must be a presence check over the reason collection, never an equality check on the whole reason tuple: a correct fix produces `path_overlap` with detail `package-lock.json ~ package-lock.json` alongside `shared_surface_overlap`, so a tuple-equality assertion would fail against the fixed state. Acceptance: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` fails because the bundled table admits no separator-free root token.

- [ ] [P1-T3] [expect-fail] Capture the failing Python regression run at `<FEATURE>/evidence/regression-testing/python-regression-fail-before.<ISO8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and `Output Summary:` recording both failures and their assertion messages. Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py`. Acceptance: the artifact records exactly two failed tests and a non-zero exit code equal to its declared `ExpectedExitCode:`.

- [ ] [P1-T4] [expect-fail] Add a published-document assertion to `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` inside the existing `issue #462 AC8` describe block: publish into a destination with no observable layout and assert the published `config/blast-radius.json` `modules` key set does not include `claude-runtime`. This is the TypeScript half of the fail-closed direction and corresponds to research `## 4.5` item 10. Acceptance: the new test fails under `npm run test:unit` (working directory `extensions/drm-copilot`) because `PAYLOAD_MODULES` still injects `claude-runtime`.

- [ ] [P1-T5] [expect-fail] Capture the failing TypeScript run at `<FEATURE>/evidence/regression-testing/typescript-regression-fail-before.<ISO8601>.md` with the four required fields plus `ExpectedExitCode: 1`, recording the failing test name and its message. Command: `npm run test:unit` with the working directory set to `extensions/drm-copilot`. Acceptance: the artifact names the failing test and records a non-zero exit code equal to its declared `ExpectedExitCode:`.

- [ ] [P1-T6] [expect-fail] Reproduce the fail-closed defect in PowerShell by executing research `## 5.1` (two unrelated `.claude/**` citations against the bundled truth table) followed by research `## 5.2` (the same pair against the self-hosted table as the negative control), from the worktree root under PowerShell 7. Artifact: `<FEATURE>/evidence/regression-testing/powershell-fail-closed-repro.<ISO8601>.md` with the four required fields and both commands' verbatim output. Acceptance: the artifact records `conflict = True` with a `module_overlap : claude-runtime` reason for the bundled table and `False` for the self-hosted control, establishing that the defect is attributable to the truth table rather than to the relation.

- [ ] [P1-T7] [expect-fail] Reproduce the fail-open defect in PowerShell by executing research `## 5.3` (a separator-free root token pair against the bundled truth table, plus `Get-ConfigRootSurface -Config $bundled`) followed by research `## 5.4` (the positive control against the self-hosted table), from the worktree root under PowerShell 7. Artifact: `<FEATURE>/evidence/regression-testing/powershell-fail-open-repro.<ISO8601>.md` with the four required fields and both commands' verbatim output. Acceptance: the artifact records an empty root-surface set and `conflict : False` for the bundled table, and `conflict = True` with both `path_overlap` and `shared_surface_overlap` reasons for the self-hosted control.

### Phase 2 — Cause A: remove `claude-runtime` from `PAYLOAD_MODULES`

- [ ] [P2-T1] Remove the `"claude-runtime": [".claude/**"],` entry from `PAYLOAD_MODULES` at `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:131-135`, leaving exactly `{ config: ["config/**"] }`. Acceptance: the exported constant declares one key and `npm run typecheck` (working directory `extensions/drm-copilot`) exits 0.

- [ ] [P2-T2] Rewrite the doc comment at `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:123-130` so it states why the `.claude` tree is not a module: every agent in the runtime is instructed to read the policy rules and process skills before doing any work, so a `.claude/**` umbrella matches nearly every radius, carries no contention information, and only suppresses concurrency under the module-map granularity criterion in `.claude/rules/parallel-orchestration.md`; and that removal never weakens the relation below the path level, because two items editing the same hook still contend at `path_overlap`. The comment must also record that `config` is retained because `config/**` in a destination holds only the two published files, so it names a subsystem an item can plausibly not touch, and that retaining it keeps the assembled map non-empty so `assertNoForbiddenGlob` has a non-vacuous input. Acceptance: the comment states all three points and the file remains at or under 500 lines.

- [ ] [P2-T3] Update the seeded source-document constants in `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` at lines 45, 240, and 252 so no seeded document declares a `claude-runtime` module. These three occurrences were absent from the research artifact's enumeration and are taken from the P0-T15 inventory. Acceptance: the three seeded literals no longer name `claude-runtime`.

- [ ] [P2-T4] Update the module-map expectations in `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` at lines 137, 153, and 338 so the root-manifest exclusion floor, the nested-project case, and the ordinal-sort case each expect the key set without `claude-runtime`. The ordinal-sort case must remain a byte-stability pin over the remaining names. Acceptance: those three expectations name the corrected key sets.

- [ ] [P2-T5] Update the `PAYLOAD_MODULES` pin in `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` at line 474 to expect exactly `{ config: ["config/**"] }`. Acceptance: the pin no longer names `claude-runtime`.

- [ ] [P2-T6] Add a negative assertion block to `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` asserting that the `PAYLOAD_MODULES` key set excludes `claude-runtime` and that the union of its glob arrays contains no member of `FORBIDDEN_GLOBS`. This is research `## 4.5` item 9 and the live source of Cause A. Acceptance: the new test passes and is distinct from the positive pin updated in P2-T5.

- [ ] [P2-T7] Update the seeded expectations in `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` at lines 44, 122, 292, and 387 so no seeded decorator document declares a `claude-runtime` module. Leave the `mandate_reads` carriage suite unchanged; it asserts a seeded round-trip rather than a specific list. Acceptance: the four seeded literals no longer name `claude-runtime` and the file remains at or under 500 lines.

- [ ] [P2-T8] Run `npm run test:unit` with the working directory set to `extensions/drm-copilot` and confirm the `blast-radius-derive-core` and `blast-radius-derive` suites pass, then confirm that `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts`, `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts`, and `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` are each at or under 500 lines. Artifact: `<FEATURE>/evidence/qa-gates/phase2-typescript-verification.<ISO8601>.md` with the four required fields plus the three measured line counts. Acceptance: `EXIT_CODE: 0` and all three counts are at or under 500.

### Phase 3 — Causes B and C: correct both truth-table copies

- [ ] [P3-T1] Replace `shared_surfaces` in `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` with exactly the six-entry destination-portable set, in this order: `.claude/settings.json`, `config/blast-radius.json`, `config/orchestration-routing.json`, `package-lock.json`, `poetry.lock`, `quality-tiers.yml`. Three of the six are separator-free, which is what restores the root-token branch of `Get-PathTokenKind` in every destination. Acceptance: the key holds exactly those six strings and the file parses as JSON.

- [ ] [P3-T2] Verify that `shared_surface_globs` in `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` remains the empty list and record the verification. All three self-hosted globs are `scripts/dev_tools/*.py` patterns naming this repository's Python dev-tooling module families and describe no destination; an empty list is acceptable rather than merely tolerable because a glob is never a source of root-token acceptance. Acceptance: the key is present and empty; no edit is made to it.

- [ ] [P3-T3] Append the four entries `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `.claude/skills/policy-compliance-order/SKILL.md`, `.claude/agent-memory/**`, and `.agents/skills/**` to `mandate_reads` in `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`, in that order, after the six existing entries. Acceptance: the key holds exactly ten strings in the stated order.

- [ ] [P3-T4] Reduce `modules` in `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` to exactly `{ "config": ["config/**"] }`. Retain the key rather than deleting it, because `tests/scripts/dev_tools/test_blast_radius_config.py` calls `load_module_globs` on the bundled copy and that helper raises `TypeError` on an absent `modules` key. Acceptance: the key declares one module with one glob.

- [ ] [P3-T5] Append the same four entries, in the same order, to `mandate_reads` in `config/blast-radius.json` after its six existing entries. This closes Cause C in the self-hosted copy, where the missing exclusions produce `path_overlap` rather than `module_overlap` because the self-hosted map carries no `claude-runtime` umbrella. Acceptance: the key holds exactly ten strings in an order identical to the bundled copy, so the Class 1 byte-equality assertion added in P6-T2 can hold.

- [ ] [P3-T6] Verify that no key of `config/blast-radius.json` other than `mandate_reads` changed: `version` is `1`, `shared_surfaces` holds its ten entries, `shared_surface_globs` holds its three entries, `modules` declares its seven subsystem modules, and `over_breadth_fraction` is `0.25`. Artifact: `<FEATURE>/evidence/other/self-hosted-config-unchanged-keys.<ISO8601>.md` with the four required fields and the observed cardinality of each key. Acceptance: every stated cardinality matches.

- [ ] [P3-T7] Confirm no pre-existing Python assertion regressed on the corrected data by running `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py tests/scripts/dev_tools/test_blast_radius_mandate_reads.py tests/scripts/dev_tools/test_blast_radius_invariants.py`. Artifact: `<FEATURE>/evidence/qa-gates/phase3-python-verification.<ISO8601>.md` with the four required fields and the passed and failed counts. Acceptance: `EXIT_CODE: 0`.

### Phase 4 — DD-1 visibility: the AC8 list and the seeded source constant

The AC8 assertion runs against the hermetic in-memory constant `SOURCE_BLAST_RADIUS` in
`extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts:74-91`, not against the
real bundled file. Narrowing the list before updating the constant keeps the phase green at every
step, because once the constant carries the two lockfile names the un-narrowed list would fail.

- [ ] [P4-T1] Narrow the AC8 forbidden-substring list at `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:284-293` by removing the `poetry.lock` and `package-lock.json` entries, retaining `'"**"'`, `'"docs/**"'`, `'"tests/**"'`, `scripts/dev_tools`, and `packages/mcp-server`. Acceptance: the list holds exactly five entries and the suite still asserts them.

- [ ] [P4-T2] Rewrite the `// Assert:` rationale comment immediately above that list, at `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:278-281`, to state the retained criterion per DD-1: what must never reach a destination is an entry naming THIS repository's directory layout, not an ecosystem-standard root filename that any destination may legitimately carry. The comment must name `poetry.lock` and `package-lock.json` as the two entries removed and record that the cost of a surface entry a destination lacks is zero under the governing surfaces-versus-modules asymmetry. Acceptance: the comment states the criterion and names both removed entries.

- [ ] [P4-T3] Update the `SOURCE_BLAST_RADIUS` constant at `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts:74-91` to mirror the corrected bundled document exactly: the six-entry `shared_surfaces` set of P3-T1, an empty `shared_surface_globs`, the ten-entry `mandate_reads` list of P3-T3, `modules` as `{ config: ["config/**"] }`, `version` `1`, and `over_breadth_fraction` `0.25`. Acceptance: the constant declares the same six keys with the same values as the file corrected in Phase 3.

- [ ] [P4-T4] Rewrite the doc comment block at `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts:61-73`, whose line 73 is the closing delimiter, so it describes the corrected bundled copy: one payload module (`config`), a six-entry destination-portable surface set of which three entries are separator-free, and a ten-entry mandate-read set. Remove the claim that the bundled document declares two payload modules. Acceptance: the comment states one payload module and does not state two.

- [ ] [P4-T5] Run `npm run test:unit` with the working directory set to `extensions/drm-copilot` and confirm the `claude-config-carriage` suite passes, including the AC8 genericity case and the published-document assertion added in P1-T4, which now passes. Artifact: `<FEATURE>/evidence/qa-gates/phase4-typescript-verification.<ISO8601>.md` with the four required fields. Acceptance: `EXIT_CODE: 0`.

### Phase 5 — Rule prose and its byte-identical mirror

- [ ] [P5-T1] Amend `.claude/rules/parallel-orchestration.md` under the `## Blast-Radius Contention Doctrine (issue #489)` section with a new subsection recording the three points required by spec AC7: (a) a destination's module map is DERIVED from the destination's own layout by `assembleModules`, which never reads the source document's `modules` key, so the bundled `modules` key is not consumed and is retained only so a maintainer reading the file is not told something false; (b) `PAYLOAD_MODULES` carries `config` only, and `claude-runtime` is disqualified in a destination by the same granularity criterion that removed it here, with the no-signal floor preserved because `config/**` in a destination holds only the two published files; (c) the bundled `shared_surfaces` and `shared_surface_globs` sets are the destination-portable subset, not a copy of the self-hosted sets, with the surfaces-versus-modules asymmetry as the stated reason — an over-matching module glob costs concurrency on every pair it touches, whereas a surface or mandate-read entry naming a path the destination lacks is inert, and a separator-free shared surface is additionally the sole gate on whether the extractor accepts a separator-free token at all. Acceptance: the amended file states all three points and remains valid Markdown; the file is exempt from the 500-line limit as documentation.

- [ ] [P5-T2] Mirror the P5-T1 amendment into `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` so the two files are byte-identical. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` enforces byte-identity for every `.claude/**` file, and the edit must therefore land in both copies within this change set. Acceptance: the bundled copy contains the identical amendment.

- [ ] [P5-T3] Verify the mirror rather than assume it, by running `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Artifact: `<FEATURE>/evidence/qa-gates/phase5-mirror-byte-identity.<ISO8601>.md` with the four required fields and the passed and failed counts. Acceptance: `EXIT_CODE: 0`, which is the byte-identity proof for both `.claude/rules/parallel-orchestration.md` copies.

### Phase 6 — The three-class key-partition drift gate

- [ ] [P6-T1] Add the declared constants to `tests/scripts/dev_tools/test_blast_radius_config_parity.py`: `PORTABLE_SHARED_SURFACES` as a frozenset of the six entries of P3-T1 with a one-line rationale comment per entry; `UMBRELLA_MODULE_NAMES` as the five disqualified names `python-dev-tools`, `vscode-extension`, `claude-runtime`, `copilot-surface`, `agents-surface`; `PAYLOAD_MODULE_NAMES` as a frozenset holding `config` only, with a comment citing `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` as the authoritative source and naming the TypeScript pin that holds it; and `BYTE_EQUAL_KEYS` as the tuple `version`, `over_breadth_fraction`, `mandate_reads`. Acceptance: all four constants exist with the stated members and `poetry run pyright` reports no error for the module.

- [ ] [P6-T2] Add the Class 1 test asserting that every key in `BYTE_EQUAL_KEYS` is equal between the two committed copies, with a failure message naming both repo-relative labels. This closes Cause C structurally: the four `mandate_reads` additions cannot land in one copy only. Acceptance: the test passes and fails if either copy's `mandate_reads` is altered alone.

- [ ] [P6-T3] Add the Class 2 test asserting that the bundled `shared_surfaces` equals `PORTABLE_SHARED_SURFACES` as a set and is a subset of the self-hosted `shared_surfaces`, and that the bundled `shared_surface_globs` is empty and a subset of the self-hosted list. Portable-set equality, not byte-equality against the self-hosted file, is the correct relation for these two keys: the divergence walk established that they were authored narrow at commit `944d58d3` and were never a copy of the self-hosted set. Acceptance: the test passes and fails on either direction of drift — a silently dropped entry or a silently added drm-copilot-specific entry.

- [ ] [P6-T4] Add the Class 3 test asserting that the bundled `modules` key set is a subset of `PAYLOAD_MODULE_NAMES`. Acceptance: the test passes against the corrected bundled file and fails if `claude-runtime` is reintroduced to it.

- [ ] [P6-T5] Add the umbrella-denylist test asserting that neither committed copy declares any member of `UMBRELLA_MODULE_NAMES` as a module name, parametrized over `COMMITTED_CONFIGS` so the failure message names the offending copy. This extends the existing two-name location-bucket pin to five umbrella names applied to both copies. Acceptance: the test passes and is parametrized over exactly the two committed copies.

- [ ] [P6-T6] Add the separator-free wildcard-free test asserting that every bundled `shared_surfaces` entry containing no path separator also contains no wildcard character. A wildcard-bearing separator-free entry would be admitted by `Get-ConfigRootSurface` yet classified as a glob, silently breaking root-token extraction. Acceptance: the test passes for the three separator-free entries `package-lock.json`, `poetry.lock`, and `quality-tiers.yml`.

- [ ] [P6-T7] Add the non-vacuity floor test asserting that `COMMITTED_CONFIGS` has exactly two members and that each collection the gate compares and intends to be non-empty is non-empty: both copies' `shared_surfaces`, both copies' `mandate_reads`, both copies' `modules`, and `PORTABLE_SHARED_SURFACES`. Acceptance: the test passes and would fail if a renamed key made any compared collection empty.

- [ ] [P6-T8] Add the parse-and-version test asserting that both committed copies parse to JSON objects and declare `version == 1`, extending the existing self-hosted-only version pin to the bundled copy. Acceptance: the test passes for both copies.

- [ ] [P6-T9] Mirror the Class 1 equality into `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` as an `It` block asserting that `version`, `over_breadth_fraction`, and `mandate_reads` are equal between `$script:CommittedConfig` and `$script:BundledConfig`, following the file's established pattern of accumulating offenders and asserting `Should -BeNullOrEmpty`. Acceptance: the block passes under `mcp__drm-copilot__run_poshqc_test`.

- [ ] [P6-T10] Mirror the Class 3 subset and the five-name umbrella denylist into `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`: one `It` block asserting the bundled `modules` key set is a subset of the payload module name set (`config` only, declared as a script-scoped constant with a comment citing the TypeScript source), and one `It` block extending the existing repository-only umbrella pin to iterate both copies. Comparison must be ordinal, matching the case-sensitive semantics of the Python reference. Acceptance: both blocks pass and the umbrella block reads both copies.

- [ ] [P6-T11] Mirror the separator-free wildcard-free assertion onto the bundled copy in `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, extending the existing self-hosted-only assertion at lines 169-184. Acceptance: the block passes for the three separator-free bundled entries.

- [ ] [P6-T12] Correct the factually wrong comment at `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1:96-98`. Remove the claim that the bundled base document's module map describes the destination repository's subsystems, and replace it with the accurate statement that the bundled `modules` key is never read — `assembleModules` derives a destination's map from the destination's own layout — and that `PAYLOAD_MODULES` in `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` is the live source of a destination's payload modules. The former comment exempted a dead field while the live source was pinned positively elsewhere. Acceptance: the comment no longer asserts the destination-subsystems ground, and the umbrella pin it annotates now applies to both copies per P6-T10.

- [ ] [P6-T13] Verify the file-size ceiling for the two files this phase extends: `tests/scripts/dev_tools/test_blast_radius_config_parity.py` and `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`. Artifact: `<FEATURE>/evidence/qa-gates/phase6-file-size-check.<ISO8601>.md` with the four required fields and the two measured counts. Acceptance: both counts are at or under 500. If either would exceed 500, split the file before proceeding and record the split in the artifact.

- [ ] [P6-T14] Run the gate in both languages: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py` from the worktree root, and the `mcp__drm-copilot__run_poshqc_test` MCP function. Write one artifact per command under `<FEATURE>/evidence/qa-gates/`, named `phase6-python-gate.<ISO8601>.md` and `phase6-powershell-gate.<ISO8601>.md`, each with the four required fields and the passed and failed counts. Acceptance: both record `EXIT_CODE: 0`, and the Python artifact records that the two regression tests added in P1-T1 and P1-T2 now pass.

### Phase 7 — Pass-after evidence and post-fix measurement

- [ ] [P7-T1] Re-run the research `## 5.1` and `## 5.2` command pair against the corrected data and capture the pass-after result at `<FEATURE>/evidence/qa-gates/powershell-fail-closed-pass-after.<ISO8601>.md` with the four required fields and both commands' verbatim output. Acceptance: the artifact records `conflict = False` for the bundled table, matching the self-hosted control, and states that the `module_overlap : claude-runtime` reason observed in P1-T6 is gone.

- [ ] [P7-T2] Re-run the research `## 5.3` and `## 5.4` command pair against the corrected data and capture the pass-after result at `<FEATURE>/evidence/qa-gates/powershell-fail-open-pass-after.<ISO8601>.md` with the four required fields and both commands' verbatim output. Acceptance: the artifact records a non-empty `Get-ConfigRootSurface` result for the bundled table and `conflict : True` for the separator-free root-token pair.

- [ ] [P7-T3] Capture the pass-after Python regression run at `<FEATURE>/evidence/qa-gates/python-regression-pass-after.<ISO8601>.md` with the four required fields. Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py`. Acceptance: `EXIT_CODE: 0` and the artifact names both regression tests as passing, pairing with the fail-before artifact from P1-T3.

- [ ] [P7-T4] Capture the pass-after TypeScript run at `<FEATURE>/evidence/qa-gates/typescript-regression-pass-after.<ISO8601>.md` with the four required fields. Command: `npm run test:unit` with the working directory set to `extensions/drm-copilot`. Acceptance: `EXIT_CODE: 0` and the artifact names the published-document assertion added in P1-T4 as passing, pairing with the fail-before artifact from P1-T5.

- [ ] [P7-T5] Confirm inventory pair 4 independently of its TypeScript test by computing `Get-FileHash` over `config/orchestration-routing.json` and over `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` and comparing the two digests. Artifact: `<FEATURE>/evidence/other/routing-pair-byte-compare.<ISO8601>.md` with the four required fields and both digests. Acceptance: the two digests are equal, discharging the second half of spec AC17; the first half is discharged by the divergence walk cited in P0-T16.

- [ ] [P7-T6] Record the post-fix conflict-graph measurement required by the spec's `## Rollout & Follow-up` section: re-derive the blast radius for the committed plans under `docs/features/active/` against `config/blast-radius.json` and record the resulting conflict-graph density and maximum parallel width. Artifact: `<FEATURE>/evidence/other/post-fix-conflict-graph.<ISO8601>.md` with the four required fields, the numeric density, the numeric maximum width, the item count, and an explicit comparison against the `issue.md:44` baseline of 83.3% density and maximum width 2 over 16 items. Acceptance: the artifact records both numeric values and the comparison. No numeric improvement target is asserted; the measurement is recorded, not gated.

### Phase 8 — Final QA loop and acceptance-criteria checkoff

Run the loop in order per language. If any step fails or rewrites a file, restart that language's
loop from its formatting step and record each attempt as its own artifact. Every task in this phase
is unconditional; `EXIT_CODE: SKIPPED` is not a passing outcome for any of them.

- [ ] [P8-T1] Run `poetry run black .` from the worktree root. Artifact: `<FEATURE>/evidence/qa-gates/final-python-black.<ISO8601>.md` with the four required fields. Acceptance: `EXIT_CODE: 0` and the artifact records whether any file was reformatted; if any was, the Python loop restarts from this task.

- [ ] [P8-T2] Run `poetry run ruff check .` from the worktree root. Artifact: `<FEATURE>/evidence/qa-gates/final-python-ruff.<ISO8601>.md` with the four required fields. Acceptance: `EXIT_CODE: 0` with zero diagnostics.

- [ ] [P8-T3] Run `poetry run pyright` from the worktree root. Artifact: `<FEATURE>/evidence/qa-gates/final-python-pyright.<ISO8601>.md` with the four required fields. Acceptance: `EXIT_CODE: 0` with zero errors.

- [ ] [P8-T4] Run the whole suite from the worktree root: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`. The selection must match P0-T8 exactly and must NOT be narrowed to named files, so the post-change figure is comparable with the baseline that P8-T12 diffs against. Artifact: `<FEATURE>/evidence/qa-gates/final-python-pytest-coverage.<ISO8601>.md` with the four required fields, and `Output Summary:` carrying the numeric passed, failed, and skipped counts and **two separate numeric percentages: the statement-covered percentage and the branch-covered percentage**, recorded from the same cells as P0-T8 and not from the `TOTAL` row's combined `Cover` cell. Acceptance: `EXIT_CODE: 0`, statement coverage at or above 85%, branch coverage at or above 75%. The new gate module `tests/scripts/dev_tools/test_blast_radius_config_parity.py` is inside this selection and its own targeted run is recorded separately by P6-T14; the changed-lines criterion is carried by P8-T12, not by this task.

- [ ] [P8-T5] Run `npm run format` with the working directory set to `extensions/drm-copilot`. Artifact: `<FEATURE>/evidence/qa-gates/final-typescript-prettier.<ISO8601>.md` with the four required fields and the list of files Prettier rewrote. Acceptance: `EXIT_CODE: 0`; if any file was rewritten, the TypeScript loop restarts from this task.

- [ ] [P8-T6] Run `npm run lint` with the working directory set to `extensions/drm-copilot`. Artifact: `<FEATURE>/evidence/qa-gates/final-typescript-eslint.<ISO8601>.md` with the four required fields. Acceptance: `EXIT_CODE: 0` with zero errors and zero warnings.

- [ ] [P8-T7] Run `npm run typecheck` with the working directory set to `extensions/drm-copilot`. Artifact: `<FEATURE>/evidence/qa-gates/final-typescript-typecheck.<ISO8601>.md` with the four required fields. Acceptance: `EXIT_CODE: 0` with zero errors.

- [ ] [P8-T8] Run `npm run test:coverage` with the working directory set to `extensions/drm-copilot`. Artifact: `<FEATURE>/evidence/qa-gates/final-typescript-jest-coverage.<ISO8601>.md` with the four required fields, and `Output Summary:` carrying the numeric suite and test pass counts and the numeric statement, branch, function, and line coverage percentages. Acceptance: `EXIT_CODE: 0`, line coverage at or above 85%, branch coverage at or above 75%.

- [ ] [P8-T9] Invoke the `mcp__drm-copilot__run_poshqc_format` MCP function. Artifact: `<FEATURE>/evidence/qa-gates/final-powershell-poshqc-format.<ISO8601>.md` with the four required fields and the list of files rewritten. Acceptance: `EXIT_CODE: 0`; if any file was rewritten, the PowerShell loop restarts from this task.

- [ ] [P8-T10] Invoke the `mcp__drm-copilot__run_poshqc_analyze` MCP function. Artifact: `<FEATURE>/evidence/qa-gates/final-powershell-poshqc-analyze.<ISO8601>.md` with the four required fields. Acceptance: `EXIT_CODE: 0` with zero diagnostics at Error or Warning severity.

- [ ] [P8-T11] Invoke the `mcp__drm-copilot__run_poshqc_test` MCP function with coverage enabled. Artifact: `<FEATURE>/evidence/qa-gates/final-powershell-poshqc-test.<ISO8601>.md` with the four required fields, and `Output Summary:` carrying the numeric passed and failed counts and the numeric line-coverage percentage. Acceptance: `EXIT_CODE: 0` and line coverage at or above 85%. The artifact must record that no branch-coverage threshold applies, because Pester measures no branch coverage.

- [ ] [P8-T12] Write the coverage delta and threshold verification at `<FEATURE>/evidence/qa-gates/coverage-delta-verification.<ISO8601>.md` with `Timestamp:`, `Command:` naming the three coverage commands compared, `EXIT_CODE:`, and `Output Summary:` carrying, per language, the baseline coverage from Phase 0, the post-change coverage from this phase, and the changed-lines coverage for the files this plan edited. For Python and TypeScript the baseline and post-change columns must each carry the statement and branch figures separately, taken from the same report cells P0-T8 and P8-T4 name, never from a single combined `Cover` cell. Acceptance: the artifact records numeric values in all three columns for Python and TypeScript and in the baseline and post-change columns for PowerShell, shows no regression against the Phase 0 baselines, and shows no reduction in coverage for the changed lines. The changed-lines column must name each file this plan edited and its measured figure; this is the binding constraint, because the TypeScript change edits an exported constant in a module whose test file already exists. No `exclude` entry was added to any coverage configuration, and the artifact states that explicitly.

- [ ] [P8-T13] Verify the 500-line ceiling across every code and test file this plan touched: `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`, `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts`, `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`, `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`, `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, and `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`. Artifact: `<FEATURE>/evidence/qa-gates/final-file-size-compliance.<ISO8601>.md` with the four required fields and one numeric count per path. Acceptance: every count is at or under 500. `tests/scripts/dev_tools/test_blast_radius_config.py` must be reported as unmodified at 499 lines.

- [ ] [P8-T14] Record the single-run clean-pass confirmation at `<FEATURE>/evidence/qa-gates/final-toolchain-single-pass.<ISO8601>.md` with the four required fields, listing every stage of all three language loops with its exit code from a single uninterrupted pass in which no stage failed and no stage rewrote a file. Acceptance: the artifact shows one contiguous pass covering Black, Ruff, Pyright, Pytest; Prettier, ESLint, `tsc`, Jest; and PoshQC format, analyze, test — every stage `EXIT_CODE: 0`. If a restart occurred, the artifact records the restart and the final clean pass.

- [ ] [P8-T15] Check off the delivered acceptance criteria in `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, changing `- [ ]` to `- [x]` only for criteria whose evidence exists on disk, one at a time, preserving each criterion's text verbatim and adding no new criterion. `spec.md` is the sole AC source for `full-bug`. When checking AC9 and AC10, record in the AC summary artifact that the three-class gate landed in `tests/scripts/dev_tools/test_blast_radius_config_parity.py` rather than in `tests/scripts/dev_tools/test_blast_radius_config.py`, because that file stands at 499 of a permitted 500 lines and cannot receive one additional line under `.claude/rules/general-code-change.md`. Acceptance: every checked criterion has a named evidence artifact, and any criterion without one remains unchecked.

- [ ] [P8-T16] Write the acceptance-criteria status summary at `<FEATURE>/evidence/issue-updates/ac-status-summary.<ISO8601>.md` in the format the tracking skill requires: `Source:`, `Total AC items:`, `Checked off (delivered):`, `Remaining (unchecked):`, and `Items remaining:` listing the text of every unchecked criterion. Acceptance: the totals reconcile with the checkbox state of `spec.md` and the artifact names the evidence artifact backing each checked criterion.
