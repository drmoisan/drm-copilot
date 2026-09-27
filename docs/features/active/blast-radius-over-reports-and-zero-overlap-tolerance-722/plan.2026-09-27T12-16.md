# blast-radius-over-reports-and-zero-overlap-tolerance (Plan)

- **Issue:** #722
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T14-30
- **Status:** Draft (pending executor preflight)
- **Version:** 1.0
- **Work Mode:** full-bug (the feature spec is the sole acceptance-criteria source; no user story)
- **Parallel run:** blast-radius-tolerance-2026-09-27 (preparation mode)
- **Branch:** bug/blast-radius-over-reports-and-zero-overlap-tolerance-722

## Preamble

### Radius hygiene (applies to every revision of this plan)

The blast radius of this item is derived from this plan and its spec by the current extractor, which
over-reports. Inline code in this plan is used only for the concrete repository paths that a task
writes, exactly as listed in the spec's files-to-change section, plus the rule file this item amends.
Read-only files, directories, commands, identifiers, configuration keys, glob shapes, and example
paths are written in plain words or inside fenced code blocks. Evidence artifact paths are written in
plain words because they are feature-relative and carry a timestamp placeholder.

### Terms used in every task

- FEATURE means the folder docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.
- TS means the execution time of the task in yyyy-MM-ddTHH-mm form.
- SCRATCH means the executor's session scratchpad directory. It is outside the repository and is
  never committed. Artifacts record it as the literal token SCRATCH, never as a host path.
- BASE_SHA means the merge-base commit recorded by P0-T11. Every scope diff is anchored to it.
- Every command-step evidence artifact carries Timestamp:, Command:, EXIT_CODE:, and Output Summary:.
  An artifact whose expected exit code is not 0 also carries ExpectedExitCode:.
- Acceptance-criteria identifiers AC-01 through AC-38 are assigned to the 38 checklist entries of the
  spec's Acceptance Criteria section in document order. The mapping is in the Acceptance Criteria
  Traceability section at the end of this plan.

### Structure (split decision recorded in the spec)

One plan, two sequential phase groups. Part A (Phases 1-7): scheduling layer, strict-mode identity,
drift handling, conflict_tolerance configuration, historical BEFORE pins. Part B (Phases 8-13):
write-intent extraction, the write_intent_extraction and path_roots keys, the mandate-read
amendment, historical AFTER pins, and the re-derivation evidence. Final group (Phases 14-18): main
sync, #452 re-gate, per-language QA loops, coverage deltas, check-off, and CI. Design points 1-7 are
all implemented; none is dropped. Bash is not touched; P14-T7 asserts that.

### Operator-directed policy change

