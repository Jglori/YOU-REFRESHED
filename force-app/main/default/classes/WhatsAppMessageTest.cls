@isTest
public class WhatsAppMessageTest {

    @isTest
    static void testWhatsAppMessage() {
        // JSON de exemplo corrigido
        String jsonString = '{' +
                                '"entry":[' +
                                    '{' +
                                        '"id":"entry1",' +
                                        '"changes":[' +
                                            '{' +
                                                '"value":{' +
                                                    '"messaging_product":"whatsapp",' +
                                                    '"metadata":{' +
                                                        '"display_phone_number":"+123456789",' +
                                                        '"phone_number_id":"987654321"' +
                                                    '},' +
                                                    '"contacts":[' +
                                                        '{' +
                                                            '"profile":{' +
                                                                '"name":"John Doe"' +
                                                            '},' +
                                                            '"wa_id":"+1234567890"' +
                                                        '}' +
                                                    '],' +
                                                    '"messages":[' +
                                                        '{' +
                                                            '"context":{' +
                                                                '"fromx":"+123456789",' +
                                                                '"id":"context1"' +
                                                            '},' +
                                                            '"fromx":"+1234567890",' +
                                                            '"id":"message1",' +
                                                            '"timestamp":"1627891234",' +
                                                            '"text":{' +
                                                                '"body":"Hello, this is a test message!"' +
                                                            '},' +
                                                            '"type":"text"' +
                                                        '}' +
                                                    ']' +
                                                '},' +
                                                '"field":"messages"' +
                                            '}' +
                                        ']' +
                                    '}' +
                                ']' +
                            '}'; // Fechamento adequado do JSON

        // Deserializa o JSON para a classe WhatsAppMessage
        WhatsAppMessage msg = (WhatsAppMessage)JSON.deserialize(jsonString, WhatsAppMessage.class);
    }
}