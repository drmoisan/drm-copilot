Timestamp: 2026-09-28T20-04
Command: npm install --prefix .; echo "npm-install-exit=$?"; git grep -nF "ip-address-10.4.0.tgz" -- package-lock.json; echo "old-tgz-grep-exit=$?"
EXIT_CODE: 0
Output Summary: (last 25 lines of output below)
```text
npm warn deprecated glob@10.5.0: Old versions of glob are not supported, and contain widely publicized security vulnerabilities, which have been fixed in the current version. Please update. Support for old versions may be purchased (at exorbitant rates) by contacting i@izs.me

added 491 packages, removed 7 packages, changed 52 packages, and audited 545 packages in 7s

131 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
npm-install-exit=0
old-tgz-grep-exit=1
```
Note: npm install exit 0; old-tgz grep exited 1 (zero matches). Acceptance met.
