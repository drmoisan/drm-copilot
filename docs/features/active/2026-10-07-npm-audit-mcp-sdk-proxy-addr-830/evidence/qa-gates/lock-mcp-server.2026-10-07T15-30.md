Timestamp: 2026-10-07T10-16
Command: (cd C:/Users/DanMoisan/repos/drm-copilot-wt/2026-10-07-npm-audit-sdk-proxy-addr/packages/mcp-server) npx --yes npm@11 install --package-lock-only && npx --yes npm@11 ci
EXIT_CODE: 0
Output Summary: added 95 packages, and audited 96 packages in 2s

## Output
```

up to date, audited 96 packages in 745ms

31 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
npm warn install-scripts 1 package has install scripts not yet covered by allowScripts:
npm warn install-scripts   esbuild@0.28.2 (postinstall: node install.js)
npm warn install-scripts
npm warn install-scripts Run `npm install-scripts ls` to review, or `npm install-scripts approve <pkg>` to allow.

added 95 packages, and audited 96 packages in 2s

31 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
npm warn install-scripts 1 package has install scripts not yet covered by allowScripts:
npm warn install-scripts   esbuild@0.28.2 (postinstall: node install.js)
npm warn install-scripts
npm warn install-scripts Run `npm install-scripts ls` to review, or `npm install-scripts approve <pkg>` to allow.
```

## git diff origin/main --stat
```
 packages/mcp-server/package-lock.json | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)
```
