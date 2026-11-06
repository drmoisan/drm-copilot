Timestamp: 2026-11-05T06-20
Command: Materialize SCRATCH/stage/current-source-final from HEAD plus the complete binary diff; compare path sets, binary diffs, and every changed file's bytes.
EXIT_CODE: 0
Output Summary:

HEAD: 726184cc65c685d17876be32de2f776441e914f5. Complete current binary diff SHA256: 3E5063B6997E6BD423B312A66966677AB358F7FE69826AC0D61834FC9BA33FBA. All 35,576 tracked paths match; all 31 current-diff files are byte-identical to host, including the tracked lifecycle helper and the corrected console-independent merge entrypoint fixture. The snapshot contains 507 Pester test files. No untracked source was introduced.

The original all-path physical audit established unchanged base content, with 36 CRLF-to-LF-only checkout differences documented separately. This clone follows the same .gitattributes and enables core.longpaths only in its own Git configuration. The ignored stale host MCP payload is absent from this clean clone; the original remains unchanged.

P4-T4 authoritative complete JaCoCo coverage, merge, and completeness use the final three-process cohort selecting all 507 test files and all 271 configured production files. P4-T6 fresh single-process isolation selects the same complete test population with only CodeCoverage.Enabled=false in a scratch settings copy. This avoids duplicate profiling while preserving every case. All three shuffled orders use all 37 touched Pester test files.

All final runs bind this exact snapshot. Earlier source digests and results remain historical and cannot substitute for final acceptance. No final pass is claimed by this source receipt.

Raw receipt: SCRATCH/issue-1082-final-source-manifest.json. Exact patch: SCRATCH/issue-1082-current-source-final.patch.
