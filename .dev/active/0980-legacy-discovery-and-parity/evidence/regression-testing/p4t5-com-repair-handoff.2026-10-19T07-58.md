# P4-T5 isolated COM R1/R3 repair handoff

Timestamp: 2026-10-19T07-58
Command: poetry run python SCRATCH/issue-980-p4t5-com-repair-freeze.py
EXIT_CODE: 0
Output Summary: FROZEN_READY for bounded confirmation: 137 tests passed; 206/206 lines and 88/88 branches covered across both production modules.

## Repair and preserved behavior

The approved `com_syntax.py` module owns pure C# candidates. `com_interop.com_source_candidates` explicitly re-exports the identical callable, with original signature/defaults and shared `Detection` identity. All other original production definitions are AST-identical after relocation. XML, provenance, redaction and aggregate budgets remain unchanged. Every original test definition/decorator/assertion is AST-identical; 111 cases remain and 26 direct/adapter regression/control cases were added. R3 supplies immediate intent comments for each metadata extraction assertion without changing it.

R1 pairs delimiters once, propagates bracket declaration continuations right-to-left, and checks a known call's closing parenthesis continuation in constant work. Argument collection expressions and explicit method declarations no longer create attribute/call findings. Genuine declaration, parameter, assembly/module and lambda attributes, attribute chains and calls nested in declaration bodies remain detected as inferred syntax. Incomplete bracket-only fragments are conservatively omitted. No compiler binding or runtime execution is claimed. These cases follow the distinction between [collection expressions](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/collection-expressions) and [explicit interface member declarations](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/language-specification/interfaces).

## Evidence and scope

The freeze manifest binds four source/test paths, ordered focused Black/Ruff/Pyright/Pytest receipts, exact raw coverage, per-module/class/callable totals, structure checks, the preserved 45-path baseline and exact executed harness snapshots. All named ranges are 100% covered. The original review/probes, 111-case proof and freeze manifests remain unchanged. The failed first repair lint attempt is preserved; the final clean sequence uses unchanged source bytes. Pytest reported 33.39 seconds; whole-command elapsed times are retained separately. Coverage's local timestamp is not reinterpreted as UTC; command receipts provide UTC execution times.

## Remaining gates

Await the executor's bounded R1/R3 confirmation and the inventory owner's one combined final ordered sequence. No predecessor suite was replayed, no optional caller/registry/CLI/MCP exposure was added, and no plan, AC, checkpoint or Git state was edited by this worker. No task/feature acceptance is claimed. Existing lexical limitations on alias resolution, preprocessing, generic forms, compiler validity and runtime behavior remain explicit.
