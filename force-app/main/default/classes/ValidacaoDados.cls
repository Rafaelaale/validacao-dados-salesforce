public with sharing class ValidacaoDados {

    public static void validarContas(List<Account> contas) {
        Set<String> nomesNormalizados = new Set<String>();
        Map<String, Account> contasPorNome = new Map<String, Account>();

        for (Account conta : contas) {
            if (String.isBlank(conta.Name)) {
                conta.addError('O nome da conta e obrigatorio.');
                continue;
            }

            String nomeNormalizado = conta.Name.trim().toLowerCase();

            if (nomesNormalizados.contains(nomeNormalizado)) {
                conta.addError('Nao e permitido duplicar o nome da conta no mesmo processamento.');
            } else {
                nomesNormalizados.add(nomeNormalizado);
                contasPorNome.put(nomeNormalizado, conta);
            }

            validarTelefone(conta);
            validarWebsite(conta);
            validarFaturamento(conta);
            validarCnpj(conta);
            validarEmail(conta);
        }

        if (nomesNormalizados.isEmpty()) {
            return;
        }

        List<Account> contasExistentes = [
            SELECT Id, Name
            FROM Account
            WHERE Name IN :contasPorNome.keySet()
        ];

        for (Account contaExistente : contasExistentes) {
            String nomeExistente = contaExistente.Name == null
                ? null
                : contaExistente.Name.trim().toLowerCase();

            if (nomeExistente == null || !contasPorNome.containsKey(nomeExistente)) {
                continue;
            }

            Account contaAtual = contasPorNome.get(nomeExistente);

            if (contaAtual.Id == null || contaAtual.Id != contaExistente.Id) {
                contaAtual.addError('Ja existe uma conta cadastrada com este nome.');
            }
        }
    }

    private static void validarTelefone(Account conta) {
        if (String.isBlank(conta.Phone)) {
            return;
        }

        String telefone = conta.Phone.replaceAll('[^0-9]', '');

        if (telefone.length() != 10 && telefone.length() != 11) {
            conta.addError('O telefone informado e invalido.');
        } else {
            conta.Phone = telefone;
        }
    }

    private static void validarWebsite(Account conta) {
        if (String.isBlank(conta.Website)) {
            return;
        }

        String website = conta.Website.trim();

        if (!website.toLowerCase().startsWith('http://')
            && !website.toLowerCase().startsWith('https://')) {
            conta.addError('O site deve comecar com http:// ou https://.');
        } else {
            conta.Website = website;
        }
    }

    private static void validarFaturamento(Account conta) {
        if (conta.AnnualRevenue != null && conta.AnnualRevenue < 0) {
            conta.addError('O faturamento anual nao pode ser negativo.');
        }
    }

    private static void validarCnpj(Account conta) {
        if (String.isBlank(conta.CNPJ__c)) {
            return;
        }

        String cnpj = conta.CNPJ__c.replaceAll('[^0-9]', '');

        if (cnpj.length() != 14) {
            conta.addError('O CNPJ informado e invalido.');
        } else {
            conta.CNPJ__c = cnpj;
        }
    }

    private static void validarEmail(Account conta) {
        if (String.isBlank(conta.Email__c)) {
            return;
        }

        String email = conta.Email__c.trim().toLowerCase();

        Boolean emailValido = Pattern.matches(
            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$',
            email
        );

        if (!emailValido) {
            conta.addError('O e-mail informado e invalido.');
        } else {
            conta.Email__c = email;
        }
    }
}