Repository policy prohibits edits to rule files. This item amends
`.claude/rules/parallel-orchestration.md` and its bundled mirror because the operator directed the
change (issue #722, 2026-09-27) and the spec records it as design point 5, a configured policy change.
No other file under the rules directory or the .github instructions directory is written.

Radius note for the parallel planner: the rule file matches the configured mandate-read subtree for
the rules directory, so derivation excludes it from the derived radius even though this plan names it.
Under constraint 1 of the mandate-read exclusion, the parallel planner appends
`.claude/rules/parallel-orchestration.md` to this item's declared radius after normalization, because
this item genuinely writes it.

### Batch budgets, mirrors, and the 500-line limit

- Per batch and per language (Python, PowerShell): at most 3 authored production files and 3 authored
  test files. Each batch begins with a batch-budget reset task that records its evidence.
- A bundled mirror is produced by copying the edited primary file with Copy-Item through the
  PowerShell tool (never through Write or Edit), so the mirror is byte-identical and is not a second
  authored file. P0-T14 records whether each mirror pair is byte-identical at baseline; a pair that is
  not identical at baseline receives the same textual edit instead of a copy, and that edit counts
  against the budget of its batch.
- No production or test file may exceed 500 lines. The drift-detection module must not grow. JSON
  fixtures are test data and follow the existing verification-integrity fixture precedent.

### Shell route

A worktree isolation hook refuses Bash-tool command text that contains the words bash, pwsh, or wsl,
heredocs, compound commands, cd-chains, or xargs. Therefore:

- Every git command in this plan is one plain command with literal arguments.
- PowerShell scripts run through the PowerShell tool when it is available. Otherwise they run through
  the Bash tool as a POSIX sh runner (Appendix A, script A1) whose command text never names pwsh.
- Python scratch scripts run as files through poetry, never as a multi-line -c argument.

### CI and determinism constraints

- A local Windows pass does not prove Linux CI. Automated tests read only committed files under the
  tests tree. They never read origin refs, the gitignored artifacts directory, the main checkout, a
  temporary file, or a Windows-only path.
- CI's only Pester job runs on windows-latest. No acceptance criterion in this plan names a Linux
  runner for Pester.
- This plan adds no bats test. No task sources a bash helper under set -u.

### Merge-order independence with sibling #452

This plan works whether or not additional #452 fixtures reach main first. It carries its own #452
scheduling fixtures with the radii embedded (P1-T2 through P1-T4). The detection relation (the Python
conflicts function and the PowerShell Test-BlastRadiusConflict function) is never edited, so every
detection verdict and reason list is unchanged. P0-T20 through P0-T22 form the pre-authorized #452
detection gate: they are authorized to run on this branch, run the #452-tagged fixtures unmodified
through both detection drivers, and record any sibling-added fixture. P14-T3 re-runs the gate after
main is merged. No task assumes that #452 merges first.

### Delegation and completion rules for the executor

- Delegate synchronously anything the next task depends on. Do not start a dependent task until the
  delegated child has returned its completion notification.
- A child that reports it is waiting on its own sub-task has not failed. Wait for its completion
  notification; do not replace it or re-run its work.
- Every phase ends with a commit-and-push task. The execution child owns every CI-dependent
  acceptance-criterion check-off and pushes that check-off before it reports done, because the parent
  cannot commit from the coordinator root.
- If a hook denies a command in this plan, stop and report the denial text. Do not bypass the hook.
- If any stop condition written into a task is reached, stop, write the evidence artifact the task
  names with the stop reason, and report to the parent. Do not improvise a substitute design.

### Command catalogue

Every command-bearing task names one or more entries below. Angle-bracket fields are filled from the
task text. Commands run from the repository root of this worktree.

```text
CMD-GIT-HEAD          git rev-parse HEAD
CMD-GIT-FETCH-MAIN    git fetch origin main
CMD-GIT-MERGE-BASE    git merge-base HEAD origin/main
CMD-GIT-STATUS        git status --porcelain
CMD-GIT-STATUS-PATH   git status --porcelain -- <pathspec>
CMD-GIT-DIFF-NAMES    git diff --name-only <BASE_SHA> -- <pathspec>
CMD-GIT-FETCH-RUN     git fetch origin parallel/<slug>-plan
CMD-GIT-MANIFEST-BLOB git rev-parse origin/parallel/<slug>-plan:docs/features/parallel/<slug>/parallel.md
CMD-GIT-TOPDIRS       git ls-tree -d --name-only HEAD
CMD-GIT-CHANGELOGS    git ls-files -- *CHANGELOG.md
CMD-GIT-452-BRANCH    git grep -l -F "#452" -- tests/fixtures/blast_radius
CMD-GIT-452-MAIN      git grep -l -F "#452" origin/main -- tests/fixtures/blast_radius
CMD-GIT-TRACKED       git ls-files --error-unmatch -- <path>
CMD-GIT-GREP-FORBID   git grep -n -F -e origin/ -e artifacts/ -- <path> <path>
CMD-GIT-ADD           git add -- <exact paths listed in the task>
CMD-GIT-COMMIT        git commit -m "<message given in the task>"
CMD-GIT-PUSH          git push origin bug/blast-radius-over-reports-and-zero-overlap-tolerance-722
CMD-GIT-MERGE-MAIN    git merge --no-edit origin/main

CMD-PY-BLACK-CHECK    poetry run black --check <paths or .>
CMD-PY-BLACK          poetry run black <paths or .>
CMD-PY-RUFF           poetry run ruff check --no-fix <paths or .>
CMD-PY-PYRIGHT        poetry run pyright <paths or nothing>
CMD-PY-TEST           poetry run pytest -v <test files or node IDs listed in the task>
CMD-PY-TEST-K         poetry run pytest -v tests/scripts/dev_tools -k <expression given in the task>
CMD-PY-COV            poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/coverage-722-<label>.json
CMD-PY-SCRIPT         poetry run python SCRATCH/<script>.py <args>

CMD-PS-SCRIPT         & 'SCRATCH/<script>.ps1' <args>                         (PowerShell tool)
CMD-PS-SCRIPT-SH      sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>         (Bash tool route)
MCP-PS-FORMAT         mcp__drm-copilot__run_poshqc_format  (workspace_root = repository root, scan_folders = paths listed in the task)
MCP-PS-ANALYZE        mcp__drm-copilot__run_poshqc_analyze (same arguments)

CMD-TS-CI             npm --prefix extensions/drm-copilot ci
CMD-TS-FORMAT         npm --prefix extensions/drm-copilot run format
CMD-TS-PRETTIER-CHECK node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --check <repository-relative TypeScript paths>
CMD-TS-LINT           npm --prefix extensions/drm-copilot run lint
CMD-TS-TYPECHECK      npm --prefix extensions/drm-copilot run typecheck
CMD-TS-TEST           npm --prefix extensions/drm-copilot run test -- <test paths relative to extensions/drm-copilot>
CMD-TS-COV            npm --prefix extensions/drm-copilot run test -- --coverage --coverageReporters=text --coverageReporters=lcov
```

Observed success outputs that acceptance conditions rely on: black check mode exits 0 and prints a
line ending "would be left unchanged."; ruff with --no-fix exits 0 and prints "All checks passed!";
pyright exits 0 and prints "0 errors"; pytest -v prints one PASSED line per collected node; Prettier
check mode exits 0 and prints "All matched files use Prettier code style!"; ESLint and tsc exit 0
with no diagnostics. The PoshQC MCP tools return no stdout or exit code, so their only observable
signal is whether the call returns or raises; every PowerShell format acceptance therefore also uses
the read-only check script A6 and a before-and-after hash comparison.

---

### Phase 0 — Policy Reads, Baselines, #452 Detection Gate, and Historical BEFORE Re-derivation

- [ ] [P0-T1] Read CLAUDE.md and the .github copilot-instructions file in full, in that order.
      Acceptance: both files read; recorded in P0-T10.
- [ ] [P0-T2] Read, in order, the .github instruction files for general code change, general unit
      test, Python code change, Python unit test, PowerShell code change, PowerShell unit test,
      TypeScript code change, and TypeScript unit test. Acceptance: all eight read; recorded in P0-T10.
- [ ] [P0-T3] Read, in order, the rule files general-code-change, general-unit-test, quality-tiers,
      and tonality under the .claude rules directory. Acceptance: all four read; recorded in P0-T10.
- [ ] [P0-T4] Read the rule files python, python-suppressions, and self-explanatory-code-commenting.
      Acceptance: all three read; recorded in P0-T10.
- [ ] [P0-T5] Read the rule file powershell. Acceptance: read; recorded in P0-T10.
- [ ] [P0-T6] Read the rule files typescript, typescript-suppressions, and architecture-boundaries.
      Acceptance: all three read; recorded in P0-T10.
- [ ] [P0-T7] Read the rule file plan-acceptance-gates and the evidence-and-timestamp-conventions
      skill. Acceptance: both read; recorded in P0-T10.
- [ ] [P0-T8] Read `.claude/rules/parallel-orchestration.md` in full, including the Read-by-mandate,
      Enum Ownership, and issue #500 sections this item amends. Acceptance: read; recorded in P0-T10.
- [ ] [P0-T9] Read this feature's issue.md, spec.md, and the research note dated 2026-09-27T12-25 in
      FEATURE/research. Acceptance: all three read; recorded in P0-T10.
- [ ] [P0-T10] Write FEATURE/evidence/baseline/phase0-instructions-read.md containing Timestamp:,
      Policy Order: (the order of P0-T1 through P0-T9), and the explicit list of every file read.
      Acceptance: the artifact exists with the three fields and lists every file named in P0-T1
      through P0-T9.
- [ ] [P0-T11] Record the baseline commit: run CMD-GIT-HEAD, CMD-GIT-FETCH-MAIN, CMD-GIT-MERGE-BASE,
      and CMD-GIT-STATUS. The CMD-GIT-MERGE-BASE output is BASE_SHA. Write
      FEATURE/evidence/baseline/git-base.TS.md. Acceptance: every command exits 0; the artifact records
      the HEAD SHA, BASE_SHA (40 hexadecimal characters), and the porcelain status.
- [ ] [P0-T12] Create the scratch scripts A1 through A9 and B39 of Appendix A in SCRATCH with the
      exact bodies given, then smoke-test A3 by running CMD-PS-SCRIPT with script pester-coverage and arguments
      -TestPath tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1
      -CoveragePath .claude/lib/blast-radius/BlastRadiusGlob.psm1
      -CoverageOutputPath SCRATCH/pester-smoke.xml. Write
      FEATURE/evidence/baseline/scratch-scripts-setup.TS.md listing the ten script names and the smoke
      output. Acceptance: the smoke run prints FailedCount=0 and exactly one line that begins
      "COVERAGE file=" and carries a numeric LinePercent value. Stop condition: if no numeric
      LinePercent is printed, stop and report that the Pester coverage reader needs revision.
- [ ] [P0-T13] Record pre-change line counts with CMD-PS-SCRIPT script line-counts over these existing
      files: `scripts/dev_tools/compute_blast_radius.py`, `scripts/dev_tools/_blast_radius_validation.py`,
      `scripts/dev_tools/parallel_drift_detection.py`, `.claude/lib/blast-radius/BlastRadius.psm1`,
      `.claude/lib/blast-radius/BlastRadiusValidation.psm1`,
      `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`,
      `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts`,
      `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts`,
      `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`,
      `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, and
      `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`. Write
      FEATURE/evidence/baseline/line-counts.TS.md. Acceptance: exit 0 and one LineCount line per file.
      Planning-time values (re-derived by line count on 2026-09-27): 421, 464, 499, 438, 374, 380, 472,
      149, 237, 257, 271. Record the printed values; they, not the planning values, are the baseline.
- [ ] [P0-T14] Record mirror-pair hashes with CMD-PS-SCRIPT script file-hashes for each primary file
      and its bundled mirror: the BlastRadius and BlastRadiusValidation modules, the Pester
      runsettings pair (scripts tree and extension resources tree), the parallel-orchestration rule
      file, the parallel-plan skill, the parallel-add skill, and the parallel-planner agent. Write
      FEATURE/evidence/baseline/mirror-hashes.TS.md. Acceptance: exit 0; the artifact states for each
      of the seven pairs whether the two hashes are equal. The mirror rule in the Preamble applies per
      pair from this record.
- [ ] [P0-T15] Python format baseline: run CMD-PY-BLACK-CHECK with the path ".". Write
      FEATURE/evidence/baseline/python-black-check.TS.md. Acceptance: artifact records the exit code
      and the count of files that would be reformatted (baseline only; no value is required).
- [ ] [P0-T16] Python lint baseline: run CMD-PY-RUFF with ".". Write
      FEATURE/evidence/baseline/python-ruff.TS.md. Acceptance: artifact records the exit code and the
      finding count.
- [ ] [P0-T17] Python type baseline: run CMD-PY-PYRIGHT with no path. Write
      FEATURE/evidence/baseline/python-pyright.TS.md. Acceptance: artifact records the exit code and
      the printed error count.
- [ ] [P0-T18] Python coverage baseline: run CMD-PY-COV with label baseline, then CMD-PY-SCRIPT with
      script py-cov-files (A7) and arguments SCRATCH/coverage-722-baseline.json followed by the three
      existing Python production files named in P0-T13. Write
      FEATURE/evidence/baseline/python-pytest-coverage.TS.md. Acceptance: the Output Summary records
      the passed, failed, and skipped counts, the TOTAL line percentage printed by the terminal table,
      the complete list of FAILED node IDs (the baseline failure set, possibly empty), and one
      LinePercent and BranchPercent value for each of the three files.
- [ ] [P0-T19] PowerShell format and lint baseline: run CMD-PS-SCRIPT with script ps-format-check (A6)
      over `.claude/lib/blast-radius/BlastRadius.psm1`, `.claude/lib/blast-radius/BlastRadiusValidation.psm1`,
      and `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`, then call
      MCP-PS-ANALYZE over the same three paths. Write FEATURE/evidence/baseline/powershell-format-analyze.TS.md.
      Acceptance: the artifact records the FORMAT-SUMMARY ChangedCount value and whether the analyze
      call returned or raised (with any error text). No tracked file is modified by this task
      (CMD-GIT-STATUS output is unchanged from P0-T11).
- [ ] [P0-T20] #452 detection gate, fixture detection (pre-authorized on this branch): run
      CMD-GIT-452-BRANCH and CMD-GIT-452-MAIN. Write FEATURE/evidence/baseline/452-fixture-inventory.TS.md.
      Acceptance: both commands exit 0; the artifact lists the branch-tree fixtures, the origin/main
      fixtures, and the set difference (fixtures on origin/main that are not on this branch). The five
      fixtures found at planning time are conflict-directory-vs-glob, conflict-directory-vs-file,
      conflict-sibling-prefix-disjoint, derivation-root-surface-reached, and
      derivation-root-surface-not-configured; any additional fixture is recorded as sibling-added.
- [ ] [P0-T21] #452 detection gate, Python driver (pre-authorized on this branch; runs the fixtures
      unmodified): run CMD-PY-TEST with exactly the ten node IDs of block B1 in Appendix B. Write
      FEATURE/evidence/baseline/452-gate-python.TS.md. Acceptance: exit 0 and ten PASSED lines, one per
      listed node ID. If P0-T20 found a sibling-added fixture on this branch, add its verdict/reasons
      or radius/findings node IDs to the run and record them.
- [ ] [P0-T22] #452 detection gate, PowerShell driver (pre-authorized on this branch; runs the
      fixtures unmodified): run CMD-PS-SCRIPT with script pester-counts (A2) once per fixture name in
      P0-T20's branch list, with -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
      and -FullNameFilter set to the fixture name wrapped in asterisks. Write
      FEATURE/evidence/baseline/452-gate-powershell.TS.md. Acceptance: every run prints PassedCount=2
      and FailedCount=0 (two parity cases per fixture: verdict and reasons, or radius and findings).
- [ ] [P0-T23] Historical-run fetch: for each slug of epic-655-followups, backlog-2026-09-26, and
      followups-2026-09-27, run CMD-GIT-FETCH-RUN and CMD-GIT-MANIFEST-BLOB. Write
      FEATURE/evidence/baseline/historical-refs.TS.md. Acceptance: all six commands exit 0; the
      artifact records the ref name and manifest blob SHA of each run. Stop condition: if a ref cannot
      be fetched, stop and report; no historical value may be assumed.
- [ ] [P0-T24] Historical radii extraction: for each slug, run CMD-PY-SCRIPT with script
      historical-extract (contract C1 in Appendix A) to read the manifest verbatim with git show and
      write the recorded radii, per-item complexity band, and band source into
      FEATURE/evidence/other/historical-<slug>-radii.TS.json. Write
      FEATURE/evidence/baseline/historical-extract.TS.md containing the full script text, the three
      commands, and per run the item count and the band source of each item. Acceptance: exit 0 per
      run; each JSON file lists every manifest item with its radius copied without modification.
- [ ] [P0-T25] Historical BEFORE edges, Python runtime: for each slug run CMD-PY-SCRIPT with script
      historical-edges (contract C2) in before mode over the radii JSON of P0-T24 and the current
      self-hosted config, writing FEATURE/evidence/other/historical-<slug>-before-python.TS.json.
      Acceptance: exit 0 per run; each output lists the edge member set with reasons, the edge count,
      the cohort partition from the Python cohort-coloring function, the cohort count, and the maximum
      cohort width.
- [ ] [P0-T26] Historical BEFORE edges, PowerShell runtime: for each slug run CMD-PS-SCRIPT with script
      historical-edges (contract C3) over the same radii JSON and config, writing
      FEATURE/evidence/other/historical-<slug>-before-powershell.TS.json. Acceptance: exit 0 per run;
      each output lists the edge member set with reasons and the edge count.
- [ ] [P0-T27] Historical BEFORE comparison: for each slug run CMD-PY-SCRIPT with script
      historical-compare (contract C4) over the two outputs of P0-T25 and P0-T26. Write
      FEATURE/evidence/baseline/historical-before-rederivation.TS.md containing the commit (HEAD and
      BASE_SHA), every command, the script texts of C2 through C4, both member sets per run, the
      comparison verdict per run, and per run the BEFORE edge count, cohort partition, cohort count,
      and maximum cohort width. PowerShell has no cohort-coloring function; the PowerShell column's
      partition is computed by applying the Python cohort-coloring function to the PowerShell edge set,
      and the artifact states this. Acceptance: every run prints MATCH. Stop condition: a MISMATCH
      stops the plan; no value is pinned into a fixture until both runtimes agree.
- [ ] [P0-T28] Record path_roots and append_only_paths inputs: run CMD-GIT-TOPDIRS and
      CMD-GIT-CHANGELOGS and confirm `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
      is tracked with CMD-GIT-TRACKED. Write FEATURE/evidence/baseline/config-value-inputs.TS.md.
      Acceptance: all commands exit 0; the artifact records the ordinally sorted top-level directory
      list (this becomes the self-hosted path_roots value in P9-T3) and the tracked changelog paths.
      Decision recorded in the artifact: append_only_paths is exactly the two entries of block B2 in
      Appendix B (the double-star changelog glob and the pack manifest registry). The list is not empty
      because the repository tracks at least one changelog and one append-only registry.
- [ ] [P0-T29] [expect-fail] Fail-before evidence for the zero-tolerance defect: run CMD-PY-SCRIPT with
      script failbefore-demo (contract C5) in scheduling mode. Write
      FEATURE/evidence/regression-testing/failbefore-zero-tolerance.TS.md with ExpectedExitCode: 1.
      Acceptance: the script exits 1 and prints that the two append-only radii of block B3 in Appendix B
      are a conflict edge under the current hand rule, which the fix must tolerate at the committed
      tolerance.
- [ ] [P0-T30] [expect-fail] Fail-before evidence for the over-reporting defect: run CMD-PY-SCRIPT with
      script failbefore-demo in extraction mode. Write
      FEATURE/evidence/regression-testing/failbefore-over-reporting.TS.md with ExpectedExitCode: 1.
      Acceptance: the script exits 1 and prints that the current derivation of the plan text in block
      B4 of Appendix B returns the glob token, the command-span token, and the read-task token as
      radius paths.
- [ ] [P0-T31] TypeScript baseline: run CMD-TS-CI, then CMD-TS-PRETTIER-CHECK over the four existing
      TypeScript files named in P0-T13, then CMD-TS-LINT, CMD-TS-TYPECHECK, and CMD-TS-COV. Write one
      artifact per command: FEATURE/evidence/baseline/ts-npm-ci.TS.md, ts-prettier-check.TS.md,
      ts-eslint.TS.md, ts-typecheck.TS.md, and ts-jest-coverage.TS.md, all under
      FEATURE/evidence/baseline. Acceptance: every artifact records its exit code; the coverage
      artifact records the Test Suites and Tests summary lines and the % Lines and % Branch values of
      the claude-blast-radius-derive-core.ts row.
- [ ] [P0-T32] PowerShell test and coverage baseline: run CMD-PS-SCRIPT with script pester-coverage,
      -TestPath tests/scripts/claude-lib/blast-radius, -CoveragePath set to the two existing modules
      named in P0-T19, and -CoverageOutputPath SCRATCH/pester-baseline.xml. Write
      FEATURE/evidence/baseline/powershell-pester-coverage.TS.md. Acceptance: the artifact records
      TotalCount, PassedCount, FailedCount, every FAILED line (the baseline failure set), and one
      numeric LinePercent per module.
- [ ] [P0-T33] Commit and push Phase 0 evidence: stage the FEATURE evidence directory with
      CMD-GIT-ADD, commit with message "chore(722): record phase 0 baselines and historical BEFORE
      evidence", and run CMD-GIT-PUSH. Acceptance: all three commands exit 0 and CMD-GIT-STATUS-PATH
      over the FEATURE folder prints nothing.

### Phase 1 — Part A: Python Scheduling Module and Scheduling Fixtures

- [ ] [P1-T1] Reset the Python batch budget: run CMD-PS-SCRIPT with script reset-batch-budget (A8)
      and argument -Kind python. Write FEATURE/evidence/other/batch-budget-reset-p1.TS.md. Acceptance:
      exit 0; the artifact lists the removed state files (possibly none).
- [ ] [P1-T2] Create `tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json`
      exactly as specified in block B5 of Appendix B. Acceptance: the file parses as JSON and carries
      the items, embedded radii, and three cases of B5.
- [ ] [P1-T3] Create `tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json`
      as specified in block B6. Acceptance: parses as JSON; three items, three cases.
- [ ] [P1-T4] Create `tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json`
      as specified in block B7. Acceptance: parses as JSON; four items, three cases, no expected edge
      and no expected tolerated overlap in any case.
- [ ] [P1-T5] Create `tests/fixtures/blast_radius/scheduling/scheduling-soft-pair-tolerated.json` as
      specified in block B8. Acceptance: parses as JSON; four items, three cases.
- [ ] [P1-T6] Create `tests/fixtures/blast_radius/scheduling/scheduling-absent-key-strict.json` as
      specified in block B9. Acceptance: parses as JSON; the embedded config has no conflict_tolerance
      key.
- [ ] [P1-T7] Write `tests/scripts/dev_tools/test_blast_radius_scheduling.py` containing exactly the
      test functions of block B10 in Appendix B, following Arrange-Act-Assert, with docstrings, reading
      only the fixture files of P1-T2 through P1-T6 and the top-level conflict fixtures of the existing
      corpus. Acceptance: the file exists and is at most 500 lines.
- [ ] [P1-T8] Write `tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py` containing the
      four hypothesis properties of block B11. Acceptance: the file exists and is at most 500 lines.
- [ ] [P1-T9] [expect-fail] Run CMD-PY-TEST over the two test files of P1-T7 and P1-T8 before the
      production module exists. Write FEATURE/evidence/regression-testing/scheduling-tests-fail-before.TS.md
      with ExpectedExitCode: 2. Acceptance: pytest exits 2 with a collection error naming the missing
      scheduling module.
- [ ] [P1-T10] Create `scripts/dev_tools/_blast_radius_scheduling.py` implementing block B12 of
      Appendix B: the ConflictTolerance value object, the strict conflict_tolerance reader, the
      per-pair decision, the cost and benefit helpers, and the scheduling entry point, with the
      mandatory docstrings and intent comments. The module calls the unchanged conflicts function and
      reuses the entry-overlap primitive, the mergeable exclusion, and the mergeable matcher; it defines
      no new overlap semantics. Acceptance: the file exists, is at most 500 lines, and imports no
      module that imports it.
- [ ] [P1-T11] Edit `scripts/dev_tools/compute_blast_radius.py` to import and re-export the public
      names of block B12 (added to the module's public name list). No other change. Acceptance: the
      file is at most 500 lines and its conflicts re-export is unchanged.
- [ ] [P1-T12] Run CMD-PY-TEST over the two test files of P1-T7 and P1-T8. Write
      FEATURE/evidence/regression-testing/scheduling-tests-pass.TS.md. Acceptance: exit 0; the verbose
      output shows a PASSED line for every test name of B10 and B11 (parametrized cases included) and
      no FAILED or ERROR line.
- [ ] [P1-T13] Run CMD-PY-TEST-K with expression blast_radius to run the existing blast-radius Python
      tests. Write FEATURE/evidence/regression-testing/blast-radius-python-regression-p1.TS.md.
      Acceptance: every FAILED node ID printed is a member of the P0-T18 baseline failure set.
- [ ] [P1-T14] Run CMD-PY-BLACK, then CMD-PY-BLACK-CHECK, CMD-PY-RUFF, and CMD-PY-PYRIGHT, each over the
      four Python files written in this phase. Write FEATURE/evidence/qa-gates/phase1-python-static.TS.md.
      Acceptance: black check mode exits 0 and prints a line ending "would be left unchanged."; ruff
      exits 0 with "All checks passed!"; pyright exits 0 with "0 errors". If the write-mode black run
      reformatted a file, re-run P1-T12 before continuing.
- [ ] [P1-T15] Commit and push Phase 1: CMD-GIT-ADD with the five fixture files, the two test files,
      the two production files of this phase, and the FEATURE evidence directory; CMD-GIT-COMMIT with
      message "feat(722): add integration-cost scheduling layer (Python)"; CMD-GIT-PUSH. Acceptance: all
      exit 0 and CMD-GIT-STATUS prints nothing for the staged paths.

### Phase 2 — Part A: Drift Helper and Tolerated-Field Validator Tests

- [ ] [P2-T1] Reset the Python batch budget (A8, -Kind python). Write
      FEATURE/evidence/other/batch-budget-reset-p2.TS.md. Acceptance: exit 0.
- [ ] [P2-T2] Write `tests/scripts/dev_tools/test_parallel_drift_scheduling.py` with exactly the tests
      of block B13 in Appendix B. Acceptance: the file exists and is at most 500 lines.
- [ ] [P2-T3] Write `tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py`
      with exactly the tests of block B14. Acceptance: the file exists and is at most 500 lines.
- [ ] [P2-T4] [expect-fail] Run CMD-PY-TEST over the P2-T2 file before the helper module exists. Write
      FEATURE/evidence/regression-testing/drift-tests-fail-before.TS.md with ExpectedExitCode: 2.
      Acceptance: pytest exits 2 with a collection error naming the missing drift helper module.
- [ ] [P2-T5] Create `scripts/dev_tools/_parallel_drift_scheduling.py` per block B15: relocate the
      existing-edge-pair collection and the observed-versus-peer decision out of the drift module, and
      make the decision call the P1-T10 per-pair decision with the drifting item's and the peer's
      complexity bands (default_band when absent). The fail-closed rule is preserved: an unevaluable
      peer radius counts as an edge. Acceptance: the file exists and is at most 500 lines.
- [ ] [P2-T6] Edit `scripts/dev_tools/parallel_drift_detection.py`: delete the two relocated private
      helpers, import their replacements from the P2-T5 module, and pass the items collection so bands
      can be read. The public signature of recompute_conflicts_with_observed is unchanged. Acceptance:
      its line count, measured with script line-counts, is less than or equal to the P0-T13 value.
- [ ] [P2-T7] Run CMD-PY-TEST over the P2-T2 and P2-T3 files, then CMD-PY-TEST-K with expression
      parallel_drift_detection. Write FEATURE/evidence/regression-testing/drift-and-validator-tests.TS.md.
      Acceptance: the first run exits 0 with a PASSED line for every B13 and B14 test; every FAILED node
      of the second run is in the P0-T18 baseline failure set.
- [ ] [P2-T8] Confirm the existing drift tests are unmodified: run CMD-GIT-DIFF-NAMES with pathspec
      tests/scripts/dev_tools and CMD-GIT-STATUS-PATH with the same pathspec. Write
      FEATURE/evidence/qa-gates/drift-tests-unmodified.TS.md. Acceptance: no listed path contains the
      text test_parallel_drift_detection.
- [ ] [P2-T9] Run CMD-PY-BLACK, CMD-PY-BLACK-CHECK, CMD-PY-RUFF, and CMD-PY-PYRIGHT over the four
      Python files of this phase. Write FEATURE/evidence/qa-gates/phase2-python-static.TS.md.
      Acceptance: as in P1-T14.
- [ ] [P2-T10] Commit and push Phase 2 (the four files and the FEATURE evidence directory; message
      "feat(722): evaluate drift pairs through the scheduling rule"). Acceptance: all three git commands
      exit 0.

### Phase 3 — Part A: conflict_tolerance Configuration, Python Key Partition, Historical BEFORE Pins

- [ ] [P3-T1] Reset the Python batch budget (A8, -Kind python). Write
      FEATURE/evidence/other/batch-budget-reset-p3.TS.md. Acceptance: exit 0.
- [ ] [P3-T2] Edit `config/blast-radius.json`: insert the conflict_tolerance member of block B2 in
      Appendix B immediately after mergeable_paths. Acceptance: the file parses as JSON and the member
      equals B2.
- [ ] [P3-T3] Edit `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`:
      insert the identical member at the same position. Acceptance: the member value is equal to the
      value in `config/blast-radius.json`.
- [ ] [P3-T4] Edit `tests/scripts/dev_tools/blast_radius_parity_test_support.py`: append the key name
      conflict_tolerance to the byte-equal key tuple and extend its comment with the reason (the key
      describes the runtime, not a repository layout). Acceptance: the file is at most 500 lines.
- [ ] [P3-T5] Write `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` with the Part A
      tests of block B16. Acceptance: the file exists and is at most 500 lines.
- [ ] [P3-T6] Create `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json` by running
      CMD-PY-SCRIPT with script historical-fixture (contract C6) in before mode over the committed P0
      evidence JSON for that run. Acceptance: the file carries the fields of block B17 with the BEFORE
      section only, and its BEFORE values equal the P0-T27 artifact values for the run.
- [ ] [P3-T7] Create `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json` the same way.
      Acceptance: as in P3-T6 for that run.
- [ ] [P3-T8] Create `tests/fixtures/blast_radius/historical-runs/epic-655-followups.json` the same way.
      Acceptance: as in P3-T6 for that run.
- [ ] [P3-T9] Write `tests/scripts/dev_tools/test_blast_radius_historical_runs.py` with the BEFORE tests
      of block B18. The file must not contain the substrings origin/ or artifacts/. Acceptance: the file
      exists and is at most 500 lines.
- [ ] [P3-T10] Run CMD-PY-TEST over the P3-T5 and P3-T9 files and over the first two node IDs of block
      B19. Write FEATURE/evidence/regression-testing/config-and-historical-before.TS.md. Acceptance:
      exit 0; PASSED lines for every B16 Part A test, every B18 BEFORE test for all three runs, and the
      two B19 nodes (the byte-equal case for conflict_tolerance and the exhaustiveness case).
- [ ] [P3-T11] Run CMD-PY-BLACK, CMD-PY-BLACK-CHECK, CMD-PY-RUFF, and CMD-PY-PYRIGHT over the three
      Python files of this phase. Write FEATURE/evidence/qa-gates/phase3-python-static.TS.md.
      Acceptance: as in P1-T14.
- [ ] [P3-T12] Commit and push Phase 3 (both config copies, the three Python files, the three fixture
      files, and the FEATURE evidence directory; message "feat(722): add conflict_tolerance and pin
      historical BEFORE values"). Acceptance: all three git commands exit 0. The TypeScript carriage
      helper and the PowerShell key-partition test are updated in Phases 4 and 5; their suites are not
      gated until then.

### Phase 4 — Part A: TypeScript Carriage of conflict_tolerance and Validator Tolerance Tests

- [ ] [P4-T1] Edit `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`:
      append conflict_tolerance to the carried-key list and add it to the emitted document literal
      after mergeable_paths and before modules; update the emission-order documentation comment.
      Acceptance: the file is at most 500 lines.
- [ ] [P4-T2] Edit `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` so its
      source truth-table constant equals the bundled config file of P3-T3. Acceptance: the file is at
      most 500 lines.
- [ ] [P4-T3] Edit `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts`: update the
      emitted key-order expectation to the order of block B20 (Part A form). Acceptance: the file is at
      most 500 lines.
- [ ] [P4-T4] Edit `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts`:
      update its key-order expectations the same way. Acceptance: the file is at most 500 lines.
- [ ] [P4-T5] Create `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts`
      with the conflict_tolerance cases of block B21. Acceptance: the file exists and is at most 500
      lines.
- [ ] [P4-T6] Create `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts`
      with the cases of block B22. Acceptance: the file exists and is at most 500 lines.
- [ ] [P4-T7] Run CMD-TS-TEST with the five test files of P4-T3 through P4-T6 and the carriage test
      claude-config-carriage.test.ts under test/lib/push-down. Write
      FEATURE/evidence/regression-testing/ts-part-a-tests.TS.md. Acceptance: exit 0 and the Tests
      summary line reports 0 failed.
- [ ] [P4-T8] Run CMD-TS-FORMAT, then CMD-TS-PRETTIER-CHECK over the six TypeScript files of this
      phase, then CMD-TS-LINT and CMD-TS-TYPECHECK. Write FEATURE/evidence/qa-gates/phase4-ts-static.TS.md.
      Acceptance: the Prettier check exits 0 and prints "All matched files use Prettier code style!";
      lint and typecheck exit 0. If the format run changed any file (compare CMD-GIT-STATUS-PATH over
      extensions/drm-copilot before and after the format run), re-run P4-T7.
- [ ] [P4-T9] Commit and push Phase 4 (the six TypeScript files and the FEATURE evidence directory;
      message "feat(722): carry conflict_tolerance through the push-down"). Acceptance: all three git
      commands exit 0.

### Phase 5 — Part A: PowerShell Scheduling Module, Registration, and Pester Tests

- [ ] [P5-T1] Reset the PowerShell batch budget (A8, -Kind powershell). Write
      FEATURE/evidence/other/batch-budget-reset-p5.TS.md. Acceptance: exit 0.
- [ ] [P5-T2] Write `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1` with the
      Describe, Context, and It blocks of block B23, driving the P1 fixtures. Acceptance: the file
      exists and is at most 500 lines.
- [ ] [P5-T3] Write `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1` with
      the BEFORE It blocks of block B24. The file must not contain the substrings origin/ or artifacts/.
      Acceptance: the file exists and is at most 500 lines.
- [ ] [P5-T4] Edit `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`: add
      conflict_tolerance to the Class 1 key list. Acceptance: the file is at most 500 lines.
- [ ] [P5-T5] Create `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` implementing block B25: the
      strict config reader, the per-pair decision helper, and Get-BlastRadiusConflictEdge, with
      comment-based help. It imports its own dependencies as the sibling modules do and resolves
      Test-BlastRadiusConflict at call time through Get-Command, failing fast with an error that names
      the facade module when the command is unavailable. Acceptance: the file is at most 500 lines.
- [ ] [P5-T6] Edit `.claude/lib/blast-radius/BlastRadius.psm1`: import the scheduling module next to
      the other sibling imports and add Get-BlastRadiusConflictEdge and Get-BlastRadiusPairDecision to
      the exported function list. The Test-BlastRadiusConflict function body is not edited. Acceptance:
      the file is at most 500 lines.
- [ ] [P5-T7] Edit `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: add the scheduling
      module to the blast-radius coverage path group. Acceptance: the file parses with
      Import-PowerShellDataFile.
- [ ] [P5-T8] Produce the mirrors per the Preamble rule: copy the P5-T5 module to
      `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1`,
      the P5-T6 facade to
      `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1`,
      and the P5-T7 runsettings to
      `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. Then run
      script file-hashes over the three pairs. Write FEATURE/evidence/qa-gates/mirrors-p5.TS.md.
      Acceptance: each pair's two hashes are equal.
- [ ] [P5-T9] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`:
      list the scheduling module next to the other blast-radius module entries. Acceptance: the file
      parses as JSON.
- [ ] [P5-T10] Run CMD-PS-SCRIPT with script pester-coverage, -TestPath set to the P5-T2 file, the P5-T3
      file, and the P5-T4 file (one run per file), -CoveragePath set to the P5-T5 module, and a
      SCRATCH coverage output path. Write FEATURE/evidence/regression-testing/pester-part-a.TS.md.
      Acceptance: every run prints FailedCount=0; the P5-T2 run prints a PassedCount equal to its
      TotalCount and one It name per B23 entry; the COVERAGE line for the scheduling module is recorded.
- [ ] [P5-T11] Run the existing blast-radius Pester directory with script pester-counts (A2) and -Path
      tests/scripts/claude-lib/blast-radius. Write
      FEATURE/evidence/regression-testing/pester-directory-p5.TS.md. Acceptance: every FAILED name is in
      the P0-T32 baseline failure set.
- [ ] [P5-T12] Format and lint: record hashes of the six PowerShell files of this phase (A5), call
      MCP-PS-FORMAT over them, record hashes again, run script ps-format-check (A6) over them, and call
      MCP-PS-ANALYZE over them. Write FEATURE/evidence/qa-gates/phase5-powershell-static.TS.md.
      Acceptance: the format call returns without raising; A6 prints FORMAT-SUMMARY ChangedCount=0; the
      analyze call returns without raising. If any hash changed, re-copy the affected mirror (P5-T8) and
      re-run P5-T10 before continuing.
- [ ] [P5-T13] Commit and push Phase 5 (the six primary PowerShell files, the three mirrors, the pack
      manifest, and the FEATURE evidence directory; message "feat(722): add PowerShell scheduling
      layer"). Acceptance: all three git commands exit 0.

### Phase 6 — Part A: Documentation (Scheduling Sections)

- [ ] [P6-T1] Edit `.claude/rules/parallel-orchestration.md`: add an "Integration-cost scheduling"
      subsection under the contention doctrine with the edge rule, the cost terms and append-only
      precedence, the pairwise benefit, the strict-identity proof (every weight and band duration is an
      integer of at least 1, so tolerance 0 reproduces the detected-conflict set and every edge implies
      a conflict), the hard classes, the statement that this is an operator-directed configured policy
      change and planners still never hand-narrow a radius, soft-overlap handling (tolerated pairs run
      in the same or adjacent cohorts without a barrier; the later-merging item merges origin/main under
      the existing per-item merge-conflict handling and re-passes CI), and the drift behaviour. In the
      Enum Ownership section record that no reason member is added and that hard, cost, benefit, and the
      tolerated_overlaps list are tolerated-not-validated fields. In the issue #500 section add
      conflict_tolerance to the byte-equal key list. Acceptance: each of the literal headings or tokens
      quoted in block B26 appears in the file.
- [ ] [P6-T2] Copy the P6-T1 file to
      `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`.
      Acceptance: the two hashes are equal (A5).
- [ ] [P6-T3] Edit `.claude/skills/parallel-plan/SKILL.md`: replace the hand pair loop in the conflict
      edge step with a call to the scheduling entry point (Python) or Get-BlastRadiusConflictEdge
      (PowerShell), record the returned tolerated overlaps in a tolerated_overlaps list on the planner
      checkpoint, and state the soft-overlap merge rule of P6-T1. Acceptance: the file contains the
      token Get-BlastRadiusConflictEdge and the token tolerated_overlaps.
- [ ] [P6-T4] Copy the P6-T3 file to
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`.
      Acceptance: hashes equal.
- [ ] [P6-T5] Edit `.claude/skills/parallel-add/SKILL.md` the same way for admission, and amend its
      statement that no field is added to conflict_edges so that it names the three tolerated extra
      fields and states that no reason member is added. Acceptance: the file contains the tokens
      Get-BlastRadiusConflictEdge and tolerated_overlaps.
- [ ] [P6-T6] Copy the P6-T5 file to
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`.
      Acceptance: hashes equal.
- [ ] [P6-T7] Edit `.claude/agents/parallel-planner.md` to name Get-BlastRadiusConflictEdge alongside
      the existing library functions and to require recording tolerated overlaps. Acceptance: the file
      contains the token Get-BlastRadiusConflictEdge.
- [ ] [P6-T8] Copy the P6-T7 file to
      `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`.
      Acceptance: hashes equal.
- [ ] [P6-T9] Run the two node IDs of block B27 with CMD-PY-TEST (the bundled-payload contract tests).
      Write FEATURE/evidence/regression-testing/mirror-contract-p6.TS.md. Acceptance: exit 0, two PASSED
      lines.
- [ ] [P6-T10] Commit and push Phase 6 (the eight Markdown files and the FEATURE evidence directory;
      message "docs(722): document integration-cost scheduling"). Acceptance: all three git commands
      exit 0.

### Phase 7 — Part A: Verification Gate

- [ ] [P7-T1] Strict identity and #452 cases, Python: run CMD-PY-TEST over the node IDs of block B28.
      Write FEATURE/evidence/qa-gates/part-a-strict-identity-python.TS.md. Acceptance: exit 0 and a
      PASSED line for every listed node.
- [ ] [P7-T2] Strict identity and #452 cases, PowerShell: run script pester-counts over the P5-T2 file
      with -FullNameFilter values from block B29, one run each. Write
      FEATURE/evidence/qa-gates/part-a-strict-identity-powershell.TS.md. Acceptance: every run prints
      FailedCount=0 and a PassedCount of at least 1.
- [ ] [P7-T3] Detection relation unchanged: run CMD-GIT-DIFF-NAMES with the detection-module pathspec
      of block B30 and CMD-GIT-STATUS-PATH with the same pathspec, then run script function-body-equal
      (A9) for Test-BlastRadiusConflict in the facade against BASE_SHA. Write
      FEATURE/evidence/qa-gates/detection-unchanged-part-a.TS.md. Acceptance: both git commands print
      nothing; A9 prints BODY-EQUAL=True.
- [ ] [P7-T4] Re-run the #452 gate commands of P0-T21 and P0-T22 unmodified. Write
      FEATURE/evidence/qa-gates/452-gate-part-a.TS.md. Acceptance: the same pass counts as P0-T21 and
      P0-T22.
- [ ] [P7-T5] Line counts: run script line-counts over every Python, PowerShell, and TypeScript file
      written in Phases 1 through 5. Write FEATURE/evidence/qa-gates/line-counts-part-a.TS.md.
      Acceptance: every value is at most 500 and the drift module value is at most its P0-T13 value.
- [ ] [P7-T6] Commit and push Phase 7 evidence (FEATURE evidence directory; message "test(722): record
      Part A verification gate"). Acceptance: all three git commands exit 0.

### Phase 8 — Part B: Python Write-Intent Module and Flag Branches

- [ ] [P8-T1] Reset the Python batch budget (A8, -Kind python). Write
      FEATURE/evidence/other/batch-budget-reset-p8.TS.md. Acceptance: exit 0.
- [ ] [P8-T2] Create the eight write-intent fixtures exactly as specified in block B31 of Appendix B:
      `tests/fixtures/blast_radius/write-intent/write-intent-glob-mention.json`,
      `tests/fixtures/blast_radius/write-intent/write-intent-command-span.json`,
      `tests/fixtures/blast_radius/write-intent/write-intent-read-task.json`,
      `tests/fixtures/blast_radius/write-intent/write-intent-root-anchoring.json`,
      `tests/fixtures/blast_radius/write-intent/write-intent-spec-contracts-only.json`,
      `tests/fixtures/blast_radius/write-intent/write-intent-placeholder-stem.json`,
      `tests/fixtures/blast_radius/write-intent/write-intent-shared-surface-read-citation.json`, and
      `tests/fixtures/blast_radius/write-intent/write-intent-flag-absent-matches-current.json`.
      Acceptance: all eight parse as JSON and carry the inputs and expected values of B31.
- [ ] [P8-T3] Write `tests/scripts/dev_tools/test_blast_radius_write_intent.py` with exactly the tests
      of block B32. Acceptance: the file exists and is at most 500 lines.
- [ ] [P8-T4] [expect-fail] Run CMD-PY-TEST over the P8-T3 file before the module exists. Write
      FEATURE/evidence/regression-testing/write-intent-tests-fail-before.TS.md with ExpectedExitCode: 2.
      Acceptance: pytest exits 2 with a collection error naming the missing write-intent module.
- [ ] [P8-T5] Create `scripts/dev_tools/_blast_radius_write_intent.py` implementing block B33: rules W1
      through W6, the read-verb, write-verb, and placeholder-stem constants, the strict readers for
      write_intent_extraction and path_roots, the token-level entry filter, and the single extractor
      selector used by derivation and validation. Acceptance: the file exists and is at most 500 lines.
- [ ] [P8-T6] Edit `scripts/dev_tools/compute_blast_radius.py`: in derivation, when the flag is true,
      take plan paths from the selector, take no paths from the spec, and take contracts from the
      write-intent spec-contract function; in normalization, when the flag is true, apply the token-level
      entry filter before the mandate-read filter. When the flag is absent or false, both functions
      execute exactly the current statements. Acceptance: the file is at most 500 lines.
- [ ] [P8-T7] Edit `scripts/dev_tools/_blast_radius_validation.py`: replace the plan-side extraction
      call used by V1 and V2 with the selector of P8-T5. Acceptance: the file is at most 500 lines. Stop
      condition: if the edit would exceed 500 lines, move the remaining selection logic into the P8-T5
      module instead and record the relocation in the P8-T8 artifact.
- [ ] [P8-T8] Run CMD-PY-TEST over the P8-T3 file, then CMD-PY-TEST-K with expression blast_radius.
      Write FEATURE/evidence/regression-testing/write-intent-python.TS.md. Acceptance: the first run
      exits 0 with a PASSED line for every B32 test; every FAILED node of the second run is in the P0-T18
      baseline failure set.
- [ ] [P8-T9] Run CMD-PY-BLACK, CMD-PY-BLACK-CHECK, CMD-PY-RUFF, and CMD-PY-PYRIGHT over the four Python
      files of this phase. Write FEATURE/evidence/qa-gates/phase8-python-static.TS.md. Acceptance: as in
      P1-T14.
- [ ] [P8-T10] Commit and push Phase 8 (the eight fixtures, the four Python files, and the FEATURE
      evidence directory; message "feat(722): add write-intent extraction (Python)"). Acceptance: all
      three git commands exit 0.

### Phase 9 — Part B: Configuration Keys, Mandate Amendment, Python Key Partition

- [ ] [P9-T1] Reset the Python batch budget (A8, -Kind python). Write
      FEATURE/evidence/other/batch-budget-reset-p9.TS.md. Acceptance: exit 0.
- [ ] [P9-T2] Edit `config/blast-radius.json`: append the Copilot instructions file under .github to
      mandate_reads, and insert write_intent_extraction with value true followed by path_roots
      immediately after conflict_tolerance. Acceptance: the file parses as JSON.
- [ ] [P9-T3] In the same file, set path_roots to the ordinally sorted directory list recorded by
      P0-T28. Acceptance: the value equals the P0-T28 list exactly.
- [ ] [P9-T4] Edit `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`:
      the same mandate_reads amendment, write_intent_extraction true, and path_roots as an empty list.
      Acceptance: mandate_reads and write_intent_extraction are equal between the two copies; the
      bundled path_roots is an empty list.
- [ ] [P9-T5] Edit `tests/scripts/dev_tools/blast_radius_parity_test_support.py`: append
      write_intent_extraction to the byte-equal key tuple; add a separate Class 2 registry named
      CLASS_TWO_TOLERANCE_KEY_ASSERTIONS mapping path_roots to the test name
      test_class_two_bundled_path_roots_are_empty; include that registry's keys in the declared
      top-level key set. The existing Class 2 registry is not changed, so the registry-consumption test
      in the config-parity module is unaffected. Acceptance: the file is at most 500 lines.
- [ ] [P9-T6] Edit `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`: add the Part B
      tests of block B16, including test_class_two_bundled_path_roots_are_empty and a consumption check
      of the new registry against this module's own namespace. Acceptance: the file is at most 500 lines.
- [ ] [P9-T7] Run CMD-PY-TEST over the P9-T6 file and over all three node IDs of block B19 (the third
      is the Part B byte-equal case). Write FEATURE/evidence/regression-testing/config-part-b.TS.md.
      Acceptance: exit 0 and a PASSED line for every listed test.
- [ ] [P9-T8] Run CMD-PY-COV with label p9. Write FEATURE/evidence/regression-testing/python-full-p9.TS.md.
      Acceptance: every FAILED node ID is in the P0-T18 baseline failure set. Stop condition: if any
      other pre-existing test fails because the committed config now enables write-intent extraction,
      stop and report the node ID; do not edit that test.
- [ ] [P9-T9] Run CMD-PY-BLACK, CMD-PY-BLACK-CHECK, CMD-PY-RUFF, and CMD-PY-PYRIGHT over the two Python
      files of this phase. Write FEATURE/evidence/qa-gates/phase9-python-static.TS.md. Acceptance: as in
      P1-T14.
- [ ] [P9-T10] Commit and push Phase 9 (both config copies, the two Python files, and the FEATURE
      evidence directory; message "feat(722): enable write-intent extraction and path_roots").
      Acceptance: all three git commands exit 0.

### Phase 10 — Part B: PowerShell Write-Intent Module, Flag Branches, Registration

- [ ] [P10-T1] Reset the PowerShell batch budget (A8, -Kind powershell). Write
      FEATURE/evidence/other/batch-budget-reset-p10a.TS.md. Acceptance: exit 0.
- [ ] [P10-T2] Write `tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1` with the
      It blocks of block B34, driving the P8-T2 fixtures. Acceptance: the file exists and is at most 500
      lines.
- [ ] [P10-T3] Edit `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`: add
      write_intent_extraction to the Class 1 list, add path_roots to the Class 2 consumer registry mapped
      to this file's own name, and add It 'declares an empty bundled path_roots list'. Acceptance: the
      file is at most 500 lines.
- [ ] [P10-T4] Create `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1` implementing block B35,
      the PowerShell port of B33 with the same constants in the same order. Acceptance: the file exists
      and is at most 500 lines.
- [ ] [P10-T5] Edit `.claude/lib/blast-radius/BlastRadius.psm1`: import the write-intent module; in
      Get-BlastRadius and Get-NormalizedDeclaredRadius add the flag branch as a delegation to the
      write-intent module (all logic stays in that module); export the write-intent functions named in
      B35. Test-BlastRadiusConflict is not edited. Acceptance: the file is at most 500 lines.
- [ ] [P10-T6] Edit `.claude/lib/blast-radius/BlastRadiusValidation.psm1`: import the write-intent
      module and replace the plan-side Get-PlanPaths call used by V1 and V2 with the write-intent
      selector. Acceptance: the file is at most 500 lines.
- [ ] [P10-T7] Produce the mirrors for P10-T4, P10-T5, and P10-T6 per the Preamble rule:
      `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1`,
      `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1`,
      and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusValidation.psm1`.
      Write FEATURE/evidence/qa-gates/mirrors-p10.TS.md. Acceptance: each pair's hashes are equal.
- [ ] [P10-T8] Reset the PowerShell batch budget (A8, -Kind powershell). Write
      FEATURE/evidence/other/batch-budget-reset-p10b.TS.md. Acceptance: exit 0.
- [ ] [P10-T9] Edit `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` to add the write-intent
      module to the blast-radius coverage paths, copy it to
      `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, and edit
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` to list the
      write-intent module. Acceptance: the runsettings pair hashes are equal and core.json parses.
- [ ] [P10-T10] Run script pester-coverage over the P10-T2 file and the P10-T3 file (one run each) with
      -CoveragePath set to the write-intent module, the facade, and the validation module. Write
      FEATURE/evidence/regression-testing/pester-part-b.TS.md. Acceptance: every run prints
      FailedCount=0; every B34 It name appears as passed.
- [ ] [P10-T11] Run script pester-counts over the whole blast-radius Pester directory. Write
      FEATURE/evidence/regression-testing/pester-directory-p10.TS.md. Acceptance: every FAILED name is
      in the P0-T32 baseline failure set.
- [ ] [P10-T12] Format and lint the six primary PowerShell files of this phase as in P5-T12. Write
      FEATURE/evidence/qa-gates/phase10-powershell-static.TS.md. Acceptance: as in P5-T12.
- [ ] [P10-T13] Commit and push Phase 10 (the seven primary files, the four mirrors, the pack manifest,
      and the FEATURE evidence directory; message "feat(722): add write-intent extraction
      (PowerShell)"). Acceptance: all three git commands exit 0.

### Phase 11 — Part B: TypeScript Carriage of write_intent_extraction and path_roots

- [ ] [P11-T1] Edit `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`:
      append write_intent_extraction and path_roots to the carried-key list and emit them after
      conflict_tolerance, before modules. Acceptance: the file is at most 500 lines.
- [ ] [P11-T2] Edit `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` so its
      source truth-table constant equals the P9-T4 bundled file. Acceptance: at most 500 lines.
- [ ] [P11-T3] Edit `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` and
      `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts`: update the
      key-order expectations to the Part B form of block B20. Acceptance: both files at most 500 lines.
- [ ] [P11-T4] Edit `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts`:
      add the write_intent_extraction and path_roots cases of block B21. Acceptance: at most 500 lines.
- [ ] [P11-T5] Run CMD-TS-TEST over the four test files of this phase and claude-config-carriage.test.ts.
      Write FEATURE/evidence/regression-testing/ts-part-b-tests.TS.md. Acceptance: exit 0 and 0 failed.
- [ ] [P11-T6] Run CMD-TS-FORMAT, CMD-TS-PRETTIER-CHECK over the five TypeScript files of this phase,
      CMD-TS-LINT, and CMD-TS-TYPECHECK. Write FEATURE/evidence/qa-gates/phase11-ts-static.TS.md.
      Acceptance: as in P4-T8.
- [ ] [P11-T7] Commit and push Phase 11 (the five files and the FEATURE evidence directory; message
      "feat(722): carry write-intent keys through the push-down"). Acceptance: all three git commands
      exit 0.

### Phase 12 — Part B: Historical AFTER Derivation, Pins, and Re-derivation Evidence

- [ ] [P12-T1] Historical AFTER from recorded radii, both runtimes: for each slug run script
      historical-edges in after mode (contracts C2 and C3) over the P0 radii JSON and the committed
      self-hosted config, then script historical-compare (C4). Write
      FEATURE/evidence/other/historical-<slug>-after-python.TS.json and the PowerShell counterpart, and
      FEATURE/evidence/qa-gates/historical-after-recorded-radii.TS.md. Acceptance: every run prints
      MATCH; the artifact records per run the AFTER edges, tolerated overlaps, edge count, cohort
      partition, cohort count, and maximum cohort width.
- [ ] [P12-T2] Historical AFTER from plan text (line-context rules W2, W3, and W5), both runtimes: for
      each slug run script historical-plan-after (contract C7) in Python and in PowerShell, pinned to
      the plan-home ref commit recorded by P0-T23, then historical-compare. Write
      FEATURE/evidence/qa-gates/historical-after-plan-text.TS.md containing the script text, the pinned
      commit, the plan and spec path of every item, both member sets, and the comparison. Acceptance:
      every run prints MATCH.
- [ ] [P12-T3] Write the final evidence artifact FEATURE/evidence/qa-gates/historical-before-after-summary.TS.md:
      one table row per run with BEFORE, AFTER (recorded radii), and AFTER (plan text) edge count,
      cohort count, and maximum cohort width, citing the P0-T27, P12-T1, and P12-T2 artifacts.
      Acceptance: three rows, nine numeric columns each, every value copied from a cited artifact.
- [ ] [P12-T4] Add the AFTER section to
      `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json`,
      `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json`, and
      `tests/fixtures/blast_radius/historical-runs/epic-655-followups.json` by running script
      historical-fixture (C6) in after mode. Acceptance: each file's AFTER values equal the P12-T1
      artifact values for the run, and its BEFORE section is byte-identical to the Phase 3 content.
- [ ] [P12-T5] Reset the Python batch budget (A8, -Kind python), then edit
      `tests/scripts/dev_tools/test_blast_radius_historical_runs.py` to add the AFTER tests of block B18.
      Write FEATURE/evidence/other/batch-budget-reset-p12a.TS.md. Acceptance: the file is at most 500
      lines and contains neither origin/ nor artifacts/.
- [ ] [P12-T6] Reset the PowerShell batch budget (A8, -Kind powershell), then edit
      `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1` to add the AFTER It
      blocks of block B24. Write FEATURE/evidence/other/batch-budget-reset-p12b.TS.md. Acceptance: the
      file is at most 500 lines and contains neither origin/ nor artifacts/.
- [ ] [P12-T7] Run CMD-PY-TEST over the P12-T5 file and script pester-counts over the P12-T6 file.
      Write FEATURE/evidence/regression-testing/historical-after-tests.TS.md. Acceptance: pytest exits 0
      with PASSED lines for every B18 test for all three runs; Pester prints FailedCount=0 and a
      PassedCount equal to its TotalCount.
- [ ] [P12-T8] Run CMD-PY-BLACK, CMD-PY-BLACK-CHECK, CMD-PY-RUFF, and CMD-PY-PYRIGHT over the P12-T5
      file, and the P5-T12 PowerShell format and lint sequence over the P12-T6 file. Write
      FEATURE/evidence/qa-gates/phase12-static.TS.md. Acceptance: as in P1-T14 and P5-T12.
- [ ] [P12-T9] Commit and push Phase 12 (the three fixtures, the two test files, and the FEATURE
      evidence directory; message "test(722): pin historical AFTER values"). Acceptance: all three git
      commands exit 0.
- [ ] [P12-T10] Confirm the historical tests read only committed fixtures: run CMD-GIT-TRACKED for each
      of the two historical test files, then CMD-GIT-GREP-FORBID over both. Write
      FEATURE/evidence/qa-gates/historical-tests-no-forbidden-refs.TS.md with ExpectedExitCode: 1.
      Acceptance: both CMD-GIT-TRACKED runs exit 0; CMD-GIT-GREP-FORBID exits 1 and prints nothing.

### Phase 13 — Part B: Documentation (Write-Intent Sections)

- [ ] [P13-T1] Edit `.claude/rules/parallel-orchestration.md`: add a "Write-intent extraction"
      subsection with rules W1 through W6, the flag and path_roots semantics, the rule that derivation
      and validation select the same extractor, the known false-negative list of the spec, and the three
      mitigations; add the Copilot instructions file to the Read-by-mandate text; add
      write_intent_extraction to the byte-equal key list and name path_roots as a Class 2 key whose
      bundled value is empty. Acceptance: each Part B token quoted in block B26 appears in the file.
- [ ] [P13-T2] Copy the P13-T1 file to
      `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
      and run the B27 node IDs with CMD-PY-TEST. Write FEATURE/evidence/regression-testing/mirror-contract-p13.TS.md.
      Acceptance: hashes equal; exit 0 with two PASSED lines.
- [ ] [P13-T3] Commit and push Phase 13 (the two Markdown files and the FEATURE evidence directory;
      message "docs(722): document write-intent extraction"). Acceptance: all three git commands exit 0.

### Phase 14 — Main Sync, #452 Re-gate, and Scope Checks

- [ ] [P14-T1] Run CMD-GIT-FETCH-MAIN, then CMD-GIT-MERGE-MAIN. Write
      FEATURE/evidence/qa-gates/main-sync.TS.md. Acceptance: the merge exits 0. If it reports conflicts,
      resolve them under the existing per-item merge-conflict handling, record every conflicted path and
      its resolution, and re-run the phase gates of every phase whose files were conflicted.
- [ ] [P14-T2] Re-run P0-T20 on the merged tree. Write FEATURE/evidence/qa-gates/452-inventory-final.TS.md.
      Acceptance: the artifact lists every #452-tagged fixture now on the branch.
- [ ] [P14-T3] #452 re-gate (pre-authorized on this branch; fixtures unmodified): run the P0-T21 and
      P0-T22 commands, extended with the node IDs and filters of every fixture listed by P14-T2. Write
      FEATURE/evidence/qa-gates/452-gate-final.TS.md. Acceptance: pytest exits 0 with a PASSED line for
      every listed node; every Pester run prints FailedCount=0.
- [ ] [P14-T4] Detection relation unchanged (final): repeat P7-T3 on the merged tree. Write
      FEATURE/evidence/qa-gates/detection-unchanged-final.TS.md. Acceptance: as in P7-T3.
- [ ] [P14-T5] Detection verdicts unchanged (final): run CMD-PY-TEST over the verdict and reasons
      parity tests of block B36 and script pester-counts over the parity Pester file. Write
      FEATURE/evidence/qa-gates/detection-verdicts-final.TS.md. Acceptance: pytest exits 0; Pester
      prints FailedCount=0.
- [ ] [P14-T6] Mirror identity (final): run script file-hashes over every mirror pair written by this
      plan (block B37). Write FEATURE/evidence/qa-gates/mirrors-final.TS.md. Acceptance: every pair is
      equal.
- [ ] [P14-T7] Bash untouched: run CMD-GIT-DIFF-NAMES and CMD-GIT-STATUS-PATH with pathspec
      .claude/lib/bash. Write FEATURE/evidence/qa-gates/bash-untouched.TS.md. Acceptance: both print
      nothing.
- [ ] [P14-T8] Commit and push Phase 14 (the merge, if any, and the FEATURE evidence directory; message
      "chore(722): sync with main and re-run #452 gate"). Acceptance: all three git commands exit 0.

### Phase 15 — Final QA: Python

- [ ] [P15-T1] Run CMD-PY-BLACK with ".". Then run CMD-PY-BLACK-CHECK with ".". Write
      FEATURE/evidence/qa-gates/final-python-black.TS.md. Acceptance: the check run exits 0 and prints a
      line ending "would be left unchanged.". If the write run reformatted any file, restart Phase 15.
- [ ] [P15-T2] Run CMD-PY-RUFF with ".". Write FEATURE/evidence/qa-gates/final-python-ruff.TS.md.
      Acceptance: exit 0 and "All checks passed!". No new noqa suppression exists in the changed files.
      On failure, fix and restart Phase 15.
- [ ] [P15-T3] Run CMD-PY-PYRIGHT. Write FEATURE/evidence/qa-gates/final-python-pyright.TS.md.
      Acceptance: exit 0 and "0 errors". On failure, fix and restart Phase 15.
- [ ] [P15-T4] Run CMD-PY-COV with label final, then script py-cov-files over the six Python
      production files of block B38. Write FEATURE/evidence/qa-gates/final-python-pytest-coverage.TS.md.
      Acceptance: every FAILED node ID is in the P0-T18 baseline failure set; every new test named in
      B10, B11, B13, B14, B16, B18, and B32 passes; each B38 file prints LinePercent of at least 85 and
      BranchPercent of at least 75. On failure, fix and restart Phase 15.
- [ ] [P15-T5] Python coverage delta: run script changed-lines (A7 companion, block B39) with
      SCRATCH/coverage-722-final.json, BASE_SHA, and the three pre-existing files of P0-T18. Write
      FEATURE/evidence/qa-gates/python-coverage-delta.TS.md recording baseline percent (P0-T18), final
      percent (P15-T4), and changed-line percent per file. Acceptance: final percent is at least the
      baseline percent for each file and every changed-line percent is at least 85.
- [ ] [P15-T6] Commit and push Phase 15 evidence (message "test(722): record final Python QA").
      Acceptance: all three git commands exit 0.

### Phase 16 — Final QA: PowerShell

- [ ] [P16-T1] Record hashes of every PowerShell file written by this plan (block B40), call
      MCP-PS-FORMAT over them, and record hashes again. Write FEATURE/evidence/qa-gates/final-powershell-format.TS.md.
      Acceptance: the call returns without raising. If any hash changed, re-copy affected mirrors and
      restart Phase 16.
- [ ] [P16-T2] Run script ps-format-check over the B40 files. Write
      FEATURE/evidence/qa-gates/final-powershell-format-check.TS.md. Acceptance: FORMAT-SUMMARY
      ChangedCount=0.
- [ ] [P16-T3] Call MCP-PS-ANALYZE over the B40 files. Write
      FEATURE/evidence/qa-gates/final-powershell-analyze.TS.md. Acceptance: the call returns without
      raising. On a raised finding, fix and restart Phase 16.
- [ ] [P16-T4] Run script pester-coverage with -TestPath tests/scripts/claude-lib/blast-radius and
      -CoveragePath set to the four PowerShell modules of block B41. Write
      FEATURE/evidence/qa-gates/final-powershell-pester-coverage.TS.md. Acceptance: every FAILED name
      is in the P0-T32 baseline failure set; every B23, B24, and B34 It passes; each B41 module prints
      LinePercent of at least 85.
- [ ] [P16-T5] PowerShell coverage delta: write FEATURE/evidence/qa-gates/powershell-coverage-delta.TS.md
      recording the P0-T32 and P16-T4 LinePercent of the facade and validation modules and the P16-T4
      value of the two new modules. Acceptance: the facade and validation values are each at least their
      baseline and at least 85; the two new module values are at least 85.
- [ ] [P16-T6] Commit and push Phase 16 evidence (message "test(722): record final PowerShell QA").
      Acceptance: all three git commands exit 0.

### Phase 17 — Final QA: TypeScript

- [ ] [P17-T1] Run CMD-TS-FORMAT, recording CMD-GIT-STATUS-PATH over extensions/drm-copilot before and
      after it; then run CMD-TS-PRETTIER-CHECK over every TypeScript file written by this plan. Write
      FEATURE/evidence/qa-gates/final-ts-prettier.TS.md. Acceptance: the check exits 0 and prints "All
      matched files use Prettier code style!". If the status changed, restart Phase 17.
- [ ] [P17-T2] Run CMD-TS-LINT. Write FEATURE/evidence/qa-gates/final-ts-eslint.TS.md. Acceptance:
      exit 0.
- [ ] [P17-T3] Run CMD-TS-TYPECHECK. Write FEATURE/evidence/qa-gates/final-ts-typecheck.TS.md.
      Acceptance: exit 0.
- [ ] [P17-T4] Run CMD-TS-COV. Write FEATURE/evidence/qa-gates/final-ts-jest-coverage.TS.md.
      Acceptance: exit 0 (the jest configuration already carries an 85 line and 75 branch threshold for
      the derivation core, so a lower value fails the run); the artifact records the Tests summary line
      and the % Lines and % Branch of the derivation core row; the pack-manifest completeness test
      passes.
- [ ] [P17-T5] TypeScript coverage delta: write FEATURE/evidence/qa-gates/ts-coverage-delta.TS.md with
      the P0-T31 and P17-T4 derivation-core values. Acceptance: the final % Lines and % Branch are each
      at least their baseline.
- [ ] [P17-T6] Commit and push Phase 17 evidence (message "test(722): record final TypeScript QA").
      Acceptance: all three git commands exit 0.

### Phase 18 — File Sizes, Batch Accounting, Acceptance-Criteria Check-off, and CI

- [ ] [P18-T1] Run script line-counts over every file written by this plan. Write
      FEATURE/evidence/qa-gates/final-line-counts.TS.md. Acceptance: every production and test file is at
      most 500 lines; the drift module is at most its P0-T13 value.
- [ ] [P18-T2] Write FEATURE/evidence/qa-gates/batch-accounting.TS.md listing, per batch (P1, P2, P3,
      P5, P8, P9, P10 first half, P10 second half, P12), the authored Python and PowerShell production
      and test files and the reset artifact that opened the batch. Acceptance: no batch lists more than 3
      production or 3 test files of one language.
- [ ] [P18-T3] Scope check: run CMD-GIT-DIFF-NAMES with pathspec "." and CMD-GIT-STATUS. Write
      FEATURE/evidence/qa-gates/scope-check.TS.md. Acceptance: every listed path is either a path
      backticked in this plan or under FEATURE; no path under .claude/lib/bash, the rules directory
      other than the parallel-orchestration rule file, or the .github instructions directory is listed.
- [ ] [P18-T4] Check off in this feature's spec.md every acceptance criterion from AC-01 through AC-37
      whose traceability row cites evidence that exists and passes, appending the evidence artifact name
      after each. AC-38 stays unchecked. Acceptance: the spec's Acceptance Criteria section contains 37
      lines beginning "- [x]" and 1 line beginning "- [ ]".
- [ ] [P18-T5] Commit and push the check-off (message "docs(722): check off locally verified
      acceptance criteria"). Acceptance: all three git commands exit 0.
- [ ] [P18-T6] CI gate, owned by the execution child: confirm the item's pull request exists with gh
      pr view for the branch, then wait for its checks with gh pr checks and the watch flag. Write
      FEATURE/evidence/qa-gates/ci-status.TS.md recording the PR number and every check name and result,
      including the windows-latest Pester job. Acceptance: every required check passes. If no pull
      request exists, record AWAITING-PR in the artifact, push it, and report that state to the parent as
      not done.
- [ ] [P18-T7] After P18-T6 passes, check off AC-38 in spec.md citing the P18-T6 artifact, commit with
      message "docs(722): check off CI acceptance criterion", and run CMD-GIT-PUSH before reporting done.
      Acceptance: the spec's Acceptance Criteria section contains 38 lines beginning "- [x]"; the push
      exits 0 before the completion report is sent.

---

## Appendix A — Scratch Scripts and Script Contracts

Scripts A1 through A9 are written verbatim. Contracts C1 through C7 define scratch scripts whose full
text is recorded in the evidence artifact of the task that runs them.

A1 run-ps.sh (Bash-tool route only):

```sh
#!/bin/sh
set -eu
pwsh -NoProfile -NonInteractive -File "$@"
```

A2 pester-counts.ps1:

```powershell
param(
    [Parameter(Mandatory)][string] $Path,
    [string] $FullNameFilter
)
$configuration = New-PesterConfiguration
$configuration.Run.Path = $Path
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
if ($PSBoundParameters.ContainsKey('FullNameFilter')) { $configuration.Filter.FullName = $FullNameFilter }
$result = Invoke-Pester -Configuration $configuration
Write-Output "TotalCount=$($result.TotalCount)"
Write-Output "PassedCount=$($result.PassedCount)"
Write-Output "FailedCount=$($result.FailedCount)"
foreach ($failedTest in $result.Failed) { Write-Output "FAILED: $($failedTest.ExpandedPath)" }
```

A3 pester-coverage.ps1:

```powershell
param(
    [Parameter(Mandatory)][string] $TestPath,
    [Parameter(Mandatory)][string[]] $CoveragePath,
    [Parameter(Mandatory)][string] $CoverageOutputPath,
    [string] $FullNameFilter
)
$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = $CoveragePath
$configuration.CodeCoverage.OutputPath = $CoverageOutputPath
if ($PSBoundParameters.ContainsKey('FullNameFilter')) { $configuration.Filter.FullName = $FullNameFilter }
$result = Invoke-Pester -Configuration $configuration
Write-Output "TotalCount=$($result.TotalCount)"
Write-Output "PassedCount=$($result.PassedCount)"
Write-Output "FailedCount=$($result.FailedCount)"
foreach ($failedTest in $result.Failed) { Write-Output "FAILED: $($failedTest.ExpandedPath)" }
$executed = @($result.CodeCoverage.CommandsExecuted)
$missed = @($result.CodeCoverage.CommandsMissed)
foreach ($file in $CoveragePath) {
    $fullPath = (Resolve-Path -LiteralPath $file).Path
    $hitLines = @($executed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $missLines = @($missed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $analyzed = @(@($hitLines) + @($missLines) | Sort-Object -Unique)
    $percent = if ($analyzed.Count -eq 0) { 'NA' } else { [math]::Round(100 * $hitLines.Count / $analyzed.Count, 2) }
    Write-Output "COVERAGE file=$file AnalyzedLines=$($analyzed.Count) CoveredLines=$($hitLines.Count) LinePercent=$percent"
}
```

A4 line-counts.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file LineCount=$((Get-Content -LiteralPath $file).Count)" }
```

A5 file-hashes.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file Hash=$((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash)" }
```

A6 ps-format-check.ps1 (read-only; uses the PoshQC analyzer settings file):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$changedCount = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    $changed = $formatted -cne $original
    if ($changed) { $changedCount++ }
    Write-Output "FORMAT file=$file Changed=$changed"
}
Write-Output "FORMAT-SUMMARY ChangedCount=$changedCount"
```

If A6 reports Changed=True for a file whose hash the MCP format call left unchanged, the two
formatters use different settings; stop and report rather than editing the file by hand.

A7 py-cov-files.py:

```python
import json
import sys
from pathlib import Path

report = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
files = report["files"]
for target in sys.argv[2:]:
    key = target if target in files else target.replace("/", "\\")
    data = files.get(key)
    if data is None:
        print(f"COVERAGE file={target} MISSING")
        continue
    summary = data["summary"]
    statements = summary["num_statements"]
    branches = summary["num_branches"]
    line_pct = 100.0 * summary["covered_lines"] / statements if statements else 100.0
    branch_pct = 100.0 * summary["covered_branches"] / branches if branches else 100.0
    print(f"COVERAGE file={target} LinePercent={line_pct:.2f} BranchPercent={branch_pct:.2f}")
```

A8 reset-batch-budget.ps1:

```powershell
param([Parameter(Mandatory)][ValidateSet('python', 'powershell')][string] $Kind)
$stateDirectory = '.claude/state'
if (-not (Test-Path -LiteralPath $stateDirectory)) { Write-Output 'RESET removed=0'; return }
$stateFiles = @(Get-ChildItem -LiteralPath $stateDirectory -Filter "$Kind-batch-budget.*.json" -File)
foreach ($stateFile in $stateFiles) { Write-Output "RESET file=$($stateFile.Name)"; Remove-Item -LiteralPath $stateFile.FullName }
Write-Output "RESET removed=$($stateFiles.Count)"
```

A9 function-body-equal.ps1:

```powershell
param(
    [Parameter(Mandatory)][string] $Path,
    [Parameter(Mandatory)][string] $Name,
    [Parameter(Mandatory)][string] $BaseSha
)
$baseText = (& git show "$($BaseSha):$Path") -join "`n"
$headText = (Get-Content -Raw -LiteralPath $Path) -replace "`r`n", "`n"
function Get-FunctionText([string] $Text, [string] $FunctionName) {
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref]$null, [ref]$null)
    $node = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $FunctionName }, $true)
    if ($null -eq $node) { throw "Function $FunctionName not found" }
    return ($node.Extent.Text -replace "`r`n", "`n").TrimEnd()
}
$equal = (Get-FunctionText $baseText $Name) -ceq (Get-FunctionText $headText $Name)
Write-Output "BODY-EQUAL=$equal"
```

B39 changed-lines.py (companion to A7, created in SCRATCH at P0-T12 with A7):

```python
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

report = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
base = sys.argv[2]
git = shutil.which("git")
if git is None:
    raise SystemExit("git executable not found")
files = report["files"]
hunk = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@", re.MULTILINE)
for target in sys.argv[3:]:
    diff = subprocess.run([git, "diff", "-U0", base, "--", target], capture_output=True, text=True, check=True).stdout
    changed: set[int] = set()
    for match in hunk.finditer(diff):
        start = int(match.group(1))
        count = int(match.group(2) or "1")
        changed.update(range(start, start + count))
    key = target if target in files else target.replace("/", "\\")
    data = files.get(key)
    if data is None:
        print(f"CHANGED file={target} MISSING")
        continue
    executed = set(data["executed_lines"])
    executable = executed | set(data["missing_lines"])
    changed_exec = changed & executable
    covered = changed_exec & executed
    pct = 100.0 * len(covered) / len(changed_exec) if changed_exec else 100.0
    print(f"CHANGED file={target} ChangedExecutable={len(changed_exec)} Covered={len(covered)} ChangedLinePercent={pct:.2f}")
```

Contracts (text recorded in the evidence artifact of the task that runs them):

- C1 historical-extract.py: arguments slug, ref, output path. Runs git show of the ref's parallel
  manifest (the manifest path for that slug under the parallel docs tree) through a subprocess whose
  executable is resolved with shutil.which; parses the YAML frontmatter with yaml.safe_load; writes a
  JSON object with the slug, ref, manifest blob SHA, and one entry per item carrying issue_num, the
  blast_radius object copied without change, complexity_band, and band_source. Band source order:
  the manifest item's complexity_band when present ("manifest"); otherwise the kickoff table for the
  slug in the primary checkout's orchestration directory, located through the first entry of git
  worktree list --porcelain, when that file is readable ("kickoff"); otherwise null with band_source
  "default_band". The artifact never records an absolute path.
- C2 historical-edges.py: arguments mode (before or after), radii JSON, config path, output path.
  Before mode: every unordered item pair through the Python conflicts function with the config as read
  at BASE_SHA; edges are the conflicting pairs with the first canonical reason. After mode: each radius
  passes through normalize_declared_radius with the committed config, then the scheduling entry point
  with the committed config produces edges and tolerated overlaps. Both modes color the edge set with
  compute_cohorts and write edges, tolerated overlaps (after mode), edge count, cohorts, cohort count,
  and maximum cohort width.
- C3 historical-edges.ps1: the PowerShell counterpart of C2 using Test-BlastRadiusConflict (before) and
  Get-NormalizedDeclaredRadius plus Get-BlastRadiusConflictEdge (after), writing edges, tolerated
  overlaps, and edge count.
- C4 historical-compare.py: compares the Python and PowerShell edge member sets (pair and reason) and,
  in after mode, the tolerated-overlap sets; prints MATCH or MISMATCH with the symmetric difference;
  colors the PowerShell edge set with compute_cohorts and prints both partitions.
- C5 failbefore-demo.py: scheduling mode builds the two radii of block B3, prints the current
  conflicts verdict, and exits 1 when the pair is a conflict (the current hand rule records every
  conflict as an edge). Extraction mode derives the block B4 plan text with the current
  derive_blast_radius and exits 1 when the result contains any of the three over-reported tokens.
- C6 historical-fixture.py: arguments mode (before or after), slug, evidence JSON paths, output path.
  Before mode writes the B17 structure with the BEFORE section. After mode loads the existing fixture,
  adds the AFTER section, and writes it back without changing the BEFORE section.
- C7 historical-plan-after (Python .py and PowerShell .ps1): for each manifest item, reads the item's
  plan and spec text with git show from the plan-home ref; the plan is the ordinally greatest file whose
  name starts with "plan." in the item's feature folder at that ref; when the folder is absent at that
  ref, the same lookup runs against origin/main at the SHA recorded in the artifact. Derives each radius
  with the committed config (write-intent extraction on), then runs the scheduling entry point and
  cohort coloring, and writes the same fields as C2 after mode.

## Appendix B — Fixture, Test, and Implementation Specifications

B1 — #452 detection gate, Python node IDs (read-only test module; run unmodified):

```text
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-glob]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-file]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-sibling-prefix-disjoint]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-directory-vs-glob]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-directory-vs-file]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-sibling-prefix-disjoint]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_radius[derivation-root-surface-reached]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_radius[derivation-root-surface-not-configured]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_findings[derivation-root-surface-reached]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_findings[derivation-root-surface-not-configured]
```

B2 — committed conflict_tolerance member (both config copies, byte-equal):

```json
"conflict_tolerance": {
  "tolerance_percent": 100,
  "weights": { "same_file": 8, "possible_overlap": 2, "append_only": 1, "module": 2 },
  "band_durations": { "C1": 1, "C2": 2, "C3": 4, "C4": 8 },
  "default_band": "C1",
  "append_only_paths": [
    "**/CHANGELOG.md",
    "extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json"
  ]
}
```

Absent-key semantics (strict): tolerance_percent 0; every weight 1; every band duration 1;
default_band C1; append_only_paths empty. At tolerance 0 the weights do not affect the edge set.

B3 — fail-before scheduling radii: two declared radii whose only path is CHANGELOG.md, empty modules,
shared surfaces, and contracts.

Notation for B4 and B31: in this plan, {{token}} stands for an inline-code span, that is, the token
enclosed in single backticks in the fixture or script text. The plan itself never writes those
backticks, so the current extractor does not harvest the example tokens into this item's radius.

Notation for B4 task lines: a line beginning with the marker TASKLINE followed by a space and a bare
task ID (P1-T1 or P1-T2) stands for a line that begins with the canonical unchecked task prefix, that
is, a hyphen, a space, an empty checkbox (an opening square bracket, a space, a closing square
bracket), a space, and that task ID enclosed in square brackets. When writing the B4 text into
script failbefore-demo (block C5), replace the TASKLINE marker and the bare ID with that prefix and
keep the remainder of the line unchanged after one separating space. The plan does not write the
canonical prefix inside the fence, because the plan validator parses task-shaped lines inside fenced
blocks as tasks of this plan.

B4 — fail-before plan text (two task lines, in the TASKLINE notation):

```text
TASKLINE P1-T1 Update {{src/app.py}} and the files matched by {{src/**/*.py}}; run {{git add src/other.py}}.
TASKLINE P1-T2 Read {{src/policy.py}} in full.
```

Over-reported tokens today: src/**/*.py, src/other.py, and src/policy.py.

Common scheduling fixture shape (B5-B9): description, tags (["#722", "#452-case"] for the 452 files,
["#722"] otherwise), config (a truth table with version 1, empty shared_surfaces and
shared_surface_globs, empty mandate_reads and mergeable_paths, modules {"config": ["config/**"]},
over_breadth_fraction 0.25, and the B2 conflict_tolerance member except in B9, with append_only_paths
replaced by ["CHANGELOG.md"]), items (key, band or null, radius with source declared and computed_at
2026-09-27T00-00), and cases (tolerance_percent or null for "use config as-is", expected_edges with
a, b, reason, hard, cost, benefit, and expected_tolerated with a, b, reasons, cost, benefit).

B5 — scheduling-452-shared-surface-hard: items 1 and 2, band C4 each, paths ["poetry.lock"],
shared_surfaces ["poetry.lock"]. Cases 0, 100, 1000000: one edge {1, 2, path_overlap, hard true, cost
8, benefit 8}; no tolerated overlap.

B6 — scheduling-452-directory-prefix-weighted: items 1, 2, 3 with null band and paths
["scripts/dev_tools"], ["scripts/dev_tools/**"], ["scripts/dev_tools/compute_blast_radius.py"]
respectively (copied from the #452 directory fixtures, embedded, not referenced). Every pair has cost 2
(possible_overlap) and benefit 1. Cases 0 and 100: three edges, reason path_overlap, hard false. Case
1000000: no edge; three tolerated overlaps with reasons ["path_overlap"].

B7 — scheduling-452-negative-controls: items 1-4 with paths ["scripts/dev_toolsX/a.py"],
["scripts/dev_tools"], ["docs/guide.md"], ["src/index.ts"]. Cases 0, 100, 1000000: no edge and no
tolerated overlap.

B8 — scheduling-soft-pair-tolerated: items 1 and 2 (band C2) with paths ["CHANGELOG.md"]; items 3 and 4
(band C4) with paths ["src/app.py"]. Pair (1, 2): cost 1 (append_only, evaluated before same_file),
benefit 2. Pair (3, 4): cost 8, benefit 8. Case 0: two edges. Case 99: edge (3, 4); tolerated (1, 2).
Case 100: no edge; tolerated (1, 2) and (3, 4).

B9 — scheduling-absent-key-strict: config without conflict_tolerance; items 1-5 with paths
["scripts/dev_tools"], ["scripts/dev_tools/**"], ["CHANGELOG.md"], ["CHANGELOG.md"], ["docs/guide.md"].
One case with tolerance null: edges (1, 2) and (3, 4), each cost 1, benefit 1, hard false; the edge
pair set equals the detected-conflict pair set.

B10 — tests in the Python scheduling test module:

```text
test_shared_surface_overlap_is_hard_at_every_tolerance
test_contract_dependency_is_hard
test_cost_same_file_weight_for_equal_concrete_entries
test_cost_append_only_is_evaluated_before_same_file
test_cost_possible_overlap_for_directory_prefix
test_cost_module_weight_times_shared_modules
test_cost_mergeable_paths_contribute_zero
test_benefit_is_minimum_band_duration
test_benefit_uses_default_band_for_missing_band
test_edge_rule_integer_inequality_boundary
test_recorded_reason_is_first_canonical_kind
test_absent_key_reads_as_strict
test_conflict_tolerance_reader_rejects_invalid_shape[<14 cases>]
test_scheduling_fixture_reproduces_expected_decisions[<5 fixture stems>]
test_452_scheduling_fixtures_embed_radii
test_strict_identity_over_existing_conflict_fixtures
test_edges_and_tolerated_overlaps_are_sorted_by_pair
```

The 14 reader cases: non-object, percent-negative, percent-float, percent-string, percent-bool,
weight-zero, weight-bool, weight-float, weight-unknown-name, weight-missing-name, band-duration-zero,
band-missing-name, default-band-out-of-range, append-only-not-list. Each asserts the raised error text
contains conflict_tolerance.

B11 — hypothesis properties: test_property_edge_implies_conflict,
test_property_tolerance_zero_equals_conflict, test_property_monotone_in_tolerance,
test_property_symmetric_decision.

B12 — Python scheduling module contract: a frozen ConflictTolerance value object; a strict reader of
conflict_tolerance returning the B2 absent-key semantics when the key is absent; a pair decision
returning verdict, edge flag, hard flag, cost, benefit, recorded reason, and the full reason list; cost
and benefit helpers; and a scheduling entry point taking items (integer key, radius, optional band)
and the config and returning edges sorted by (a, b) with a < b and tolerated overlaps sorted the same
way. Edge rule: edge if and only if conflict and (hard or cost times 100 is greater than benefit times
tolerance_percent). Hard means the reasons include shared_surface_overlap or contract_dependency. Cost
sums, over overlapping path pairs after the mergeable exclusion, append_only weight when the concrete
overlapping path matches append_only_paths by the mergeable matcher, else same_file weight when both
entries are concrete and equal, else possible_overlap weight; plus module weight times the number of
shared modules. Benefit is the minimum band duration of the two items, using default_band for a missing
band.

B13 — tests in the drift scheduling test module:

```text
test_tolerated_pair_within_tolerance_is_not_reported
test_tolerated_pair_that_becomes_hard_is_reported
test_tolerated_pair_exceeding_tolerance_is_reported
test_tolerance_zero_output_equals_conflict_only_output
test_unevaluable_peer_radius_counts_as_edge
test_existing_edge_pairs_normalize_order
test_missing_band_uses_default_band
```

B14 — tests in the validator tolerated-field module:
test_orchestrator_state_accepts_tolerated_edge_fields,
test_planner_state_accepts_tolerated_edge_fields,
test_orchestrator_state_accepts_tolerated_overlaps_list,
test_planner_state_accepts_tolerated_overlaps_list,
test_out_of_enum_reason_is_still_rejected. The first four assert zero errors; the last asserts the
existing reason-enum error is still reported.

B15 — drift helper contract: an existing-edge-pair collector (relocated unchanged) and an observed-pair
edge decision that returns True when the peer radius cannot be evaluated and otherwise returns the
scheduling rule's edge flag for the observed radius against the peer radius with both items' bands.

B16 — tests in the config tolerance-keys module. Part A:
test_committed_conflict_tolerance_values[self-hosted], test_committed_conflict_tolerance_values[bundled],
test_committed_conflict_tolerance_reads_cleanly[self-hosted],
test_committed_conflict_tolerance_reads_cleanly[bundled]. Part B:
test_committed_write_intent_extraction_is_true[self-hosted],
test_committed_write_intent_extraction_is_true[bundled],
test_mandate_reads_include_copilot_instructions[self-hosted],
test_mandate_reads_include_copilot_instructions[bundled],
test_self_hosted_path_roots_match_pinned_directory_list (the P0-T28 list pinned in the test),
test_class_two_bundled_path_roots_are_empty, test_tolerance_registry_keys_are_consumed.

B17 — historical fixture fields: run, source_ref, manifest_blob, base_commit, items (issue_num,
complexity_band, band_source, radius), expected_radius_sizes (per item counts of paths, modules,
shared_surfaces, contracts), before (config, edges, edge_count, cohorts, cohort_count,
max_cohort_width), and after (config, edges, tolerated_overlaps, edge_count, cohorts, cohort_count,
max_cohort_width).

B18 — tests in the historical-runs module, each parametrized over the three runs. BEFORE:
test_before_radius_sizes_match_pins, test_before_edges_match_pins,
test_before_strict_scheduling_equals_detection, test_before_cohorts_match_pins. AFTER:
test_after_edges_match_pins, test_after_tolerated_overlaps_match_pins, test_after_cohorts_match_pins,
test_after_edges_are_subset_of_before_edges.

B19 — config-parity node IDs (read-only module, run unmodified):

```text
tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_one_keys_are_equal_across_both_committed_copies[conflict_tolerance]
tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_top_level_key_is_classified_and_shared_by_both_copies
tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_one_keys_are_equal_across_both_committed_copies[write_intent_extraction]   (Part B only)
```

B20 — emitted key order. Part A: version, shared_surfaces, shared_surface_globs, mandate_reads,
mergeable_paths, conflict_tolerance, modules, over_breadth_fraction. Part B: version, shared_surfaces,
shared_surface_globs, mandate_reads, mergeable_paths, conflict_tolerance, write_intent_extraction,
path_roots, modules, over_breadth_fraction.

B21 — TypeScript carriage cases: for each carried key (conflict_tolerance in Part A;
write_intent_extraction and path_roots in Part B) one case asserting the destination document carries
the source value verbatim and one case asserting the key is omitted when the source lacks it.

B22 — TypeScript validator cases: the orchestrator-state and planner-state validators return zero
errors for a valid checkpoint whose edges carry hard, cost, and benefit and which carries a
tolerated_overlaps list; an out-of-enum reason still yields the existing error.

B23 — Pester It blocks in the scheduling test file: one It per B10 test (names in sentence form,
including 'rejects <Case>' over the 14 reader cases and 'reproduces the expected decisions for
<FixtureName>' over the five fixtures), plus 'matches detection at tolerance 0 for <FixtureName>' over
every top-level conflict fixture and 'decides (b, a) the same as (a, b)'.

B24 — Pester It blocks in the historical-runs file, over the three runs: 'reproduces the pinned BEFORE
edges for <Run>', 'matches detection at tolerance 0 for <Run>', and (Part B) 'reproduces the pinned
AFTER edges and tolerated overlaps for <Run>'. Cohort partitions are asserted by the Python module only,
because PowerShell has no cohort-coloring function; the Pester file asserts the edge sets that feed it.

B25 — PowerShell scheduling module contract: Get-BlastRadiusConflictEdge (-Item, -Config) returning a
hashtable with edges and tolerated_overlaps; Get-BlastRadiusPairDecision (per-pair helper);
Get-ConfigConflictTolerance (strict reader, error text contains conflict_tolerance). Semantics identical
to B12.

B26 — literal tokens that must appear in the amended rule file. Part A: the heading text
"Integration-cost scheduling", tolerance_percent, append_only_paths, tolerated_overlaps, and
Get-BlastRadiusConflictEdge. Part B: the heading text "Write-intent extraction", write_intent_extraction,
path_roots, and copilot-instructions.md.

B27 — bundled-payload contract node IDs (read-only module):

```text
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_required_runtime_files
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

