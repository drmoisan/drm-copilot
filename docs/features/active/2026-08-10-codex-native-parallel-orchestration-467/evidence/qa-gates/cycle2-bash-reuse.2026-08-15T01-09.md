# Cycle 2 Bash Evidence Reuse

Timestamp: 2026-08-15T02-04
Command: Re-hash the P0-T11 Bash kcov XML and test receipt after P2-T5; do not execute any Bash QA command.
EXIT_CODE: 0
Output Summary: Both frozen Bash artifacts exactly match their P0-T11 hashes. The P2-T5 fingerprint proves Bash inputs unchanged, so the retained test and line result remains valid without rerunning the suite. Branch coverage remains N/A/not-PASS and is not represented as a genuine numeric result.

## Integrity

- Coverage artifact: `evidence/qa-gates/cycle1-bash-kcov.2026-08-14T09-36/cov.xml`
- Expected coverage SHA-256: `0C936506F4C73BAF09ADD135951AF05ADECA81D20720745EEC8237AB59570B7E`
- Current coverage SHA-256: `0C936506F4C73BAF09ADD135951AF05ADECA81D20720745EEC8237AB59570B7E`
- Test artifact: `evidence/qa-gates/cycle1-bash-test.2026-08-14T09-36.md`
- Expected test SHA-256: `CB434B268C6089F1F32659CA7CB1960EDC50BAD4107811CCCD19C508463A93B4`
- Current test SHA-256: `CB434B268C6089F1F32659CA7CB1960EDC50BAD4107811CCCD19C508463A93B4`
- P2-T5 freshness receipt SHA-256: `B0EF30BCF55FBC38EA6AEDB39D02162DF0355D87A784311CF4F0AB34F147B9A7`
- Exact hash equality: `YES`

## Retained result

- Lines: `1,339/1,461 = 91.60%`
- Tests: `255/255 passed; 0 failed`
- Branches: `N/A/not-PASS`
- Numeric branch result claimed: `NO`
- Bash suite rerun in cycle 2: `NO`

Result: PASS for applicable Bash gates
