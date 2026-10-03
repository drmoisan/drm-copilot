# r2 P8-T17 host-path scan of the feature folder

Timestamp: 2026-10-03T16-40
Command: step script SCRATCH/steps/r2-p8-t17.ps1 (git grep --untracked -i -l with two run-time-assembled tokens over FEATURE; JUnit file count under FEATURE; exit 1 when the grep exit is not 1 or a JUnit file exists)
EXIT_CODE: 0
Output Summary: no file-name line printed; HOSTPATH-GREP-EXIT=1; JUNIT-COUNT=0. No file in the feature folder carries an absolute host path, and no JUnit file is stored under FEATURE.
