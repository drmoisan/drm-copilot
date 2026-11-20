# P1-T11 independent executor verification

Timestamp: 2026-10-18T07-32
Command: poetry run python SCRATCH/issue-980-verify-p1t11.py 2026-10-18T07-30
EXIT_CODE: 0
Output Summary: 94 final-byte public-runtime probes; five exact staged paths; 160 unchanged prior paths; 24 frozen v1 paths; all 251 executable lines, 116 branch arcs and 27 callable/class ranges covered.

## Verified boundary

The [specialist handoff](../other/p1t11-path-policy.2026-10-18T07-30.md) and [independent machine receipt](p1t11-executor-checks.2026-10-18T07-31.json) establish one pure path policy over a validated profile and injected non-following metadata. Read scope is explicit; writes require a closed artifact kind and exact identifier/path grant. Portable path syntax, reserved device names, alternate streams, traversal, separator/case/Unicode aliases, component containment and protected output separation fail closed.

The 94 independent cases use the installed public runtime and the accepted domain-profile example. Its default documentation root may contain discovery artifact roots on POSIX, Windows drive and UNC workspace anchors. The same cases reject production/configuration/output collisions, wrong-kind grants, sibling-prefix escapes, symlink/reparse ancestors, repeated identities and inconsistent directory metadata. Parent and leaf replacement invalidate a prepared write; an unrelated sibling does not. These checks use injected memory metadata and perform no test filesystem mutation.

The initial 94-case result retained its original hashes. A later attempt to capture a matching source snapshot correctly stopped because formatting had already changed a source file. That attempted capture is not binding evidence. After the final specialist handoff, the complete bounded 94-case probe was rerun successfully and its two hashes matched the staged production files. No broader suite was repeated by the executor.

Only the exact two production and three test modules changed in this task. All 160 accepted prior-task hashes and 24 frozen v1/export paths remain unchanged; maximum file size is 472 lines. The independent checker recomputed raw coverage, every measured callable/class range, staged Git object identities, file hashes and whitespace status. All checks passed.

## Verified quality evidence

| Check | Result | Evidence |
| --- | --- | --- |
| Black, final pass 4 | Exit 0; five unchanged files | [Formatting](p1t11-format-pass4.2026-10-18T07-29.md) |
| Ruff, pass 4 | Exit 0; zero findings | [Lint](p1t11-lint-pass4.2026-10-18T07-29.md) |
| Full Pyright, pass 4 | Exit 0; zero code diagnostics | [Types](p1t11-types-pass4.2026-10-18T07-29.md) |
| Final path tests | Exit 0; 241 passed in 24.63 seconds | [Tests](p1t11-tests-pass4.2026-10-18T07-30.md) |
| Reversed path modules | Exit 0; 241 passed in 10.25 seconds | [Isolation](p1t11-tests-reversed.2026-10-18T07-30.md) |
| Resource consistency | Exit 0; 33 unchanged resources | [Resources](p1t11-resource-check.2026-10-18T07-30.md) |
| Tracked quality tiers | Exit 0; 26 entries/26 projects | [Classification](p1t11-tracked-tiers.2026-10-18T07-30.md) |
| Final scope/coverage audit | Exit 0; no findings | [Audit](p1t11-task-audit.2026-10-18T07-30.md) |

Raw coverage confirms path_models.py at 98/98 lines and 34/34 arcs, and path_policy.py at 153/153 lines and 82/82 arcs. Both modules are new; all 251 added executable lines, 116 arcs and 27 function/method/class ranges have 100% coverage. No prior production module changed. No dependency, suppression, skip, policy or coverage threshold changed.

The [broader earlier run](p1t11-tests-pass2.2026-10-18T07-27.md) records 537 passed and one failed fixture assertion; it is not a passing gate. That fixture arranged a project entry at the documentation root and therefore correctly triggered output protection before its intended file/directory assertion. The fixture now uses the production root. Immutable catalog reuse reduced repeated setup work while mutable documents and fake metadata remain independent. Production bytes remained unchanged after that earlier run. Initial formatting and five Ruff E501 diagnostics are retained; the clean ordered pass follows their corrections. TypeScript, PowerShell and C# checks are not applicable to these Python-only additions; complete repository QA remains Phase 11.

## Checkoff and integration handoff

P1-T11 is verified and checked. Phase 1 is complete; plan progress is 15/84. AC-10, AC-11, AC-12 and AC-14 remain the only checked feature criteria, 4/66 in each source. No broader workspace, wrapper or native-enforcement criterion is inferred from this pure boundary. P2-T1 is the next task.

PathMetadataReader must supply trustworthy complete directory names, stable identities and non-following observations. The later I/O layer must revalidate immediately before exclusive creation or digest-matched atomic replacement; these values do not mint native authority, validate artifact content or eliminate races between separate OS operations. Symlink/reparse paths are conservatively rejected even when their current target is internal. The Phase 2 snapshot loader must load pinned local extension schemas only from configured documentation roots before constructing the supplied catalog/profile. General read-scope permission is not sufficient for that schema-specific restriction.
