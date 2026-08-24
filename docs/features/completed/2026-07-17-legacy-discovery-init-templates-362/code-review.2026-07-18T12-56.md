# Code Review: legacy-discovery-init-templates (#362) — R4 Re-Review, Remediation Cycle 1

**Review Date:** 2026-07-18
**Reviewer:** feature-review agent (Claude, R4 re-audit)
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/`
**Feature Folder Selection Rule:** folder suffix matches issue #362 in the branch name; only active folder with material scoping-doc changes on this branch.
**Base Branch:** `epic/legacy-discovery-and-parity-integration` (merge-base `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`)
**Head Branch:** `feature/legacy-discovery-init-templates-362` (HEAD `7610bf2539f62bba5e4489f559ed486fb368043a`)
**Review Type:** Post-remediation re-review (full feature-vs-base diff, both commits `48d16f6f` and `7610bf25`)

---

## Executive Summary

This branch adds the `dev.discovery.init` scaffolding command (three new Python modules under `scripts/dev_tools/discovery/`), eight committed workspace templates under `docs/discovery/templates/`, a one-line Poetry console-script registration, a root-anchoring `.gitignore` fix, and 84 discovery-package tests. The remediation commit `7610bf25` resolves all four Blocking findings from the initial review: the seven artifact templates are now actually tracked in git (verified in a fresh detached checkout of HEAD), the domain-profile template parses under the real #360 loader, all seven rendered artifact instances validate against the real `schemas/discovery/v1/` schemas, and the package's public re-export surface is restored and regression-guarded.

Evidence reviewed: the regenerated PR-context summary/appendix, the full `f18c1c16..7610bf25` diff, direct inspection of all production and test sources and all eight templates, an independent verification script (loader parse, seven `jsonschema.validate` runs, `$schema` path resolution, import-surface check), a real end-to-end CLI invocation against a scratchpad target, and an independent full toolchain re-run (Black, Ruff, Pyright, Pytest with coverage — all exit 0, 1708 passed, 0 skipped).

**What changed:**
Relative to the base: `scripts/dev_tools/discovery/{init_cli,init_flow,init_models}.py` (new), `scripts/dev_tools/discovery/__init__.py` (re-export surface restored + namespace docstring), `docs/discovery/templates/**` (8 files), `.gitignore` (`artifacts` -> `/artifacts`), `pyproject.toml` (`dev.discovery.init` script), `tests/scripts/dev_tools/discovery/**` (5 test modules), and feature-folder documentation/evidence.

**Top 3 risks:**
1. Cross-repository `$schema` resolution: rendered artifact instances written into a consumer repository carry relative `$schema` paths computed against drm-copilot's tree; they will not resolve from an external consumer checkout. This is an explicitly recorded open question owned by feature 9002 (spec.md "Upstream Dependencies"), not a defect in this branch.
2. `.gitignore` anchoring is repository-wide: any future intentionally ignored nested `artifacts/` directory now requires its own entry. Current working tree is clean, so nothing regressed today.
3. Suppression hygiene: seven test-only `# noqa: ARG001` comments deviate from the pre-authorized comment format (Minor; see findings).

**PR readiness recommendation:** **Go** — all prior Blockers independently verified as resolved; toolchain and coverage gates pass; the only open finding is Minor and test-only.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev_tools/discovery/test_init_models.py` | lines 20, 24, 28, 32, 35, 41 | Bare `# noqa: ARG001` on `pathlib.Path` stub functions; `.claude/rules/python-suppressions.md` pre-authorizes this fact pattern only as `ARG002` with a required reason comment (`- match [InterfaceName] API`) | Amend to `# noqa: ARG001 - match pathlib.Path API`; consider proposing `ARG001` for the pre-authorized list (policy-doc change owned by the repo owner) | Suppressions must exactly match a pre-authorized pattern or carry explicit approval; substance matches the authorized test-stub pattern, so severity is Minor | Grep of new test files; `.claude/rules/python-suppressions.md` "ARG002" section |
| Minor | `tests/scripts/dev_tools/discovery/test_init_cli.py` | line 79 | Same bare `# noqa: ARG001` deviation on a `create_discovery_workspace` stub | Amend to `# noqa: ARG001 - match create_discovery_workspace API` | Same as above | Grep of new test files |
| Info | `scripts/dev_tools/discovery/init_models.py` | lines 13-23 | `init_models.py` reports 6/12 lcov branch records; the 6 unhit records are phantom `return from function` branches on the six `typing.Protocol` ellipsis stubs, which have no executable alternative | No action required; documented in the policy audit's coverage section | Prevents future reviews from misreading the lcov record as a coverage gap; all executable lines/branches are covered (100% lines) | `artifacts/python/lcov.info` BRDA records for `init_models.py` |
| Info | `docs/discovery/templates/artifacts/*.template.json` | `$schema` fields | Relative `$schema` paths resolve from the templates' committed location but will not resolve from rendered instances inside an external consumer repository | Track under feature 9002 as already recorded in `spec.md` ("Open cross-feature question") | Cross-repo resolution convention is owned by 9002; this branch correctly copies the current convention verbatim | `spec.md` Upstream Dependencies; reviewer `$schema` resolution check (all 7 resolve in-repo) |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Clean three-layer decomposition exactly as specified: `init_cli.py` is pure wiring (argparse, stderr print, `SystemExit(1) from exc`), `init_flow.py` is pure orchestration with zero I/O of its own and no `argparse`/`print`, and `init_models.py` isolates the `FileSystem` protocol, the disk-backed implementation, and the path constants.
- The no-partial-scaffold invariant is enforced structurally: `create_discovery_workspace` runs `validate_template_set` and `validate_target_path` before the first `ensure_dir`/`write_text`, and `zip(..., strict=True)` over the template/output constant tuples fails loudly if the two tuples ever drift out of alignment.
- `validate_template_set` collects and reports every missing template path in one `FileNotFoundError` rather than failing on the first, which gives a consumer a complete fix list in one run.
- The remediation restored `__init__.py` correctly: the #360 re-export block is byte-for-byte in spirit (same names, `__all__`), the new namespace docstring is merged in, and `test_package_exports.py` asserts identity (`is`) against the defining submodules so the surface cannot silently regress again.
- The R1 fix chose the `.gitignore` anchor (`/artifacts`) rather than relocating the templates, which keeps the spec's documented template layout intact; `git check-ignore` confirms the nested path is no longer matched and the top-level orchestration `artifacts/` directory remains ignored.

#### Typing and API notes

- Full type annotations throughout; type-only imports (`Mapping`, `Path`, `FileSystem`, `Sequence`) are correctly deferred under `TYPE_CHECKING` with `from __future__ import annotations`.
- `FileSystem` as a six-method `typing.Protocol` matches the established repo precedent and keeps the flow layer testable without disk. `RealFileSystem.write_text` creating parent directories is a small behavioral superset of `pathlib`, and `init_flow` does not depend on it (it calls `ensure_dir` explicitly), so fake implementations without that behavior remain valid.
- New public surface: `create_discovery_workspace(target_dir, template_root, fs, *, force=False)` uses a keyword-only flag for future extension, per policy preference.

#### Error handling and logging

- Exception types are specific and match the spec's contract (`FileNotFoundError`, `NotADirectoryError`, `FileExistsError`); the CLI catches exactly the four expected types — no bare/broad except — and chains with `from exc`.
- The `FileExistsError` message for a non-empty target says "Pass force=True to proceed anyway", which is the API-level phrasing; the CLI flag is `--force`. A consumer seeing the CLI error gets a technically accurate but API-flavored hint. Cosmetic; not raised as a finding since the message still identifies the exact condition and the `--force` flag is documented in `--help`.

---

## Test Quality Audit

The discovery subset is 84 tests in 0.24s; the full suite is 1708 tests in 8.80s with 0 failures and 0 skips. The previously skipped schema-conformance placeholder was replaced with an implemented test that runs `jsonschema.validate` for all seven rendered artifacts against the real merged schemas — closing the exact detection gap that allowed the R2/R3 divergences to ship in the original commit. Coverage: 100% lines on all four new/changed production files; repo-wide 88.17% lines / 78.90% branches with no regression.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/discovery/test_init_flow.py` — full positive/negative/edge matrix for the flow layer against an in-memory `FakeFileSystem`, plus the two real-contract tests (loader parse, schema conformance). Negative tests assert both the exception and that nothing was written.
- `tests/scripts/dev_tools/discovery/test_init_cli.py` — argparse contract, success-path delegation, template-root override, parametrized fail-fast exit codes with stderr assertions, and a pyproject registration check.
- `tests/scripts/dev_tools/discovery/test_init_models.py` — `RealFileSystem` delegation via `monkeypatch` on `pathlib.Path` (no real I/O), path-constant shape invariants, default-root resolution.
- `tests/scripts/dev_tools/discovery/test_domain_neutrality.py` — disallowed-token regex over all 8 templates and over rendered output from a real scaffold pass.
- `tests/scripts/dev_tools/discovery/test_package_exports.py` — identity and `__all__` regression guards for the restored re-export surface.
- `evidence/qa-gates/r1c1-*.2026-07-18T12-18.md` and `evidence/regression-testing/r1c1-clean-checkout-verification.*` — executor evidence; all headline numbers independently reproduced by this review.

### Quality assessment prompts

- **Determinism:** no clock, RNG, network, or environment dependence; inputs are in-memory structures and committed repo files.
- **Isolation:** each test constructs its own `FakeFileSystem`/stubs; CLI tests never reach the flow layer's real logic.
- **Speed:** 0.24s for the 84-test subset (observed in this review's run).
- **Diagnostics:** exception-message assertions and f-string assert messages identify the failing template/token/export by name.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Templates contain only placeholder tokens; no credentials, tokens, or endpoints anywhere in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | No `subprocess`, `os.system`, `eval`, or `exec` in any changed file. |
| Input validation at boundaries | ✅ PASS | Target path and template set validated fail-fast before any write; partial template sets rejected with a complete missing-path list. |
| Error handling remains explicit | ✅ PASS | Specific exception types only; CLI converts exactly four expected types to `SystemExit(1)`; verified end-to-end (missing-parent invocation exits 1 with a clear message and writes nothing). |
| Configuration / path handling is safe | ✅ PASS | No path strings interpolated into commands; `resolve_default_template_root` computes from `__file__`; templates never executed as code (literal `str.replace` only). |

---

## Research Log

No external research was required. All determinations rest on in-repo sources: the feature folder documents, `.claude/rules/*`, `scripts/dev_tools/discovery/domain_profile*.py` (the real #360 loader), `schemas/discovery/v1/*.schema.json` (the real #359 schemas), `scripts/dev_tools/validate_json.py` (`_load_schema` no-scheme rule), and the git history of both branch commits.

---

## Verdict

The remediated branch is ready for normal PR flow. All four cycle-1 Blockers are independently verified as resolved at HEAD `7610bf25` — committed template presence in a fresh checkout, real-loader parse of the domain profile, real-schema validation of all seven rendered artifacts, and the restored, regression-guarded public re-export surface. The toolchain is clean in a single pass and coverage exceeds the uniform gates with no regression. The two Minor findings (suppression comment format in test code) and two Info notes do not affect production behavior and may be handled during PR polish or as follow-ups; they do not warrant a second remediation cycle. This conclusion is consistent with the Findings Table and the **Go** recommendation above.
