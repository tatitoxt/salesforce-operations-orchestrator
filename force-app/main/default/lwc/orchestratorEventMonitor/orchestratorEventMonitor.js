import { LightningElement, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrchestratorEventMonitor extends LightningElement {
    channelName = '/event/Operation_Event__e';
    subscription = {};
    @track events = [];
    isConnected = false;

    get connectionStatus() {
        return this.isConnected ? 'Connected Live' : 'Connecting...';
    }

    get connectionBadgeClass() {
        return this.isConnected ? 'slds-badge slds-theme_success' : 'slds-badge slds-theme_warning';
    }

    connectedCallback() {
        this.registerEmpApiErrorListener();
        this.handleSubscribe();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleSubscribe() {
        const messageCallback = (response) => {
            const eventPayload = response.data.payload;
            const newEvent = {
                id: response.data.event.replayId,
                status: eventPayload.Status__c || 'EVENT',
                message: eventPayload.Message__c || 'Operation event received',
                time: new Date(eventPayload.Timestamp__c || Date.now()).toLocaleTimeString()
            };
            this.events = [newEvent, ...this.events.slice(0, 19)];

            this.dispatchEvent(new ShowToastEvent({
                title: 'Real-Time Event: ' + newEvent.status,
                message: newEvent.message,
                variant: newEvent.status === 'Completed' ? 'success' : 'info'
            }));
        };

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            this.subscription = response;
            this.isConnected = true;
        }).catch(() => {
            this.isConnected = false;
        });
    }

    handleUnsubscribe() {
        if (this.subscription && this.subscription.channel) {
            unsubscribe(this.subscription, () => {
                this.isConnected = false;
            });
        }
    }

    registerEmpApiErrorListener() {
        onError((error) => {
            console.error('empApi streaming error', error);
        });
    }

    handleClearFeed() {
        this.events = [];
    }
}
