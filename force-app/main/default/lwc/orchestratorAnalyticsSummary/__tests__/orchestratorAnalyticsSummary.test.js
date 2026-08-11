import { createElement } from 'lwc';
import OrchestratorAnalyticsSummary from 'c/orchestratorAnalyticsSummary';

describe('c-orchestrator-analytics-summary', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders KPI metric cards', () => {
        const element = createElement('c-orchestrator-analytics-summary', {
            is: OrchestratorAnalyticsSummary
        });
        document.body.appendChild(element);

        const cards = element.shadowRoot.querySelectorAll('.kpi-card');
        expect(cards.length).toBe(4);
    });
});
