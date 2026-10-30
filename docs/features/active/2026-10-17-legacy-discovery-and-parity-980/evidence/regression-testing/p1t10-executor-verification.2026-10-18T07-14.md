# P1-T10 independent executor verification

Timestamp: 2026-10-18T07-14
Command: poetry run python SCRATCH/issue-980-verify-p1t10.py
EXIT_CODE: 0
Output Summary: 93 public-runtime cases, nine exact staged paths, 151 unchanged prior paths, 24 frozen v1 paths and 107 coverage ranges verified; 384/384 changed executable lines are covered.

## Verified boundary

The [specialist handoff](../other/p1t10-profile-boundary.2026-10-18T07-11.md) and [machine receipt](p1t10-executor-checks.2026-10-18T07-13.json) establish the complete immutable v2 profile, typed section views, configurable gate policy, mandatory claim rules, inert activation locator and explicit compatibility dispatch. All required profile fields are represented; missing/malformed fields, duplicate IDs, invalid repository/client ownership and mismatched extension pins fail before exposing a profile.

The 93 independent cases use the installed public runtime and actual offline catalog. They verify JSON/YAML equivalence, all required fields, source/target/combined roles, sorted global/client/feature requirement unions, optional offline/mobile behavior, all planning prerequisites, immutable core rules, runtime capability, draft state, numeric limits, extension catalog identity, activation and explicit v1/v2 parsing. All three review defects have passing regressions: fresh imports no longer cycle, requirement names match the core vocabulary, and schema-valid integral numbers produce typed integer limits without delayed access failures.

Five exact probe-source snapshots were retained before the four overload docstrings were added. Independent AST comparison, excluding docstrings and source-position attributes, proves unchanged executable behavior across all five final production files. Only domain_profile.py differs textually from that probe. The final receipt binds the retained 93 cases to current staged hashes and preserves the documentation diff; no broad suite was repeated by the executor.

GatePolicy cannot disable claim consistency, verified/passed evidence, exclusion rationale, profile validity or path safety. Configured completion switches remain separate. Optional modes become obligations only through the explicit global/client/feature union; applicability defaults cannot remove an inherited obligation. A configured profile is not a completion claim. Drafts remain structurally representable and fail require_configured.

The legacy parser remains the default for existing exported entry points; trusted exact v2 selection uses a lazy import and cannot be selected by artifact content. The placeholder profile validator now uses authoritative v2 parsing and retains explicit v1 compatibility. The dispatcher changes only its three obsolete profile-dependent assertions. The other 151 accepted paths, including the existing v1 profile tests, retain their recorded hashes; 24 frozen schema/example/fixture/export-test paths remain unchanged from HEAD.

## Verified quality evidence

| Check | Result | Evidence |
| --- | --- | --- |
| Black, final pass 10 | Exit 0; nine unchanged files | [Formatting](p1t10-black-pass10.2026-10-18T07-06.md) |
| Ruff, pass 10 | Exit 0; zero findings | [Lint](p1t10-ruff-pass10.2026-10-18T07-06.md) |
| Full Pyright, pass 10 | Exit 0; zero code diagnostics | [Types](p1t10-pyright-pass10.2026-10-18T07-07.md) |
| Broader runtime/caller run | Exit 0; 1,008 passed before docstring-only changes | [Broad tests](p1t10-tests-pass8.2026-10-18T07-05.md) |
| Final affected callers | Exit 0; 578 passed on final bytes | [Final tests](p1t10-tests-pass10.2026-10-18T07-09.md) |
| Reversed changed modules | Exit 0; 123 passed | [Isolation](p1t10-tests-reversed.2026-10-18T07-10.md) |
| Resource consistency | Exit 0; 33 unchanged resources | [Resources](p1t10-resources.2026-10-18T07-07.md) |
| Tracked quality tiers | Exit 0; 26/26 projects | [Classification](p1t10-tracked-tiers.2026-10-18T07-07.md) |
| Final scope/coverage audit | Exit 0; no findings | [Audit](p1t10-task-audit-pass2.2026-10-18T07-12.md) |

Raw coverage independently confirms 571/572 lines and 143/144 branch arcs. All three new modules and the replacement adapter have 100% line/branch coverage. The existing v1 parser improves from 189/190 lines and 77/78 arcs to 202/203 lines and 81/82 arcs; its sole uncovered missing-sentinel path is unchanged. All 107 measured function/method/class ranges were recomputed, and every new or changed range has 100% line coverage. All 384 changed executable lines are covered. Maximum file length is 475; required production docstrings and staged whitespace checks pass.

Initial format/lint/type failures, the zero-test nonexistent-path command and the first audit's incorrect HEAD comparison remain recorded. Each applicable code correction restarted the ordered gate. The audit correction uses the accepted P1-T1 hash for its already-relocated test and changed no source. No dependency, suppression, skip, policy or coverage configuration changed. Tests use immutable/in-memory values and existing read-only fixtures. TypeScript, PowerShell and C# checks are not applicable to this Python-only task; full feature QA remains pending.

## Checkoff and remaining boundaries

P1-T10 is verified and checked. Plan progress becomes 14/84. No additional full-feature criterion is satisfied by this task alone; AC-10, AC-11, AC-12 and AC-14 remain checked, 4/66 in each source. Local filesystem authorization, protected activation, whole-workspace operations and semantic completion still require their assigned tasks before AC-03/AC-04/AC-29/AC-30 can be checked. P1-T11 is next.

The pure profile parser requires configured extension declarations to match supplied pinned catalog bytes. The later root-controlled snapshot loader must load those authorized bytes before final profile construction. Physical path containment/collisions and protected activation are not inferred from this typed configuration value.
