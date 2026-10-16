# Scratch Setup — Issue #932

Timestamp: 2026-10-16T00-28
Task: [P0-T3]
Command: Write tool: SCRATCH/cov/README.txt and SCRATCH/g10/README.txt; Glob tool: pattern `*/README.txt` rooted at SCRATCH
EXIT_CODE: 0

Method: the Write tool wrote the one-line file `README.txt` (content `Issue 932 scratch directory; not committed.`) to `SCRATCH/cov/README.txt` and `SCRATCH/g10/README.txt`, creating the parent directories. No shell command was used. `SCRATCH` resolves to the session scratchpad subdirectory `issue-932/`.

Glob results (relative to SCRATCH):

- `cov/README.txt`
- `g10/README.txt`

Output Summary: The Glob tool returned exactly the two expected files; `SCRATCH/cov/` and `SCRATCH/g10/` exist.
