# Scope exclusions (issue #543)

Timestamp: 2026-10-02T05-47
Timestamp-Correction: original value 2026-10-02T06-50 was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T05-58.md), an upper bound on the command run time.
Task: P10-T3
Command: `git diff ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github` and `git status --porcelain -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github`
Route: native (D2, D3)
EXIT_CODE: 0

Output Summary:
- Both commands printed nothing.
- The Python CLI deferral (`scripts/dev_tools/validate_orchestration_artifacts.py` unchanged) and the exclusion of `.claude/**` and `.github/**` were respected.
- The diff is anchored to the merge base with `origin/main` (`ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`, D2) rather than to local `main`; this is the anchored form of the spec's `git diff main` command and stays fixed if `origin/main` advances.
