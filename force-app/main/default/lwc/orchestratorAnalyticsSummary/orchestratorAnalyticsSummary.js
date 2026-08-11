import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import ORCHESTRATOR_CHANNEL from '@salesforce/messageChannel/orchestratorChannel__c';
import getAnalyticsSummary from '@salesforce/apex/OrchestratorController.getAnalyticsSummary';

export default class OrchestratorAnalyticsSummary extends LightningElement {
    wiredAnalyticsResult;
    subscription = null;

    totalTasks = 0;
    criticalPending = 0;
    completionRate = 0;
    avgProgress = 0;

    @wire(MessageContext)
    messageContext;

    @wire(getAnalyticsSummary)
    wiredAnalytics(result) {
        this.wiredAnalyticsResult = result;
        if (result.data) {
            this.totalTasks = result.data.totalTasks || 0;
            this.criticalPending = result.data.criticalPending || 0;
            this.completionRate = result.data.completionRate || 0;
            this.avgProgress = result.data.avgProgress || 0;
        } else if (result.error) {
            console.error('Error loading analytics summary', result.error);
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
        if (message && (message.actionType === 'REFRESH_DATA' || message.actionType === 'BATCH_EXECUTE')) {
            refreshApex(this.wiredAnalyticsResult);
        }
    }
}
