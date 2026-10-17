# Code Review: blast-radius path extractor misses real plan writes (Issue #797)

- Timestamp: 2026-10-09T07-51
- Branch: `bug/blast-radius-path-extractor-misses-real-plan-writes-797`
- Range reviewed: `e7d3779b..9608477a` (full branch diff against the `origin/main` merge base)
- Reviewer inputs: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (regenerated at head `9608477a`), the production and test diffs, the feature evidence tree, and CI run 37900002916.

## Executive Summary

The change is small, well-scoped, and consistent across the two runtimes. The allowlist test is replaced by a pure predicate in each leaf module, and both consult sites in each classifier call the predicate. The surrounding classification order (root surface, placeholder marker, separator, colon, line-suffix strip, wildcard, feature-folder span) is unchanged. Directory-shaped rejection (#489) is preserved through the structural rule: a component with no dot, a dot-leading component outside the known-name set, a digit-led tail, and a trailing dot all fail.

The Python and PowerShell predicates are semantically equivalent on every input class I traced: `rpartition` with an empty-stem check corresponds to `LastIndexOf('.') -le 0`; `re.fullmatch` corresponds to `\A...\z`; frozenset membership corresponds to an ordinal `HashSet[string]`. Cross-runtime equivalence is pinned three ways: a Pester test that reads the Python constants from source, a shared fixture exercised by both parity suites, and mirrored predicate case tables. All of these pass in CI.

No blocking findings. Four non-blocking findings (one Low on residual cross-runtime casing behavior, one Low on documentation list formatting, two Informational).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (non-blocking) | `scripts/dev_tools/_blast_radius_token_shapes.py`; `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | `is_file_shaped_component` final line; `Test-FileShapedComponent` `ToLowerInvariant()` line | CR-1. The predicate lower-cases the extension before matching an ASCII-only pattern. Python `str.lower()` and .NET `ToLowerInvariant()` use different case-mapping rules for a few non-ASCII code points (for example U+0130, which Python maps to two code points), so a non-ASCII tail could in principle be accepted by one runtime and rejected by the other. The plan's Risks section records this as an untested residual. Whether any real divergence exists on the CI runtimes was not determined in this review. | Remove the casing dependency: match `[A-Za-z][A-Za-z0-9]*` against the raw extension in both runtimes (or check that the extension is ASCII before lower-casing). Update the parity pin text accordingly. | Python is the declared authority and parity is a spec invariant. Removing the lower-casing step makes parity hold by construction instead of relying on two Unicode casing tables agreeing. Practical exposure is very low, because plan tokens with non-ASCII extensions are rare. | `_blast_radius_token_shapes.py:218`; `BlastRadiusTokenShape.psm1` `$extension = $Component.Substring($dotIndex + 1).ToLowerInvariant()`; plan "Risks and Notes" bullet 1 |
| Low (non-blocking) | `.claude/rules/parallel-orchestration.md` (and bundled mirror) | "Known false negatives", items 6-7 (around line 559-567) | CR-2. Item 7 is appended to a list introduced as "Write-intent extraction can drop a genuine write in these cases", but the separator-free bare-name drop happens in the classifier, before write-intent extraction. Item 6 still ends with a period although it is no longer the last item, and item 7 embeds its own mitigation, while the following "Three mitigations bound these cases" text does not mention it. | In a later documentation pass, either broaden the lead-in to "Extraction can drop a genuine write in these cases", or move item 7 to a separate sentence. Change item 6's terminal period to a semicolon. Keep the mirror byte-identical. | Readers use this list to understand which pipeline stage dropped a path. The present wording attributes item 7 to the wrong stage. The AC-12 literal requirement is still met. | `git diff e7d3779b..9608477a -- .claude/rules/parallel-orchestration.md` |
| Informational | `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` | `Parity with the Python reference` Context | CR-3. The parity pins extract `KNOWN_FILE_NAMES` and `FILE_EXTENSION_PATTERN_TEXT` from the Python source with regular expressions that depend on the current literal shape (`frozenset((...).split())`, double-quoted pattern). A reformat or refactor of the Python constant (for example a tuple of strings) would make the extraction yield zero names. | No change required. The `Count | Should -Be 18` and `Should -Not -BeNullOrEmpty` assertions make that failure explicit rather than producing a false pass. If the constant shape changes, update the extractor regex in the same change. | The pin follows the established pattern at `BlastRadiusWriteIntent.Tests.ps1:239-252`. It fails safely, not silently. | CI artifact `poshqc-test-results`: 2 `Python source` cases, 0 failed |
| Informational | `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` | `test_known_file_names_are_the_adopted_set`, `test_file_extension_pattern_text_uses_explicit_ascii_classes` | CR-4. These two constant-pin tests use bare `assert` without a failure message, unlike the other added tests. | Optional: add messages naming the expected and observed values. | pytest assertion introspection already prints both operands for `==` comparisons, so the failure output is actionable as-is. | file lines 193-213 |

## Correctness Review Notes

- Python/PowerShell predicate equivalence (traced):
  - `""`: both return false (not in the set; no separator or `dotIndex = -1`).
  - `"."`: both return false (empty stem; `dotIndex = 0`).
  - `"beta."`: empty extension fails `fullmatch` / `IsMatch` on `\A[a-z][a-z0-9]*\z`.
  - `".claude"`: leading dot gives an empty stem / `dotIndex = 0`, so both return false. `.shellcheckrc` is accepted only through the known-name set.
  - `"jest.config.cjs"`: the last dot is used in both runtimes, so the extension is `cjs`.
  - `"a/b.bats:12"`: the `:<digits>` suffix is stripped before the predicate in both classifiers (unchanged `LINE_SUFFIX_RE` / `$script:LineSuffixPattern`).
- The wildcard branch now uses the same predicate. `tests/fixtures/Sample.*` remains `glob` through the known top-level segment, and bare `Sample.*` remains rejected by the separator rule, which matches spec A1.
- Accepted over-acceptance residuals (`src/TaskMaster.Domain`, `owner/repo.git`, `example.com/page.html`, dotted ref tails) err toward extra contention edges, which is the documented fail-closed direction, and they are pinned by tests in both runtimes.
- Removal of `RECOGNIZED_PATH_EXTENSIONS`: a repository search in this review found no remaining reference in `scripts`, `.claude`, `extensions`, or `tests`.
- Re-export: `BlastRadiusExtraction.psm1` adds `Test-FileShapedComponent` to its `Export-ModuleMember` list, consistent with the existing re-export of `Test-PlaceholderMarker` and `Test-MultipleFeatureFolderSpan`. A test pins the export surface.
- Historical re-pin: the only moved value is edge 588-622 `cost` 152 -> 160 in `backlog-2026-09-26.json`, which equals one same-file weight of 8 for `extensions/drm-copilot/jest.config.cjs` now surviving normalization. Both runtimes agree (`evidence/regression-testing/historical-repin.2026-10-09T03-55.md`; CI HistoricalRuns 9/9 passed).
- Comments and docstrings that referred to the allowlist were updated at every site the spec names (Python `:74`, `:90-91`, `:258-262`, `:309-312`; PowerShell help and inline comments).

## Best-Practice Assessment

| Area | Assessment |
|---|---|
| Separation of concerns | New logic lives in the leaf token-shape modules (no import cycle risk), and the classifiers only call it. This also keeps `_blast_radius_extraction.py` (468) and `BlastRadiusExtraction.psm1` (464) under the 500-line limit. |
| Readability | Docstrings and comment-based help explain the rule, the rejected shapes, and the issue linkage; inline comments state why, not what. |
| Totality / robustness | Both predicates are total; `[AllowEmptyString()]` on the PowerShell parameter preserves the empty-string contract. |
| Test design | Data-driven positive, negative, boundary, and residual cases are mirrored in both runtimes. Fail-before was demonstrated with the exact failing names, and pass-after is confirmed in CI. |
| Fixture design | The shared fixture uses realistic stems to avoid the W6 placeholder-stem filter (spec A8). It also includes a dot-directory and a bare directory in the same plan as negative controls. |

## Verdict

Approve. Blocking findings: 0. Non-blocking: CR-1 (Low), CR-2 (Low), CR-3 (Informational), CR-4 (Informational).
