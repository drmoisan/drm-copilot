/**
 * Public facade for the active-feature-folder cluster.
 *
 * Re-exports the public surface mirroring the Python
 * `new_active_feature_folder.py` `__all__`. The CLI `main`/`parseArgs`
 * entrypoint is intentionally not ported; the service supplies typed inputs via
 * the service-call helper.
 */

export {
  type ActiveFolderResult,
  EXCLUDED_POTENTIAL_NAMES,
  type FolderFileSystem,
  type IssueMeta,
  NAME_PATTERN,
  PLACEHOLDERS,
  PLAN_TIMESTAMP_TEMPLATE_NAME,
  RealFolderFileSystem,
  extractDateFromTimestamp,
  getEstTimestamp,
  resolveWorkspace,
  validateFeatureName,
} from "./models";

export {
  formatChecklist,
  getSection,
  prependToSectionBody,
  setHeaderPlaceholder,
  setSection,
  updateSectionBody,
  upsertWorkModeMarker,
} from "./markdown";

export {
  buildFolderSlug,
  copyFeatureTemplateForMinorAudit,
  copyTemplate,
  defaultCodeLauncher,
  defaultIssueFetcher,
  findPotentialFile,
  isInsidersSession,
  materializePlanFile,
  parseIssueNumber,
  resolveCodeCli,
} from "./io";

export { shouldUseMinorAuditMode, updateFeatureDocs } from "./docs";

export { type CreateActiveFolderOptions, createActiveFolder } from "./flow";
