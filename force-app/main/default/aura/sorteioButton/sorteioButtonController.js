({
    navigateToFlow : function(component, event, helper) {
        
        var currentUrl = window.location.href;

        component.set("v.currentPageUrl", currentUrl);

        var flowUrl = component.get("v.flowUrl");
        var pageUrlParam = encodeURIComponent(currentUrl); 
        
        
        var finalFlowUrl = flowUrl + "?currentPageUrl=" + pageUrlParam;
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": finalFlowUrl
        });
        urlEvent.fire();
    }
})