# Child 2 interface amendment ([P1-T5], spec D-12)

Timestamp: 2026-11-17T19-35
Command: grep -c 'agent generator imports' <child 2 spec>; grep -c 'passes them through unchanged' <child 2 spec>; git diff -U0 <BASE> -- docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/spec.md; grep -n of the headings `### Interface for epic child 3` and `## Data & State`; grep -rln 'Interface for epic child 3' tests extensions/drm-copilot/test
EXIT_CODE: 0
Output Summary: `agent generator imports` returns 0 matches. `passes them through unchanged` returns 1 match, on one line. The diff against `BASE` (the merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD`) is one hunk that replaces the single body line of the section with three lines. That hunk lies between the `### Interface for epic child 3` heading and the next heading `## Data & State`. No other section and no other child 2 file changed. No test under `tests/` or `extensions/drm-copilot/test/` names the section heading.

New section body (verbatim):

> Child 3's agent source files carry the D-16 write-scope literals verbatim.
> Child 3's PowerShell agent generator passes them through unchanged and computes none.
> Child 3 imports nothing from `write-scopes.ts`, and this child's TypeScript three-direction checker remains the sole D-16 assertion over the generated agent files. This section was amended by issue #1028 under its decision D-12.
