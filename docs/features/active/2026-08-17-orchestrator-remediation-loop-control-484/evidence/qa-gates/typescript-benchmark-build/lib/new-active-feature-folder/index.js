"use strict";
/**
 * Public facade for the active-feature-folder cluster.
 *
 * Re-exports the public surface mirroring the Python
 * `new_active_feature_folder.py` `__all__`. The CLI `main`/`parseArgs`
 * entrypoint is intentionally not ported; the service supplies typed inputs via
 * the service-call helper.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.createActiveFolder = exports.updateFeatureDocs = exports.shouldUseMinorAuditMode = exports.resolveCodeCli = exports.parseIssueNumber = exports.materializePlanFile = exports.isInsidersSession = exports.findPotentialFile = exports.defaultIssueFetcher = exports.defaultCodeLauncher = exports.copyTemplate = exports.copyFeatureTemplateForMinorAudit = exports.buildFolderSlug = exports.upsertWorkModeMarker = exports.updateSectionBody = exports.setSection = exports.setHeaderPlaceholder = exports.prependToSectionBody = exports.getSection = exports.formatChecklist = exports.validateFeatureName = exports.resolveWorkspace = exports.getEstTimestamp = exports.extractDateFromTimestamp = exports.RealFolderFileSystem = exports.PLAN_TIMESTAMP_TEMPLATE_NAME = exports.PLACEHOLDERS = exports.NAME_PATTERN = exports.EXCLUDED_POTENTIAL_NAMES = void 0;
var models_1 = require("./models");
Object.defineProperty(exports, "EXCLUDED_POTENTIAL_NAMES", { enumerable: true, get: function () { return models_1.EXCLUDED_POTENTIAL_NAMES; } });
Object.defineProperty(exports, "NAME_PATTERN", { enumerable: true, get: function () { return models_1.NAME_PATTERN; } });
Object.defineProperty(exports, "PLACEHOLDERS", { enumerable: true, get: function () { return models_1.PLACEHOLDERS; } });
Object.defineProperty(exports, "PLAN_TIMESTAMP_TEMPLATE_NAME", { enumerable: true, get: function () { return models_1.PLAN_TIMESTAMP_TEMPLATE_NAME; } });
Object.defineProperty(exports, "RealFolderFileSystem", { enumerable: true, get: function () { return models_1.RealFolderFileSystem; } });
Object.defineProperty(exports, "extractDateFromTimestamp", { enumerable: true, get: function () { return models_1.extractDateFromTimestamp; } });
Object.defineProperty(exports, "getEstTimestamp", { enumerable: true, get: function () { return models_1.getEstTimestamp; } });
Object.defineProperty(exports, "resolveWorkspace", { enumerable: true, get: function () { return models_1.resolveWorkspace; } });
Object.defineProperty(exports, "validateFeatureName", { enumerable: true, get: function () { return models_1.validateFeatureName; } });
var markdown_1 = require("./markdown");
Object.defineProperty(exports, "formatChecklist", { enumerable: true, get: function () { return markdown_1.formatChecklist; } });
Object.defineProperty(exports, "getSection", { enumerable: true, get: function () { return markdown_1.getSection; } });
Object.defineProperty(exports, "prependToSectionBody", { enumerable: true, get: function () { return markdown_1.prependToSectionBody; } });
Object.defineProperty(exports, "setHeaderPlaceholder", { enumerable: true, get: function () { return markdown_1.setHeaderPlaceholder; } });
Object.defineProperty(exports, "setSection", { enumerable: true, get: function () { return markdown_1.setSection; } });
Object.defineProperty(exports, "updateSectionBody", { enumerable: true, get: function () { return markdown_1.updateSectionBody; } });
Object.defineProperty(exports, "upsertWorkModeMarker", { enumerable: true, get: function () { return markdown_1.upsertWorkModeMarker; } });
var io_1 = require("./io");
Object.defineProperty(exports, "buildFolderSlug", { enumerable: true, get: function () { return io_1.buildFolderSlug; } });
Object.defineProperty(exports, "copyFeatureTemplateForMinorAudit", { enumerable: true, get: function () { return io_1.copyFeatureTemplateForMinorAudit; } });
Object.defineProperty(exports, "copyTemplate", { enumerable: true, get: function () { return io_1.copyTemplate; } });
Object.defineProperty(exports, "defaultCodeLauncher", { enumerable: true, get: function () { return io_1.defaultCodeLauncher; } });
Object.defineProperty(exports, "defaultIssueFetcher", { enumerable: true, get: function () { return io_1.defaultIssueFetcher; } });
Object.defineProperty(exports, "findPotentialFile", { enumerable: true, get: function () { return io_1.findPotentialFile; } });
Object.defineProperty(exports, "isInsidersSession", { enumerable: true, get: function () { return io_1.isInsidersSession; } });
Object.defineProperty(exports, "materializePlanFile", { enumerable: true, get: function () { return io_1.materializePlanFile; } });
Object.defineProperty(exports, "parseIssueNumber", { enumerable: true, get: function () { return io_1.parseIssueNumber; } });
Object.defineProperty(exports, "resolveCodeCli", { enumerable: true, get: function () { return io_1.resolveCodeCli; } });
var docs_1 = require("./docs");
Object.defineProperty(exports, "shouldUseMinorAuditMode", { enumerable: true, get: function () { return docs_1.shouldUseMinorAuditMode; } });
Object.defineProperty(exports, "updateFeatureDocs", { enumerable: true, get: function () { return docs_1.updateFeatureDocs; } });
var flow_1 = require("./flow");
Object.defineProperty(exports, "createActiveFolder", { enumerable: true, get: function () { return flow_1.createActiveFolder; } });
