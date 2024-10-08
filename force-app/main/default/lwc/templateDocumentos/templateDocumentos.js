import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class TemplateDocumento extends NavigationMixin(LightningElement) {
    navigateNext() {
        try{
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/lightning/n/GeradorVariaveis',
                },
            });
        }catch(e){
            console.error("não foi possível navegar pra próxima página: "+ e);
        }
    }
}