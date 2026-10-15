# Baseline CI overall coverage (P0-T12)

Timestamp: 2026-10-07T00:00:00Z
Command: gh run download 37645267440 --name shell-coverage --dir artifacts/pester/kcov-baseline-756; then grep -m1 -o 'line-rate="[0-9.]*"' artifacts/pester/kcov-baseline-756/cov.xml (equivalent: Grep tool with -o on the same file)
EXIT_CODE: 0
Output Summary: cov.xml is at the artifact root. First line-rate attribute = line-rate="0.938" (93.8%). Download exit code 0.
