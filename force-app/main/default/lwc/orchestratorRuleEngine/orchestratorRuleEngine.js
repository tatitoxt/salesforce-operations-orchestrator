import { LightningElement, wire, track } from 'lwc';
import getOperationRules from '@salesforce/apex/OrchestratorController.getOperationRules';

export default class OrchestratorRuleEngine extends LightningElement {
    @track rules = [];

    @wire(getOperationRules)
    wiredRules({ data, error }) {
        if (data) {
            this.rules = data;
        } else if (error) {
            console.error('Error fetching Custom Metadata Rules', error);
        }
    }
}
