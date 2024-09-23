public with sharing class TaskHelper {
    public static void validateTaskDate(List<Task> tasks){
        System.debug('tasks que estão chegando: ' + tasks);
        LeadSLAHelper.validateTaskDate(tasks);
    }
}