B28 — Part A strict-identity and #452 node IDs: the test_blast_radius_scheduling.py nodes
test_scheduling_fixture_reproduces_expected_decisions for all five fixture stems,
test_452_scheduling_fixtures_embed_radii, test_strict_identity_over_existing_conflict_fixtures, and the
test_blast_radius_historical_runs.py nodes test_before_strict_scheduling_equals_detection and
test_before_cohorts_match_pins for all three runs.

B29 — Pester filters: *scheduling-452-shared-surface-hard*, *scheduling-452-directory-prefix-weighted*,
*scheduling-452-negative-controls*, *scheduling-soft-pair-tolerated*, *scheduling-absent-key-strict*,
*matches detection at tolerance 0*.

B30 — detection-module pathspec: the Python conflicts, glob, and mergeable modules under
scripts/dev_tools (_blast_radius_conflicts.py, _blast_radius_glob.py, _blast_radius_mergeable.py) and
the BlastRadiusConflict and BlastRadiusGlob modules under .claude/lib/blast-radius.

B31 — write-intent fixtures. Shared config: version 1, shared_surfaces ["poetry.lock",
"config/blast-radius.json"], empty shared_surface_globs and mergeable_paths, mandate_reads
[".claude/rules/**", ".github/copilot-instructions.md"], modules {"config": ["config/**"]},
over_breadth_fraction 0.25, write_intent_extraction true, path_roots ["src", "config", "docs", "tests",
".claude"]. Feature folder demo-feature-1 unless stated; FG is its feature-folder glob. Expected paths:

