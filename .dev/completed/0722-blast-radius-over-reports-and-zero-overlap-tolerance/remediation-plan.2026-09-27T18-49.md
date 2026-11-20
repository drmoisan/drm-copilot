# blast-radius-over-reports-and-zero-overlap-tolerance (Remediation Plan, Cycle 1)

- **Issue:** #722
- **Pull request:** #748 (head f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T18-49
- **Status:** Draft (preflight revision 2 applied; pending executor preflight)
- **Work Mode:** full-bug (spec.md is the acceptance-criteria source; this cycle's requirements
  source is FEATURE/remediation-inputs.2026-09-27T18-49.md)
- **Branch:** bug/blast-radius-over-reports-and-zero-overlap-tolerance-722
- **Main plan:** FEATURE/plan.2026-09-27T12-16.md (executed through P18-T5; P18-T6 and P18-T7 remain open)

## Preamble

### Findings in scope

- **R1** Order-dependent run-time lookup of the detection relation. Get-ConflictRelationCommand in
  `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` (lines 320-331) resolves
  Test-BlastRadiusConflict with Get-Command from the scheduling module's own scope; it fails with
  "Test-BlastRadiusConflict is not available; import the facade module BlastRadius.psm1 before
  scheduling." whenever the facade is not visible from that scope (34 CI failures).
- **R2** The no-Python-invocation guard rejects the ampersand invocation of the local variable
  relation at line 384 of the same module, because that variable is not a [scriptblock] parameter
  (1 CI failure).

### Chosen design

1. The relation becomes an explicit [scriptblock] parameter named Relation on the two relation-using
   functions, Get-BlastRadiusPairDecision and Get-BlastRadiusConflictEdge. The conflict-edge function
   forwards it to every pair decision; the pair decision invokes it once with RadiusA first. No
   command is resolved at run time, so the result cannot depend on import order or a global import.
2. Get-ConflictRelationCommand, its two script-scope constants, and its Get-Command call are deleted.
   An omitted relation fails fast at the top of both functions with the fixed message
   "-Relation is required: pass ${function:Test-BlastRadiusConflict} from the facade module
   BlastRadius.psm1." The message does not depend on which modules are loaded, so a caller that
   imports only the scheduling module receives the same deterministic error in every session.
3. A caller that imports the facade supplies the facade's own function object,
   ${function:Test-BlastRadiusConflict}. A function script block stays bound to the module that
   defined it, so the relation runs in the facade's session state whatever scope invokes it.
4. Test-BlastRadiusConflict is not edited or moved; only the facade's header comment changes.
   The facade export list is unchanged, so the fourteen-name export test in
   tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 (lines 469-475) is unaffected.
5. The API change is confined to functions added by this unmerged feature. Every in-repository caller
   (three Pester files, three documentation files, and their bundled mirrors) is updated here.

Rejected alternatives: a script-block default that names Test-BlastRadiusConflict still resolves the
command from the scheduling module's scope (R1 persists); same-named facade wrapper functions depend
on nested-module shadowing and module-qualified resolution, which this plan cannot verify before
execution; an import of the facade from the scheduling module creates an import cycle (facade line 74).

### Guard form (R2)

The guard helper `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`
collects every [scriptblock]-typed parameter name declared anywhere in the scanned file (lines
128-165, TypeConstraintAst named scriptblock, case-insensitive) and skips an ampersand-invoked
variable whose name is in that set (carve-out (a), lines 36-39 and 372-375). The suite pins that form
in "reports no finding for a scriptblock-parameter seam invocation" and "reports no finding when a
seam variable differs from its parameter by letter case" (lines 350-385 of
tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1). An ampersand
invocation of the parameter Relation therefore produces no finding.

### Terms

- FEATURE means docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.
- TS means the execution time of the task in yyyy-MM-ddTHH-mm form.
- SCRATCH means the executor's session scratchpad directory, outside the repository. Artifacts record
  the literal token SCRATCH, never a host path.
- Artifacts replace the absolute repository root path with the literal token ROOT.
- R_HEAD means the commit recorded by P0-T5 (HEAD before any remediation edit).
- R_MAIN_BASE means the merge-base recorded by P0-T5 (FINAL_BASE of the main plan when origin/main
  has not been merged again).
- The executor has no PowerShell tool. Every PowerShell script runs through CMD-PS-SCRIPT-SH
  (script A1). Command text never contains the words that the worktree isolation hook refuses, and
  never contains loops, shell variables, heredocs, compound commands, or cd-chains.
- Every command-step artifact carries Timestamp:, Command:, EXIT_CODE:, and Output Summary:. An
  artifact whose expected exit code is not 0 also carries ExpectedExitCode:.
- KL-510 has the meaning defined in the Terms of the main plan (issue #510 bundle-state case (a)
  PASSED or case (b) STATE-ONLY).
- The #452 Pester gate form has the meaning defined in the Terms of the main plan. Its gate fixtures
  are the five recorded by the main plan's P14-T2: conflict-directory-vs-glob,
  conflict-directory-vs-file, conflict-sibling-prefix-disjoint, derivation-root-surface-reached, and
  derivation-root-surface-not-configured.
- AC-38 of the spec is not checked off by this cycle. The coordinator re-runs CI.

### Files written by this cycle

Production PowerShell (2): `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`,
`.claude/lib/blast-radius/BlastRadius.psm1` (header comment only).

Pester (3): `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1`,
`tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`,
`tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1`.

Documentation (3): `.claude/agents/parallel-planner.md`, `.claude/skills/parallel-plan/SKILL.md`,
`.claude/skills/parallel-add/SKILL.md`.

Mirrors (5, produced only by copy with script A10):
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1`,
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1`,
`extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`,
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`,
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`.

No Python, TypeScript, bash, rule, or .github instruction file is written. The PowerShell batch is
one batch of 2 production and 3 test files, opened by the budget reset of P1-T1.

### Test-change boundary (inputs constraint 5)

Existing tests change only by passing the relation explicitly, with one exception that cannot take
that form: the It "fails fast naming the facade when Test-BlastRadiusConflict is unavailable" (lines
354-357 of the scheduling Pester file) mocks Get-Command inside the scheduling module, and the
scheduling module no longer calls Get-Command. It is replaced by an It asserting the successor
fail-fast path without a mock (the message still names BlastRadius.psm1), and one new It proves the
supplied relation is the one invoked. No assertion is weakened and no other test is removed.

### Shell route and command catalogue

Every command-bearing task names one or more entries below. Angle-bracket fields are filled from the
task text. Commands run from the repository root of this worktree.

```text
CMD-GIT-HEAD          git rev-parse HEAD
CMD-GIT-REMOTE-HEAD   git rev-parse origin/bug/blast-radius-over-reports-and-zero-overlap-tolerance-722
CMD-GIT-SHOW-NAMES    git show --name-only --format= HEAD
CMD-GIT-ANCESTOR      git merge-base --is-ancestor f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d HEAD
CMD-GIT-FETCH-MAIN    git fetch origin main
CMD-GIT-MERGE-BASE    git merge-base HEAD origin/main
CMD-GIT-STATUS        git status --porcelain
CMD-GIT-STATUS-PATH   git status --porcelain -- <pathspec>
CMD-GIT-DIFF-NAMES    git diff --name-only <base> -- <pathspec>
CMD-GIT-ADD           git add -- <exact paths listed in the task>
CMD-GIT-COMMIT        git commit -m "<message>" --trailer "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>" --trailer "Claude-Session: https://claude.ai/code/session_01P1iNMUJbD7Uf29ACDCXuYg"
CMD-GIT-PUSH          git push origin bug/blast-radius-over-reports-and-zero-overlap-tolerance-722
CMD-GIT-COUNT-OPEN    git grep -c -F -e "- [ ]" -- <FEATURE>/spec.md
CMD-GH-RUN            gh run view 36356018317 --json conclusion,headSha,status
CMD-PS-SCRIPT-SH      sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>        (Bash tool; the only PowerShell route)
CMD-PY-SCRIPT         poetry run python SCRATCH/<script>.py <args>
CMD-PY-TEST           poetry run pytest -v <node IDs or files listed in the task>
CMD-TS-TEST           npm --prefix extensions/drm-copilot run test -- <test paths relative to extensions/drm-copilot>
MCP-PS-FORMAT         mcp__drm-copilot__run_poshqc_format (workspace_root = repository root, scan_folders = paths listed in the task)
```

