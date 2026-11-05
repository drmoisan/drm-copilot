Timestamp: 2026-11-05T06-34
Command: python SCRATCH/issue-1082-final-evidence.py coverage
EXIT_CODE: 0
Output Summary:

Authoritative final coverage is the complete native Pester 6.2 three-process cohort on snapshot 3E5063B6997E6BD423B312A66966677AB358F7FE69826AC0D61834FC9BA33FBA at HEAD 726184cc. All 507 test files and 14,298 cases are accounted for: 14,288 passed, zero failed, ten existing skips; all three exits and merge/completeness returned zero.

| Population | Baseline | Final | Interpretation |
|---|---:|---:|---|
| Python production lines | 32,270/33,367 (96.7123%) | 32,270/33,367 (96.7123%) | Identical denominator and covered lines |
| Python production branches | 11,722/12,516 (93.6561%) | 11,722/12,516 (93.6561%) | Identical denominator and covered branches |
| Bash production lines | 3,524/3,745 (94.0988%) | 3,616/3,799 (95.1829%) | Every production file retained; 54 additional instrumented lines |
| Bash raw kcov lines | 3,524/3,745 | 3,616/4,059 (89.0860%) | Final raw report also misclassifies 260 documentation lines; they remain disclosed |
| PowerShell configured production files | 271 | 271 | Identical configured roots and file population |
| PowerShell production lines | 2,964/24,056 (12.3213%) | 22,850/24,365 (93.7821%) | Baseline is affected-suite-only; final is complete-suite coverage; not a like-for-like test-scope gain |
| PowerShell production instructions | Baseline captured in raw Pester 5 report | 35,399/38,203 (92.6603%) | Final merged JaCoCo report |

The Python final run passed 16,099 tests with six existing skips using pytest-xdist; baseline passed 16,087 with six skips. No Python production source changed. Bash final passed all 799 cases versus baseline 766.

| Runtime file | Baseline line coverage | Final line coverage |
|---|---:|---:|
| scripts/bash/container_versions.sh | 16/16 (100%) | 31/31 (100%) |
| .devcontainer/lib/workspace.sh | New | 16/16 (100%) |
| .devcontainer/verify-container.sh | 39/62 (62.9032%) | 91/91 (100%) |
| .devcontainer/post-create.sh | 92/124 (74.1935%) | 101/118 (85.5932%) |
| scripts/dev-tools/HostBootstrap.psm1 | 190/190 (100%) | 191/191 (100%) |
| scripts/powershell/PoshQC/PoshQC.psm1 | 53/60 (88.3333%) | 54/61 (88.5246%) |
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 192/205 (93.6585%) | 192/205 (93.6585%) |

The same 953-case focused Pester population also passed on both Pester versions (944 passed, nine existing skips). Under Pester 6 its line counter was 2,983/24,365. The increase of 309 reported production line records across the same 271 files is an instrumentation/reporting change, not a source exclusion; unchanged HostBootstrap source itself reports 190 versus 191 executable lines. Consequently the whole-suite final numerator is not presented as a test-quality improvement over the focused baseline.

Changed-line mapping uses the retained actual pre-change files from the original baseline materialization, normalized only for line terminators, with difflib replacement/insertion ranges intersected with report executable line records. Blank/comment/declaration-only lines absent from the tracer are listed in the raw mapping, rather than counted as covered. No reported executable changed line is omitted.

| Changed production file | Covered/measured changed lines | Coverage |
|---|---:|---:|
| .devcontainer/verify-container.sh | 75/75 | 100.0000% |
| scripts/bash/container_versions.sh | 18/18 | 100.0000% |
| .devcontainer/post-create.sh | 6/6 | 100.0000% |
| .devcontainer/lib/workspace.sh | 16/16 | 100.0000% |
| scripts/powershell/PoshQC/PoshQC.psm1 | 2/2 | 100.0000% |
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 1/1 | 100.0000% |

All 115 measured changed Bash lines and all three measured changed PowerShell runtime lines are covered. The new workspace helper is 16/16, and the newly introduced verifier/predicate execution paths are fully covered. Repository line coverage exceeds 80%; new executable units meet 90%; changed runtime files meet their applicable 85% floor and changed-code coverage does not regress. Python changed files are tests only, so new Python production-code coverage is N/A. Dockerfile build instructions and declarative JSON/PSD1 configuration are validated by full builds, runtime probes and contracts rather than assigned invented line coverage.

Canonical/bundled runtime copies are checked byte-for-byte in the contracts evidence. Bundled copies are outside the established configured instrumentation roots; their canonical measured line coverage is traced through exact byte parity, not claimed as separately instrumented coverage or added to the denominator. Every configured production file remains in each final shard.

Raw evidence: SCRATCH/issue-1082-final-cohort-numeric-summary.json; SCRATCH/issue-1082-changed-line-coverage.json; baseline/final Python coverage JSON; baseline/final Bash XML; original baseline Pester XML; final cohort merged JaCoCo/JUnit under SCRATCH/stage/current-source-final/artifacts/pester. Invalid HOME probes, interrupted diagnostics, and older failing snapshots do not contribute to final coverage.
