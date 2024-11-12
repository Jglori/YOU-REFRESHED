import { LightningElement, api, wire } from 'lwc';
import getSalesTeamMembers from '@salesforce/apex/SalesTeamController.getSalesTeamMembers';

export default class EquipeVendasOpp extends LightningElement {
    @api recordId;
    salesTeamMembers;
    title;

    @wire(getSalesTeamMembers, { opportunityId: '$recordId' })
    wiredSalesTeamMembers({ error, data }) {
        if (data) {
            this.salesTeamMembers = data.map(member => {
                return {
                    ...member,
                    profileUrl: `/lightning/r/User/${member.userId}/view`
                };
            });
            this.title = `Equipe de Vendas (${this.salesTeamMembers.length})`;
        } else if (error) {
            this.salesTeamMembers = undefined;
            this.title = 'Equipe de Vendas (0)';
        }
    }
}