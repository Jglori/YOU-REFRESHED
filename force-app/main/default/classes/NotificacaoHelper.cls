public class NotificacaoHelper {
    public static void notificacaoEquipeVendas(List<Product2> produtos) {
        Set<Id> idProduto = new Set<Id>();
        List<Opportunity> listaOportunidades = new List<Opportunity>();
    
        if (!produtos.isEmpty()) {
            
            for (Product2 produto : produtos) {
                idProduto.add(produto.Id);
            }
    
            listaOportunidades = OpportunityDA.obterOportunidadePorIdProduto(idProduto);
        }
    
        if (!listaOportunidades.isEmpty()) {

            buscarEquipeVendas(listaOportunidades);
        }
    }


    public static void buscarEquipeVendas(List<Opportunity> listaOportunidades) {
        List<User> usuarios = UserSelector.obterUsuarios();
        Set<String> emailsEquipeVendas = new Set<String>();
        Set<Id> supervisoresProcessados = new Set<Id>();
        Id idReporte;

        for (Opportunity opp : listaOportunidades) {
            for (User user : usuarios) {
                
                if (opp.Corretor__r.UsuarioCorretor__c == user.Id) {
                   idReporte = user.Reportase__c;
                    
                    emailsEquipeVendas.add(user.Email);
    
                    buscarSupervisores(idReporte, user, emailsEquipeVendas, listaOportunidades, supervisoresProcessados);
                }
            }
        }
    
    }
    
    public static void buscarSupervisores(Id idReporte, User user, Set<String> emailsEquipeVendas, List<Opportunity> listaOportunidades, Set<Id> supervisoresProcessados) {
        
        if (idReporte != null && user.Reportase__r.Email != null && !supervisoresProcessados.contains(user.Reportase__c)) {
            
            emailsEquipeVendas.add(user.Reportase__r.Email);
            supervisoresProcessados.add(user.Reportase__c);
            
            User supervisor = [SELECT Id, Email, Reportase__c, Reportase__r.Email FROM User WHERE Id = :idReporte LIMIT 1];
            
            buscarSupervisores(idReporte, supervisor, emailsEquipeVendas, listaOportunidades, supervisoresProcessados);
        }
    
        if (!emailsEquipeVendas.isEmpty()) {
            List<String> listaEmailsEquipeVendas = new List<String>(emailsEquipeVendas);
    
            mandarEmailEquipeVendas(listaEmailsEquipeVendas, listaOportunidades);
        }
    }

    public static void mandarEmailEquipeVendas(List<String> listaEmailsEquipeVendas, List<Opportunity> listaOportunidades) {
        List<Contact> contatos = [SELECT Id, Name, Email, UsuarioCorretor__r.Email FROM Contact WHERE RecordType.Name = 'Corretor'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id, DeveloperName, Name FROM EmailTemplate WHERE Name = 'Template de email para a equipe de vendas' LIMIT 1];

        if (!listaOportunidades.isEmpty()) {
            
          Id produtoId = listaOportunidades[0].Unidade__r.Id;
          String nomeUnidade = listaOportunidades[0].Unidade__r.Name;
          String statusUnidade = listaOportunidades[0].Unidade__r.Status__c;
    
            for (Contact contato : contatos) {
                if (listaEmailsEquipeVendas.contains(contato.UsuarioCorretor__r.Email)) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(template.Id);  
                    email.setTargetObjectId(contato.Id); 
                    email.setWhatId(produtoId);  
                    email.setToAddresses(new String[] { contato.UsuarioCorretor__r.Email});  
                    
                    emails.add(email);
                }

            }

            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }

    public static void notificacaoCliente(List<Product2> produtos) {
        Set<Id> idProduto = new Set<Id>();
        List<Opportunity> listaEmailCliente = new List<Opportunity>();
        String nomeUnidade;
        String statusUnidade;
        String emailCliente;
        Id idContato;

        if(!produtos.isEmpty()){

            for (Product2 produto : produtos) {
                idProduto.add(produto.id);
            }

            listaEmailCliente = OpportunityDA.obterOportunidadePorIdProduto(idProduto);
        }

        if(!listaEmailCliente.isEmpty()){
            nomeUnidade = listaEmailCliente[0].Unidade__r.Name;
            statusUnidade = listaEmailCliente[0].Unidade__r.Status__c;
            emailCliente = listaEmailCliente[0].Account.PersonEmail;
            idContato = listaEmailCliente[0].Account.id;

            mandarEmailCliente(idContato, emailCliente, nomeUnidade, statusUnidade, idProduto);
        }
    }


    public static void mandarEmailCliente(Id idContato, String emailCliente, String nomeUnidade, String statusUnidade, Set<id> setIdProduto){
        EmailTemplate template = [SELECT Id, DeveloperName, Name FROM EmailTemplate WHERE Name = 'Template de notifcação para o cliente' LIMIT 1];
        Product2 produto = ProdutoSelector.buscarUnidadePorSetId(setIdProduto);
        Account idCliente = [SELECT Id, PersonContact.Id FROM Account WHERE Id = :idContato];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        

        if(statusUnidade == 'Disponivel'){

            email.setTemplateId(template.Id);  
            email.setTargetObjectId(idCliente.PersonContact.Id); 
            email.setWhatId(produto.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }else if(statusUnidade == 'Reservada'){
            email.setTemplateId(template.Id);  
            email.setTargetObjectId(idCliente.PersonContact.Id); 
            email.setWhatId(produto.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }else{

            email.setTemplateId(template.Id);  
            email.setTargetObjectId(idCliente.PersonContact.Id); 
            email.setWhatId(produto.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
}