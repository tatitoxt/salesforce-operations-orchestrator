import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import ORCHESTRATOR_CHANNEL from '@salesforce/messageChannel/orchestratorChannel__c';

export default class OrchestratorFilterBar extends LightningElement {
    searchTerm = '';
    statusValue = 'ALL';
    priorityValue = 'ALL';
    categoryValue = 'ALL';
    searchTimeout;

    @wire(MessageContext)
    messageContext;

    get statusOptions() {
        return [
            { label: 'All Statuses', value: 'ALL' },
            { label: 'Pending', value: 'Pending' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Completed', value: 'Completed' },
            { label: 'Failed', value: 'Failed' }
        ];
    }

    get priorityOptions() {
        return [
            { label: 'All Priorities', value: 'ALL' },
            { label: 'Critical', value: 'Critical' },
            { label: 'High', value: 'High' },
            { label: 'Medium', value: 'Medium' },
            { label: 'Low', value: 'Low' }
        ];
    }

    get categoryOptions() {
        return [
            { label: 'All Categories', value: 'ALL' },
            { label: 'Data Sync', value: 'Data Sync' },
            { label: 'Workflow Automation', value: 'Workflow Automation' },
            { label: 'Integration API', value: 'Integration API' },
            { label: 'Billing Audit', value: 'Billing Audit' },
            { label: 'System Maintenance', value: 'System Maintenance' }
        ];
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        window.clearTimeout(this.searchTimeout);
        this.searchTimeout = window.setTimeout(() => {
            this.dispatchFilterChange();
        }, 300);
    }

    handleStatusChange(event) {
        this.statusValue = event.detail.value;
        this.dispatchFilterChange();
    }

    handlePriorityChange(event) {
        this.priorityValue = event.detail.value;
        this.dispatchFilterChange();
    }

    handleCategoryChange(event) {
        this.categoryValue = event.detail.value;
        this.dispatchFilterChange();
    }

    handleResetFilters() {
        this.searchTerm = '';
        this.statusValue = 'ALL';
        this.priorityValue = 'ALL';
        this.categoryValue = 'ALL';
        this.dispatchFilterChange();
    }

    dispatchFilterChange() {
        const payload = {
            searchTerm: this.searchTerm,
            status: this.statusValue,
            priority: this.priorityValue,
            category: this.categoryValue
        };
        const message = {
            actionType: 'FILTER_CHANGE',
            payload: JSON.stringify(payload),
            timestamp: Date.now()
        };
        publish(this.messageContext, ORCHESTRATOR_CHANNEL, message);
    }
}
