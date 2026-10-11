# locked-version-extension

Timestamp: 2026-10-08T19-13
Command: git grep -nF -A1 "node_modules/handlebars" -- extensions/drm-copilot/package-lock.json ; git grep -nF "handlebars-4.7.9.tgz" -- extensions/drm-copilot/package-lock.json
EXIT_CODE: 0
Output Summary: first command exit 0, lists handlebars version 4.7.10 (greater than 4.7.9, within ^4); second command exit 1 with zero matches.

First command (exit 0):

```text
extensions/drm-copilot/package-lock.json:4512:    "node_modules/handlebars": {
extensions/drm-copilot/package-lock.json-4513-      "version": "4.7.10",
```

Second command (exit 1, no matches):

```text
(no output)
```
