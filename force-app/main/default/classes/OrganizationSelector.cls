public without sharing class OrganizationSelector {
    public static Organization obterNomeOrganizacao() {
        return [SELECT Name FROM Organization LIMIT 1];
    }
}