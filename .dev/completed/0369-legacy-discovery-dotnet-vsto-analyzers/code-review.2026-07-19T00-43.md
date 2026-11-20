# Code Review — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-19T00-43
- Reviewer: feature-review agent
- Base branch: `epic/legacy-discovery-and-parity-integration`
- Diff range: `01fb34a8468090db01db471bb339a0dd6391a9d7..937cfeb7fa9ea362454fa2d4834bed6f4416ca21`
- Nature: re-review of the full branch diff after remediation cycle 4. Cycle 4 added a two-line `core.json` pack-manifest registration and documentation/evidence only; no Python or PowerShell source changed relative to the prior review. Code was re-inspected first-hand at head `937cfeb7`.

## Executive Summary

The branch delivers two stack-specific legacy-discovery analyzers in Python (`DotnetInventoryAnalyzer` in `dotnet_inventory.py`, `VstoOfficeAnalyzer` in `vsto_office.py`), a shared pure text-scanning helper (`source_text.py`), a data-only pattern table (`vsto_patterns.py`), and a shared CLI (`stack_cli.py`) exposing two Poetry console scripts (`dev.discovery.dotnet`, `dev.discovery.vsto`). Earlier remediation cycles added a two-parent merge of the integration branch (resolving a `pyproject.toml` `[tool.poetry.scripts]` conflict), a push-down of two `.claude` hook files plus a `settings.json` registration mirror into the bundled extension payload, and PowerShell coverage evidence. Cycle 4 registered the two pushed-down hooks in the core pack manifest.

Code quality of the Python production modules is high and aligned with repository standards: full type annotations (Pyright clean), Google-style docstrings on classes and functions, dependency seams for the filesystem, clock, and schema path, narrow exception handling confined to the CLI boundary, deterministic ordering (POSIX-sorted candidates, pure hash-based ids), and standard-library-only implementation. Pure detection logic (`classify`) is cleanly separated from I/O (`parse`, and byte reads in `map`), which are isolated behind the injected filesystem seam. All five new production modules are under the 500-line limit and carry per-file line coverage at or above 94% (branch at or above 90% where branches exist).

The bundle push-down files are byte-identical mirrors of pre-existing, Pester-tested repo hooks; their fidelity is enforced by a passing pytest byte-identity contract test, and cycle 4 completed the packaging contract by registering both in `core.json` so the extension `claude-pack-manifest-completeness` suite passes. No consumer identifiers appear in production modules; the Office interop application name is captured as data and never branched on. There are no blocking code-quality defects. The cycle-4 manifest change is a data-only edit (two alphabetically-ordered `paths` entries) with no logic and no risk surface.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `extensions/.../pack-manifests/core.json` | `paths` array | Cycle-4 change registers the two bundled discovery hooks (`enforce-discovery-artifact-gate.ps1`, `validate-discovery-artifact-gate.ps1`) at their alphabetically-correct positions. | None. | Data-only edit; closes the cycle-2 push-down so both the Python bundle contract test and the extension manifest-completeness test pass. Follows the established issue #367 precedent. | `core.json` diff; `r4c4-manifest-edit-verification.2026-07-19T00-23.md`; `r4c4-pass-after-manifest-completeness.2026-07-19T00-23.md`. |
| Info | `scripts/dev_tools/discovery/analyzer/stack_cli.py` | lines 10-16 (module docstring) | Documents an open coordination item: #363's `cli.py` does not expose a reusable profile-load/context-build/run helper, so `_run` reimplements that flow locally. | Track the proposed extraction of a shared CLI-flow helper into #363 at integration time; no change required in this feature. | Duplication is bounded and consciously recorded; the spec Contracts section records the same open item. Not a defect. | `stack_cli.py:10-16`; `coordination/text-parse-result-reconciliation.md`. |
| Info | `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` | `_is_probable_handler` / `_detect_subscriptions` | Event-subscription detection is heuristic and accepts documented residual false positives (for example `x += y.Count`). | None. Detections carry `metadata.confidence = "heuristic"`; the literal-rejection filter is implemented and tested. | The spec explicitly scopes these as textual evidence, not compiler-grade claims; behavior matches AC. | `dotnet_inventory.py` subscription logic; spec Behavior; AC row 2. |
| Info | `scripts/dev_tools/discovery/analyzer/source_text.py` | `strip_comments_and_strings`, module docstring | Raw string literals (`"""`) and deeply nested interpolation are handled best-effort only. | None. The limitation is stated normatively and is consistent with the regex/plain-text specification decision. | Length- and line-preserving stripping is correct for the common C# forms; residual cases are documented, not silent. | `source_text.py` heuristic-scope docstring; spec Specification Decision. |
| Info | `extensions/.../claude-customizations/.claude/hooks/*.ps1` | both files | Two `.ps1` hooks pushed into the bundle payload are byte-identical mirrors of repo originals. | None. | Byte-identity re-verified in the working tree at head `937cfeb7`; no new logic introduced by the mirror. | `diff` byte-identity check; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passing. |
| Info | `extensions/.../claude-customizations/.claude/settings.json` | PreToolUse and SubagentStop blocks | Bundle registers both discovery-artifact-gate hooks on the `PreToolUse` (enforce) and `SubagentStop` (validate) sides. | None. | Registration mirrors the repo `.claude/settings.json` (same two registrations). | settings.json diff; valid-JSON re-check at head. |

