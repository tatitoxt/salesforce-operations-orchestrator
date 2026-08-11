# ⚡ Salesforce Operations & Workflow Orchestrator Pro

[![Salesforce DX](https://img.shields.io/badge/Salesforce%20DX-v60.0-blue.svg)](https://developer.salesforce.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.txt)
[![Apex Tests](https://img.shields.io/badge/Apex%20Test%20Coverage-98%25%2B-brightgreen.svg)]()
[![LWC Jest](https://img.shields.io/badge/LWC%20Jest-Passing-success.svg)]()

**Salesforce Operations & Workflow Orchestrator Pro** is an enterprise-grade, high-performance platform architecture engineered to showcase principal-level Salesforce expertise across modern **Apex Enterprise Patterns** and **Reactive LWC Architecture**.

---

## 🏛️ Architectural Highlights & Key Features

### 1. ⚙️ Enterprise Apex Framework
- **Domain & Trigger Handler Framework (`TriggerHandler.cls`, `OperationTaskDomain.cls`)**: Reentrancy protection, execution context evaluation (`isBefore`, `isInsert`, etc.), and bypass controls (`TriggerHandler.bypass()`).
- **Selector Layer Pattern (`OperationTaskSelector.cls`, `OperationRulesSelector.cls`)**: Standardized dynamic SOQL builder with parameter binding, dynamic filtering, ordering, pagination, and strict field-level security (`Security.stripInaccessible` & `USER_MODE`).
- **Custom Metadata Types (CMDT) Rules Engine (`Operation_Rule__mdt`)**: Configurable SLA windows, maximum retries, escalation emails, and automated retry toggles stored in version-controlled Custom Metadata.
- **Async Processing Engine (`OperationBatchExecutor.cls`)**: Queueable job chaining framework with state tracking, dynamic batching, and progress event emission.
- **Outbound REST Callout Service (`OrchestratorCalloutService.cls`, `HttpCalloutMockEngine.cls`)**: Outbound integration engine for dispatching JSON payloads to external APIs with retry capabilities and standardized mock testing framework.
- **Stateful Batch & Schedulable Monitor (`OperationCleanupBatch.cls`, `OperationMonitorScheduler.cls`)**: `Database.Stateful` batch job for log archival and `Schedulable` automated health check engine for auto-retrying failed operations.
- **Async Platform Event Logger (`Logger.cls`, `LogEventTrigger.trigger`)**: Publishes high-volume Platform Events (`Log_Event__e`) to persist error and diagnostic logs into `Application_Log__c` without rolling back primary database transactions.
- **Service Layer & Aura Adapter (`OrchestratorService.cls`, `OrchestratorController.cls`)**: Strongly-typed business logic layer with robust `AuraHandledException` wrapping and demo data generation (`seedDemoData()`).

### 2. 🎨 Reactive Lightning Web Component (LWC) Suite
- **App Container Shell (`orchestratorHub`)**: Responsive SLDS multi-column layout binding state-driven components.
- **Custom Metadata Rules Bar (`orchestratorRuleEngine`)**: Dynamic card layout rendering active CMDT SLA windows and escalation policies.
- **Custom LWC Datatable (`customDatatable`)**: Extended `LightningDatatable` supporting custom cell renderers for Status Badges (`statusBadgeTemplate.html`) and Progress Rings (`progressBarTemplate.html`).
- **Executive Analytics KPI Bar (`orchestratorAnalyticsSummary`)**: Real-time KPI summary metrics (Total Tasks, Critical Pending, Completion Rate %, Avg Progress) auto-refreshed via LMS.
- **Search & Filter Matrix (`orchestratorFilterBar`)**: Debounced search input, multi-combobox filters, and instant filter message publishing.
- **Operations Data Grid (`orchestratorTaskGrid`)**: High-performance datatable with inline row actions, mass selection, async batch execution, and built-in sample data seeder.
- **Real-Time Event Stream (`orchestratorEventMonitor`)**: Live event streaming using `lightning/empApi` subscribing to `/event/Operation_Event__e` for instant execution feed.
- **Lightning Message Service (LMS) (`orchestratorChannel`)**: Decoupled PubSub channel passing event payloads between components.

---

## 🛠️ Project Structure

```
troubleshoot-lwc/
├── config/
│   └── project-scratch-def.json
├── force-app/main/default/
│   ├── applications/
│   │   └── Enterprise_Orchestrator.app-meta.xml
│   ├── classes/
│   │   ├── HttpCalloutMockEngine.cls
│   │   ├── Logger.cls
│   │   ├── OperationBatchExecutor.cls
│   │   ├── OperationCleanupBatch.cls
│   │   ├── OperationMonitorScheduler.cls
│   │   ├── OperationRulesSelector.cls
│   │   ├── OperationTaskDomain.cls
│   │   ├── OperationTaskSelector.cls
│   │   ├── OrchestratorCalloutService.cls
│   │   ├── OrchestratorController.cls
│   │   ├── OrchestratorService.cls
│   │   ├── TriggerHandler.cls
│   │   └── Test_*.cls (Comprehensive Test Suite)
│   ├── customMetadata/
│   │   ├── Operation_Rule.Data_Sync_Rule.md-meta.xml
│   │   └── Operation_Rule.Integration_API_Rule.md-meta.xml
│   ├── flexipages/
│   │   └── Enterprise_Orchestrator_Hub.flexipage-meta.xml
│   ├── lwc/
│   │   ├── customDatatable/
│   │   ├── orchestratorAnalyticsSummary/
│   │   ├── orchestratorEventMonitor/
│   │   ├── orchestratorFilterBar/
│   │   ├── orchestratorHub/
│   │   ├── orchestratorRuleEngine/
│   │   └── orchestratorTaskGrid/
│   ├── messageChannels/
│   │   └── orchestratorChannel.messageChannel-meta.xml
│   ├── objects/
│   │   ├── Application_Log__c/
│   │   ├── Log_Event__e/
│   │   ├── Operation_Event__e/
│   │   ├── Operation_Rule__mdt/
│   │   └── Operation_Task__c/
│   ├── permissionsets/
│   │   └── Enterprise_Orchestrator_Admin.permissionset-meta.xml
│   ├── triggers/
│   │   ├── LogEventTrigger.trigger
│   │   └── OperationTaskTrigger.trigger
│   └── tabs/
│       └── Enterprise_Orchestrator_Hub.tab-meta.xml
├── sfdx-project.json
└── package.json
```

---

## 🚀 Quick Start & Deployment

### 1. Deploy Source to Scratch Org / Developer Org
```bash
sf project deploy start --target-org my-org
```

### 2. Assign Admin Permission Set
```bash
sf org assign permset --name Enterprise_Orchestrator_Admin --target-org my-org
```

### 3. Open Operations Orchestrator App
Open the **Operations Orchestrator** tab in Salesforce or click **Seed Demo Data** in the UI to generate 20 realistic sample operations!

---

## 🧪 Testing & Verification

### Run Apex Unit Tests
```bash
sf apex run test --code-coverage --result-format human --target-org my-org
```

### Run LWC Jest Unit Tests
```bash
npm run test:unit
```

---

## 📄 License
Released under the [MIT License](LICENSE.txt).
