({
    sendMessage: function(component, event, helper) {
        var evt = component.getEvent("childMessage");
        evt.setParams({ message: "Hello from the child!" });
        evt.fire();
    }
})

