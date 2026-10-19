# P4-T7 frozen format review

Timestamp: 2026-10-19T10-23
Published UTC: 2026-10-19T10:23:22.726403+00:00
Command: `poetry run python SCRATCH/issue-980-p4t7-format-review.py`
EXIT_CODE: 0

Output Summary: SCOPED_FORMAT_REPAIR_REQUIRED. The four frozen Python/.NET source and test streams, eight successful focused gate receipts and both raw coverage reports match their retained hashes. No behavioral probe remains open.

- P4T7-FR1: Replace the default setup.cfg option matcher with deterministically bounded parsing for valid and invalid whitespace-heavy option lines. The six retained observations demonstrate approximately quadratic matching work; timing is diagnostic only.
- P4T7-FR2: Exclude opaque ProjectExtensions content from declaration extraction. The probe incorrectly reports OpaqueData alongside a genuine PackageReference. Microsoft documents this element as non-MSBuild information ignored by MSBuild. [MSBuild ProjectExtensions](https://learn.microsoft.com/en-us/visualstudio/msbuild/projectextensions-element-msbuild?view=visualstudio)
- P4T7-FR3: Complete typed helper/test contracts and immediate intent comments in the Python pair, retaining all assertions and parametrizations.

Reused proof: Python 98 cases, 154/154 statements, 86/86 branches and seven named callables; .NET 63 cases, 126/126 statements, 66/66 branches and nine named callables. No suite was replayed. The probe used original shared bytes from 1dd38613; the active shared repair was not loaded.

The separate shared finding set remains pending its owner repair. Node, integration, composed proof and final task acceptance remain pending. The separate .NET raw/rendered newline qualification retains its designated owner. No plan or acceptance-criteria checkbox changed.

Exact source, receipt, coverage, probe and raw harness bindings: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t7-executor-format-review.2026-10-19T10-23.json`.
