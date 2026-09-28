# AC Check-Off — Registration, mirroring, and coverage (9 criteria; spec.md and user-story.md)

Timestamp: 2026-09-17T08:47:53-04:00 (file write time)
Command: per-criterion review against the named evidence, then '- [ ] ' -> '- [x] ' for the lines between '### Registration, mirroring, and coverage' and the next heading in spec.md and user-story.md (criterion text unchanged)
EXIT_CODE: 0
Output Summary: 9 of 9 criteria verified and checked off in both files.

| # | Criterion (abridged) | Verified by |
| --- | --- | --- |
| 1 | WorktreeResolution.psm1 appears exactly once in core.json paths (exact-equality filter compared to one) | [P3-T5] expression evaluated to 1; evidence/regression-testing/manifest-suite.2026-09-13T22-00.md: "lists .claude/lib/worktree-resolution/WorktreeResolution.psm1 exactly once" (`@(... Where-Object { $_ -eq $expected }).Count | Should -Be 1`) |
| 2 | WorktreeTargetResolution.psm1 appears exactly once in core.json paths | [P3-T5] expression evaluated to 1; manifest-suite: "lists .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 exactly once" |
| 3 | Manifest suite follows DiscoveryValidation: -Contain, exactly-once, on-disk coverage | manifest-suite: two "lists ... in core.json paths" rows, two "exactly once" rows, "registers every on-disk worktree-resolution module so none is unregistered" |
| 4 | Separate Describe asserting SHA-256 identity with a Test-Path -LiteralPath $bundleFile guard | manifest-suite: Describe "WorktreeResolution bundle mirror byte identity" with two rows; the phrase search returned exactly 1 match |
| 5 | Both modules mirrored and byte-identical by SHA-256 | evidence/qa-gates/bundle-mirror-hashes.2026-09-13T22-00.md ([P3-T6]) and evidence/qa-gates/bundle-mirror-hashes.post-format.2026-09-13T22-00.md ([P4-T4]; final hashes E5C1C03C...4109 and EDE6AD16...A3A5, equal) |
| 6 | Both paths in CodeCoverage.Path of scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | evidence/qa-gates/coverage-path-exclusion-check.2026-09-13T22-00.md: both match counts 1 |
| 7 | Both paths in the extension runsettings copy; the copies stay text-identical; parity test passes | coverage-path-exclusion-check: both match counts 1; both copies SHA-256 21BED2B8...CA78; evidence/regression-testing/poshqc-parity-pytest.2026-09-13T22-00.md: 1 passed, exit 0 |
| 8 | No extensions/drm-copilot/resources/ path added to CodeCoverage.Path in either copy | coverage-path-exclusion-check: comment-stripped counts 0 in both copies (slices 268 lines) |
| 9 | Line coverage >= 85% per file, keyed on the package element, not inferred from a green run | evidence/qa-gates/final-poshqc-selfhosted-coverage.2026-09-13T22-00.md: package `.../.claude/lib/worktree-resolution`, WorktreeResolution.psm1 98.59 (140/2), WorktreeTargetResolution.psm1 100.00 (101/0); evidence/qa-gates/coverage-delta.2026-09-13T22-00.md states the figures are read from XML because CoveragePercentTarget = 0 |

Note for criterion 9: the MCP runner produced no row for either module ([P4-T6]:
INSTALLED-EXTENSION-SETTINGS). The per-file figures come from the self-hosted run, which reads the in-repo
run settings, as spec.md Ruling D directs.
