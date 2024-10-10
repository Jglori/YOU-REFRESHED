import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class TemplateDocumento extends NavigationMixin(LightningElement) {
    navigateNext() { 
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/n/GeradorVariaveis',
            },
        });
    }
}