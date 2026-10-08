try {
    Account conta = new Account(
        Name = 'Teste Validacao Receita Negativa',
        Phone = '11987654321',
        Website = 'https://example.com',
        AnnualRevenue = -100
    );

    insert conta;
    System.debug('ERRO: a conta foi inserida, mas deveria ser bloqueada pela receita negativa.');
} catch (DmlException e) {
    System.debug('VALIDACAO FUNCIONOU: ' + e.getMessage());
}