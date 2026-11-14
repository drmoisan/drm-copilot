# Self-review against the policy-audit, code-review and feature-audit templates — remediation cycle 2 ([P1-T13])

Timestamp: 2026-11-14T09-09
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md and feature-audit.yyyy-MM-ddTHH-mm.md against git diff 2c8dee6dd3a82f210561d9efe623767ae902de51 (merge-base of origin/main and HEAD, unchanged since [P0-T1]) to the working tree, 261 tracked paths plus 13 untracked cycle files; figures read from the cycle-2 records listed below
EXIT_CODE: 0
Output Summary: 0 FAIL rows. Every checklist item is PASS or N/A. Against the cycle-1 self-review (self-review.2026-11-14T07-53.md), the branch diff adds: the quality-tiers.yml entry for `.claude/lib/hook-dispatch` (F1), the registryHookPaths helper and the registry-aware collectRegisteredHookClosure (F2), the new unit-test file and the extended integration assertion, and checkbox state in spec.md and user-story.md. The Linux hook-suite CI criterion stays open as pending-CI and is not a FAIL row.

Records read: evidence/remediation-baseline/quality-tiers.2026-11-14T08-45.md, typescript-static.2026-11-14T08-47.md, jest-root.2026-11-14T08-48.md, jest-extension.2026-11-14T08-49.md; evidence/other/main-integration.2026-11-14T08-49.md and task-check.cycle2.* records; evidence/qa-gates/typescript-static.2026-11-14T09-00.md, jest-root.2026-11-14T09-01.md, jest-extension.2026-11-14T09-01.md, quality-tiers.2026-11-14T09-02.md, pytest.2026-11-14T09-07.md, conditional-gates.2026-11-14T09-07.md, consistency.2026-11-14T09-09.md.

## Findings of this cycle (explicit rows)
| Item | Result | Evidence |
|---|---|---|
| F1 — QT008 for `.claude/lib/hook-dispatch` | PASS | entry added (T3, sibling rationale); check_quality_tiers exit 1 at baseline, exit 0 with "quality-tiers: OK (34 entries, 34 discovered projects)" in quality-tiers.2026-11-14T09-02.md; tier tests pass in pytest.2026-11-14T09-07.md |
| F2 — bundle publish closure test (Expected > 21, Received 10) | PASS | failing in jest-root.2026-11-14T08-48.md and jest-extension.2026-11-14T08-49.md; passing in both final Jest gates; integration test now asserts every registry hook is a required path |
| [P0-T5] sweep of the F2 class | PASS | main-integration.2026-11-14T08-49.md classifies every code or test hit; one consumer (collectRegisteredHookClosure), re-targeted in [P1-T2]; [P1-T4] skip branch |

## Policy audit: coverage evidence checklist and per-language rows
| Item | Result | Evidence |
|---|---|---|
| TypeScript row | PASS | 3 test files changed, no production TypeScript; root Jest 5574 passed, 0 failed, lines 98.29% -> 98.29%, branches 93.67% -> 93.68%; extension Jest 5557 passed, 0 failed, lines 97.17% -> 97.17%, branches 93.94% -> 93.94% |
| TypeScript baseline artifacts | PASS | remediation-baseline/jest-root.2026-11-14T08-48.md, jest-extension.2026-11-14T08-49.md |
| TypeScript post-change artifacts | PASS | qa-gates/jest-root.2026-11-14T09-01.md, jest-extension.2026-11-14T09-01.md |
| Python row | PASS | no Python file changed; pytest 16723 passed, 0 failed; line 97.13% and branch 94.42%, equal to pytest.2026-11-14T07-50.md |
| PowerShell row | N/A | no PowerShell file changed and no Pester suite reads a changed file (conditional-gates.2026-11-14T09-07.md) |
| Bash row | N/A | no shell script changed |
| YAML configuration (quality-tiers.yml) | PASS | check_quality_tiers exit 0; contract tests pass |
| Per-language comparison summary | PASS | comparison tables in the three final gate records |

## Policy audit: 1 General unit test policy
| Item | Result | Evidence |
|---|---|---|
| Independence | PASS | new cases share no state; parallel Jest gates green |
| Isolation | PASS | each new case targets registryHookPaths with one input shape |
| Fast execution | PASS | the two touched suites run in under 1 s (task-check P1-T3) |
| Determinism | PASS | in-memory JSON text only; no clock, randomness or timers |
| Readability and maintainability | PASS | descriptive It names; hookEntry helper builds entries |
| Baseline coverage documented | PASS | Phase 0 Jest records |
| No coverage regression | PASS | no total dropped in either Jest gate or in pytest |
| Changed files meet thresholds | N/A | changed TypeScript files are test code, outside the denominator; every coverageThreshold entry met |
| New code coverage >= 90% | N/A | no production code added |
| Positive flows | PASS | "returns every PreToolUse hook path named by a registry command" |
| Negative flows | PASS | "skips a registry hook whose command names no .codex/hooks script" (non-string, missing command, non-object hook, non-array hooks, .claude path) |
| Edge cases | PASS | "returns no path for a registry without PreToolUse groups" (empty hooks, non-array PreToolUse, no hooks block, top-level array); duplicate paths de-duplicated in the first case |
| Error handling | PASS | a missing registry throws from readFileSync, so collectRegisteredHookClosure fails closed |
| Concurrency | N/A | none |
| State transitions | N/A | no stateful component |
| Clear failure messages | PASS | toEqual over path lists names the differing paths; `missing` lists unpublished files |
| Arrange-Act-Assert pattern | PASS | each new case carries the three sections |
| Document intent | PASS | file and helper TSDoc |
| Avoid external dependencies | PASS | no network, process or temporary file; the integration test keeps the read-through filesystem that refuses bundle writes |
| Use mocks or stubs | N/A | pure function, none needed |
| Environment stability | PASS | no global state touched |
| Pre-submission review | PASS | this record |

