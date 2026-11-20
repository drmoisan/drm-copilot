# Code Review: Skill-Referenced Scripts Bundled With Their Skills (#762)

---

**Review Date:** 2026-09-28
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762`
**Feature Folder Selection Rule:** Only active feature folder changed on the branch; its `-762` suffix matches the canonical issue number supplied by the caller.
**Base Branch:** `main` (merge base `42e95e275953d3235eeab7ed5cebf26c7b019f51`)
**Head Branch:** `fix/skill-bundled-scripts` @ `4606f5ab73dc8e5dabdcccc89a40b7e1ad585412`
**Review Type:** Initial review

---

## Executive Summary

The branch fixes issue #762 (skills invoking scripts that the push-down bundle does not carry). It relocates ten `cleanup-merged-worktrees` bash scripts into `.claude/skills/cleanup-merged-worktrees/scripts/`, relocates `Invoke-CiGateParser.ps1` into `.claude/lib/ci-gate/`, mirrors all eleven files byte-identically into `extensions/drm-copilot/resources/claude-customizations/`, lists them in `core.json`, extends Shell QC discovery and kcov scope to `.claude/skills/`, and adds a pytest-run guard that checks every skill's script references and skill-folder files against the bundle and pack manifests. Evidence reviewed: the full diff (139 files, of which about 90 are feature-folder documentation and evidence), local re-runs of black/ruff/pyright and the guard and bundle-contract pytest suites, byte comparison of all mirror pairs, a whole-repository old-path sweep, and the CI artifacts of run 36514443218 (all 16 jobs `success`). Implementation quality is good: relocations are content-preserving renames (similarity 93-100%), the guard has a clean pure/I-O split, and coverage is unchanged or improved in every language.

**What changed:**
- Bash: `git mv` of ten scripts; edits limited to `# shellcheck source=` directives and path comments. Library resolution already used `$SCRIPT_DIR` and library-relative paths, so runtime behavior is unchanged at the new location. `shell_qc_lib.sh` adds `.claude/skills` to `discover_shell_scripts` roots and to the kcov `--include-pattern`.
- PowerShell: parser moved (only its `.EXAMPLE` path changed); Pester suite moved to `tests/scripts/claude-lib/ci-gate/`; new `CiGate.Manifest.Tests.ps1`; parser added to the Pester coverage allow-list in both PoshQC settings copies.
- Python: new `skill_bundle_contract.py` (pure, 495 lines) and `skill_bundle_contract_cli.py` (I/O, 219 lines); four new test files; one pinned SHA-256 digest re-baselined.
- Skills/rules: `cleanup-merged-worktrees`, `orchestrate`, `epic-orchestrate` SKILL.md and `.claude/rules/shell.md` updated with bundled paths.

