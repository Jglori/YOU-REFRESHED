trigger LoggoutEventTrigger on LogoutEventStream (after insert) { 
    // LogoutEventStream event = Trigger.new[0];
    // User us = new User(Id = event.UserId, Situacao__c = 'offline');
    // update us;

    // List<ParticipanteRoleta__c> rl = ParticipanteRoletaSelector.obterParticipantesPorUserID(us.Id);
    // if(rl.isEmpty()){
    //     delete rl;
    // }
  }