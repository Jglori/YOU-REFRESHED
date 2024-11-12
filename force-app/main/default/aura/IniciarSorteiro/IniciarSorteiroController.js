({
    iniciarSorteio: function(component, event, helper) {
        component.set("v.isProcessing", true);
        
        // Chama o método Apex
        var action = component.get("c.executarSorteio");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.message", "Sorteio executado com sucesso!");
            } else {
                component.set("v.message", "Erro ao executar sorteio.");
            }
            component.set("v.isProcessing", false);
        });
        
        $A.enqueueAction(action);
    }
})