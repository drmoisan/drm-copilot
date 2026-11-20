# Code Review: csharp-legacy-gate-command-correctness (Issue #469)

- **Branch:** `bug/csharp-legacy-gate-command-correctness-469` @ `d342c6c77e85b052a489bb7dbc881f6dca9dbe92`
- **Base:** `main` @ merge base `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- **Review Date:** 2026-08-13
- **Scope:** Full branch diff (40 files): 4 canonical `csharp-legacy` Markdown variant sources, `README.md`, 4 Python test files, feature-folder documents and evidence, 2 potential-feature documents.

## Executive Summary

This is a content-correction bugfix with test hardening. The production-side change is byte-level Markdown only: the four `csharp-legacy` variant sources and the `README.md` legacy section now document a CSharpier invocation that actually executes (`format`/`check` subcommands through the manifest-pinned `dotnet tool run`), local MSBuild gates that cannot be skipped by incrementality (`/t:Rebuild /m`), a shell-portable platform token, and a nullable gate matching the consumer's per-file opt-in model. The test-side change adds five real-bytes content-contract tests and two repeated-generation determinism tests, plus a behavior-preserving compaction of the Codex customization test file to stay under the 500-line limit.

Quality is high. The forbidden-literal choices show careful collision analysis (`csharpier .` vs `csharpier check .`; `sln /t:Build` vs the intentionally retained `/t:Build` explanation prose), and the span-scoped nullable predicate is a precise regression guard that permits greppable prohibition prose while forbidding the property on any command line. The reviewer independently verified discrimination with two mutant probes (a reintroduced `sln /t:Build` and an injected `/p:Nullable=enable` command span); both were caught by the new exclude tests with actionable failure messages, and both files were restored cleanly. The full Python toolchain passes in one clean pass under reviewer re-execution.

No Blocking findings. Three Advisory/Informational findings are recorded below; none requires a remediation plan.

Typed-Python review (required because Python files changed): all new constants, helpers, and tests carry complete type annotations (`tuple[Path, ...]`, `tuple[str, str]`, `list[str]`, `dict[str, str]`); Pyright exits 0; no `Any`, no `# type: ignore`, no `# noqa` anywhere in the diff; docstrings and intent comments comply with `.claude/rules/self-explanatory-code-commenting.md`.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Advisory | docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/issue-updates/issue-469.2026-08-13T17-28.md | whole file | Working tree carries an uncommitted orchestrator edit replacing `PostedAs: unknown` with the posted comment URL (issue #469 comment 5286830741); HEAD `d342c6c7` still records the pre-posting text | Commit this file to the branch before PR authoring | The branch's evidence trail should match the posted GitHub state; an unstaged edit is silently lost if the worktree is discarded | `git status --porcelain` shows ` M .../issue-469.2026-08-13T17-28.md`; `git diff` shows the PostedAs replacement |
| Advisory | artifacts/pr_context.summary.txt | Close candidates section | The author-asserted autoclose list contains the malformed token `#ISO-8601`, an artifact of the context generator matching a `#` reference inside prose; if propagated verbatim into a PR body it would produce a bogus closing reference | When authoring the PR, list only `#469` as the closing reference; optionally file a follow-up against the pr-context reference extractor | Preventing a malformed `Closes #ISO-8601` line in the PR body; the branch content itself is not at fault | `artifacts/pr_context.summary.txt` lines under "Auto-close issues (author asserted)" |
| Informational | tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py, tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py | `_spans_with_both_literals`, constant blocks | The span-predicate helper, the regex constant, and the required/forbidden substring tuples are duplicated verbatim across the two contract files rather than shared | Accept as-is; if a third surface is ever added, extract a shared helper module under `tests/` | The two files are independent surface contracts and the repo pattern keeps contract files self-contained; duplication of 7+3 literals is a deliberate readability trade recorded in the spec's per-file test strategy | Diff hunks for both files show identical `LEGACY_REQUIRED_SUBSTRINGS`, `LEGACY_FORBIDDEN_SUBSTRINGS`, `NULLABLE_SPAN_SCOPE_LITERALS`, `INLINE_CODE_SPAN_PATTERN`, and `_spans_with_both_literals` |
| Informational | tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py | test_push_down_codex_repeated_generation_is_deterministic | The Codex determinism test uses `packs=frozenset({"core", "csharp"})` with `csharp_variant="legacy"` where the spec's Regression-tests bullet literally says `csharp-legacy`; the deviation is correct (the Codex engine raises `ManifestError` for variant-specific pack names) and is documented in the test docstring and Plan Note 2 | None required | The implementation matches engine behavior; the plan of record (revision 2, Note 2) records the verified rationale with the exact source lines (`push_down_codex_pack_selection.py` lines 85-90) | Test docstring: "The engine rejects variant-specific pack names, so the public `csharp` spelling is paired with the `legacy` variant selector"; plan Note 2 |

