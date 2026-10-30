# P4-T3 consolidated independent candidate review

Timestamp: 2026-10-19T05-00
Command: Review the frozen thirteen-path candidate; run the bounded reproduction and retained-proof binding harnesses linked below.
EXIT_CODE: 0
Output Summary: CANDIDATE_REVISIONS_REQUIRED. The single consolidated review found three blocking declaration-scanner defects. Review execution succeeded; P4-T3 remains unchecked.

The exact candidate is `p4t3-candidate-freeze.2026-10-19T04-46.json`, SHA-256 `a078045ecbba053eb113419bd50d9e14767a616c4f8f90626c31993bb1daff32`. The paired JSON contains all thirteen working/index hashes, native routing/profile binding, exact source anchors, proof references and the complete finding set. Accepted baseline is `6a94e5789e8622d4f1aaa2f3aa2c45e1a9c92f89`; checked WIP is `ec2745639ee52f1f3cd683d82d61e9535d3e79ec`.

## Complete findings

1. **P4-T3-R1 — contextual `record` is misclassified as a declaration.** `foreach (var record in items)` produces a type named `in` (`csharp_declarations.py:329`, helper at 121–140). The projection marks it detected syntax and high confidence for pinned input (`dotnet_inventory.py:245`). Require a defensible declaration context/name and preserve legitimate record forms. Add the retained regression and a projection assertion.
2. **P4-T3-R2 — an anonymous delegate creates a named delegate finding.** `System.Action a = delegate { Work(); };` produces a delegate named `Work` (`csharp_declarations.py:174–195`). Named-delegate scanning crosses into the anonymous body. Exclude both anonymous forms before that scan, preserve named/generic delegates and function-pointer exclusions, and add the retained regression and projection assertion.
3. **P4-T3-R3 — declaration rescans have no aggregate work limit.** `_generic` (line 66) and `_event_or_delegate` (line 182) repeatedly scan suffixes from the outer declaration loop (line 323). For repetitions 64/128/256, bounded instrumentation measured 8,832/34,048/133,632 generic token-index accesses and 4,671/17,535/67,839 event-prefix accesses, with no limit failure. Add an aggregate deterministic bound or equivalent one-pass spans covering these rescans, return `source-work-limit` without partial claims, and use small deterministic regressions. No large stress test or compiler dependency is required.

The two valid C# examples and six small work-growth cases are recorded in [the probe result](p4t3-executor-candidate-probes.2026-10-19T04-51.json). The probe instrument counts accesses to the same token tuple; it does not modify production bytes. Static inspection establishes the v2 detected/high projection consequence; no separate public projection run is claimed.

## Retained evidence and reviewed boundaries

[The binding reconciliation](p4t3-executor-review-bindings.2026-10-19T04-57.json) passed for all thirteen candidate files, 38 accepted predecessor paths, twelve preserved caller/fixture paths, nine exact AST comparisons, twelve focused format/lint/type/test receipts, six public helper/carrier contracts and five original test definitions. Existing test results are reused: tokenizer 58, masking 108, scanners 111 and dependent callers 83. No broad suite or final ordered gate was rerun.

Measured coverage is tokenizer 97/98 lines and 47/48 branches; masking plus adapter 153/153 and 50/50; declaration/event/projection modules 345/345 and 158/158. All 53 measured class/callable ranges meet 90%. The sole uncovered tokenizer guard is the defensive 64 MiB direct-text size check. Documentation/comment changes have exact executable-AST qualifications; these retained results do not establish the missing R1–R3 behaviors.

The review covered raw/interpolated/verbatim masking, Unicode and physical line endings, bounded decode/token/output paths, literal/inferred separation, original-byte provenance, legacy carrier identity, publication boundaries, neutral core content, intent documentation, file size and test isolation. No additional blocking finding was established in those areas. All source/test files are at most 470 lines. The existing `mem_fs_path` fixture is in-memory.

Working bytes and Git bytes are separate evidence. The legacy source helper adapter has an exact CRLF-to-LF mapping under actual `text=auto,eol=lf`; new/untracked or substantive unstaged paths are not described as index-equal. The historical masking normalization receipt is under `evidence/regression-testing/`, with 22 exact and 21 normalized paths. Prior failed worker diagnostics and their original hashes remain retained.

## Handoff

This immutable receipt closes the single consolidated candidate review. Parent authorization is required for the scoped repair transition; no production/tests, checkpoint, plan, ACs, staging or commit were changed by this review. After one repair, confirm the R1–R3 reproductions and changed-file bindings while retaining this review for unchanged paths. Full task acceptance waits for the final ordered gates.

Status: 34/84 tasks and 13/66 ACs remain accepted. Current phase: P4-T3 candidate review. Upcoming task order: P4-T3, P4-T4, P4-T5, P4-T6, P4-T7.

The binding-harness snapshot uses the portable token `SCRATCH/worker` for its one host-root literal. Its exact executed original remains preserved under verifier SCRATCH with a separate checksum in the paired review JSON; the portable snapshot is not represented as raw-byte identical.
