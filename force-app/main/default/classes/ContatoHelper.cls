public with sharing class ContatoHelper{

     public static Boolean validarCPF(String cpf) {
        cpf = cpf.replaceAll('[^0-9]', '');
    
        if (cpf.length() == 11) {
   

       if (cpf == '00000000000' || cpf == '11111111111' || cpf == '22222222222' ||
       cpf == '33333333333' || cpf == '44444444444' || cpf == '55555555555' ||
       cpf == '66666666666' || cpf == '77777777777' || cpf == '88888888888' ||
       cpf == '99999999999') {
       return false;
       }

          
        Integer soma = 0;
        for (Integer i = 0; i < 9; i++) {
            soma += Integer.valueOf(cpf.substring(i, i+1)) * (10 - i);
        }
        Integer primeiroDigito = 11 - Math.mod(soma, 11);
        if (primeiroDigito == 10 || primeiroDigito == 11) {
            primeiroDigito = 0;
        }
        
        if (primeiroDigito != Integer.valueOf(cpf.substring(9, 10))) {
            return false;
        }
        
        soma = 0;
        for (Integer i = 0; i < 10; i++) {
            soma += Integer.valueOf(cpf.substring(i, i+1)) * (11 - i);
        }
        Integer segundoDigito = 11 - Math.mod(soma, 11);
        if (segundoDigito == 10 || segundoDigito == 11) {
            segundoDigito = 0;
        }
        
        if (segundoDigito != Integer.valueOf(cpf.substring(10, 11))) {
            return false;
        }
        
        return true;
       } else {
       
            return false;
        }
       
      }
}