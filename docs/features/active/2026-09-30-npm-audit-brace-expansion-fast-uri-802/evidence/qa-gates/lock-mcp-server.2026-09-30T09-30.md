Timestamp: 2026-09-30T08-59
Command: (in /c/Users/DanMoisan/repos/drm-copilot-wt/2026-09-29T13-45/packages/mcp-server) npx --yes npm@11 install --package-lock-only && npx --yes npm@11 ci && git diff origin/main --stat -- package-lock.json
EXIT_CODE: 0
Output Summary:
    [key] added 95 packages, and audited 96 packages in 2s
    [key]  packages/mcp-server/package-lock.json | 6 +++---
    npm warn install-scripts 1 package has install scripts not yet covered by allowScripts:
    npm warn install-scripts   esbuild@0.28.2 (postinstall: node install.js)
    npm warn install-scripts
    npm warn install-scripts Run `npm install-scripts ls` to review, or `npm install-scripts approve <pkg>` to allow.
     packages/mcp-server/package-lock.json | 6 +++---
     1 file changed, 3 insertions(+), 3 deletions(-)
