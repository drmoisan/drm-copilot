# AC-7 production source diff (#647)

Timestamp: 2026-10-01T23-18
Command: git diff --name-only 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot/src ; git status --porcelain -- extensions/drm-copilot/src ; git diff -U0 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot/src
EXIT_CODE: 0

Name list:
- extensions/drm-copilot/src/lib/codex-native-converter/index.ts
- extensions/drm-copilot/src/lib/codex-native-converter/models.ts

Porcelain under src: (empty; no `??` path)

-U0 content lines (removed -> added):
- index.ts: `PlannedEmission,` -> `type PlannedEmission,`; `SectionIntent,` -> `type SectionIntent,`; `SemanticCue,` -> `type SemanticCue,`; `TranslationTrace,` -> `type TranslationTrace,`
- models.ts: `PlannedEmission,` -> `type PlannedEmission,`; `SectionIntent,` -> `type SectionIntent,`; `SemanticCue,` -> `type SemanticCue,`; `SourceSection,` -> `type SourceSection,`; `TranslationTrace,` -> `type TranslationTrace,`

Output Summary: exactly the two named files; 9 removed and 9 added content lines; every added line matches `^\+\s+type [A-Za-z]+,$`; deleting `type ` from each added line yields the corresponding removed line. No runtime behavior change.
