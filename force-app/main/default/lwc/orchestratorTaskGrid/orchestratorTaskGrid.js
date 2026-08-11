import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, publish, MessageContext } from 'lightning/messageService';
import ORCHESTRATOR_CHANNEL from '@salesforce/messageChannel/orchestratorChannel__c';

import getOrchestrationTasks from '@salesforce/apex/OrchestratorController.getOrchestrationTasks';
import executeBatchOperations from '@salesforce/apex/OrchestratorController.executeBatchOperations';
import seedSampleData from '@salesforce/apex/OrchestratorController.seedSampleData';
import clearAllTasks from '@salesforce/apex/OrchestratorController.clearAllTasks';

const ROW_ACTIONS = [
    { label: 'Execute Task', name: 'execute' },
    { label: 'View Details', name: 'view' }
];

export default class OrchestratorTaskGrid extends LightningElement {
    @track tasks = [];
    totalCount = 0;
    pageSize = 10;
    pageNumber = 1;
    isLoading = false;
    selectedTaskIds = [];

    searchTerm = '';
    statusFilter = 'ALL';
    priorityFilter = 'ALL';
    categoryFilter = 'ALL';

    subscription = null;
    wiredTasksResult;

    @wire(MessageContext)
    messageContext;

    columns = [
        { label: 'Task ID', fieldName: 'name', type: 'text', initialWidth: 130 },
        { label: 'Subject', fieldName: 'subject', type: 'text' },
        {
            label: 'Status',
            fieldName: 'status',
            type: 'statusBadge',
            typeAttributes: { badgeClass: { fieldName: 'badgeClass' } },
            initialWidth: 140
        },
        { label: 'Priority', fieldName: 'priority', type: 'text', initialWidth: 110 },
        { label: 'Category', fieldName: 'category', type: 'text', initialWidth: 160 },
        { label: 'Progress', fieldName: 'progress', type: 'progressBar', initialWidth: 180 },
        {
            type: 'action',
            typeAttributes: { rowActions: ROW_ACTIONS }
        }
    ];

    @wire(getOrchestrationTasks, {
        searchTerm: '$searchTerm',
        status: '$statusFilter',
        priority: '$priorityFilter',
        category: '$categoryFilter',
        pageSize: '$pageSize',
        pageNumber: '$pageNumber'
    })
    wiredTasks(result) {
        this.wiredTasksResult = result;
        this.isLoading = false;
        if (result.data) {
            this.totalCount = result.data.totalCount;
            this.tasks = (result.data.tasks || []).map((t) => {
                return {
                    id: t.Id,
                    name: t.Name,
                    subject: t.Subject__c,
                    status: t.Status__c,
                    priority: t.Priority__c,
                    category: t.Category__c,
                    progress: t.Progress__c || 0,
                    badgeClass: this.computeBadgeClass(t.Status__c)
                };
            });
        } else if (result.error) {
            this.showToast('Error', 'Failed to load tasks', 'error');
        }
    }

    connectedCallback() {
        this.subscribeToChannel();
    }

    disconnectedCallback() {
        this.unsubscribeFromChannel();
    }

    subscribeToChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                ORCHESTRATOR_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }
    }

    unsubscribeFromChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        if (!message) return;
        if (message.actionType === 'FILTER_CHANGE' && message.payload) {
            const filterState = JSON.parse(message.payload);
            this.searchTerm = filterState.searchTerm || '';
            this.statusFilter = filterState.status || 'ALL';
            this.priorityFilter = filterState.priority || 'ALL';
            this.categoryFilter = filterState.category || 'ALL';
            this.pageNumber = 1;
            this.isLoading = true;
        } else if (message.actionType === 'REFRESH_DATA') {
            refreshApex(this.wiredTasksResult);
        }
    }

    computeBadgeClass(status) {
        switch (status) {
            case 'Completed': return 'slds-badge slds-theme_success';
            case 'In Progress': return 'slds-badge slds-theme_info';
            case 'Failed': return 'slds-badge slds-theme_error';
            case 'Escalated': return 'slds-badge slds-theme_warning';
            default: return 'slds-badge';
        }
    }

    get isBatchDisabled() {
        return this.selectedTaskIds.length === 0;
    }

    get isFirstPage() {
        return this.pageNumber <= 1;
    }

    get isLastPage() {
        return this.pageNumber * this.pageSize >= this.totalCount;
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedTaskIds = selectedRows.map((row) => row.id);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'execute') {
            this.executeTasks([row.id]);
        }
    }

    handleExecuteSelected() {
        if (this.selectedTaskIds.length > 0) {
            this.executeTasks(this.selectedTaskIds);
        }
    }

    async executeTasks(taskIds) {
        this.isLoading = true;
        try {
            const jobId = await executeBatchOperations({ taskIds: taskIds });
            this.showToast('Batch Dispatched', `Enqueued async queueable job: ${jobId}`, 'success');
            publish(this.messageContext, ORCHESTRATOR_CHANNEL, {
                actionType: 'BATCH_EXECUTE',
                timestamp: Date.now()
            });
            await refreshApex(this.wiredTasksResult);
        } catch (error) {
            this.showToast('Error', error.body ? error.body.message : 'Execution failed', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async handleSeedData() {
        this.isLoading = true;
        try {
            const count = await seedSampleData();
            this.showToast('Demo Data Seeded', `Successfully inserted ${count} demo operation records.`, 'success');
            publish(this.messageContext, ORCHESTRATOR_CHANNEL, {
                actionType: 'REFRESH_DATA',
                timestamp: Date.now()
            });
            await refreshApex(this.wiredTasksResult);
        } catch (error) {
            this.showToast('Error', error.body ? error.body.message : 'Seeding failed', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async handleClearAll() {
        this.isLoading = true;
        try {
            await clearAllTasks();
            this.showToast('Tasks Cleared', 'All operations cleared from the system.', 'info');
            publish(this.messageContext, ORCHESTRATOR_CHANNEL, {
                actionType: 'REFRESH_DATA',
                timestamp: Date.now()
            });
            await refreshApex(this.wiredTasksResult);
        } catch (error) {
            this.showToast('Error', error.body ? error.body.message : 'Clear failed', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handlePreviousPage() {
        if (!this.isFirstPage) {
            this.pageNumber -= 1;
            this.isLoading = true;
        }
    }

    handleNextPage() {
        if (!this.isLastPage) {
            this.pageNumber += 1;
            this.isLoading = true;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
