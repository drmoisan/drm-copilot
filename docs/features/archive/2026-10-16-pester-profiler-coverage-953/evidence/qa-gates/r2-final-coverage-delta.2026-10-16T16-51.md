# r2 final coverage delta (P5-T4)

Timestamp: 2026-10-16T16-51
Command: sh "SCRATCH/issue-953-r2-p5-t4.sh" (pwsh text: CRP steps 1-7 on SCRATCH/issue-953-r2-baseline-coverage.xml and SCRATCH/issue-953-r2-final-coverage.xml; key-set and per-file total comparison; CLD via git diff -U0 136d02fcb4ab6b87f87dc01479571f028262119b -- <path> for the three changed modules with the final L(key, nr) of every added line; final L('scripts/powershell/poshqc/poshqc.testing.psm1', 174))
EXIT_CODE: 0
Output Summary:
  BASELINE LINE_COVERED=17091 LINE_TOTAL=18563 LINE_PERCENT=92.07 SOURCEFILE_COUNT=208
  FINAL    LINE_COVERED=17123 LINE_TOTAL=18594 LINE_PERCENT=92.09 SOURCEFILE_COUNT=208
  FINAL_THRESHOLD_PASS=True (repository-wide line coverage at least 85%)
  KEYSET_EQUAL=True; NON_MOD_TOTAL_CHANGES=0 (every per-file total outside MOD_KEYS is unchanged)
  MOD_KEYS (baseline -> final, covered/missed):
    scripts/powershell/poshqc/poshqc.shard.psm1 49/0 -> 82/0 (100%)
    scripts/powershell/poshqc/poshqc.coveragemerge.psm1 70/0 -> 72/0 (100%)
    scripts/powershell/poshqc/poshqc.testing.psm1 193/14 -> 190/13 (93.6%)
  CLD and final line hits:
    scripts/powershell/PoshQC/PoshQC.Shard.psm1: CHANGED_LINES=98 EXECUTABLE_CHANGED=35 UNCOVERED_CHANGED=0 UNCOVERED=[]
      Executable changed lines (all ci > 0): 36,37,39,40,43,44,46,47,48,50,52,53,54,55,56,57,58,59,62,63,64,65,70,106,107,108,110,246,247,248,249,250,252,253,255. Every other added line is ABSENT (help text, blank lines, braces, param declarations).
    scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1: CHANGED_LINES=8 EXECUTABLE_CHANGED=2 UNCOVERED_CHANGED=0 UNCOVERED=[]
      Lines: 34=ABSENT; 35=ABSENT; 90=ABSENT; 91=ABSENT; 92=ci=2 mi=0; 93=ci=1 mi=0; 94=ABSENT; 95=ABSENT
    scripts/powershell/PoshQC/PoshQC.Testing.psm1: CHANGED_LINES=3 EXECUTABLE_CHANGED=1 UNCOVERED_CHANGED=0 UNCOVERED=[]
      Lines: 156=ABSENT; 412=ABSENT; 413=ci=3 mi=0
  Final L('scripts/powershell/poshqc/poshqc.testing.psm1', 174) = ci=1 mi=0 (baseline ci=0; the default WriteShardFileList seam body is now executed, CR-12).
  The bundled copies under extensions/drm-copilot/resources/powershell/PoshQC/ are outside the coverage roots of config/poshqc-coverage.json:3-9 and are not measured. Pester measures no branch coverage, so no branch figure is reported.