Observed success outputs relied on (from recorded runs of the main plan): script A2 and A3 print
TotalCount=, PassedCount=, and FailedCount= lines and one FAILED: line per failing test; A3 prints one
line beginning "COVERAGE file=" per coverage path; Pester Detailed output prints "[+]" for a passing
and "[-]" for a failing It; A5 prints "Hash=" per file; A6 prints "FORMAT-SUMMARY ChangedCount=";
A8 prints a line beginning "RESET removed="; A9 prints "BODY-EQUAL=True" or "BODY-EQUAL=False";
A10 prints "COPIED"; B42 prints "CHANGED file=... Found=True ... ChangedLinePercent=";
Invoke-PoshQCTest prints "Tests Passed: N, Failed: N, Skipped: N, Inconclusive: N, NotRun: N"
(`scripts/powershell/PoshQC/PoshQC.Testing.psm1` lines 423-428); git grep -c prints "path:count"
and exits 1 with no output on zero matches. Scripts R1 through R4 are new; each prints a fixed
summary line on success (R1 prints PESTER-FAILED-TOTAL= and JUNIT-SUMMARY lines; R4 prints
CI-FAILED-COUNT=), and R1, R2, and R4 exit non-zero on failure by construction (Appendix R).
Pester 5.6.1 sets the global LASTEXITCODE to FailedCount plus FailedBlocksCount plus
FailedContainersCount at the end of a run, while the JUnit file holds only test cases; R1 records
both so a failed block or container that produces no failed test case is still observed.

### CI invocation mirrored

The poshqc job runs, on windows-latest in one pwsh process, Import-Module of
scripts/powershell/PoshQC/PoshQC.psm1 followed by Invoke-PoshQCTest -Root at the workspace root
(`.github/workflows/_poshqc.yml` lines 38-42). Invoke-PoshQCTest loads
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (Run.Path scripts, tests/powershell,
tests/scripts; Run.Exit true; CodeCoverage enabled; JUnit output to the artifacts pester directory),
applies config/poshqc-scan.json (the same three folders), and hosts Invoke-Pester in the global
session state through its trampoline (`scripts/powershell/PoshQC/PoshQC.Testing.psm1` lines 261-281).
Script R1 performs the same call with two differences: its BuildConfiguration seam sets Run.Exit to
false so the process survives to read the JUnit file and print a summary, and it imports Pester
5.6.1 explicitly before PoshQC (under the A1 route this host lists Pester 5.6.1 and 3.4.0; the pin
guards against a different version resolving first on another host; the EnsureModule seam at
`scripts/powershell/PoshQC/PoshQC.Testing.psm1` lines 160-166 imports Pester by name without a
version). Test selection, ordering, coverage configuration, and the single process are otherwise
identical.

---

### Phase 0 — Policy Reads, Baseline State, and Fail-Before Evidence

- [x] [P0-T1] Read, in order, CLAUDE.md, .github/copilot-instructions.md, and the .github instruction
      files for general code change, general unit test, PowerShell code change, and PowerShell unit
      test. Acceptance: all six read; recorded in P0-T4.
- [x] [P0-T2] Read, in order, the rule files general-code-change, general-unit-test, quality-tiers,
      tonality, powershell, and plan-acceptance-gates under the .claude rules directory, the
      Integration-cost scheduling section of the parallel-orchestration rule file, and the
      evidence-and-timestamp-conventions skill. Acceptance: all read; recorded in P0-T4.
- [x] [P0-T3] Read FEATURE/remediation-inputs.2026-09-27T18-49.md, FEATURE/spec.md, the Terms and
      Appendix A of FEATURE/plan.2026-09-27T12-16.md, and this plan in full. Acceptance: all read;
      recorded in P0-T4.
- [x] [P0-T4] Write FEATURE/evidence/remediation-baseline/phase0-instructions-read.TS.md with
      Timestamp:, Policy Order: (the order of P0-T1 through P0-T3), and the explicit list of every
      file read. Acceptance: the artifact carries the three fields and names every file of P0-T1
      through P0-T3.
- [x] [P0-T5] Record the baseline state: run CMD-GIT-HEAD, CMD-GIT-ANCESTOR, CMD-GIT-FETCH-MAIN,
      CMD-GIT-MERGE-BASE, and CMD-GIT-STATUS. CMD-GIT-HEAD output is R_HEAD; CMD-GIT-MERGE-BASE
      output is R_MAIN_BASE. Write FEATURE/evidence/remediation-baseline/git-state.TS.md.
      Acceptance: every command exits 0; R_HEAD and R_MAIN_BASE are 40 hexadecimal characters;
      CMD-GIT-STATUS prints no line other than an untracked ("??") line for
      FEATURE/remediation-inputs.2026-09-27T18-49.md or FEATURE/remediation-plan.2026-09-27T18-49.md,
      or for the FEATURE/evidence files this phase writes, or the untracked directory line for
      FEATURE/evidence/remediation-baseline/. Stop condition: CMD-GIT-ANCESTOR exits
      non-zero (the branch does not contain the PR head of the inputs) or CMD-GIT-STATUS prints any
      other line; record and report.
- [x] [P0-T6] Create in SCRATCH, with the exact bodies given in Appendix A of the main plan, the
      scripts A1 (run-ps.sh), A2 (pester-counts.ps1), A3 (pester-coverage.ps1), A4
      (line-counts.ps1), A5 (file-hashes.ps1), A6 (ps-format-check.ps1), A8
      (reset-batch-budget.ps1), A9 (function-body-equal.ps1), A10 (copy-file.ps1), and B42
      (changed-lines-cov.py); and, with the exact bodies of Appendix R of this plan, R1
      (poshqc-ci-mirror.ps1), R2 (poshqc-analyze.ps1), R3 (relation-audit.ps1), and R4
      (ci-failed-tests.ps1). Write FEATURE/evidence/remediation-baseline/scratch-scripts.TS.md
      listing the fourteen names. Acceptance: all fourteen files exist in SCRATCH with the specified
      bodies.
- [x] [P0-T7] Mirror identity at baseline: run CMD-PS-SCRIPT-SH with script file-hashes (A5) over the
      five primary files and five mirror files named in "Files written by this cycle". Write
      FEATURE/evidence/remediation-baseline/mirror-hashes-before.TS.md. Acceptance: exit 0 and the
      two Hash values of each of the five pairs are equal. Stop condition: any pair differs; report
      it (a copy would overwrite a divergent mirror).
- [x] [P0-T8] Line counts at baseline: run CMD-PS-SCRIPT-SH with script line-counts (A4) over the
      two production and three Pester files of this cycle. Write
      FEATURE/evidence/remediation-baseline/line-counts-before.TS.md. Acceptance: exit 0; five
      "LineCount=" lines are recorded; the scheduling module prints LineCount=490.