**Top 3 risks:**
1. The guard recognizes script dependencies only through an enumerated invocation grammar. Before the fix it did not detect the `orchestrate`/`epic-orchestrate` parser references at all (prose citation "via `scripts/orchestration/...`"); that case is covered only by the dedicated `test_ci_gate_parser_skills_invoke_bundled_parser` and by rewriting the skill text into an explicit `pwsh -File` form. A future skill that cites a script in prose would not be flagged.
2. `skill_bundle_contract.py` is at 495 of 500 permitted lines; adding the next invocation form will require a module split.
3. The orchestrate S9 instruction now reads `pwsh -NoProfile -File ... -ChecksJson <checks-json>`. Passing a JSON document containing double quotes as a native command-line argument is quoting-sensitive, particularly on Windows; the parser also accepts pipeline input, which avoids that exposure.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; all toolchain stages and CI jobs pass on code-identical head `7d8234ed`, and coverage thresholds are met in every changed language.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/dev_tools/skill_bundle_contract.py` | `_INVOCATION_PATTERNS`, lines 43-68 | Reference detection is limited to enumerated invocation verbs (`bash`/`sh`/`source`, `pwsh -File`, `&`, `.`, `Import-Module`, `python`, `python -m`). A backticked script path in prose (for example "Parse the JSON via `scripts/x.ps1`") is treated as a citation and not checked. The pre-fix guard run reported only the cleanup-worktrees violation and returned `()` for both orchestration skills. | Track a follow-up to flag backticked script paths under non-published roots (for example `scripts/**`) in `SKILL.md` bodies as a warning class, or document an authoring rule that skill script invocations must use an explicit invocation form. | The guard is the regression barrier for AC6; prose citations are the form that originally escaped detection for two of the three affected skills. | `evidence/regression-testing/guard-before-fix.2026-09-28T22-02.md` (second failure: `got {'orchestrate': (), 'epic-orchestrate': ()}`); spec Risks section acknowledges the heuristic. |
| Minor | `scripts/dev_tools/skill_bundle_contract_cli.py` | lines 59, 96, 127, 129 | Error branches (absent folder in `_files_under`, pack manifest without a `paths` string list, absent `.claude/skills`, absent manifest folder) have no tests; branch coverage is 77.27% (17/22), close to the 75% floor. | Add tests that call `load_repository_inputs` / `_load_pack_paths` through an injected filesystem seam or small in-memory adapter (no temporary files) for each error branch. | Error contracts documented in docstrings are unverified; the branch figure leaves little margin for future edits. | `artifacts/python/lcov.info` parsed by review: 53/57 lines, 17/22 branches; `evidence/qa-gates/python-test-coverage-new.2026-09-28T22-17.md` term-missing row. |
| Minor | `scripts/dev_tools/skill_bundle_contract.py` | whole file (495 lines) | File is 5 lines under the 500-line limit; the executor already condensed docstrings to stay under it. | Split reference extraction (`_split_frontmatter`, `_allowed_tools_block`, `parse_allowed_tools`, `extract_script_references` and patterns) into a separate module before adding further invocation forms. | Prevents a forced split under time pressure and keeps the extraction grammar independently reviewable. | `wc -l` on the file; `evidence/qa-gates/line-counts-final.2026-09-28T22-17.md`. |
| Minor | `.claude/skills/orchestrate/SKILL.md` | S9 procedure step 3, line 275 | The documented invocation passes the `gh pr checks` JSON as a `-ChecksJson` native argument to `pwsh -File`. Embedded double quotes in a native argument are subject to shell and CreateProcess quoting rules. | Document the pipeline form (`gh pr checks ... \| pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -HeadSha <sha>`) as the primary form, or note the quoting requirement. | Reduces the chance of a malformed-JSON parse failure during the S9 CI gate. | Parser `.DESCRIPTION` states it accepts `-ChecksJson` or the pipeline; skill diff at line 275. |
| Info | `scripts/dev_tools/skill_bundle_contract.py` | `_PATH_TOKEN`, line 44 | Script suffixes covered are `.sh`, `.ps1`, `.psm1`, `.py`. Node entry points (`.js`, `.mjs`, `.cjs`, `.ts`) are not recognized. | No action now; extend the suffix set if a skill begins invoking a Node script. | The research audit found no Node invocations in the 56 skills, so the current set matches present usage. | `research/2026-09-28T19-15-skill-bundle-audit-research.md` audit table. |
| Info | `scripts/dev_tools/skill_bundle_contract.py` | `find_violations` / `find_stale_exceptions`, lines 446-495 | Each function calls `_all_violations(inputs)`, so a combined run evaluates every skill twice. | No action required; optionally compute once in `main` and pass the result. | Guard runtime is under one second (spec performance constraint met). | Local run: 94 tests in 0.56s. |
| Info | `tests/fixtures/blast_radius/historical-runs/*.json` | backlog-2026-09-26.json 239-248; epic-655-followups.json 22-23; followups-2026-09-27.json 25-30, 695-700 | These fixtures still contain the old `scripts/bash/cleanup*worktrees*` paths. | No action; they are recorded historical run data consumed as test input, not callers. | AC4 excludes historical records; rewriting recorded data would falsify the fixture. | `git grep` old-path sweep in policy audit Appendix B. |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The canonical local PowerShell coverage artifact is absent in the worktree. | None for this branch; the CI-published file of the same name from run 36514443218 was inspected (parser 94.12%, report total 96.11%). | Coverage verdict rests on an inspected artifact, not on inference. | `gh run download 36514443218 -n poshqc-test-results`. |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Pure evaluation (`skill_bundle_contract.py`) has no I/O; the CLI module owns filesystem reads and injects a `loader` into `main`, which lets CLI tests run on inline data.
- `SkillBundleViolation.__post_init__` enforces the closed set of reasons at construction.
- Stale-exception detection (`find_stale_exceptions`) makes the #763 exception registry self-expiring, satisfying AC7 without manual bookkeeping.
- `_allowed_tools_block` deliberately parses only the `allowed-tools` block with `yaml.safe_load`, with a documented reason (some `description:` values are not valid YAML).
- `PUBLISHED_ROOT_FOLDERS` is pinned to the TypeScript `ROOT_FOLDERS` by `test_published_root_folders_match_typescript_root_folders`, preventing silent drift from the push-down engine.

#### Typing and API notes

- Full annotations; `Mapping`/`Iterable`/`Callable` imported under `TYPE_CHECKING`; `cast` narrows parsed YAML/JSON `object` values instead of using `Any`. Pyright: 0 errors. No `# type: ignore` or `# noqa`.
- Public API matches the spec: `parse_allowed_tools`, `extract_script_references`, `evaluate_skill_bundle`, `load_repository_inputs`, `find_violations`, `main`, plus `find_stale_exceptions`.

#### Error handling and logging

- Specific exceptions (`ValueError`, `FileNotFoundError`) with contextual messages; YAML errors are re-raised with `from`.
- The CLI emits report lines on stderr as its output contract and returns 1/0. It has no top-level handler, so a malformed manifest surfaces as a traceback; this is consistent with fail-fast policy.

### PowerShell implementation audit

#### What changed well

- The parser move is a 99%-similar rename; only the `.EXAMPLE` help path changed. Its test suite moved with it and resolves the script via `$PSScriptRoot`.
- The relocated file was explicitly added to `CodeCoverage.Path` so it stays in the coverage denominator, with an explanatory comment.

#### API and safety notes

- New manifest test is read-only (no temporary files, no external process) and asserts both membership and uniqueness.

#### Error handling and logging

- Unchanged parser behavior: fail-fast on unrecognized bucket values.

### Bash implementation audit (additional scope)

- Relocated scripts resolve siblings through `SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)` and the scan-helper fallback through the library's own directory, so the move requires no logic change.
- `shell_qc_lib.sh` change is two string additions (discovery root and kcov include); covered by a new discovery case and updated command-assertion tests with fail-before evidence.
- Bundle mirrors under `extensions/` are outside the Shell QC roots, as with the existing `.claude/lib/bash` mirrors; byte identity to the linted and measured sources was confirmed with `cmp`.

---

## Test Quality Audit

Tests are deterministic, file-read-only, and fast. Fail-before evidence exists for the guard (2 expected failures), the CI-gate manifest test, and the Shell QC discovery change (4 expected failures), each followed by after-fix evidence.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_skill_bundle_contract.py` — 18 extraction and parsing tests, including parametrized verbs/operators, placeholders, globs, and citations.
- `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py` — each violation reason, core vs. pack-specific carriage, scripts outside the skill folder, exception suppression and staleness.
- `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py` — exit codes and stderr contract via injected loader.
- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` — repository guard against the real bundle and manifests; runs in CI (`quality-checks7` 3.12 log shows the file with 5 passing tests).
- `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` — core manifest membership.
- `tests/shell/test_shell_qc_discovery.bats`, `test_shell_qc_commands.bats` — discovery root and kcov include pattern.
- `evidence/regression-testing/guard-before-fix.2026-09-28T22-02.md`, `guard-after-fix.2026-09-28T22-17.md` — regression proof for AC2, AC3, AC6.
- `evidence/qa-gates/ci-dispatch.2026-09-28T22-17.md` — green run 36514443218 on `7d8234ed`.

### Quality assessment prompts

- **Determinism:** No clock, randomness, network, or temporary files; repository tests read committed files only.
- **Isolation:** One behavior per test; inline `SkillBundleInputs` per unit test.
- **Speed:** 42 guard tests in 0.57s.
- **Diagnostics:** Repository guard failures list `<skill> | <path> | <reason>` per violation; stale exceptions are reported by name and issue.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no credentials, tokens, or `.env` files. |
| No unsafe subprocess or command construction | ✅ PASS | Guard performs no subprocess calls; bash changes are path strings only. |
| Input validation at boundaries | ✅ PASS | Manifest shape validated in `_load_pack_paths`; frontmatter fence and YAML validated. |
| Error handling remains explicit | ✅ PASS | Specific exceptions; no broad catches added. |
| Configuration / path handling is safe | ✅ PASS | Repository-relative POSIX paths; `--repo-root` defaults to the current directory; bundle mirror byte identity verified for all 15 changed `.claude` files and `pester.runsettings.psd1`. |
| Old-path callers removed | ✅ PASS | `git grep` for old parser and cleanup paths outside `docs/features` returns only historical blast-radius fixtures. |

---

## Research Log

No external research was required. All conclusions derive from the branch diff, repository files, local check-only commands, and GitHub Actions run 36514443218 artifacts.

---

## Verdict

The change is ready for normal PR flow. It satisfies the spec's design, keeps script behavior unchanged, keeps the bundle mirror byte-identical, and adds an automated CI guard with fail-before evidence. The four Minor findings (guard grammar scope, untested CLI error branches, file size headroom, and the S9 argument-passing form) are improvements suitable for a follow-up and do not block merge.
