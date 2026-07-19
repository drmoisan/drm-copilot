# Code Review — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-18T23-16
- Reviewer: feature-review agent
- Base branch: `epic/legacy-discovery-and-parity-integration`
- Diff range: `01fb34a8468090db01db471bb339a0dd6391a9d7..62662879766c9280015800634195a9582cb52041`
- Nature: re-review of the full branch diff (analyzer feature + merge integration + bundle push-down).

## Executive Summary

The branch delivers two stack-specific legacy-discovery analyzers in Python (`DotnetInventoryAnalyzer`, `VstoOfficeAnalyzer`), a shared pure text-scanning helper (`source_text.py`), a data-only pattern table (`vsto_patterns.py`), and a shared CLI (`stack_cli.py`) with two Poetry console scripts. The two most recent remediation cycles added a two-parent merge of the integration branch (resolving a `pyproject.toml` `[tool.poetry.scripts]` conflict) and a push-down of two `.claude` hook files plus a settings.json registration mirror into the bundled extension payload.

Code quality of the Python production modules is high and aligned with repository standards: full type annotations (Pyright strict clean), Google-style docstrings on classes and functions, dependency seams for the filesystem, clock, and schema path, narrow exception handling confined to the CLI boundary, and standard-library-only implementation. All five new production modules are under the 500-line limit and carry per-file coverage above threshold.

The bundle push-down files are byte-identical mirrors of pre-existing, Pester-tested repo hooks; their fidelity is enforced by a now-passing pytest byte-identity contract test. No consumer identifiers appear in production modules. There are no blocking code-quality defects. The one gating issue for PR readiness is a policy/evidence gap, not a code defect: the mandatory PowerShell coverage artifact is absent for the two added `.ps1` files (tracked in the policy audit and remediation inputs).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev_tools/discovery/analyzer/stack_cli.py` | lines 10-16 | The module documents an open coordination item: #363's `cli.py` does not expose a reusable profile-load/context-build/run helper, so `_run` reimplements that flow locally. | Track the proposed extraction of a shared CLI-flow helper into #363 at integration time; no change required in this feature. | Duplication is bounded and consciously recorded; the spec's Contracts section records the same open item. Not a defect. | `stack_cli.py:10-16`; spec.md Contracts "CLI contract". |
| Info | `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` | `+=`/`-=` subscription detection | Event-subscription detection is heuristic and accepts documented residual false positives (e.g. `x += y.Count`). | None. Detections carry `metadata.confidence = "heuristic"` and the claim-scoping rule is documented normatively. | The spec explicitly scopes these as evidence, not compiler-grade claims; behavior matches the AC. | spec.md Behavior; AC row 2. |
| Info | `extensions/.../claude-customizations/.claude/hooks/*.ps1` | both files | Two `.ps1` hooks pushed into the bundle payload are byte-identical mirrors of repo originals. | None for code; ensure the mandatory PowerShell coverage artifact or an explicit packaged-output exclusion classification is recorded (see policy audit PA-1). | Byte-identity verified; no new logic. The gap is coverage evidence, not code quality. | `diff` byte-identity check; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passing. |
| Info | `extensions/.../claude-customizations/.claude/settings.json` | lines 155-165, 191-205 | Bundle registers both discovery-artifact-gate hooks on the `PreToolUse` and `SubagentStop` sides. | None. | Registration mirrors the repo `.claude/settings.json` (same two registrations). | settings.json diff; repo settings grep count 2. |

## Detailed Observations

### Python production modules

- `stack_cli.py` uses constructor/keyword dependency seams (`clock`, `fs`, `schema_path`) with sensible defaults, matching the `.claude/rules/python.md` "dependency seams without frameworks" guidance. The CLI catches only `DomainProfileError` and `AnalyzerError` at the boundary and maps them to exit code 1; argparse supplies exit code 2; success returns 0. This matches the framework exit-code contract and the AC.
- Decision-logic and multi-step blocks carry intent comments (for example the two failure-boundary comments around profile loading and `run_analyzer`), satisfying the self-explanatory-code-commenting policy.
- `source_text.py` (the comment/string stripper and id/hash helpers) is pure and reports 100% line coverage; it is the correct home for the state-machine logic and keeps I/O out of the classify stage.
- `TextParseResult` subtyping (per spec Contracts) keeps `classify` pure by carrying file text from `parse`; `classify` isinstance-narrows and raises `AnalyzerError` on a plain `ParseResult`, which is fail-fast and tested.

### Merge integration and bundle push-down

- The `pyproject.toml` `[tool.poetry.scripts]` block resolves cleanly with both new console scripts present and no duplicate keys or conflict residue.
- The two pushed-down hooks are byte-identical to the repo originals; the settings.json registration mirror matches the repo registration. The previously-failing bundle contract test now passes.

## Typed-Python Review

Python files changed on this branch were reviewed for typing. All five new modules are fully annotated and pass Pyright strict (`r2c2-pyright.2026-07-18T22-58.md`, 0 errors). No `Any` escape hatches, no `# type: ignore` suppressions. `from __future__ import annotations` is used and `TYPE_CHECKING`-guarded imports isolate typing-only symbols. Typed-Python verdict: PASS.

## Overall Code-Review Verdict

No blocking code-quality defects. The sole gating item for PR readiness is the absent mandatory PowerShell coverage artifact for the bundle hook mirrors, recorded as PA-1 in the policy audit and carried into remediation inputs.
