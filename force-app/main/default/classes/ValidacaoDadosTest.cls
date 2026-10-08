@IsTest
private class ValidacaoDadosTest {

    private static String nomeUnico(String prefixo) {
        return prefixo + ' ' + String.valueOf(DateTime.now().getTime());
    }

    private static Account criarContaValida(String nome) {
        return new Account(
            Name = nome,
            Phone = '11 (98765-4321)',
            Website = '  https://example.com  ',
            AnnualRevenue = 1000
        );
    }

    private static String primeiraMensagem(Database.SaveResult resultado) {
        if (resultado == null || resultado.getErrors().isEmpty()) {
            return 'Erro de DML sem detalhes.';
        }

        return resultado.getErrors()[0].getMessage();
    }

    private static void validarInsercaoComSucesso(
        Database.SaveResult resultado
    ) {
        System.assertEquals(
            true,
            resultado.isSuccess(),
            'A insercao deveria ser concluida com sucesso. Erro: ' +
            primeiraMensagem(resultado)
        );
    }

    private static void validarInsercaoBloqueada(
        Database.SaveResult resultado,
        String trechoMensagem
    ) {
        System.assertEquals(
            false,
            resultado.isSuccess(),
            'A insercao deveria ser bloqueada.'
        );

        String mensagem = primeiraMensagem(resultado).toLowerCase();

        System.assert(
            mensagem.contains(trechoMensagem.toLowerCase()),
            'A mensagem deveria conter "' +
            trechoMensagem +
            '", mas foi: ' +
            mensagem
        );
    }

    @IsTest
    static void deveCriarContaValidaENormalizarDados() {
        Account conta = criarContaValida(
            nomeUnico('Teste Conta Valida')
        );

        Test.startTest();
        Database.SaveResult resultado = Database.insert(conta, false);
        Test.stopTest();

        validarInsercaoComSucesso(resultado);

        Account contaConsultada = [
            SELECT Name, Phone, Website, AnnualRevenue
            FROM Account
            WHERE Id = :conta.Id
            LIMIT 1
        ];

        System.assertEquals(
            '11987654321',
            contaConsultada.Phone
        );

        System.assertEquals(
            'https://example.com',
            contaConsultada.Website
        );

        System.assertEquals(
            1000,
            contaConsultada.AnnualRevenue
        );
    }

    @IsTest
    static void deveBloquearWebsiteInvalido() {
        Account conta = criarContaValida(
            nomeUnico('Teste Website Invalido')
        );

        conta.Website = 'site-invalido';

        Test.startTest();
        Database.SaveResult resultado = Database.insert(conta, false);
        Test.stopTest();

        validarInsercaoBloqueada(
            resultado,
            'site deve comecar'
        );
    }

    @IsTest
    static void deveBloquearFaturamentoNegativo() {
        Account conta = criarContaValida(
            nomeUnico('Teste Receita Negativa')
        );

        conta.AnnualRevenue = -100;

        Test.startTest();
        Database.SaveResult resultado = Database.insert(conta, false);
        Test.stopTest();

        validarInsercaoBloqueada(
            resultado,
            'faturamento anual'
        );
    }

    @IsTest
    static void deveBloquearTelefoneInvalido() {
        Account conta = criarContaValida(
            nomeUnico('Teste Telefone Invalido')
        );

        conta.Phone = '123';

        Test.startTest();
        Database.SaveResult resultado = Database.insert(conta, false);
        Test.stopTest();

        validarInsercaoBloqueada(
            resultado,
            'telefone'
        );
    }

    @IsTest
    static void deveBloquearNomesDuplicadosNoMesmoProcessamento() {
        String nome = nomeUnico('Teste Nome Duplicado');

        Account primeiraConta = criarContaValida(nome);
        Account segundaConta = criarContaValida(nome.toUpperCase());

        Test.startTest();

        List<Database.SaveResult> resultados = Database.insert(
            new List<Account>{ primeiraConta, segundaConta },
            false
        );

        Test.stopTest();

        System.assertEquals(
            2,
            resultados.size()
        );

        System.assertEquals(
            true,
            resultados[0].isSuccess(),
            'A primeira conta deveria ser inserida.'
        );

        validarInsercaoBloqueada(
            resultados[1],
            'duplicar'
        );
    }

    @IsTest
    static void deveBloquearNomeJaExistente() {
        String nome = nomeUnico('Teste Nome Ja Existente');

        Account primeiraConta = criarContaValida(nome);
        Account segundaConta = criarContaValida(nome.toUpperCase());

        Test.startTest();

        Database.SaveResult primeiroResultado = Database.insert(
            primeiraConta,
            false
        );

        Database.SaveResult segundoResultado = Database.insert(
            segundaConta,
            false
        );

        Test.stopTest();

        validarInsercaoComSucesso(primeiroResultado);

        validarInsercaoBloqueada(
            segundoResultado,
            'ja existe'
        );
    }

    @IsTest
    static void deveBloquearCnpjComQuantidadeInvalidaDeDigitos() {
        Account conta = criarContaValida(
            nomeUnico('Teste CNPJ Invalido')
        );

        conta.CNPJ__c = '12.345.678/0001-9';

        Test.startTest();
        Database.SaveResult resultado = Database.insert(conta, false);
        Test.stopTest();

        validarInsercaoBloqueada(
            resultado,
            'cnpj'
        );
    }

    @IsTest
    static void deveBloquearEmailInvalido() {
        Account conta = criarContaValida(
            nomeUnico('Teste Email Invalido')
        );

        conta.Email__c = 'email-invalido';

        Test.startTest();
        Database.SaveResult resultado = Database.insert(conta, false);
        Test.stopTest();

        System.assertEquals(
            false,
            resultado.isSuccess(),
            'O e-mail invalido deveria ser bloqueado.'
        );

        String mensagem = primeiraMensagem(resultado).toLowerCase();

        System.assert(
            mensagem.contains('email') ||
            mensagem.contains('e-mail'),
            'A mensagem deveria informar que o e-mail e invalido. Mensagem: ' +
            mensagem
        );
    }

    @IsTest
    static void deveAceitarCamposCnpjEEmailVazios() {
        Account conta = criarContaValida(
            nomeUnico('Teste Campos Vazios')
        );

        conta.CNPJ__c = null;
        conta.Email__c = null;

        Test.startTest();
        Database.SaveResult resultado = Database.insert(conta, false);
        Test.stopTest();

        validarInsercaoComSucesso(resultado);
    }

    @IsTest
    static void deveNormalizarCnpjEEmail() {
        Account conta = criarContaValida(
            nomeUnico('Teste CNPJ Email')
        );

        conta.CNPJ__c = '11.222.333/0001-81';
        conta.Email__c = 'TESTE@EXAMPLE.COM';

        Test.startTest();
        Database.SaveResult resultado = Database.insert(conta, false);
        Test.stopTest();

        validarInsercaoComSucesso(resultado);

        Account contaConsultada = [
            SELECT CNPJ__c, Email__c
            FROM Account
            WHERE Id = :conta.Id
            LIMIT 1
        ];

        System.assertEquals(
            '11222333000181',
            contaConsultada.CNPJ__c
        );

        System.assertEquals(
            'teste@example.com',
            contaConsultada.Email__c
        );
    }
}