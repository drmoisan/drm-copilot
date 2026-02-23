# 2026-02-22-create-active-folder-bug (User Story)

- **Issue:** #43
- **Owner:** drmoisan
- **Status:** Draft
- **Work Mode:** full

## Story
As a maintainer running active-folder creation, I want deterministic promoted-file resolution and persisted full-mode marker behavior so that bug folder bootstrap is reliable and reproducible.

## Acceptance Signals
- Active-file auto-resolve can derive feature name from canonical promoted markdown path.
- Invalid auto-resolve input yields deterministic guidance.
- Explicit full mode persists exactly one `- Work Mode: full` marker.
