# Remediation cycle 1 commit and push (P2-T9)

Timestamp: 2026-10-17T01-40
Command: git add -- docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962 .github/workflows/_security-scan.yml .github/workflows/README.md tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
EXIT_CODE: 0
Output Summary: Commit d91d8e274 ("ci(962): keep the security scan non-blocking while pre-existing findings remain", 23 files) pushed as a fast-forward (f31be1979..d91d8e274) without --force or --force-with-lease. HEAD equals origin/bug/ci-skip-evidence-only-commits-962. Porcelain was empty after the push (observed before this artifact and the P2-T9 checkbox were written; both are committed by the orchestrator's next evidence commit, RPD-6). AC-36 remains unchecked in spec.md.

- `git add -- <paths above>` EXIT_CODE: 0 -> (no output)
- `git commit -m "ci(962): keep the security scan non-blocking while pre-existing findings remain" -m "<trailer>"` EXIT_CODE: 0 -> `[bug/ci-skip-evidence-only-commits-962 d91d8e274]`, 23 files changed, 515 insertions(+), 25 deletions(-)
- `git push origin HEAD:refs/heads/bug/ci-skip-evidence-only-commits-962` EXIT_CODE: 0 -> `f31be1979..d91d8e274  HEAD -> bug/ci-skip-evidence-only-commits-962`
- `git status --porcelain` EXIT_CODE: 0 -> (empty)
- `git rev-parse HEAD` EXIT_CODE: 0 -> `d91d8e2746101c90c7170914e796a3168622b2b5`
- `git rev-parse origin/bug/ci-skip-evidence-only-commits-962` EXIT_CODE: 0 -> `d91d8e2746101c90c7170914e796a3168622b2b5`
