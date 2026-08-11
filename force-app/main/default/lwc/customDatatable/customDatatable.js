import LightningDatatable from 'lightning/datatable';
import statusBadgeTemplate from './statusBadgeTemplate.html';
import progressBarTemplate from './progressBarTemplate.html';

export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        statusBadge: {
            template: statusBadgeTemplate,
            typeAttributes: ['badgeClass']
        },
        progressBar: {
            template: progressBarTemplate,
            typeAttributes: []
        }
    };
}
