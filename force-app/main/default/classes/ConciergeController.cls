public class ConciergeController {
    @AuraEnabled(cacheable = true)
    public static Map<String, String> obterCanaisAtendimento() {
        return ConciergeService.obterCanaisAtendimento();
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, String> obterOrigens() {
        return ConciergeService.obterOrigens();
    }

    @AuraEnabled
    public static String obterLeadsPorInformacoesConcierge(String celular, String email, Boolean isJuridica , String phone) {
        return ConciergeService.obterLeadsPorInformacoesConcierge(celular, email, isJuridica  , phone);
    }

    @AuraEnabled
    public static String obterRoletasLeadsVigentes() {
        return ConciergeService.obterRoletasLeadsVigentes();
    }

    @AuraEnabled
    public static void criarLead(Map<String, String> formulario) {
        try {
            ConciergeService.criarLead(formulario);
            System.debug('Passou execução concierge');
        } catch(Exception e) {
            System.debug('Erro ao criar lead: ' + e.getMessage());
            throw e;
        }
    }
    
    @AuraEnabled
    public static void atualizarLead(List<Map<String, Object>> formulario) {
        try {
            ConciergeService.atualizarLead(formulario);
            System.debug('Passou execução concierge');
        } catch(Exception e) {
            System.debug('Erro ao atualizar lead: ' + e.getMessage());
            throw e;
        }
    }

    @AuraEnabled
    public static void criarTaskReiteracao(String jsonData, Id roletaId) {
        ConciergeService.criarTaskReiteracao(jsonData, roletaId);
    }

    @AuraEnabled
    public static void criarTaskReiteracaoeAssociarCorretor(String jsonData, Id corretorId) {
        ConciergeService.criarTaskReiteracaoeAssociarCorretor(jsonData, corretorId);
    }
    @AuraEnabled
    public static List<Contact> buscarTodosCorretores() {
        return ConciergeService.buscarTodosCorretores();
    }

    @AuraEnabled
    public static List<Contact> buscarCorretoresLetra(String corretor) {
        return ConciergeService.buscarCorretoresLetra(corretor);
    }
}