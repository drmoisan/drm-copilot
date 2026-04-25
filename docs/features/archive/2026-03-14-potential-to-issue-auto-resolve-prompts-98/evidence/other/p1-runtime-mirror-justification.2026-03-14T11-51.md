Timestamp: 2026-03-14T11:51:20.0000000-04:00
Reason: extensions/drm-copilot/package.json declares main as ./out/extension.js, so the generated runtime mirror must be synchronized after the constrained TypeScript source fix for the installed extension to execute the new active-editor auto-resolution path.
Source Of Truth: extensions/drm-copilot/src/extension.ts
Generated Runtime Mirror: extensions/drm-copilot/out/extension.js
Expected Side Effect: TypeScript emit may also refresh extensions/drm-copilot/out/extension.js.map.
