public class EmailManager {

    public static void sendMail(String address, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{ address });
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        
        inspectResults(results);
    }
    
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) System.debug('Email enviado com sucesso!');
            else {
                sendResult = false;
                System.debug('Houve os seguinte erros: '+ res.getErrors());
            }
        }
        return sendResult;
    }
}