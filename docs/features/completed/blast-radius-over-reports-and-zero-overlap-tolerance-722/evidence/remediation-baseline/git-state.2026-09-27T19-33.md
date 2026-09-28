# Baseline Git State (Remediation Cycle 1, P0-T5)

Timestamp: 2026-09-27T19-33
Command: git rev-parse HEAD; git merge-base --is-ancestor f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d HEAD; git fetch origin main; git merge-base HEAD origin/main; git status --porcelain
EXIT_CODE: 0

## Per-command results

1. git rev-parse HEAD -> EXIT_CODE 0
   Output: f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d
2. git merge-base --is-ancestor f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d HEAD -> EXIT_CODE 0 (no output)
3. git fetch origin main -> EXIT_CODE 0
   Output: "From https://github.com/drmoisan/drm-copilot / * branch main -> FETCH_HEAD"
4. git merge-base HEAD origin/main -> EXIT_CODE 0
   Output: beae3f021674e64fa6662097fe48a332d8da62b8
5. git status --porcelain -> EXIT_CODE 0
   Output:
   ?? docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/remediation-baseline/
   ?? docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/remediation-inputs.2026-09-27T18-49.md
   ?? docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/remediation-plan.2026-09-27T18-49.md

## Recorded values

R_HEAD: f5d06476e4cd5e76c36b34f29d1c1e4a1e30f33d
R_MAIN_BASE: beae3f021674e64fa6662097fe48a332d8da62b8
R_MAIN_BASE equals the main plan FINAL_BASE (FEATURE/evidence/qa-gates/main-sync.2026-09-27T17-55.md), so origin/main has not been merged again.

Output Summary: PASS. All five commands exited 0. R_HEAD and R_MAIN_BASE are 40 hexadecimal characters. The PR head f5d06476 is an ancestor of HEAD (it is HEAD). Status shows only the three permitted untracked lines (the remediation-baseline evidence directory, the remediation inputs, and the remediation plan).
