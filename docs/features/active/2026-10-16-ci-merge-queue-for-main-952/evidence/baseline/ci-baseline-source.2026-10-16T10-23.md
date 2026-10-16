# CI Baseline Source Check (P0-T3)

Timestamp: 2026-10-16T10-23
Command: git ls-files -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/; then Read of the lexicographically greatest listed file matching ci-baseline.*.md
EXIT_CODE: 0
Output Summary:
- Rule: D-BASE (baseline CI run), as recorded by ORCH-1.
- Listed files matching ci-baseline.*.md: ci-baseline.2026-10-16T09-22.md, ci-baseline.2026-10-16T09-57.md
- File read: docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/ci-baseline.2026-10-16T09-57.md
- B (ci-baseline file)=04f594f2ad2b891cbd8d1388a2e7fe2c67044d28
- B (P0-T2 merge-base)=04f594f2ad2b891cbd8d1388a2e7fe2c67044d28
- B values equal: true
- PS_BASE_CLAUDE_GATE=99.25 (numeric)
- PS_BASE_CODEX_GATE=87.90 (numeric)
- PS_BASE_RELEASE=94.93 (numeric)
- R_base=38881687469
