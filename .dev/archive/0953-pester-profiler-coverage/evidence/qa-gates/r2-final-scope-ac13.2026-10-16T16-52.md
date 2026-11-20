# r2 final AC-13 scope and check name (P5-T9)

Timestamp: 2026-10-16T16-52
Command: git diff --name-only origin/main...HEAD; git status --porcelain; sh "SCRATCH/issue-953-r2-p5-t9.sh" ($mb = git merge-base origin/main HEAD; on: block of every .github/workflows/*.yml compared with git show "${mb}:.github/workflows/<name>"; Select-String regex counts of '^  poshqc:\s*$' and '^    name: PowerShell QC\s*$' in .github/workflows/_poshqc.yml)
EXIT_CODE: 0
Output Summary:
  MERGE_BASE=5d2d9a9728b3763cb4398bdae1e54ef84ee98936
  .github/workflows/ci.yml in diff listing: False; in porcelain listing: False
  WORKFLOWS_CHECKED=14 ON_BLOCK_DIFFS=0 (every on: block is identical to the merge-base text)
  POSHQC_JOB_ID_LINES=1; POSHQC_NAME_LINES=1 (job id poshqc and name PowerShell QC kept; check name stays poshqc / PowerShell QC)
