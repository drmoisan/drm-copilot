Timestamp: 2026-10-07T10-16
Command: (cd C:/Users/DanMoisan/repos/drm-copilot-wt/2026-10-07-npm-audit-sdk-proxy-addr) npx --yes npm@11 install --package-lock-only && npx --yes npm@11 ci
EXIT_CODE: 0
Output Summary: added 544 packages, and audited 545 packages in 7s

## Output
```

up to date, audited 545 packages in 1s

132 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
npm warn install-scripts 2 packages have install scripts not yet covered by allowScripts:
npm warn install-scripts   @parcel/watcher@2.6.0 (install: node-gyp rebuild)
npm warn install-scripts   unrs-resolver@1.12.2 (postinstall: node postinstall.js)
npm warn install-scripts
npm warn install-scripts Run `npm install-scripts ls` to review, or `npm install-scripts approve <pkg>` to allow.
npm warn deprecated glob@10.5.0: Old versions of glob are not supported, and contain widely publicized security vulnerabilities, which have been fixed in the current version. Please update. Support for old versions may be purchased (at exorbitant rates) by contacting i@izs.me

added 544 packages, and audited 545 packages in 7s

132 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
npm warn install-scripts 2 packages have install scripts not yet covered by allowScripts:
npm warn install-scripts   @parcel/watcher@2.6.0 (install: node scripts/build-from-source.js)
npm warn install-scripts   unrs-resolver@1.12.2 (postinstall: node postinstall.js)
npm warn install-scripts
npm warn install-scripts Run `npm install-scripts ls` to review, or `npm install-scripts approve <pkg>` to allow.
```

## git diff origin/main --stat
```
 package-lock.json | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)
```