- [x] [P0-T9] Caller and lookup audit at baseline: run CMD-PS-SCRIPT-SH with script relation-audit
      (R3) and argument -Root with value ".". Write
      FEATURE/evidence/remediation-baseline/relation-audit-before.TS.md recording the full output.
      Acceptance: exit 0; the output carries one "CALLER-AUDIT" line, six "DOC file=" lines, and one
      "LOOKUP-AUDIT" line; the LOOKUP-AUDIT line reports RelationHelperLines=2 and GetCommandLines=2.
      The CALLER-AUDIT counts are recorded as observed (expected Calls=21 MissingRelation=21).
- [x] [P0-T10] Record the CI failure: run CMD-GH-RUN, then run R4 through CMD-PS-SCRIPT-SH with
      -RunId 36356018317 and record its full output in the same artifact. Write
      FEATURE/evidence/remediation-baseline/ci-run-36356018317.TS.md (its EXIT_CODE refers to the R4
      run; the CMD-GH-RUN exit code is recorded in the body). Acceptance: CMD-GH-RUN exits 0 and the
      JSON reports conclusion "failure" and headSha f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d; R4
      exits 0; CI-FAILED-COUNT=35, equal to the "Failed: 35" count of the CI "Tests Passed:" summary
      line of run 36356018317. The text of a CI-FAILED line is the Pester expanded path
      (Describe.Context.It), and each line is assigned to a test file by the Describe name its text
      begins with: "BlastRadiusScheduling." to
      tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 (Describe at line 151);
      "Blast-radius historical runs." to
      tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 (line 65);
      "BlastRadiusWriteIntent." to tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1
      (line 110); "enforcement hooks must not invoke Python." to
      tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 (line 99). The
      artifact states the file for each line. Required assignment: 26 scheduling, 6 historical-runs,
      and 2 write-intent lines (the 34 R1 failures), and 1 guard line that contains "reports no
      Python invocation beyond the allowlist across the guarded tree" (R2, the It at line 473). Stop
      condition: a CI-FAILED line that begins with none of the four Describe names, or any other
      count; record and report. The CI-FAILED set is CI_FAILED.
- [x] [P0-T11] [expect-fail] R1 fail-before, scheduling suite alone in a fresh process: run
      CMD-PS-SCRIPT-SH with script pester-coverage (A3) and arguments
      -TestPath tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
      -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1,.claude/lib/blast-radius/BlastRadius.psm1
      -CoverageOutputPath SCRATCH/rem-p0-scheduling.xml. Write
      FEATURE/evidence/regression-testing/failbefore-r1-scheduling-alone.TS.md with
      ExpectedExitCode: 0 (A3 exits 0 whatever the test outcome; the fail signal is FailedCount).
      Acceptance: exit 0; TotalCount, PassedCount, FailedCount, and both COVERAGE lines are recorded
      verbatim. Branch rule, applied mechanically: when FailedCount is greater than 0 and the output
      contains the literal "is not available; import the facade module", the artifact records
      "R1-REPRODUCED-IN-ISOLATION: yes"; otherwise it records "R1-REPRODUCED-IN-ISOLATION: no",
      cites the CI-FAILED lines recorded by P0-T10 as the R1 fail-before evidence, and quotes the
      CI-FAILED lines that P0-T10 assigns to this test file. Either branch satisfies this task.
- [x] [P0-T12] [expect-fail] R1 fail-before, historical-runs suite alone in a fresh process: as
      P0-T11 with -TestPath tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
      and -CoverageOutputPath SCRATCH/rem-p0-historical.xml. Write
      FEATURE/evidence/regression-testing/failbefore-r1-historical-alone.TS.md with
      ExpectedExitCode: 0. Acceptance: as P0-T11, including its branch rule.
- [x] [P0-T13] [expect-fail] R2 fail-before, guard suite alone: run CMD-PS-SCRIPT-SH with script
      pester-counts (A2) and argument
      -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1. Write
      FEATURE/evidence/regression-testing/failbefore-r2-guard.TS.md with ExpectedExitCode: 0 (A2
      exits 0; the fail signal is FailedCount). Acceptance: exit 0; FailedCount=1; exactly one FAILED
      line, and it ends with "reports no Python invocation beyond the allowlist across the guarded
      tree"; the output contains the literal "ampersand-invoked variable $relation is not a
      [scriptblock] parameter". Stop condition: FailedCount is not 1 or the literal is absent; the
      finding differs from R2, so report it.
- [x] [P0-T14] [expect-fail] Full-tree fail-before, as CI runs it: run CMD-PS-SCRIPT-SH with script
      poshqc-ci-mirror (R1) and argument -Root with value "." in the background (Bash tool
      run_in_background), and wait for its completion notification before starting P0-T15. Write
      FEATURE/evidence/regression-testing/failbefore-full-tree-ci-mirror.TS.md with
      ExpectedExitCode: 1, recording the PESTER-VERSION line, the PESTER-FAILED-TOTAL line, the
      "Tests Passed:" summary line, the JUNIT-SUMMARY line, every JUNIT-FAILED line, and the count
      of JUNIT-FAILED lines whose text contains "BlastRadiusScheduling" or "HistoricalRuns" or
      "historical runs". Acceptance: exit 1; the PESTER-VERSION line reads 5.6.1; JUNIT-SUMMARY
      reports a CaseCount of at least 5000 and a FailedCount of at least 1; one JUNIT-FAILED line
      contains "reports no Python invocation beyond the allowlist across the guarded tree". The
      recorded JUNIT-FAILED set is the pre-fix failure set that P2-T5 consults, its CaseCount is
      PRE_CASES, and PESTER-FAILED-TOTAL minus the JUNIT-SUMMARY FailedCount is PRE_EXTRA. Stop
      condition: CaseCount below 5000 (the run did not cover the tree), no JUNIT-SUMMARY line, or a
      PESTER-VERSION line reading any other version.
- [x] [P0-T15] [expect-fail] R1 fail-before, write-intent suite alone in a fresh process (2 of the 34
      R1 CI failures are in this file): as P0-T11 with
      -TestPath tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 and
      -CoverageOutputPath SCRATCH/rem-p0-writeintent.xml, run after the P0-T14 completion
      notification and before P1-T1. Write
      FEATURE/evidence/regression-testing/failbefore-r1-writeintent-alone.TS.md with
      ExpectedExitCode: 0. Acceptance: as P0-T11, including its branch rule (the "no" branch quotes
      the CI-FAILED lines that P0-T10 assigns to this test file). Its TotalCount is WI_TOTAL.

### Phase 1 — Implementation, Mirrors, Format, and Analyze

- [x] [P1-T1] Open the PowerShell batch: run CMD-PS-SCRIPT-SH with script reset-batch-budget (A8)
      and argument -Kind powershell. Write FEATURE/evidence/other/batch-budget-reset-rem1.TS.md.
      Acceptance: exit 0 and the output contains a line beginning "RESET removed=".
- [x] [P1-T2] Edit `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` exactly as specified in
      Appendix S, edits S1 through S5 (header note, fail-fast message constant, removal of
      Get-ConflictRelationCommand, the Relation parameter and invocation in
      Get-BlastRadiusPairDecision, and the Relation parameter and forwarding in
      Get-BlastRadiusConflictEdge). Acceptance: script relation-audit (R3), run through
      CMD-PS-SCRIPT-SH with -Root ".", prints "LOOKUP-AUDIT RelationHelperLines=0 GetCommandLines=0";
      the S4 invocation introduces the new literal "& $Relation -RadiusA" (absent at R_HEAD, where
      line 384 invokes the lowercase local variable), and
      `git grep -c -F -e '& $Relation -RadiusA' -- .claude/lib/blast-radius/BlastRadiusScheduling.psm1`
      prints the count 1; script line-counts (A4) prints a LineCount of at most 500 for it. Record
      the three outputs in FEATURE/evidence/other/scheduling-edit-rem1.TS.md.
