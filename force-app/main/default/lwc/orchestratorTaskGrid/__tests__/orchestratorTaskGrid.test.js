import { createElement } from 'lwc';
import OrchestratorTaskGrid from 'c/orchestratorTaskGrid';

describe('c-orchestrator-task-grid', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders lightning-card container and action buttons', () => {
        const element = createElement('c-orchestrator-task-grid', {
            is: OrchestratorTaskGrid
        });
        document.body.appendChild(element);

        const card = element.shadowRoot.querySelector('lightning-card');
        expect(card).not.toBeNull();
        expect(card.title).toBe('Workflows & Operations Grid');
    });
});