```text
glob-mention         plan: task "Update {{src/app.py}} and the files matched by {{src/**/*.py}}."           paths {FG, src/app.py}
command-span         plan: task "Update {{src/app.py}}, then run {{git add src/other.py}}."                 paths {FG, src/app.py}
read-task            plan: T1 "Read {{src/policy.py}} in full." + next line "Also cite {{src/policy_detail.py}}."
                           T2 "Verify and fix {{src/fixme.py}}."  T3 "Update {{src/app.py}}."  T4 "**Baseline:** Read {{src/base.py}}."
                                                                                                          paths {FG, src/app.py, src/fixme.py}
root-anchoring       plan: task "Update {{src/app.py}}, {{research/notes.md}}, and {{evidence/other/follow-ups.md}}."
                           case path_roots as shared config: {FG, src/app.py}
                           case path_roots []: {FG, src/app.py, research/notes.md, evidence/other/follow-ups.md}
spec-contracts-only  spec: "## Public API" then list items {{computeWidget}}, {{src/spec_only.py}}, {{*.ts}}, {{git add widget}}
                           plan: task "Update {{src/app.py}}."                                             paths {FG, src/app.py}; contracts {computeWidget}
placeholder-stem     plan: task "Update {{src/app.py}}, {{src/x.ts}}, {{tests/foo.py}}, and {{tests/example.md}}." paths {FG, src/app.py}
shared-surface-read-citation  items A (demo-feature-a): "Read {{config/blast-radius.json}} in full." + "Update {{src/a_module.py}}."
                           B (demo-feature-b): "Update {{config/blast-radius.json}} to add the key." + "Update {{src/b_module.py}}."
                           C (demo-feature-c): "Update {{config/blast-radius.json}} with a second key."
                           D (demo-feature-d): "Update {{src/d_module.py}}; run {{git diff config/blast-radius.json}}."
                           expected: A and D shared_surfaces []; B and C shared_surfaces [config/blast-radius.json];
                           at tolerance 100: edge (B, C) hard true; no edge and no tolerated overlap for any pair with A or D
flag-absent-matches-current  plan: the glob-mention and command-span task lines together; configs without the key and with false
                           expected paths {FG, src/**/*.py, src/app.py, src/other.py}; normalization of a recorded radius with
                           ["src/**/*.py", "src/x.ts"] returns it unchanged in both configs; V1 and V2 findings []
```

