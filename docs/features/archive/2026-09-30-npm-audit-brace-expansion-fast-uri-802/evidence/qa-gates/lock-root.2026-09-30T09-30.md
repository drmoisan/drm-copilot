Timestamp: 2026-09-30T08-58
Command: (in /c/Users/DanMoisan/repos/drm-copilot-wt/2026-09-29T13-45) npx --yes npm@11 install --package-lock-only && npx --yes npm@11 ci && git diff origin/main --stat -- package-lock.json
EXIT_CODE: 0
Output Summary:
    [key] added 544 packages, and audited 545 packages in 8s
    [key]  package-lock.json | 12 ++++++------
    npm warn install-scripts   @parcel/watcher@2.6.0 (install: node scripts/build-from-source.js)
    npm warn install-scripts   unrs-resolver@1.12.2 (postinstall: node postinstall.js)
    npm warn install-scripts
    npm warn install-scripts Run `npm install-scripts ls` to review, or `npm install-scripts approve <pkg>` to allow.
     package-lock.json | 12 ++++++------
     1 file changed, 6 insertions(+), 6 deletions(-)
