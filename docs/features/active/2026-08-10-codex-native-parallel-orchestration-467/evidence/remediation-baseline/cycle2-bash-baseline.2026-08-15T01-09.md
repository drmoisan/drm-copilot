# Cycle 2 Bash Baseline Receipt

Timestamp: 2026-08-15T01-38
Command: Get-FileHash cycle1-bash-kcov.2026-08-14T09-36/cov.xml,cycle1-bash-test.2026-08-14T09-36.md -Algorithm SHA256; parse cov.xml root line counters; Select-String cycle1-bash-test.2026-08-14T09-36.md -Pattern 'tests|line coverage|branch coverage'
EXIT_CODE: 0
Output Summary: The Bash baseline records 1,339/1,461 = 91.60% lines and 255/255 passing tests. Branch coverage remains N/A/not-PASS; kcov placeholder branch attributes are not reported as a genuine numeric branch result.

- kcov XML SHA-256: `0C936506F4C73BAF09ADD135951AF05ADECA81D20720745EEC8237AB59570B7E`
- Test receipt SHA-256: `CB434B268C6089F1F32659CA7CB1960EDC50BAD4107811CCCD19C508463A93B4`
- Lines: 1,339/1,461 = 91.60%
- Tests: 255/255 passed; 0 failed
- Branches: N/A/not-PASS
- Numeric branch result claimed: no
- Baseline disposition: PASS for applicable Bash gates

Result: PASS for applicable gates