W3 matching: the first word after an optional bold label is compared case-insensitively to the
read-verb set; the write-verb set is matched case-insensitively as whole words anywhere in the title.

B32 — tests in the Python write-intent module:

```text
test_w1_glob_mention_tokens_are_dropped
test_w1_feature_folder_glob_is_never_dropped
test_w2_multi_word_span_tokens_are_dropped
test_w3_read_task_tokens_are_dropped
test_w3_write_verb_overrides_read_verb
test_w4_tokens_outside_path_roots_are_dropped
test_w4_disabled_when_path_roots_empty
test_w5_spec_contributes_contracts_only
test_w6_placeholder_stem_tokens_are_dropped
test_shared_surface_read_citation_is_not_hard
test_flag_absent_matches_current_behavior
test_flag_false_matches_current_behavior
test_derived_radius_passes_v1_v2_in_write_intent_mode
test_write_intent_vocabularies_match_powershell
test_property_write_intent_rules_never_add_a_token
test_write_intent_fixture_reproduces_expected_radius[<8 fixture stems>]
test_write_intent_reader_rejects_invalid_shape[flag-string, flag-int, path-roots-string, path-roots-non-string-entry]
test_normalization_keeps_feature_folder_glob_in_write_intent_mode
```

B33 — Python write-intent module contract: constants READ_VERBS ("Read", "Verify", "Confirm",
"Inspect", "Review", "Baseline"), WRITE_VERBS ("Fix", "Write", "Update", "Edit", "Add", "Create",
"Delete", "Remove", "Rename", "Author", "Append", "Replace"), and PLACEHOLDER_STEMS (the 26 single ASCII
letters plus foo, bar, baz, example, sample, placeholder; stems are compared case-insensitively). Readers: write_intent_extraction must be a
boolean when present; path_roots must be a list of non-empty strings when present. W1 drops any token
containing * or ?; W2 drops every token of an inline span that splits into more than one word; W3 uses
the plan-acceptance-gates attribution window (a task line plus following non-task lines up to the next
ATX heading); W4 strips a leading "./" and drops a concrete token whose first segment is not in
path_roots and is not a configured root surface (disabled when path_roots is empty or absent); W5 makes
the spec contribute contracts only, with W1 and W2 applied to contract harvesting; W6 drops a concrete
token whose final-component stem is in PLACEHOLDER_STEMS. The token-level filter (W1, W4, W6) applies in
normalization and keeps an entry that starts with docs/features/, ends with "/**", and has no other
wildcard (the feature-folder glob). The selector returns the write-intent plan paths when the flag is
true and the current plan paths otherwise.

