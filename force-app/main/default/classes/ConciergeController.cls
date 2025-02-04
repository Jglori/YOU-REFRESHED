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
            ConciergeService.criarLead(formulario);} @AuraEnabled public static void atualizarLead(List<Map<String, Object>> formulario) { ConciergeService.atualizarLead(formulario); } @AuraEnabled public static void criarTaskReiteracao(String jsonData, String informacoesAdicionais) { ConciergeService.criarTaskReiteracao(jsonData, informacoesAdicionais); }

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
        return ConciergeService.buscarCorretoresLetra(corretor);} @AuraEnabled(cacheable=true)public static String buscarPerfil(Id userId) {return ConciergeService.buscarPerfil(userId);}@AuraEnabled(cacheable=true) public static String buscarNomeCorretor(){  return ConciergeService.buscarNomeCorretor();
    }
}