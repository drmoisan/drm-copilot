# Restricted consumer token scan ([P7-T10])

Timestamp: 2026-11-04T03-23
Command: sh SCRATCH/issue-1033-token-scan.sh (the union of `git diff --name-only MERGE_BASE HEAD` and the paths of `git status --porcelain --untracked-files=all`, MERGE_BASE = fd6ee4e5a0815fa69b03fc56c0ea82d49b2f5ee3; for each existing file a case-insensitive extended-regex `grep -i -E -c -e 'r[g]f' -e 'fore[c]ast'`, each pattern passed through `-e`; the file count and the summed match count printed)
EXIT_CODE: 0
Output Summary: FILES_SCANNED=100; PATTERNS=r[g]f fore[c]ast (the two bracket-class patterns, recorded as patterns, never as the tokens themselves); MATCHES=0.