B34 — Pester It blocks in the write-intent test file: one It per B32 test in sentence form, including
'reproduces the expected radius for <FixtureName>' over the eight fixtures and 'pins the same read-verb,
write-verb, and placeholder-stem sets as the Python module'.

B35 — PowerShell write-intent module contract: the B33 semantics with Test-WriteIntentExtractionEnabled,
Get-ConfigPathRoot, Get-WriteIntentPlanPath, Get-WriteIntentSpecContract, Select-WriteIntentPathEntry,
and Get-PlanPathForConfig, and the constants $script:WriteIntentReadVerb, $script:WriteIntentWriteVerb,
and $script:WriteIntentPlaceholderStem in the same order as B33.

B36 — detection verdict node IDs: every test_conflict_fixture_reproduces_the_expected_verdict and
test_conflict_fixture_reproduces_the_expected_reasons node of the Python parity module (selected with
CMD-PY-TEST-K and expression "conflict_fixture_reproduces"), and the Pester parity file filtered with
*Blast-radius contention parity*.

B37 — mirror pairs: the BlastRadius, BlastRadiusScheduling, BlastRadiusWriteIntent, and
BlastRadiusValidation modules; the Pester runsettings pair; the parallel-orchestration rule file; the
parallel-plan and parallel-add skills; the parallel-planner agent.

