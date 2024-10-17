public class OmnichannelController {
    /**
     * Método responsável pela seleção de canais de atendimento no usuário para
     * recepção de leads dos respectivos canais.
     */
    @AuraEnabled
    public static String selecionarCanais(List<String> canaisAtendimento) {
        return OmnichannelService.selecionarCanais(canaisAtendimento);
    }

    /**
     * Método responsável pela aceitação do lead atribuído ao corretor, definindo
     * o corretor como proprietário.
     */
    @AuraEnabled
    public static String aceitarLead(Id idLead) {
        return OmnichannelService.aceitarLead(idLead);
    }

    /**
     * Método responsável pela rejeição do lead atribuído ao corretor, limpando a
     * roleta e corretor escolhidos.
     */
    @AuraEnabled
    public static String rejeitarLead(Id idLead) {
        return OmnichannelService.rejeitarLead(idLead);
    }

    /**
     * Método responsável pela alteração da situação do corretor enquanto participantes
     * de roletas, criando novos participantes caso não hajam.
     */
    @AuraEnabled
    public static String alterarSituacao(String novaSituacao) {
        return OmnichannelService.alterarSituacao(novaSituacao);
    }

    /**
     * Método responsável pela obtenção de leads atribuídos e aceitos pelo corretor.
     */
    @AuraEnabled
    public static String obterLeadsEmTrabalho() {
        return OmnichannelService.obterLeadsEmTrabalho();
    }

    /**
     * Método responsável pela obtenção dos leads atribuídos ao corretor, porém ainda
     * não aceitos.
     */
    @AuraEnabled
    public static String obterLeadsEmNovo() {
        return OmnichannelService.obterLeadsEmNovo();
    }

    /**
     * Método responsável pela obtenção do usuário para apresentação da situação e
     * canais de atendimento selecionados.
     */
    @AuraEnabled
    public static String obterUsuario() {
        return OmnichannelService.obterUsuario();
    }

    /**
     * Método responsável pela obtenção das situações disponíveis para o usuário atual.
     */
    @AuraEnabled
    public static Map<String, String> obterSituacoes() {
        return OmnichannelService.obterSituacoes();
    }

    @AuraEnabled
    public static String definirStatusInicial() {
        return OmnichannelService.definirStatusInicial();
    }

    /**
     * Método responsável pela obtenção dos canais de atendimento relacionados às
     * roletas que o corretor é membro.
     */
    @AuraEnabled
    public static Map<String, String> obterCanaisAtendimento() {
        return OmnichannelService.obterCanaisAtendimento();
    }
}