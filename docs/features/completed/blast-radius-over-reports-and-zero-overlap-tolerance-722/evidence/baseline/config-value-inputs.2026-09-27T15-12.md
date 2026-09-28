# path_roots and append_only_paths Inputs (P0-T28)

Timestamp: 2026-09-27T15-12
Command: git ls-tree -d --name-only HEAD ; git ls-files -- "*CHANGELOG.md" ; git ls-files --error-unmatch -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
EXIT_CODE: 0
Output Summary: All three commands exited 0. The tracked top-level directory list has 17 entries (ordinally sorted below); it becomes the self-hosted path_roots value in P9-T3. One changelog is tracked (extensions/drm-copilot/CHANGELOG.md). The pack manifest registry is tracked. Decision: append_only_paths is exactly the two entries of plan block B2.

## Tracked top-level directories (ordinally sorted; git ls-tree -d --name-only HEAD)

```text
.agents
.cache
.claude
.codex
.devcontainer
.github
.vscode
config
docs
examples
extensions
packages
schemas
scripts
src
tests
virtual
```

The git ls-tree output is already in byte (ordinal) order; the list above is that output unchanged.

As a JSON list (self-hosted path_roots value for P9-T3):

```json
[".agents", ".cache", ".claude", ".codex", ".devcontainer", ".github", ".vscode", "config", "docs", "examples", "extensions", "packages", "schemas", "scripts", "src", "tests", "virtual"]
```

## Tracked changelog paths (git ls-files -- "*CHANGELOG.md")

```text
extensions/drm-copilot/CHANGELOG.md
```

## Pack manifest registry tracked (git ls-files --error-unmatch)

```text
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
```

Exit 0, so the file is tracked.

## Decision: append_only_paths

append_only_paths is exactly the two entries of plan block B2:

```json
[
  "**/CHANGELOG.md",
  "extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json"
]
```

The list is not empty because the repository tracks at least one changelog
(extensions/drm-copilot/CHANGELOG.md, matched by the double-star changelog glob) and one append-only
registry (the Claude pack manifest).
