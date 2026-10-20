# P6-T1 shared declarations and serializer scope

The approved public declarations are frozen for dependent implementation. RuntimeIdentity retains its five keyword-only fields; ServiceRuntimeError distinguishes unavailable and corrupt installed identity without a fallback.

The serializer helper was absent before creation. Both modules retain the 500-line limit. Explicit catalog validation remains injected; to_json uses the existing trusted installed catalog reader. No implementation QA or service authority is claimed by this declaration freeze.
