public class MetaphoneService {
    public List<String> buscaFoneticamente(String palavra, List<String> nomes) {
        List<String> resultado = new List<String>();
        
        System.debug('Palavra: ' + palavra);
        System.debug('Nomes: ' + nomes);
        
        String palavraCodificada = encodeMetaphone(palavra);
        System.debug('Palavra codificada: ' + palavraCodificada);
        
        for (String nome : nomes) {
            String nomeCodificado = encodeMetaphone(nome);
            System.debug('Nome: ' + nome + ', Codificado: ' + nomeCodificado);
            if (palavraCodificada.equals(nomeCodificado)) {
                resultado.add(nome);
            }
        }
        
        return resultado;
    }
    
    private String encodeMetaphone(String input) {
        input = input.toUpperCase().replaceAll('[^A-Z]', '');
        String metaphone = '';

        for (Integer i = 0; i < input.length(); i++) {
            String c = input.substring(i, i + 1);

            switch on c {
                when 'A', 'E', 'I', 'O', 'U' {
                    if (i == 0) {
                        metaphone += c; // Inclui apenas a primeira vogal
                    }
                }
                when 'B' {
                    if (i == 0 || input.substring(i - 1, i) != 'B') {
                        metaphone += 'B';
                    }
                }
                when 'C' {
                    if (i < input.length() - 1 && input.substring(i + 1, i + 2) == 'H') {
                        metaphone += 'X';
                        i++;
                    } else if (i < input.length() - 1 && 'EI'.contains(input.substring(i + 1, i + 2))) {
                        metaphone += 'S';
                    } else {
                        metaphone += 'K';
                    }
                }
                when 'D' {
                    if (i < input.length() - 1 && input.substring(i + 1, i + 2) == 'G') {
                        metaphone += 'J';
                        i++;
                    } else {
                        metaphone += 'T';
                    }
                }
                when 'F' {
                    metaphone += 'F';
                }
                when 'G' {
                    if (i < input.length() - 1 && 'EI'.contains(input.substring(i + 1, i + 2))) {
                        metaphone += 'J';
                    } else {
                        metaphone += 'G';
                    }
                }
                when 'J' {
                    metaphone += 'J';
                }
                when 'K' {
                    metaphone += 'K';
                }
                when 'L' {
                    metaphone += 'L';
                }
                when 'M' {
                    metaphone += 'M';
                }
                when 'N' {
                    metaphone += 'N';
                }
                when 'P' {
                    if (i < input.length() - 1 && input.substring(i + 1, i + 2) == 'H') {
                        metaphone += 'F';
                        i++;
                    } else {
                        metaphone += 'P';
                    }
                }
                when 'Q' {
                    metaphone += 'K';
                }
                when 'R' {
                    metaphone += 'R';
                }
                when 'S' {
                    if (i < input.length() - 1 && input.substring(i + 1, i + 2) == 'H') {
                        metaphone += 'X';
                        i++;
                    } else {
                        metaphone += 'S';
                    }
                }
                when 'T' {
                    if (i < input.length() - 1 && input.substring(i + 1, i + 2) == 'H') {
                        metaphone += 'T';
                    } else {
                        metaphone += 'T';
                    }
                }
                when 'V' {
                    metaphone += 'V';
                }
                when 'X' {
                    metaphone += 'KS';
                }
                when 'Z' {
                    metaphone += 'S';
                }
                when else {
                }
            }
        }

        return metaphone.length() > 4 ? metaphone.substring(0, 4) : metaphone;
    }
}