B38 — Python production files for final coverage: `scripts/dev_tools/_blast_radius_scheduling.py`,
`scripts/dev_tools/_parallel_drift_scheduling.py`, `scripts/dev_tools/_blast_radius_write_intent.py`,
`scripts/dev_tools/compute_blast_radius.py`, `scripts/dev_tools/_blast_radius_validation.py`,
and `scripts/dev_tools/parallel_drift_detection.py` (six files).

B40 — PowerShell files for final QA: the three new or changed modules of Phases 5 and 10 plus the
validation module, the four Pester files written by this plan, and the self-hosted runsettings file.

B41 — PowerShell modules for final coverage: `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`,
`.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1`, `.claude/lib/blast-radius/BlastRadius.psm1`,
and `.claude/lib/blast-radius/BlastRadiusValidation.psm1`.

## Acceptance Criteria Traceability

| ID | Spec criterion (abbreviated) | Implementation | Tests / verification | Evidence |
| --- | --- | --- | --- | --- |
| AC-01 | P0 #452 detection gate | P0-T20..P0-T22 | P0-T21, P0-T22, P14-T3 | evidence/baseline/452-gate-python, 452-gate-powershell |
| AC-02 | P0 historical re-derivation, both runtimes | P0-T23..P0-T27 | P0-T27 | evidence/baseline/historical-before-rederivation |
| AC-03 | three historical fixtures with BEFORE and AFTER | P3-T6..P3-T8, P12-T4 | P3-T10, P12-T7 | evidence/regression-testing/historical-after-tests |
| AC-04 | final BEFORE/AFTER evidence incl. W2, W3, W5 | P12-T1..P12-T3 | P12-T2 | evidence/qa-gates/historical-before-after-summary |
| AC-05 | historical tests read committed fixtures only | P3-T9, P5-T3, P12-T5, P12-T6 | P12-T7, P12-T10 | evidence/qa-gates/historical-tests-no-forbidden-refs |
| AC-06 | detection relation unchanged | none (no detection edit) | P7-T3, P14-T4, P14-T5 | evidence/qa-gates/detection-unchanged-final |
| AC-07 | strict identity tests, Python and Pester | P1-T10, P5-T5 | P7-T1, P7-T2 | evidence/qa-gates/part-a-strict-identity-python |
| AC-08 | absent-key identity fixture | P1-T6 | P7-T1, P7-T2 | evidence/qa-gates/part-a-strict-identity-powershell |
| AC-09 | #452 shared-surface case hard | P1-T2 | P7-T1, P7-T2 | evidence/qa-gates/part-a-strict-identity-python |
| AC-10 | #452 directory-prefix case weighted, edge at 0 | P1-T3 | P7-T1, P7-T2 | evidence/qa-gates/part-a-strict-identity-python |
| AC-11 | #452 negative controls edge-free | P1-T4 | P7-T1, P7-T2 | evidence/qa-gates/part-a-strict-identity-powershell |
| AC-12 | #452 fixtures embed radii | P1-T2..P1-T4 | P7-T1 | evidence/qa-gates/part-a-strict-identity-python |
| AC-13 | edge rule implemented, each term tested | P1-T10, P5-T5 | P1-T12, P5-T10 | evidence/regression-testing/scheduling-tests-pass, pester-part-a |
| AC-14 | soft-pair tolerated fixture | P1-T5 | P7-T1, P7-T2 | evidence/qa-gates/part-a-strict-identity-python |
| AC-15 | hypothesis property tests | P1-T8 | P1-T12 | evidence/regression-testing/scheduling-tests-pass |
| AC-16 | conflict_tolerance reader rejections, both runtimes | P1-T10, P5-T5 | P1-T12, P5-T10 | evidence/regression-testing/pester-part-a |
| AC-17 | both config copies carry committed values | P3-T2, P3-T3 | P3-T10 | evidence/regression-testing/config-and-historical-before |
| AC-18 | skills and agent call scheduling function | P6-T3..P6-T8 | P6-T9 | evidence/regression-testing/mirror-contract-p6 |
| AC-19 | enum unchanged; tolerated fields accepted | P2-T3, P4-T6 | P2-T7, P4-T7 | evidence/regression-testing/drift-and-validator-tests, ts-part-a-tests |
| AC-20 | drift via helper module | P2-T5, P2-T6 | P2-T7 | evidence/regression-testing/drift-and-validator-tests |
| AC-21 | drift module not grown; drift tests unmodified | P2-T6 | P2-T8, P18-T1 | evidence/qa-gates/drift-tests-unmodified |
| AC-22 | W1-W6 in both runtimes | P8-T5, P10-T4 | P8-T8, P10-T10 | evidence/regression-testing/write-intent-python, pester-part-b |
| AC-23 | shared-surface read-citation fixture | P8-T2 | P8-T8, P10-T10 | evidence/regression-testing/write-intent-python |
| AC-24 | spec-contracts-only fixture | P8-T2 | P8-T8, P10-T10 | evidence/regression-testing/write-intent-python |
| AC-25 | flag-absent identity fixture, both runtimes | P8-T6, P10-T5 | P8-T8, P10-T10 | evidence/regression-testing/pester-part-b |
| AC-26 | derived radius passes V1 and V2 in write-intent mode | P8-T7, P10-T6 | P8-T8, P10-T10 | evidence/regression-testing/write-intent-python |
| AC-27 | vocabularies pinned by parity test | P8-T5, P10-T4 | P8-T8, P10-T10 | evidence/regression-testing/pester-part-b |
| AC-28 | config copies: mandate amendment, flag, path_roots | P9-T2..P9-T4 | P9-T7 | evidence/regression-testing/config-part-b |
| AC-29 | key-partition tests classify new keys | P3-T4, P9-T5, P9-T6, P5-T4, P10-T3 | P9-T7, P10-T10 | evidence/regression-testing/config-part-b |
| AC-30 | TypeScript carries three keys; tests pass | P4-T1..P4-T5, P11-T1..P11-T4 | P11-T5 | evidence/regression-testing/ts-part-b-tests |
| AC-31 | mirrors, runsettings, pack manifest | P5-T7..P5-T9, P10-T7, P10-T9 | P14-T6, P17-T4, P13-T2 | evidence/qa-gates/mirrors-final |
| AC-32 | no bash file changed | none | P14-T7 | evidence/qa-gates/bash-untouched |
| AC-33 | rule-file amendment, content-identical mirror | P6-T1, P6-T2, P13-T1, P13-T2 | P13-T2, P14-T6 | evidence/regression-testing/mirror-contract-p13 |
| AC-34 | Python toolchain and coverage | Phases 1-3, 8-9, 12 | P15-T1..P15-T5 | evidence/qa-gates/final-python-pytest-coverage |
| AC-35 | PowerShell toolchain and coverage | Phases 5, 10, 12 | P16-T1..P16-T5 | evidence/qa-gates/final-powershell-pester-coverage |
| AC-36 | TypeScript toolchain and coverage | Phases 4, 11 | P17-T1..P17-T5 | evidence/qa-gates/final-ts-jest-coverage |
| AC-37 | 500-line limit and batch budgets | all batches | P18-T1, P18-T2 | evidence/qa-gates/batch-accounting |
| AC-38 | CI green incl. windows-latest Pester | P18-T6 | P18-T6, P18-T7 | evidence/qa-gates/ci-status |

## Planner Adversarial Self-Review

SELF-REVIEW: RE-DERIVED THIS PASS

Initial authoring pass. Every citation below was read directly in the current tree of this worktree
during this pass; none is carried forward from the research note without re-reading.

- scripts/dev_tools/_blast_radius_conflicts.py: CONFLICT_KINDS order at lines 56-61 (path_overlap,
  module_overlap, shared_surface_overlap, contract_dependency); conflicts at line 160 reads only
  mergeable_paths from config (lines 181-191). Drives B5 recorded reason and the claim that scheduling
  fixtures need only mergeable_paths plus conflict_tolerance.
- scripts/dev_tools/_blast_radius_glob.py: public name list at lines 58-66 includes _entries_overlap as
  an intentional package-internal export; entry-overlap function at line 273.
