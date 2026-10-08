# README Documentation Tokens, Both Copies (P6-T26)

Timestamp: 2026-10-02T08-45
Command: git/static-equivalent deviation DEV-P6-T26 (replaces `Select-String -SimpleMatch`). `git grep -c -F -e '<token>' -- scripts/powershell/PoshQC/README.md extensions/drm-copilot/resources/powershell/PoshQC/README.md` run from `<ROOT>` for each of the six tokens.
EXIT_CODE: 0
Output Summary: both files: poshqc-coverage.json=3, fallback=1, *.Tests.ps1=1, DefaultExcludedDirs=1, source==1, src/**/*.ps1=0 (that `git grep` printed nothing and exited 1, which is the zero-count result).

| Token | scripts/powershell/PoshQC/README.md | extensions/.../PoshQC/README.md |
| --- | --- | --- |
| `poshqc-coverage.json` | 3 | 3 |
| `fallback` | 1 | 1 |
| `*.Tests.ps1` | 1 | 1 |
| `DefaultExcludedDirs` | 1 | 1 |
| `source=` | 1 | 1 |
| `src/**/*.ps1` | 0 | 0 |

- The two files are byte-identical (git blob 7f035c3f12926e8fd4f302000386f2ffcdf203bf, P6-T2).
- Acceptance (AC-16): counts at least 1 for the first five tokens and 0 for `src/**/*.ps1`, in both files. Met.