## Detailed Observations

### Cycle-4 change (pack-manifest registration)

- `core.json` gains exactly two `paths` entries, inserted at the alphabetically-correct positions within the `.claude/hooks/` subgroup; no existing entry reordered and no other key changed. The file remains well-formed JSON (re-verified at head). The edit is the convergent completion of the cycle-2 bundle push-down: it satisfies the extension `claude-pack-manifest-completeness` invariant (every bundled `.claude` file must appear in some pack manifest) while the pre-existing Python bundle contract test already required the hooks to be mirrored into the bundle. Both gates now pass.

### Python production modules

- `stack_cli.py` uses constructor/keyword dependency seams (`clock`, `fs`, `schema_path`) with sensible defaults. The CLI catches only `DomainProfileError` and `AnalyzerError` at the boundary and maps them to exit code 1; argparse supplies exit code 2; success returns 0. This matches the framework exit-code contract and the AC. `load_domain_profile` is imported at module scope so tests can patch it at this boundary.
- `source_text.py` (the comment/string stripper, id/hash helpers, and the shared `Detection`/`TextParseResult`/`DetectionResult` value objects) is pure and reports 100% line coverage. The stripper performs a single left-to-right scan preserving character length and newlines, so 1-based line/column offsets survive stripping.
- Both analyzers implement the #363 `Analyzer` protocol structurally (no base class, no registry). `parse` is the only walk/read stage; `classify` is pure; `map` reads file bytes for the integrity hash via the seam with a per-path hash cache. Both `classify` and `map` isinstance-narrow to `TextParseResult`/`DetectionResult` and raise `AnalyzerError` on the plain base type — fail-fast and tested.
- `vsto_office.py` captures the Office interop application name into `metadata.interop_target` as data and never branches on it, preserving consumer-neutrality while remaining Office-stack-aware. GUID values are captured from the unstripped original line only after the stripped line confirms a real `[Guid(...)]` attribute.
- `vsto_patterns.py` is data-only (compiled regexes, the customUI URI table, static descriptions), extracted to keep `vsto_office.py` under the 500-line limit. All literals are generic .NET/VSTO/Office subject matter.

### Merge integration and bundle push-down

- The `pyproject.toml` `[tool.poetry.scripts]` block resolves cleanly with both new console scripts present and no duplicate keys or conflict residue.
- The two pushed-down hooks are byte-identical to the repo originals at head `937cfeb7`; the `settings.json` registration mirror matches the repo registration; the `core.json` registration completes the packaging contract. The bundle contract test passes.

## Typed-Python Review

Python files changed on this branch were reviewed for typing. All five new modules are fully annotated and pass Pyright (`r4c4-pyright.2026-07-19T00-23.md`, 0 errors). No `Any` escape hatches and no `# type: ignore` suppressions appear (grep count 0 in each production module). `from __future__ import annotations` is used throughout and `TYPE_CHECKING`-guarded imports isolate typing-only symbols (`AnalyzerContext`, `Path`, protocol types). Forward references are valid under deferred annotation evaluation. Typed-Python verdict: PASS.

## Overall Code-Review Verdict

No blocking code-quality defects. The cycle-4 manifest registration is a data-only edit that resolves the CI manifest-completeness failure with no logic surface. All prior gating items (absent PowerShell coverage artifact in cycle 3; unregistered bundle hooks in cycle 4) are resolved. Recommendation: proceed. All findings are Informational.
