public with sharing class SalesTeamController {
    @AuraEnabled(cacheable=true)
    public static List<SalesTeamMember> getSalesTeamMembers(Id opportunityId) {
        List<SalesTeamMember> teamMembers = new List<SalesTeamMember>();

        // Query para obter o usuário a partir do campo Corretor__c da Oportunidade
        Opportunity opp = [SELECT Corretor__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        
        if (opp.Corretor__c != null) {
            User startUser = [SELECT Id, Name, Cargo__c, Reportase__c, Coordenador__c FROM User WHERE Id = :opp.Corretor__c LIMIT 1];

            if (startUser != null) {
                // Adiciona o usuário à equipe
                teamMembers.add(new SalesTeamMember(startUser.Id, startUser.Name, startUser.Cargo__c));

                // Construir hierarquia acima
                buildSalesTeamAbove(startUser, teamMembers);

                // Construir hierarquia abaixo
                buildSalesTeamBelow(startUser, teamMembers);

                // Inclui o Coordenador, se existir
                if (startUser.Coordenador__c != null) {
                    User coordinator = [SELECT Id, Name, Cargo__c FROM User WHERE Id = :startUser.Coordenador__c LIMIT 1];
                    if (coordinator != null) {
                        teamMembers.add(new SalesTeamMember(coordinator.Id, coordinator.Name, coordinator.Cargo__c));
                    }
                }
            }
        }

        return teamMembers;
    }

    private static void buildSalesTeamAbove(User user, List<SalesTeamMember> teamMembers) {
        if (user.Reportase__c != null) {
            User nextUser = [SELECT Id, Name, Cargo__c, Reportase__c, Coordenador__c FROM User WHERE Id = :user.Reportase__c LIMIT 1];
            if (nextUser != null && !containsUser(teamMembers, nextUser.Id)) {
                teamMembers.add(new SalesTeamMember(nextUser.Id, nextUser.Name, nextUser.Cargo__c));
                buildSalesTeamAbove(nextUser, teamMembers);
            }
        }
    }

    private static void buildSalesTeamBelow(User user, List<SalesTeamMember> teamMembers) {
        List<User> subordinates = [SELECT Id, Name, Cargo__c, Reportase__c, Coordenador__c FROM User WHERE Reportase__c = :user.Id];
        for (User subordinate : subordinates) {
            if (!containsUser(teamMembers, subordinate.Id)) {
                teamMembers.add(new SalesTeamMember(subordinate.Id, subordinate.Name, subordinate.Cargo__c));
                buildSalesTeamBelow(subordinate, teamMembers);
            }
        }
    }

    private static Boolean containsUser(List<SalesTeamMember> teamMembers, Id userId) {
        for (SalesTeamMember member : teamMembers) {
            if (member.userId == userId) {
                return true;
            }
        }
        return false;
    }

    public class SalesTeamMember {
        @AuraEnabled public Id userId;
        @AuraEnabled public String userName;
        @AuraEnabled public String userCargo;

        public SalesTeamMember(Id userId, String userName, String userCargo) {
            this.userId = userId;
            this.userName = userName;
            this.userCargo = userCargo;
        }
    }
}