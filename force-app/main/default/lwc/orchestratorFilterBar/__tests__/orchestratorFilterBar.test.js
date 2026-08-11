import { createElement } from 'lwc';
import OrchestratorFilterBar from 'c/orchestratorFilterBar';

describe('c-orchestrator-filter-bar', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders search input and comboboxes', () => {
        const element = createElement('c-orchestrator-filter-bar', {
            is: OrchestratorFilterBar
        });
        document.body.appendChild(element);

        const searchInput = element.shadowRoot.querySelector('lightning-input');
        expect(searchInput).not.toBeNull();

        const comboboxes = element.shadowRoot.querySelectorAll('lightning-combobox');
        expect(comboboxes.length).toBe(3);
    });
});
