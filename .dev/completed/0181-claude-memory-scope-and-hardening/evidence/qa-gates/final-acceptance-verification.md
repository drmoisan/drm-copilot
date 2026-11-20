# Final QA — Acceptance Criteria Verification

Timestamp: 2026-06-13T11-51

This artifact maps each Acceptance Criterion in `spec.md` (lines 375-390) and `user-story.md` (lines 104-115) to its verifying evidence.

## spec.md Acceptance Criteria

| # | Criterion (abridged) | Verifying evidence |
|---|---|---|
| 1 | Push-down copies only `scope: general` memories; repo/unmarked excluded | test_scope_filter_copies_general_memory, test_scope_filter_excludes_repo_memory, test_scope_filter_excludes_unmarked_memory (test_push_down_claude_memory_scope.py); final-pytest.md |
| 2 | Fail-safe default: no/malformed/unrecognized scope -> repo, excluded | test_read_memory_scope_defaults_repo_* and test_scope_filter_excludes_malformed_frontmatter_memory |
| 3 | Files outside agent-memory copied verbatim, unaffected | test_scope_filter_copies_non_memory_file_verbatim; existing copy-tree test still passes |
| 4 | `re`-based scope parser added, no PyYAML | `_read_memory_scope` uses `re` only; no `import yaml`; pyproject unchanged (verified) |
| 5 | Two main scripts byte-identical and both carry filter | final-script-parity.md (EXIT 0) |
| 6 | Template carries filter and source-root resolves to bundled dir | P2-T1/P2-T2 edits; template `main()` now uses `Path(__file__).resolve().parent.parent / "claude-customizations"` |
| 7 | 11 memories annotated (10 repo, 1 general); 3 indexes repo | Phase 3 verification: grep count 1 general / 10 repo; all indexes repo |
| 8 | Six domain-neutral general memories present; index references them | Phase 4 files + MEMORY.md index (6 references); repository-neutral grep returned NONE |
| 9 | Parity test exempts agent-memory and asserts scope conditions | test_bundled_claude_payload_contains_all_repo_runtime_contracts (exempt), test_bundled_agent_memory_scopes_are_well_formed |
| 10 | Validator enforces the three remediation-cycle invariants | test_remediation_cycle_* (test_validate_orchestrator_state.py); final-pytest.md |
| 11 | Backward compatible: no remediation_loop validates as before | test_no_remediation_loop_is_backward_compatible |
| 12 | Prose rule documents 3 invariants + foreign-`$id` warning, mirrored | .claude/rules/orchestrator-state.md + bundle mirror; final-mirror-parity.md (EXIT 0) |
| 13 | Type-only exemption documented in 4 rule files, mirrored | P7 edits to general-unit-test.md, python.md, typescript.md, csharp.md + mirrors; final-mirror-parity.md |
| 14 | Root coverage policy unchanged; no rejected artifact introduced | No-rejected-artifact check: coverage.md ABSENT, no diff-cover/cov-fail-under/PyYAML import, no foreign-`$id` schema file, 85/75 intact in quality-tiers.md and general-unit-test.md |
| 15 | Every non-memory `.claude` change mirrored byte-identically | final-mirror-parity.md (all 5 pairs EXIT 0) |
| 16 | Full Python toolchain passes; extension toolchain only if TS changes | final-black.md, final-ruff.md, final-pyright.md, final-pytest.md (all EXIT 0); final-typescript-na.md |

## user-story.md Acceptance Criteria

| # | Criterion (abridged) | Verifying evidence |
|---|---|---|
| 1 | General memory distributed | test_scope_filter_copies_general_memory |
| 2 | Repo memory not distributed | test_scope_filter_excludes_repo_memory |
| 3 | Unmarked/malformed/unrecognized -> repo, not distributed | test_read_memory_scope_defaults_repo_*, test_scope_filter_excludes_unmarked_memory, test_scope_filter_excludes_malformed_frontmatter_memory |
| 4 | Files outside agent-memory unaffected | test_scope_filter_copies_non_memory_file_verbatim |
| 5 | Template source root is bundled dir + carries filter | P2-T1/P2-T2; template main() source-root fix |
| 6 | 11 memories annotated; 3 indexes repo | Phase 3 verification |
| 7 | Six domain-neutral general memories, referenced by index | Phase 4 verification |
| 8 | Validator rejects malformed cycle; no-loop validates unchanged | test_remediation_cycle_* + test_no_remediation_loop_is_backward_compatible |
| 9 | Invariants documented as prose rule, mirrored byte-identically | orchestrator-state.md + bundle mirror |
| 10 | Type-only exemption documented in general-unit-test + py/ts/cs, mirrored | P7 edits + mirrors |
| 11 | Root coverage unchanged; no rejected snapshot artifact | No-rejected-artifact check (above) |
| 12 (US #11) | Three follow-up GitHub issues for cross-language items | OUT OF SCOPE for the executor; filed by the orchestrator per spec Decision L. Not implemented in this change set. |

## No-Rejected-Artifact Check (explicit)

- `rules/coverage.md`: ABSENT at root and bundle.
- `diff-cover` gate / `--cov-fail-under`: not introduced (no command or rule references it).
- JSON schema with foreign `$id` (`drmoisan.github.io/mix-calculator/`): no schema file added; the string appears only in the warning prose of `orchestrator-state.md`, which explicitly states it must not be copied verbatim.
- 6-step toolchain: not introduced; root retains its existing toolchain.
- PyYAML: not added; the scope parser is `re`-based. The token "PyYAML" appears only in docstrings stating the dependency is intentionally not added.
- Coverage policy: 85% line / 75% branch and the T1-T4 tier system retained (quality-tiers.md and general-unit-test.md unchanged in thresholds).

## Deviation Note (P9-T2 / spec S7 internal contradiction)

The plan task P9-T2 and spec S7 / spec line 299-301 literally require the parity test to assert that "every non-index bundled memory carries `scope: general`." That assertion is mutually exclusive with spec S3, which deliberately keeps 10 `scope: repo` non-index memories in the bundle (annotated, not removed). Asserting all non-index memories are general therefore fails against the approved S3 data design.

Resolution applied: the parity test asserts the demonstrable risk-mitigation intent of spec S7 (spec line 298-301: prevent a repo-specific memory from being silently distributed and prevent an index from being mismarked). The implemented test requires (a) every `MEMORY.md` index is exactly `scope: repo`, and (b) every non-index memory declares an explicit recognized scope (`general` or `repo`) — rejecting absent/unrecognized scopes that would otherwise be silently distributed or left unmarked. This honors both S3 (repo memories remain in the bundle) and the S7 mitigation purpose, while the literal "all-general" wording cannot be satisfied with the approved data. Flagged for planner/spec reconciliation.