## Detailed Review Notes

### Production content (Markdown resource payloads)

- All four variant files were verified byte-level by the reviewer: all seven required substrings present, all three file-scoped forbidden literals absent, zero fenced code blocks (so inline spans are the complete command surface), and no inline span carrying both `msbuild` and `/p:Nullable=enable`.
- The Claude `rules/csharp.md` line-83 edit site (the severity-first ordering invariant's cited fragment) was corrected as specified; the surrounding warning-to-error rationale remains coherent because `/p:TreatWarningsAsErrors=true` is retained.
- Structure preservation (AC8): the four-step numbering, gate ordering sentence, restart-from-formatting rule, "If the environment prevents..." paragraph, and Delta Requirements sections are unchanged in every file, verified in the diff hunks.
- Placeholder conventions preserved: `<solution>.sln` on the Claude surface and `README.md`; `TaskMaster.sln` on the Codex surface. No cross-surface normalization occurred.
- `README.md` legacy section: corrected commands present; no stale form (`csharpier .`, `sln /t:Build`, `/p:Platform="Any CPU"`, `/p:Nullable=enable`) appears anywhere in the section; the test line and surrounding prose are untouched.

### Tests

- Discrimination is proven, not asserted: executor fail-before evidence records 4 failed / 0 passed against pre-fix content, and the reviewer's two post-fix mutant probes each produced a targeted failure naming the file and literal/span. The modern-profile pin passed before the fix (executor baseline evidence), confirming it is a baseline pin rather than a fix artifact.
- The compaction of `test_selected_legacy_csharp_writes_variant_content_to_canonical_paths` is behavior-preserving: the same seeded paths, same manifest writes, same exit-code assertion, same canonical-destination assertions, and same variant-path-absence assertions, restructured through `_seed_legacy_variant_tree` and loops. File went from 497 to 495 lines including the new determinism test.
- Determinism tests correctly exclude timestamped push-down artifacts from the comparison by pointing `artifact_root` outside both destination roots, and they guard against a vacuous pass with `assert first_map` (non-empty) before the equality assertion.
- No temporary files, no wall-clock reads, no randomness, no network in any new test.

### Toolchain and typing

- Reviewer re-ran: `poetry run black --check .` (exit 0), `poetry run ruff check .` (exit 0), `poetry run pyright` (exit 0), `poetry run pytest --cov --cov-branch --cov-report=term` (exit 0; 3781 passed, 5 pre-existing skips; 92.30% line / 84.66% branch, identical to baseline).
- No suppressions of any kind were added; `.claude/rules/python-suppressions.md` is not engaged.

### Tonality

- All changed documentation (variant sources, README, feature docs, potential entries) uses neutral, factual, imperative language consistent with `.claude/rules/tonality.md`. No humor, hyperbole, or decorative metaphor was found in the diff.

## Verdict

No Blocking or Major findings. The change is ready for PR authoring once the uncommitted evidence-file update is committed (Advisory finding 1).