- [x] [P1-T3] Edit `.claude/lib/blast-radius/BlastRadius.psm1` header lines 21-23 exactly as
      specified in Appendix S, edit S6; change nothing else in the file. Then run CMD-PS-SCRIPT-SH
      with script function-body-equal (A9) twice, with -Path set to this file, -Name
      Test-BlastRadiusConflict, and -BaseSha set first to R_HEAD and then to R_MAIN_BASE. Write
      FEATURE/evidence/other/facade-edit-rem1.TS.md. Acceptance: both A9 runs print
      BODY-EQUAL=True; CMD-GIT-DIFF-NAMES with base R_HEAD and pathspec
      .claude/lib/blast-radius/BlastRadius.psm1 lists that one path, and CMD-GIT-STATUS-PATH with the
      same pathspec prints one line for it.
- [x] [P1-T4] Edit `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1` exactly as
      specified in Appendix T, edits T1 through T3 (capture the relation in BeforeAll, pass
      -Relation at the thirteen existing call sites, replace the Get-Command mock It with the two
      Its given). Acceptance: script line-counts (A4) prints a LineCount of at most 500; the
      behavioral check is P2-T2.
- [x] [P1-T5] Edit `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`
      exactly as specified in Appendix T, edit T4 (capture the relation in BeforeAll; pass -Relation
      at lines 107 and 127). Acceptance: A4 prints a LineCount of at most 500; the behavioral check
      is P2-T2.
- [x] [P1-T6] Edit `tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1` exactly as
      specified in Appendix T, edit T5 (capture the relation in BeforeAll after line 40; pass
      -Relation at lines 190, 191, and 298). Acceptance: A4 prints a LineCount of at most 500; the
      behavioral check is P2-T3.
- [x] [P1-T7] Edit the three documentation files exactly as specified in Appendix D, edits D1
      through D3: `.claude/agents/parallel-planner.md` line 170,
      `.claude/skills/parallel-plan/SKILL.md` line 317, and `.claude/skills/parallel-add/SKILL.md`
      line 67 (each call signature gains the Relation argument on the same line, and one sentence
      states that the argument is required). Acceptance: verified by P1-T9.
- [x] [P1-T8] Produce the mirrors: run CMD-PS-SCRIPT-SH with script copy-file (A10) once per pair,
      -Source the primary and -Destination the mirror, for the five pairs of "Files written by this
      cycle"; then run script file-hashes (A5) over the ten files. Write
      FEATURE/evidence/qa-gates/mirrors-rem1.TS.md. Acceptance: five COPIED lines; each pair's two
      Hash values are equal.
- [x] [P1-T9] Caller audit after the edits: run CMD-PS-SCRIPT-SH with script relation-audit (R3) and
      -Root ".". Write FEATURE/evidence/qa-gates/relation-audit-after.TS.md recording the full output.
      Acceptance: exit 0; "CALLER-AUDIT Calls=23 MissingRelation=2"; exactly two CALL lines carry
      HasRelation=False, both in tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
      and both with It='fails fast naming -Relation when the relation is omitted'; each of the six
      "DOC file=" lines reports CallLines=1 WithRelation=1; "LOOKUP-AUDIT RelationHelperLines=0
      GetCommandLines=0". Stop condition: any other count; list the offending CALL or DOC lines and
      fix the caller before continuing.
- [x] [P1-T10] Format check: run CMD-PS-SCRIPT-SH with script ps-format-check (A6) over the five
      PowerShell files of this cycle and the two PowerShell mirrors. Write
      FEATURE/evidence/qa-gates/format-check-rem1.TS.md. Acceptance: exit 0 and
      "FORMAT-SUMMARY ChangedCount=0". If any file reports Changed=True, call MCP-PS-FORMAT over
      that primary file, re-run P1-T8, and restart Phase 1 from P1-T10; if A6 still reports
      Changed=True for a file the MCP call left byte-identical (A5 hash unchanged), stop and report
      (the two formatters disagree).
- [x] [P1-T11] Analyze: run CMD-PS-SCRIPT-SH with script poshqc-analyze (R2) and arguments -Root "."
      -ScanFolder .claude/lib/blast-radius,tests/scripts/claude-lib/blast-radius. Write
      FEATURE/evidence/qa-gates/analyze-rem1.TS.md. Acceptance: exit 0 and the output contains the
      line "ANALYZE-DONE folders=.claude/lib/blast-radius,tests/scripts/claude-lib/blast-radius"
      and no line containing "PSScriptAnalyzer reported". On a finding, fix it, re-run P1-T8, and
      restart Phase 1 from P1-T10.
- [x] [P1-T12] Line counts after the edits: run script line-counts (A4) over the five PowerShell
      files of this cycle and the two PowerShell mirrors. Write
      FEATURE/evidence/qa-gates/line-counts-rem1.TS.md. Acceptance: every LineCount is at most 500;
      each mirror equals its primary.

### Phase 2 — Verification As CI Runs It

- [x] [P2-T1] R2 pass-after: run CMD-PS-SCRIPT-SH with script pester-counts (A2) and
      -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1. Write
      FEATURE/evidence/qa-gates/guard-after-rem1.TS.md. Acceptance: exit 0; FailedCount=0;
      PassedCount equals TotalCount; no FAILED line; the output carries a "[+]" line for
      "reports no Python invocation beyond the allowlist across the guarded tree".
- [x] [P2-T2] R1 pass-after, the three suites alone, each in a fresh process: run P0-T11, P0-T12, and
      P0-T15 again with -CoverageOutputPath SCRATCH/rem-p2-scheduling.xml,
      SCRATCH/rem-p2-historical.xml, and SCRATCH/rem-p2-writeintent.xml. Write
      FEATURE/evidence/qa-gates/suites-alone-rem1.TS.md. Acceptance: all three runs exit 0 with
      FailedCount=0 and no FAILED line; the scheduling run prints TotalCount=51 and "[+]" lines for
      "fails fast naming -Relation when the relation is omitted" and "invokes the supplied relation
      rather than resolving a command"; the historical run prints TotalCount=9; the write-intent run
      prints a TotalCount equal to WI_TOTAL (this cycle adds and removes no It in that file).
