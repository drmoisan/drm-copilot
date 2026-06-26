# F10 Property-Test Tooling Note

Timestamp: 2026-06-26T11-29

SearchScope: extensions/drm-copilot/package.json (devDependencies, dependencies, overrides)
SearchPatterns: fast-check
SearchResult: none — `fast-check` is not a dependency of the `extensions/drm-copilot` package.

Decision (per plan P2-T5): adding a new dev dependency is out of scope and the
TypeScript rule prohibits adding dependencies without explicit approval. The T1
classifier invariant coverage is therefore provided by Jest `it.each`
table-driven exhaustive cases over the github-copilot and claude classification
matrices in `test/lib/codex-native-converter/classifier.test.ts`, plus an
explicit determinism assertion (identical inputs yield identical classification)
and a one-mapping-per-path assertion (every discovered path yields exactly one
MappingRecord with a defined SourceKind). This satisfies the
property/exhaustive-invariant requirement of `.claude/rules/quality-tiers.md`
for T1 classifier modules without introducing `fast-check`.
