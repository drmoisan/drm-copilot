# P4-T5 checked COM subset handoff

Timestamp: 2026-10-19T07-27
Command: python SCRATCH/issue-980-p4t5-com-freeze.py
EXIT_CODE: 0
Output Summary: FROZEN_READY for a scoped WIP commit; 111 focused tests passed. P4-T5 acceptance remains pending.

## Scope and baseline

Only the three source/test paths in the paired freeze manifest are owned. Accepted baseline is `957908053625c5a22099bafe5b6fd3dde2aedde2`; the shared baseline and test-split absence supplement are retained. No accepted production/test stream was changed, no predecessor suite replayed, no policy/schema/registry/checkpoint/plan/AC/Git write occurred.

## Behavior and decisions

`ComInteropAnalyzer` operates independently of dotnet selection. `com_source_candidates` and `com_project_candidates` return the existing `Detection` carrier. Source candidates distinguish attributes, type lookup, object lookup, activation candidates, lifetime calls and other known COM marshaling. All source bindings/execution remain unverified; GUID alone, ordinary activation, arbitrary marshaling and DllImport alone are insufficient. Secure project declarations retain operation, condition presence and explicit true/false/unresolved EmbedInteropTypes; values, raw conditions, GUID arguments and target paths are omitted.

Pins have an independent `source_files` count cap and `document_bytes` aggregate byte cap, including duplicate/unused pins. The bounded path index forwards each group to the accepted exact repository/revision/path/byte verifier. Selected input bytes and conservative output reservation each have separate document_bytes budgets; record capacity is reserved before candidate allocation. Exhaustion discards partial output and yields fixed diagnostics. No optional imports, external execution or I/O are introduced.

## Focused verification

Black, Ruff, scoped Pyright and 111 tests passed in one unchanged-byte ordered sequence. Pytest reported 29.70 seconds; complete command elapsed times are in the exact receipts. Module coverage is 170/170 lines and 74/74 branches, with 100% on all eight callables and the analyzer class. Tests cover redaction, anchors, encoding/pins, duplicate provenance, independent work/output limits, XML safety, inert conditions, false booleans, lookalikes, deterministic layouts and no file I/O. Earlier failed diagnostics and autoformat receipts remain preserved.

## Remaining work and deliberate compatibility limits

The inventory owner runs the one combined final seven-stage sequence after the consolidated executor review. Registry/CLI/MCP exposure and optional caller rewiring remain in their planned tasks. P4-T8 must migrate optional callers deliberately: core does not recover raw GUID arguments or preserve the old raw-line GUID search, and it rejects malformed/comment-only project fragments. Static candidate spelling is not compiler binding; aliases, preprocessing, generic invocation forms, conditions and runtime platform behavior remain unresolved. This is a checked WIP boundary, not final task/feature acceptance.

## Primary semantic references

- [MSBuild common project items](https://learn.microsoft.com/en-us/visualstudio/msbuild/common-msbuild-project-items?view=visualstudio)
- [Type.GetTypeFromProgID](https://learn.microsoft.com/en-us/dotnet/api/system.type.gettypefromprogid?view=net-9.0)
- [Activator.CreateComInstanceFrom](https://learn.microsoft.com/en-us/dotnet/api/system.activator.createcominstancefrom?view=netframework-4.8.1)
- [Marshal.FinalReleaseComObject](https://learn.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.marshal.finalreleasecomobject?view=net-9.0)
