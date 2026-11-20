# Native fixture correction

Only the synthetic report filename changes to the existing loader contract. Original rejection findings and the failed fixture are retained.

```diff
--- before/native.py
+++ after/native.py
@@ -85,7 +85,7 @@
 value['analyzers'] = {'enabled': ['repository'], 'options': {'max_file_bytes': 4096}, 'ignored_paths': [], 'extension_result_manifests': []}
 profile = ProfileV2(json.dumps(value), format='json', catalog=catalog)
 put(profile.artifacts['profile'], canonical_json(profile.document))
-put(profile.artifacts['reports'] + '/existing.md', b'# Generated view\n')
+put(profile.artifacts['reports'] + '/coverage-report.md', b'# Generated view\n')
 primitives = LocalMutationPrimitives(workspace_root=str(root), lock_path=str(scratch / ('issue-980-p4t1-' + uuid4().hex + '.lock')))
 repository = LocalGitReader(workspace_root=str(root), repository_id=profile.repository.id, run=git_command)


```