## Policy audit: 2 General code change policy
| Item | Result | Evidence |
|---|---|---|
| Clarify the objective | PASS | remediation-inputs.2026-11-14T07-57.md findings F1 and F2 |
| Read existing change plans | PASS | remediation-plan.2026-11-14T07-57.md executed in order |
| Document the plan | PASS | plan checked off on disk with a task-check.cycle2 record per task |
| Simplicity first | PASS | one function plus two narrowing helpers; one YAML entry |
| Reusability | PASS | registryHookPaths is exported and used by the helper and the integration test |
| Extensibility | N/A | test helper |
| Separation of concerns | PASS | parsing is pure (registryHookPaths); file reads stay in collectRegisteredHookClosure |
| At or below the 800-line hard limit | PASS | largest changed file 262 lines (consistency.2026-11-14T09-09.md) |
| Descriptive names | PASS | registryHookPaths mirrors registry_hook_paths |
| Docs and docstrings | PASS | TSDoc on every new function; collectRegisteredHookClosure TSDoc names both sources |
| 1. Formatting | PASS | Prettier "All matched files use Prettier code style!" |
| 2. Linting | PASS | ESLint 0 findings |
| 3. Type checking | PASS | tsc 0 errors (test project included); no type assertion, no suppression |
| 4. Testing | PASS | root and extension Jest, pytest green |
| Full toolchain loop | PASS | single clean pass, no restart |
| Explicit reporting | PASS | each gate record carries Timestamp, Command, EXIT_CODE and Output Summary |
| Update supporting documents | N/A | no fact in README, the architecture document or the execution-environment brief changed |

## Policy audit: 3 and 4 language sections
| Item | Result | Evidence |
|---|---|---|
| TypeScript strong typing (unknown plus narrowing, no `as`) | PASS | isRecord type guard and Array.isArray narrowing; bracket access for index-signature properties |
| TypeScript ES modules | PASS | import syntax only |
| TypeScript Jest, *.test.ts naming, AAA | PASS | real-bundle-filesystem.test-helpers.test.ts |
| 3A Python | N/A | no Python changed |
| 3B PowerShell | N/A | no PowerShell changed |
| 3C Bash | N/A | no bash changed |
| 3D JSON | N/A | no JSON changed |
| 4A Python unit tests | N/A | no Python test changed |
| 4B PowerShell unit tests | N/A | no Pester test changed |

## Policy audit: 6 and 7 metrics, CI cross-check, 8 gaps
| Item | Result | Evidence |
|---|---|---|
| Total, passed and failed tests | PASS | root Jest 5574/0, extension Jest 5557/0, pytest 16723/0 |
| Test file size | PASS | 98 and 139 lines |
| CI cross-check | N/A | CI runs on the PR head after the push |
| Removed or skipped tests | PASS | no test removed or skipped |

## Code review checklist
| Item | Result | Evidence |
|---|---|---|
| No secrets in code | PASS | diff inspected |
| No unsafe subprocess or command construction | PASS | none added; commands are parsed as text only |
| Input validation at boundaries | PASS | registry JSON narrowed from unknown; entries of another shape skipped |
| Error handling remains explicit | PASS | missing registry throws (fail closed) |
| Configuration and path handling is safe | PASS | node:path join under the bundle root; POSIX relative paths for both Jest legs |
| TypeScript: what changed well | PASS | the closure test now covers the dispatched PreToolUse hooks the registry lists |
| TypeScript: type safety and maintainability | PASS | no any, no assertion, no suppression |
| Python, PowerShell and C# audits | N/A | out of scope |
| Determinism, isolation, speed and diagnostics prompts | PASS | see section 1 rows |

## Feature audit: acceptance criteria touched by this cycle
| Item | Result | Evidence |
|---|---|---|
| spec.md Issue AC 5 "Both `pack-manifests/core.json` files list ..." | PASS | checked in [P1-T11]; pytest contract tests and both Jest gates green |
| spec.md Issue AC 5 "Every existing test that pinned the per-hook registration shape ..." | PASS | checked in [P1-T11]; the last pinned reader (collectRegisteredHookClosure) reads the registry |
| user-story.md "Bundle settings and config, bundle mirrors ..." | PASS | checked in [P1-T11] |
| Definition of Done "Behavior matches acceptance criteria on Windows and on the Linux hook-suite CI job" | N/A | pending-CI, left unchecked |
| Cost reports unchanged | PASS | empty diff in consistency.2026-11-14T09-09.md |

## Observations (non-blocking)
- origin/main advanced during the cycle (Merge pull request #1178, issue 1156) without moving the merge base of origin/main and HEAD; per the plan the executor did not merge origin/main.
- The literal `poetry -C <worktree root> run pytest <absolute paths>` form and a Write of a scratch `.py` helper were denied by PREIMPLEMENTATION_GATE_BLOCKED; the sh launcher route ran every Python step.