- scripts/dev_tools/_blast_radius_mergeable.py: matches_mergeable_path at line 82 and
  exclude_mergeable_paths at line 137 (reused by B12 for append_only matching).
- scripts/dev_tools/compute_blast_radius.py: 421 lines; derive_blast_radius at line 223 (spec paths
  from all lines at 268-272); normalize_declared_radius at line 294 takes no feature folder (drives the
  B33 feature-folder-glob shape rule); FEATURE_FOLDER_ROOT and FEATURE_FOLDER_PREFIX at lines 99-100.
- scripts/dev_tools/_blast_radius_extraction.py: PLAN_TASK_RE at lines 61-63; inline span split at
  238; classify_path_token at 243 rejects directory-shaped tokens (line 324) and accepts a glob by
  extension (330); extract_contract_identifiers at 416 harvests separator-free lettered tokens (472).
  Drives B31 expected values.
- scripts/dev_tools/parallel_drift_detection.py: 499 lines; recompute_conflicts_with_observed at 271;
  _existing_edge_pairs at 447 and _observed_contends at 473 are referenced only inside this module
  (repository-wide search), so relocation breaks no test import.
- scripts/dev_tools/_blast_radius_validation.py: 464 lines; validate_blast_radius at 296.
- .claude/lib/blast-radius/BlastRadius.psm1: 438 lines; sibling imports at 57-62; Test-BlastRadiusConflict
  at 342-430 with parameters RadiusA, RadiusB, Config; export list at 432-438.
- .claude/lib/blast-radius/BlastRadiusValidation.psm1: 374 lines; own imports at 39-42; Get-PlanPaths
  call at 360.
- .claude/lib/blast-radius/BlastRadiusConflict.psm1: Get-ConfigMergeablePath 47, Test-MergeablePath 74,
  Get-NonMergeablePathEntry 148; BlastRadiusGlob.psm1: Test-EntryOverlap 273.
- scripts/powershell/PoshQC/settings/pester.runsettings.psd1: blast-radius coverage group at 174-185;
  the extension resources copy carries the same lines.
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json: blast-radius module
  entries at 136-144; config entry at 162.
- extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts: 380 lines; CARRIED_KEYS
  at 132-139 (append-only indexing); document literal at 369-377.
- extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts: 472 lines; key-order
  expectation at 448-454.
- extensions/drm-copilot/jest.config.cjs: coverageThreshold entry for the derivation core at 238-240
  (lines 85, branches 75) and for parallel-state-structures at 213-215; drives P17-T4.
- extensions/drm-copilot/run-jest.cjs: forwards arguments to jest with the local config (lines 21-32).
- extensions/drm-copilot/package.json: scripts format, lint, typecheck, test, test:coverage at 207-212;
  no dependency-cruiser script.
- tests/scripts/dev_tools/blast_radius_parity_test_support.py: 257 lines; BYTE_EQUAL_KEYS 108-113;
  CLASS_TWO_KEY_ASSERTIONS 120-123; DECLARED_TOP_LEVEL_KEYS 143-145; unconsumed_class_keys 216.
- tests/scripts/dev_tools/test_blast_radius_config_parity.py: 499 lines; byte-equal test at 182-183;
  exhaustiveness test at 205; registry-consumption check at 372-374 resolves names in its own globals
  (drives the separate registry of P9-T5).
- tests/scripts/dev_tools/test_blast_radius_parity.py: fixture ids are file stems (174-177); the four
  parametrized tests at 364-444 (drives B1).
- tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1: It names include the fixture name
  (239, 254, 275, 290); drives P0-T22 filters.
- tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1: 271 lines; ClassOneKeys at
  33; ClassTwoKeyConsumerFile at 40-43; consumer-file check at 246-249.
- tests/fixtures/blast_radius: five #452-tagged fixtures (search for the literal #452); the
  directory-vs-glob and sibling-prefix radii read at their input blocks (drive B6 and B7).
- config/blast-radius.json and the bundled copy: current key sets and values read in full; bundled
  mandate_reads equals self-hosted mandate_reads.
- pyproject.toml: addopts at line 115 supplies only an LCOV reporter (drives the explicit
  term-missing and json reporters of CMD-PY-COV); coverage source at 119.
- .claude/hooks/enforce-powershell-batch-budget.ps1: treats .ps1, .psm1, and .psd1 as PowerShell
  source (lines 7, 34), so the runsettings file counts against the budget (drives the P10 split).
- .claude/hooks/enforce-python-batch-budget.ps1: state file under .claude/state named by kind and
  session (lines 349, 363); drives A8.
- extensions/drm-copilot/CHANGELOG.md: the only tracked changelog found (drives B2).

Sibling-region checks performed in this pass: the drift module's other private helpers
(_latest_events_by_item, _radii_by_item_key, _is_drift_resolved) stay in place; the facade's
Get-NormalizedDeclaredRadius (202-286) is the only other facade function Part B edits; the
config-parity module is not edited because it is at 499 lines.

---

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
CITATION: scripts/dev_tools/_blast_radius_conflicts.py | lines 56-61 CONFLICT_KINDS; line 160 conflicts; lines 181-191 config read
CITATION: scripts/dev_tools/_blast_radius_glob.py | lines 58-66 public names; line 273 _entries_overlap
CITATION: scripts/dev_tools/_blast_radius_mergeable.py | line 82 matches_mergeable_path; line 137 exclude_mergeable_paths
CITATION: scripts/dev_tools/compute_blast_radius.py | 421 lines; line 223 derive_blast_radius; line 294 normalize_declared_radius; lines 99-100 feature folder constants
CITATION: scripts/dev_tools/_blast_radius_extraction.py | lines 61-63 PLAN_TASK_RE; line 243 classify_path_token; line 416 extract_contract_identifiers
CITATION: scripts/dev_tools/parallel_drift_detection.py | 499 lines; line 271 recompute_conflicts_with_observed; lines 447 and 473 private helpers
CITATION: scripts/dev_tools/_blast_radius_validation.py | 464 lines; line 296 validate_blast_radius
CITATION: .claude/lib/blast-radius/BlastRadius.psm1 | 438 lines; lines 57-62 imports; lines 342-430 Test-BlastRadiusConflict; lines 432-438 exports
CITATION: .claude/lib/blast-radius/BlastRadiusValidation.psm1 | 374 lines; lines 39-42 imports; line 360 Get-PlanPaths call
CITATION: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | lines 174-185 blast-radius coverage paths
CITATION: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json | lines 136-144 blast-radius module entries
CITATION: extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts | lines 132-139 CARRIED_KEYS; lines 369-377 document literal
CITATION: extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts | lines 448-454 key-order expectation
CITATION: extensions/drm-copilot/jest.config.cjs | lines 238-240 derivation-core coverage threshold
CITATION: tests/scripts/dev_tools/blast_radius_parity_test_support.py | lines 108-113 BYTE_EQUAL_KEYS; lines 120-123 Class 2 registry; lines 143-145 declared keys
CITATION: tests/scripts/dev_tools/test_blast_radius_config_parity.py | lines 182-183 byte-equal test; line 205 exhaustiveness test; lines 372-374 registry consumption
CITATION: tests/scripts/dev_tools/test_blast_radius_parity.py | lines 174-177 fixture stems; lines 364-444 parametrized tests
CITATION: tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | line 33 ClassOneKeys; lines 40-43 Class 2 consumer registry
CITATION: tests/fixtures/blast_radius/conflict-directory-vs-glob.json | input radii paths
CITATION: config/blast-radius.json | full file; mandate_reads lines 20-32
CITATION: pyproject.toml | line 115 addopts LCOV-only reporter
CITATION: .claude/hooks/enforce-powershell-batch-budget.ps1 | lines 7 and 34 PowerShell source extensions
AC-INVENTORY: AC-01, AC-02, AC-03, AC-04, AC-05, AC-06, AC-07, AC-08, AC-09, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-20, AC-21, AC-22, AC-23, AC-24, AC-25, AC-26, AC-27, AC-28, AC-29, AC-30, AC-31, AC-32, AC-33, AC-34, AC-35, AC-36, AC-37, AC-38
AC-MAPPING: AC-01 | IMPLEMENTATION: P0-T20..P0-T22 | TESTS: P0-T21, P0-T22, P14-T3 | EVIDENCE: evidence/baseline/452-gate-python
AC-MAPPING: AC-02 | IMPLEMENTATION: P0-T23..P0-T27 | TESTS: P0-T27 | EVIDENCE: evidence/baseline/historical-before-rederivation
AC-MAPPING: AC-03 | IMPLEMENTATION: P3-T6..P3-T8, P12-T4 | TESTS: P3-T10, P12-T7 | EVIDENCE: evidence/regression-testing/historical-after-tests
AC-MAPPING: AC-04 | IMPLEMENTATION: P12-T1..P12-T3 | TESTS: P12-T2 | EVIDENCE: evidence/qa-gates/historical-before-after-summary
AC-MAPPING: AC-05 | IMPLEMENTATION: P3-T9, P5-T3, P12-T5, P12-T6 | TESTS: P12-T7, P12-T10 | EVIDENCE: evidence/qa-gates/historical-tests-no-forbidden-refs
AC-MAPPING: AC-06 | IMPLEMENTATION: no detection edit | TESTS: P7-T3, P14-T4, P14-T5 | EVIDENCE: evidence/qa-gates/detection-unchanged-final
AC-MAPPING: AC-07 | IMPLEMENTATION: P1-T10, P5-T5 | TESTS: P7-T1, P7-T2 | EVIDENCE: evidence/qa-gates/part-a-strict-identity-python
AC-MAPPING: AC-08 | IMPLEMENTATION: P1-T6 | TESTS: P7-T1, P7-T2 | EVIDENCE: evidence/qa-gates/part-a-strict-identity-powershell
AC-MAPPING: AC-09 | IMPLEMENTATION: P1-T2 | TESTS: P7-T1, P7-T2 | EVIDENCE: evidence/qa-gates/part-a-strict-identity-python
AC-MAPPING: AC-10 | IMPLEMENTATION: P1-T3 | TESTS: P7-T1, P7-T2 | EVIDENCE: evidence/qa-gates/part-a-strict-identity-python
AC-MAPPING: AC-11 | IMPLEMENTATION: P1-T4 | TESTS: P7-T1, P7-T2 | EVIDENCE: evidence/qa-gates/part-a-strict-identity-powershell
AC-MAPPING: AC-12 | IMPLEMENTATION: P1-T2..P1-T4 | TESTS: P7-T1 | EVIDENCE: evidence/qa-gates/part-a-strict-identity-python
AC-MAPPING: AC-13 | IMPLEMENTATION: P1-T10, P5-T5 | TESTS: P1-T12, P5-T10 | EVIDENCE: evidence/regression-testing/scheduling-tests-pass
AC-MAPPING: AC-14 | IMPLEMENTATION: P1-T5 | TESTS: P7-T1, P7-T2 | EVIDENCE: evidence/qa-gates/part-a-strict-identity-python
AC-MAPPING: AC-15 | IMPLEMENTATION: P1-T8 | TESTS: P1-T12 | EVIDENCE: evidence/regression-testing/scheduling-tests-pass
AC-MAPPING: AC-16 | IMPLEMENTATION: P1-T10, P5-T5 | TESTS: P1-T12, P5-T10 | EVIDENCE: evidence/regression-testing/pester-part-a
AC-MAPPING: AC-17 | IMPLEMENTATION: P3-T2, P3-T3 | TESTS: P3-T10 | EVIDENCE: evidence/regression-testing/config-and-historical-before
AC-MAPPING: AC-18 | IMPLEMENTATION: P6-T3..P6-T8 | TESTS: P6-T9 | EVIDENCE: evidence/regression-testing/mirror-contract-p6
AC-MAPPING: AC-19 | IMPLEMENTATION: P2-T3, P4-T6 | TESTS: P2-T7, P4-T7 | EVIDENCE: evidence/regression-testing/drift-and-validator-tests
AC-MAPPING: AC-20 | IMPLEMENTATION: P2-T5, P2-T6 | TESTS: P2-T7 | EVIDENCE: evidence/regression-testing/drift-and-validator-tests
AC-MAPPING: AC-21 | IMPLEMENTATION: P2-T6 | TESTS: P2-T8, P18-T1 | EVIDENCE: evidence/qa-gates/drift-tests-unmodified
AC-MAPPING: AC-22 | IMPLEMENTATION: P8-T5, P10-T4 | TESTS: P8-T8, P10-T10 | EVIDENCE: evidence/regression-testing/write-intent-python
AC-MAPPING: AC-23 | IMPLEMENTATION: P8-T2 | TESTS: P8-T8, P10-T10 | EVIDENCE: evidence/regression-testing/write-intent-python
AC-MAPPING: AC-24 | IMPLEMENTATION: P8-T2 | TESTS: P8-T8, P10-T10 | EVIDENCE: evidence/regression-testing/write-intent-python
AC-MAPPING: AC-25 | IMPLEMENTATION: P8-T6, P10-T5 | TESTS: P8-T8, P10-T10 | EVIDENCE: evidence/regression-testing/pester-part-b
AC-MAPPING: AC-26 | IMPLEMENTATION: P8-T7, P10-T6 | TESTS: P8-T8, P10-T10 | EVIDENCE: evidence/regression-testing/write-intent-python
AC-MAPPING: AC-27 | IMPLEMENTATION: P8-T5, P10-T4 | TESTS: P8-T8, P10-T10 | EVIDENCE: evidence/regression-testing/pester-part-b
AC-MAPPING: AC-28 | IMPLEMENTATION: P9-T2..P9-T4 | TESTS: P9-T7 | EVIDENCE: evidence/regression-testing/config-part-b
AC-MAPPING: AC-29 | IMPLEMENTATION: P3-T4, P9-T5, P9-T6, P5-T4, P10-T3 | TESTS: P9-T7, P10-T10 | EVIDENCE: evidence/regression-testing/config-part-b
AC-MAPPING: AC-30 | IMPLEMENTATION: P4-T1..P4-T5, P11-T1..P11-T4 | TESTS: P11-T5 | EVIDENCE: evidence/regression-testing/ts-part-b-tests
AC-MAPPING: AC-31 | IMPLEMENTATION: P5-T7..P5-T9, P10-T7, P10-T9 | TESTS: P14-T6, P17-T4, P13-T2 | EVIDENCE: evidence/qa-gates/mirrors-final
AC-MAPPING: AC-32 | IMPLEMENTATION: no bash edit | TESTS: P14-T7 | EVIDENCE: evidence/qa-gates/bash-untouched
AC-MAPPING: AC-33 | IMPLEMENTATION: P6-T1, P6-T2, P13-T1, P13-T2 | TESTS: P13-T2, P14-T6 | EVIDENCE: evidence/regression-testing/mirror-contract-p13
AC-MAPPING: AC-34 | IMPLEMENTATION: Phases 1-3, 8-9, 12 | TESTS: P15-T1..P15-T5 | EVIDENCE: evidence/qa-gates/final-python-pytest-coverage
AC-MAPPING: AC-35 | IMPLEMENTATION: Phases 5, 10, 12 | TESTS: P16-T1..P16-T5 | EVIDENCE: evidence/qa-gates/final-powershell-pester-coverage
AC-MAPPING: AC-36 | IMPLEMENTATION: Phases 4, 11 | TESTS: P17-T1..P17-T5 | EVIDENCE: evidence/qa-gates/final-ts-jest-coverage
AC-MAPPING: AC-37 | IMPLEMENTATION: all batches | TESTS: P18-T1, P18-T2 | EVIDENCE: evidence/qa-gates/batch-accounting
AC-MAPPING: AC-38 | IMPLEMENTATION: P18-T6 | TESTS: P18-T6, P18-T7 | EVIDENCE: evidence/qa-gates/ci-status
UNRESOLVED-GAPS: NONE