- [x] [P2-T3] Blast-radius directory with coverage, convention, and uniqueness: run script
      pester-coverage (A3) with -TestPath tests/scripts/claude-lib/blast-radius, -CoveragePath
      .claude/lib/blast-radius/BlastRadiusScheduling.psm1,.claude/lib/blast-radius/BlastRadius.psm1,
      and -CoverageOutputPath SCRATCH/rem-p2-directory.xml; then script pester-counts (A2) with
      -Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1; then A2 with
      -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1. Write
      FEATURE/evidence/qa-gates/powershell-coverage-rem1.TS.md. Acceptance: the A3 run prints
      TotalCount=535 (534 in the main plan's P16-T4 plus one net new It), FailedCount=0, and a
      LinePercent of at least 85 for each of the two modules; the two A2 runs print FailedCount=0.
      The artifact records the main plan baseline values from
      FEATURE/evidence/qa-gates/final-powershell-pester-coverage.2026-09-27T18-09.md
      (BlastRadiusScheduling.psm1 100, BlastRadius.psm1 100) beside the new values.
- [x] [P2-T4] Changed-line coverage: run CMD-PY-SCRIPT with script changed-lines-cov (B42) and
      arguments jacoco SCRATCH/rem-p2-directory.xml, the R_HEAD value, and the two module paths
      .claude/lib/blast-radius/BlastRadiusScheduling.psm1 and .claude/lib/blast-radius/BlastRadius.psm1.
      Write FEATURE/evidence/qa-gates/powershell-changed-lines-rem1.TS.md. Acceptance: exit 0; two
      "CHANGED file=" lines with Found=True; the scheduling module prints a ChangedLinePercent of at
      least 85; the facade (comment-only change) prints ChangedExecutable=0 and
      ChangedLinePercent=100.00.
- [x] [P2-T5] Full tree, one process, coverage on, as CI runs it: run CMD-PS-SCRIPT-SH with script
      poshqc-ci-mirror (R1) and -Root "." in the background and wait for its completion notification.
      Write FEATURE/evidence/qa-gates/full-tree-ci-mirror-rem1.TS.md recording the PESTER-VERSION
      line, the PESTER-FAILED-TOTAL line, the "Tests Passed:" line, the JUNIT-SUMMARY line, and
      every JUNIT-FAILED line. The test file of a JUNIT-FAILED line is the repo-relative path before
      ' :: '. Acceptance (both cases): the PESTER-VERSION line reads 5.6.1. Acceptance (clean case):
      exit 0; PESTER-FAILED-TOTAL=0; JUNIT-SUMMARY reports FailedCount=0 and a CaseCount of at least
      PRE_CASES plus 1 (one net new It; suites that enumerate repository files may add cases for the
      evidence files this cycle writes); the "Tests Passed:" line carries "Failed: 0". Acceptance
      (pre-existing case, used only when FailedCount is greater than 0): the artifact carries
      ExpectedExitCode: 1; PESTER-FAILED-TOTAL minus the JUNIT-SUMMARY FailedCount is not greater
      than the same difference recorded by P0-T14 (PRE_EXTRA); and, for every JUNIT-FAILED line, a
      proof block showing all five of: (a) the identical line is in the P0-T14 failure set; (b) the
      failing test file is none of the three Pester files of this cycle and not the guard file; (c)
      CMD-GIT-DIFF-NAMES with base R_MAIN_BASE and pathspec set to that test file prints nothing,
      and CMD-GIT-STATUS-PATH with the same pathspec prints nothing; (d) no path listed by
      CMD-GIT-DIFF-NAMES with base R_MAIN_BASE and pathspec "." is imported or dot-sourced by that
      test file (its Import-Module and dot-source lines are quoted); (e) the JUNIT-FAILED name (the
      text after ' :: ') occurs in no CI_FAILED line, so the test did not fail in CI at f5d06476
      (CI_FAILED is complete because its count equals the CI Failed count of 35), which carries the
      full feature diff against origin/main, and the artifact states that the failure is
      specific to the local environment. The CaseCount condition applies in both cases. Stop
      condition: any failure lacking all five proofs, a PESTER-VERSION line reading any other
      version, or any JUNIT-FAILED line containing "BlastRadius", "blast-radius", or "no Python
      invocation"; report it as a remediation failure.
- [x] [P2-T6] #452 Pester gate form: run script pester-counts (A2) with
      -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 and no filter. Write
      FEATURE/evidence/qa-gates/452-gate-rem1.TS.md. Acceptance: TotalCount=80, FailedCount=0, no
      result line whose first non-whitespace text after ANSI removal is "[-]", and exactly two "[+]"
      result lines ending " for F" for each of the five gate fixtures named in the Terms.
- [x] [P2-T7] Detection relation unchanged (as main plan P14-T4): run CMD-GIT-DIFF-NAMES with base
      R_MAIN_BASE and CMD-GIT-STATUS-PATH, each with the pathspec
      scripts/dev_tools/_blast_radius_conflicts.py scripts/dev_tools/_blast_radius_glob.py
      scripts/dev_tools/_blast_radius_mergeable.py .claude/lib/blast-radius/BlastRadiusConflict.psm1
      .claude/lib/blast-radius/BlastRadiusGlob.psm1; then run script function-body-equal (A9) for
      Test-BlastRadiusConflict in .claude/lib/blast-radius/BlastRadius.psm1 against R_MAIN_BASE.
      Write FEATURE/evidence/qa-gates/detection-unchanged-rem1.TS.md. Acceptance: both git commands
      print nothing; A9 prints BODY-EQUAL=True.
- [x] [P2-T8] Mirror identity (final): run script file-hashes (A5) over the ten files of the five
      mirror pairs. Write FEATURE/evidence/qa-gates/mirrors-final-rem1.TS.md. Acceptance: each pair's
      two Hash values are equal.
- [x] [P2-T9] Scope: run CMD-GIT-DIFF-NAMES with base R_HEAD and pathspec "." and CMD-GIT-STATUS.
      Write FEATURE/evidence/qa-gates/scope-rem1.TS.md. Acceptance: the union of the two listings is
      exactly the thirteen paths of "Files written by this cycle" plus paths under FEATURE; no path
      ends in .py or .ts, and no path lies under .claude/lib/bash, .claude/rules, or
      .github/instructions.
- [x] [P2-T10] Python and TypeScript unaffected. Rationale recorded in the artifact: P2-T9 shows no
      Python or TypeScript file changed; the Python scheduling module calls conflicts directly and
      does not consume the PowerShell modules; no TypeScript source or test names either changed
      function. Consumer check: run CMD-PY-TEST over the two node IDs of the main plan's block B27
      and the eight Python files of its block B43, then CMD-TS-TEST over the three TypeScript files
      of block B43. Write FEATURE/evidence/qa-gates/consumers-rem1.TS.md. Acceptance: pytest prints a
      PASSED line for every collected node, except that the KL-510 node may fail when its failure
      satisfies KL-510 case (b), recorded as the main plan's Terms require (then ExpectedExitCode: 1);
      Jest exits 0 and its "Tests:" line contains "passed" and not "failed". The artifact's EXIT_CODE
      refers to the pytest run; the Jest exit code is recorded in the body. Stop condition: any other
      failure.

### Phase 3 — Commit and Push

No task in this phase writes an evidence artifact: every result is reported to the caller, so the
tree stays clean after each push. Every Phase 0 through Phase 2 task is ticked in this plan file
before P3-T1 runs; P3-T1 and P3-T2 are ticked by P3-T3.

- [x] [P3-T1] Implementation commit and push: run CMD-GIT-STATUS, then CMD-GIT-ADD with exactly the
      thirteen paths of "Files written by this cycle", FEATURE/remediation-inputs.2026-09-27T18-49.md,
      FEATURE/remediation-plan.2026-09-27T18-49.md, and FEATURE/evidence; then CMD-GIT-COMMIT with the
      message "fix(722): pass the conflict relation to the scheduling layer explicitly" (one commit,
      both trailers as the catalogue gives them); then CMD-GIT-PUSH; then CMD-GIT-STATUS again.
      Report the commit SHA and the command results to the caller. Acceptance: add, commit, and push
      exit 0; the final CMD-GIT-STATUS prints nothing.
- [x] [P3-T2] AC-38 remains open: run CMD-GIT-COUNT-OPEN over FEATURE/spec.md, then
      CMD-GIT-DIFF-NAMES with base R_HEAD and pathspec FEATURE/spec.md, then CMD-GIT-STATUS-PATH with
      the same pathspec. Report the outputs to the caller. Acceptance: CMD-GIT-COUNT-OPEN prints the
      count 1; the diff and the status each print nothing. AC-38 stays unchecked.
- [x] [P3-T3] Completion commit and push: tick P3-T1, P3-T2, and this task's own checkbox in
      FEATURE/remediation-plan.2026-09-27T18-49.md and change nothing else in any file; then run
      CMD-GIT-ADD with only FEATURE/remediation-plan.2026-09-27T18-49.md; then CMD-GIT-COMMIT with the
      message "docs(722): record remediation cycle 1 completion"; then CMD-GIT-PUSH; then
      CMD-GIT-SHOW-NAMES, CMD-GIT-STATUS, CMD-GIT-HEAD, and CMD-GIT-REMOTE-HEAD. This task's own box
      is ticked before its commit, and its acceptance is re-verified after the push; if add, commit,
      or push fails, the executor un-ticks this task's box and reports the failure. Report the
      outputs to the caller. Acceptance: add, commit, and push exit 0; CMD-GIT-SHOW-NAMES prints
      exactly the one line docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/remediation-plan.2026-09-27T18-49.md;
      a final git status --porcelain (CMD-GIT-STATUS) prints nothing and HEAD equals
      origin/bug/blast-radius-over-reports-and-zero-overlap-tolerance-722 (CMD-GIT-HEAD and
      CMD-GIT-REMOTE-HEAD print the same 40-character SHA).

---

## Appendix R — New Scratch Scripts

R1 poshqc-ci-mirror.ps1 (the CI poshqc test step with Run.Exit set false and Pester pinned to
5.6.1; exits 1 on any failed test case or any non-zero Pester failure total). The PESTER-VERSION
line joins the versions of every loaded Pester module, so a second loaded version makes the line
read other than 5.6.1. The JUNIT-FAILED classname is made repo-relative so no absolute path reaches
an artifact:

```powershell
param([Parameter(Mandatory)][string] $Root)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath $Root).Path
$junitPath = Join-Path $Root 'artifacts/pester/pester-junit.xml'
Remove-Item -LiteralPath $junitPath -ErrorAction SilentlyContinue
Import-Module Pester -RequiredVersion 5.6.1
Import-Module (Join-Path $Root 'scripts/powershell/PoshQC/PoshQC.psm1')
$buildConfiguration = {
    param($Settings)
    $configuration = New-PesterConfiguration -Hashtable $Settings
    $configuration.Run.Exit = $false
    $configuration
}
$global:LASTEXITCODE = -1
Invoke-PoshQCTest -Root $Root -BuildConfiguration $buildConfiguration
$pesterFailedTotal = $global:LASTEXITCODE
Write-Output "PESTER-VERSION $((@(Get-Module -Name Pester) | ForEach-Object { $_.Version.ToString() }) -join ',')"
Write-Output "PESTER-FAILED-TOTAL=$pesterFailedTotal"
[xml] $document = Get-Content -Raw -LiteralPath $junitPath
$cases = @($document.SelectNodes('//testcase'))
$failed = @($cases | Where-Object { $null -ne $_.SelectSingleNode('failure') -or $null -ne $_.SelectSingleNode('error') })
Write-Output "JUNIT-SUMMARY CaseCount=$($cases.Count) FailedCount=$($failed.Count)"
foreach ($case in $failed) {
    $class = $case.GetAttribute('classname')
    if ($class.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) { $class = $class.Substring($Root.Length).TrimStart('\', '/') -replace '\\', '/' }
    Write-Output "JUNIT-FAILED: $class :: $($case.GetAttribute('name'))"
}
if ($failed.Count -gt 0 -or $pesterFailedTotal -ne 0) { exit 1 }
exit 0
```

A PESTER-FAILED-TOTAL of -1 means Pester did not set the exit code; it is non-zero, so R1 exits 1.

R2 poshqc-analyze.ps1 (Invoke-PoshQCAnalyze throws "PSScriptAnalyzer reported N issue(s)." on any
finding, `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` line 183, so the process exits non-zero and
ANALYZE-DONE is not printed):

```powershell
param(
    [Parameter(Mandatory)][string] $Root,
    [Parameter(Mandatory)][string[]] $ScanFolder
)
$ErrorActionPreference = 'Stop'
$ScanFolder = @($ScanFolder | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$Root = (Resolve-Path -LiteralPath $Root).Path
Import-Module (Join-Path $Root 'scripts/powershell/PoshQC/PoshQC.psm1')
Invoke-PoshQCAnalyze -Root $Root -ScanFolders $ScanFolder
Write-Output "ANALYZE-DONE folders=$($ScanFolder -join ',')"
```

R3 relation-audit.ps1 (read-only; parses every PowerShell file under the four roots and reports each
call of the two scheduling functions, the six documentation copies, and the lookup residue):

```powershell
param([Parameter(Mandatory)][string] $Root)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath $Root).Path
$names = @('Get-BlastRadiusPairDecision', 'Get-BlastRadiusConflictEdge')
$folders = @('.claude', 'scripts', 'tests', 'extensions/drm-copilot/resources/claude-customizations/.claude')
$calls = 0
$missing = 0
foreach ($folder in $folders) {
    foreach ($file in @(Get-ChildItem -LiteralPath (Join-Path $Root $folder) -Recurse -File -Include '*.ps1', '*.psm1')) {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$null)
        $found = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $names -contains $n.GetCommandName() }, $true)
        foreach ($command in $found) {
            $calls++
            $hasRelation = @($command.CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.CommandParameterAst] -and $_.ParameterName -eq 'Relation' }).Count -gt 0
            if (-not $hasRelation) { $missing++ }
            $itName = ''
            $parent = $command.Parent
            while ($null -ne $parent) {
                if ($parent -is [System.Management.Automation.Language.CommandAst] -and $parent.GetCommandName() -eq 'It' -and $parent.CommandElements.Count -gt 1) {
                    $itName = $parent.CommandElements[1].Extent.Text
                    break
                }
                $parent = $parent.Parent
            }
            $relative = $file.FullName.Substring($Root.Length).TrimStart('\', '/') -replace '\\', '/'
            Write-Output "CALL $($relative):$($command.Extent.StartLineNumber) $($command.GetCommandName()) HasRelation=$hasRelation It=$itName"
        }
    }
}
Write-Output "CALLER-AUDIT Calls=$calls MissingRelation=$missing"
foreach ($doc in @('.claude/agents/parallel-planner.md', '.claude/skills/parallel-plan/SKILL.md', '.claude/skills/parallel-add/SKILL.md')) {
    foreach ($copy in @($doc, "extensions/drm-copilot/resources/claude-customizations/$doc")) {
        $lines = @(Get-Content -LiteralPath (Join-Path $Root $copy) | Where-Object { $_ -match 'Get-BlastRadiusConflictEdge -Item' })
        $withRelation = @($lines | Where-Object { $_ -match '-Relation' })
        Write-Output "DOC file=$copy CallLines=$($lines.Count) WithRelation=$($withRelation.Count)"
    }
}
$scheduling = @(Get-Content -LiteralPath (Join-Path $Root '.claude/lib/blast-radius/BlastRadiusScheduling.psm1'))
$helperLines = @($scheduling | Where-Object { $_ -match 'Get-ConflictRelationCommand' }).Count
$getCommandLines = @($scheduling | Where-Object { $_ -match 'Get-Command' }).Count
Write-Output "LOOKUP-AUDIT RelationHelperLines=$helperLines GetCommandLines=$getCommandLines"
```

Expected R3 counts after the edits: 23 calls = 16 in the scheduling Pester file (13 existing, 2 in
the fail-fast It without the argument, 1 in the stub It) + 2 in the historical-runs file + 3 in the
write-intent file + 1 in each copy of the scheduling module.

R4 ci-failed-tests.ps1 (read-only; lists the failed Pester results of a CI run from the Detailed
output's "[-] " marker in the failed-step log; throws, and so exits non-zero, when gh fails):

```powershell
param([Parameter(Mandatory)][string] $RunId)
$ErrorActionPreference = 'Stop'
$log = @(& gh run view $RunId --log-failed)
if ($LASTEXITCODE -ne 0) { throw "gh run view exited $LASTEXITCODE" }
$failed = @($log | Where-Object { $_ -match '\[-\] ' } | ForEach-Object { (($_ -split '\[-\] ', 2)[1]) -replace '\x1b\[[0-9;]*m', '' })
Write-Output "CI-FAILED-COUNT=$($failed.Count)"
foreach ($name in $failed) { Write-Output "CI-FAILED: $name" }
```

## Appendix S — Production Edits

Every line number in this appendix is the line number of the file at R_HEAD, before any edit this
appendix makes.

S1 — scheduling module header, lines 26-28. Replace:

```text
      - Test-BlastRadiusConflict lives in the facade BlastRadius.psm1, which
        imports this module, so it is resolved at call time with Get-Command
        rather than imported; a missing command fails fast naming the facade.
```

with:

```text
      - Test-BlastRadiusConflict lives in the facade BlastRadius.psm1, which
        imports this module, so the caller supplies it as the [scriptblock]
        -Relation; an omitted relation fails fast naming the facade.
```

S2 — scheduling module lines 56-58. Replace the comment and the two constants RelationCommand and
FacadeModule with these two lines (single-quoted, so the braces are literal text):

```powershell
# The fail-fast message for an omitted relation; the facade defines the relation.
$script:RelationRequired = '-Relation is required: pass ${function:Test-BlastRadiusConflict} from the facade module BlastRadius.psm1.'
```

S3 — scheduling module lines 320-332. Delete the two comment lines, the function
Get-ConflictRelationCommand, and the blank line that follows it.

S4 — Get-BlastRadiusPairDecision.
- In .DESCRIPTION, replace "calls Test-BlastRadiusConflict exactly once" with "calls the supplied
  -Relation exactly once" (same line; the wrap of the paragraph is otherwise unchanged).
- After the .PARAMETER BandB block, add a blank line and:

```text
    .PARAMETER Relation
        The detection relation; pass ${function:Test-BlastRadiusConflict}.
```

- In param(), put a comma after the BandB declaration and add the line `[scriptblock] $Relation` as
  the last parameter (not mandatory, no default).
- Replace the body lines 382-384 (tolerance read, lookup, invocation) with:

```powershell
    if ($null -eq $Relation) { throw $script:RelationRequired }
    $tolerance = Get-ConfigConflictTolerance -Config $Config
    $result = & $Relation -RadiusA $RadiusA -RadiusB $RadiusB -Config $Config
```

S5 — Get-BlastRadiusConflictEdge.
- After the .PARAMETER Config block, add a blank line and:

```text
    .PARAMETER Relation
        The detection relation passed to every pair decision; pass
        ${function:Test-BlastRadiusConflict}.
```

- In param(), put a comma after the Config declaration and add `[scriptblock] $Relation` as the last
  parameter (not mandatory, no default).
- Insert `if ($null -eq $Relation) { throw $script:RelationRequired }` as the first body line, before
  the tolerance read at line 464.
- Append ` -Relation $Relation` to the Get-BlastRadiusPairDecision call at line 473.

Expected size: 490 lines minus 1 (S2) minus 13 (S3) plus 4 (S4) plus 6 (S5) = 486.

S6 — facade `.claude/lib/blast-radius/BlastRadius.psm1` lines 21-23. Replace:

```text
    It also re-exports two scheduling functions of BlastRadiusScheduling.psm1
    (issue #722), which resolves Test-BlastRadiusConflict from this facade at
    call time:
```

with:

```text
    It also re-exports two scheduling functions of BlastRadiusScheduling.psm1
    (issue #722); each takes the relation as -Relation, so a caller passes
    ${function:Test-BlastRadiusConflict} from this facade:
```

## Appendix T — Pester Edits

Every line number in this appendix is the line number of the file at R_HEAD, before any insertion
this appendix makes into the same file.

T1 — scheduling Pester file, BeforeAll. After line 54 (the scheduling-module import), add:

```powershell
    # The relation is passed explicitly to every scheduling call, so no call
    # depends on command resolution inside the scheduling module.
    $script:ConflictRelation = ${function:Test-BlastRadiusConflict}
```

T2 — scheduling Pester file, call sites. Append ` -Relation $script:ConflictRelation` to each call of
Get-BlastRadiusPairDecision or Get-BlastRadiusConflictEdge at lines 157, 166, 229, 230, 240, 241,
277, 313, 331, 334, 335, 345, and 346 (thirteen sites; inside the script blocks of lines 334 and 335
the argument goes before the closing brace).

T3 — scheduling Pester file, lines 354-357. Replace the It "fails fast naming the facade when
Test-BlastRadiusConflict is unavailable" with:

```powershell
        It 'fails fast naming -Relation when the relation is omitted' {
            { Get-BlastRadiusPairDecision -RadiusA (Get-TestRadius) -RadiusB (Get-TestRadius) -Config (Get-TestConfig) } | Should -Throw -ExpectedMessage '*-Relation is required*BlastRadius.psm1*'
            { Get-BlastRadiusConflictEdge -Item @() -Config (Get-TestConfig) } | Should -Throw -ExpectedMessage '*-Relation is required*BlastRadius.psm1*'
        }

        It 'invokes the supplied relation rather than resolving a command' {
            # Two empty radii never conflict under Test-BlastRadiusConflict, so a
            # conflict here can only come from the supplied stub.
            $stub = { @{ conflict = $true; reasons = @(@{ kind = 'contract_dependency'; detail = 'stub' }) } }
            $decision = Get-BlastRadiusPairDecision -RadiusA (Get-TestRadius) -RadiusB (Get-TestRadius) -Config (Get-TestConfig) -Relation $stub
            $decision['conflict'] | Should -BeTrue
            $decision['hard'] | Should -BeTrue
            $decision['reason'] | Should -BeExactly 'contract_dependency'
        }
```

The stub declares no param block, so the named arguments bind to its automatic argument list and
no unused-parameter analyzer finding arises.

T4 — historical-runs Pester file. After line 37 (the facade import) add the same capture line as T1
(with its two comment lines), and append ` -Relation $script:ConflictRelation` to the calls at lines
107 and 127.

T5 — write-intent Pester file. After line 40 (the facade import) add the same capture line as T1
(with its two comment lines), and append ` -Relation $script:ConflictRelation` at lines 190 and 191
immediately after `-Config $config`, inside the parentheses, and at the end of the call on line
298.

## Appendix D — Documentation Edits

D1 — `.claude/agents/parallel-planner.md` line 170. Inside the existing code span, after
"-Config <parsed truth table>", add " -Relation ${function:Test-BlastRadiusConflict}" so the whole
signature stays on line 170. After the sentence ending "by hand." add: "The -Relation argument is
required: the scheduling module does not resolve the relation itself, and an omitted relation fails
fast."

D2 — `.claude/skills/parallel-plan/SKILL.md` line 317. Inside the existing code span, after
"-Config <parsed truth table>", add " -Relation ${function:Test-BlastRadiusConflict}" on the same
line. After the sentence ending "It returns `edges` and `tolerated_overlaps`." add: "The -Relation
argument is required; pass the facade's Test-BlastRadiusConflict function object as shown."

D3 — `.claude/skills/parallel-add/SKILL.md` line 67. Inside the existing code span, after
"-Config <config>", add " -Relation ${function:Test-BlastRadiusConflict}" on the same line. After
the clause ending "which push-down publishes into the destination workspace." add: "The -Relation
argument is required and carries the facade's detection relation; an omitted relation fails fast."

Line wrapping of the surrounding Markdown prose may be adjusted, but each signature code span must
remain on the single line that also carries "Get-BlastRadiusConflictEdge -Item" (R3 counts that line).

## Remediation Traceability

| ID | Finding | Implementation | Tests / verification | Evidence |
| --- | --- | --- | --- | --- |
| R1 | order-dependent run-time relation lookup | P1-T2, P1-T3, P1-T4, P1-T5, P1-T6, P1-T7 | P0-T10, P0-T11, P0-T12, P0-T14, P0-T15, P1-T9, P2-T2, P2-T3, P2-T5 | evidence/remediation-baseline/ci-run-36356018317, evidence/qa-gates/suites-alone-rem1, full-tree-ci-mirror-rem1, relation-audit-after |
| R2 | ampersand invocation of a non-parameter variable | P1-T2 | P0-T10, P0-T13, P2-T1, P2-T5 | evidence/qa-gates/guard-after-rem1 |

Spec criteria re-verified without check-off change: AC-06 (P2-T7), the #452 gate (P2-T6), the
500-line and batch limits (P1-T12, P1-T1), mirror identity (P2-T8). AC-38 stays open (P3-T2).

## Planner Adversarial Self-Review

Every citation below was re-derived against the current tree in this authoring pass:

- `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`: header lines 26-28; constants lines 56-58;
  Get-ConflictRelationCommand lines 320-331 with the Get-Command call at line 326 and the throw at
  line 328; Get-BlastRadiusPairDecision description line 340, param block lines 366-380, body lines
  382-384; Get-BlastRadiusConflictEdge param block lines 453-462, tolerance read line 464, pair call
  line 473; export list lines 485-490; total 490 lines.
- `.claude/lib/blast-radius/BlastRadius.psm1`: header lines 21-26; scheduling import line 74;
  Test-BlastRadiusConflict lines 371-459; export list lines 461-475.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1`: imports lines 51-54;
  call sites 157, 166, 229, 230, 240, 241, 277, 313, 331, 334, 335, 345, 346; mock It lines 354-357.
- `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`: import line 37;
  calls lines 107 and 127; nine Its (three runs times three).
- `tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1`: facade import line 40;
  calls lines 190, 191, 298.
- `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` lines 469-475: export names
  unchanged by this cycle.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` lines 350-385 and
  473-484; `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` lines 36-39,
  128-165, 353, 372-381.
- `.github/workflows/_poshqc.yml` lines 38-42; `scripts/powershell/PoshQC/PoshQC.Testing.psm1`
  lines 151-170, 261-281, 400, 423-428; `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` line 183;
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 2-5, 12-23, 190;
  `config/poshqc-scan.json` line 4.
- `.claude/agents/parallel-planner.md` line 170; `.claude/skills/parallel-plan/SKILL.md` line 317;
  `.claude/skills/parallel-add/SKILL.md` line 67.
- Main plan FEATURE/plan.2026-09-27T12-16.md: Appendix A scripts A1-A10 and B42; Terms (KL-510,
  #452 gate form); P14-T4 and P7-T3; block B30 pathspec; blocks B27, B43, B46, B47.
- FEATURE/evidence/qa-gates/final-powershell-pester-coverage.2026-09-27T18-09.md: 534 tests, 50
  scheduling, 9 historical, LinePercent 100 for both modules; 452-gate-final.2026-09-27T17-57.md:
  80 parity tests and the five gate fixtures; main-sync.2026-09-27T17-55.md: FINAL_BASE.
- FEATURE/spec.md line 700 (AC-38 open).

Preflight revision 1 re-derived, in this pass, against the current tree:

- `tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1`: facade import line 40;
  line 190 `(Get-BlastRadiusPairDecision -RadiusA $reader -RadiusB $writer -Config $config)['conflict']`;
  line 191 the same form with `['hard']`; line 298 `$result = Get-BlastRadiusConflictEdge -Item
  $derived.ToArray() -Config $config` ending the call.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` line 473: It
  'reports no Python invocation beyond the allowlist across the guarded tree'.
- `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`: line 384 invokes the lowercase local
  `$relation`, so the case-sensitive fixed string "& $Relation -RadiusA" has zero matches at R_HEAD;
  Get-Command on lines 27 and 326 and Get-ConflictRelationCommand on lines 322 and 383 (the P0-T9
  counts 2 and 2).
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1`: EnsureModule seam lines 160-166 (Import-Module
  by name, -Global, no version); BuildConfiguration seam line 169; EnsureModule call line 294;
  InvokePester call line 400; summary lines 423-428.
- `.github/workflows/_poshqc.yml` lines 38-42; `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  line 4 (Run.Exit) and line 10 (Output.Verbosity Detailed, the source of the "[-] " marker R4
  reads).

Sibling regions re-checked: the write-intent file's lines 185-189 and 299-301 carry no scheduling
call; Appendix S and Appendix T line numbers are stated as R_HEAD numbers so that insertions (T1,
T4, T5, S2, S3) do not shift the citations of later edits; the scheduling module's other script constants (lines 43-61) are kept;
the facade body and exports are untouched; the scheduling Pester file's It at lines 285-297 and 310
call Test-BlastRadiusConflict directly and need no change; the historical-runs It at line 80 calls
the relation directly and needs no change; the rule file line 407 names the entry point without a
signature and needs no change.

Preflight revision 2 re-derived, in this pass:

- Describe lines, read from the current tree: `BlastRadiusScheduling.Tests.ps1` line 151
  ('BlastRadiusScheduling'); `BlastRadius.HistoricalRuns.Tests.ps1` line 65 ('Blast-radius
  historical runs'); `BlastRadiusWriteIntent.Tests.ps1` line 110 ('BlastRadiusWriteIntent');
  `enforcement-hooks-no-python-invocation.Tests.ps1` line 99 ('enforcement hooks must not invoke
  Python') and its It at line 473.
- CI log of run 36356018317 (observation supplied by the caller; the planner has no gh access in this
  pass): the "[-] " text is the Pester expanded path, and the failed lines assign 26 scheduling, 6
  historical-runs, 2 write-intent, and 1 guard. Corroborated in the tree only by
  FEATURE/remediation-inputs.2026-09-27T18-49.md line 7 ("35 failed"); P0-T10 re-observes the log
  and stops on any other assignment.
- EnsureModule reuses the loaded 5.6.1 (observed under pwsh -NoProfile; observation supplied by the
  caller). `scripts/powershell/PoshQC/PoshQC.Testing.psm1` lines 160-166 re-read: Import-Module by
  name with -Global and no -Force or version.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 4 (Exit) and line 10 (Verbosity
  'Detailed').
- `BlastRadiusWriteIntent.Tests.ps1` scheduling calls at lines 190, 191, and 298; its Its at line 278
  and line 311 are -ForEach templated, so the write-intent TotalCount is recorded by P0-T15 (WI_TOTAL)
  rather than stated here.
- Sibling regions: P0-T14 now hands off to P0-T15 instead of P1-T1; P0-T11's "no" branch wording is
  inherited by P0-T12 and P0-T15; P2-T3 already runs the whole blast-radius directory, which contains
  the write-intent file, so it needs no extension; P2-T5 proof (e) relies on CI_FAILED completeness,
  which P0-T10 now establishes by the count 35.
