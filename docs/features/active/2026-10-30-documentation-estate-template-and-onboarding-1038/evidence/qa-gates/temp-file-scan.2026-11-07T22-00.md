# Temporary-file and process scan (NEW-PS)

Timestamp: 2026-11-07T22-00
Command: sh SCRATCH/issue-1038-scans.sh temp (for each string: cat <the five NEW-PS files> | grep -c -i -F -e "<string>")
EXIT_CODE: 0
Output Summary: 0 matches for every one of the eight strings across the five NEW-PS files.

- New-TemporaryFile | 0
- TestDrive | 0
- GetTempPath | 0
- GetTempFileName | 0
- $env:TEMP | 0
- Start-Process | 0
- System.Diagnostics.Process | 0
- Start-Job | 0
