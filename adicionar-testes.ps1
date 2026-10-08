$arquivo = "force-app\main\default\classes\ValidacaoDadosTest.cls"
$texto = [System.IO.File]::ReadAllText((Resolve-Path $arquivo))

$novosTestes = @'
    @IsTest
    static void deveNormalizarCnpjEEmail() {
        Account conta = criarContaValida('Teste CNPJ Email ' + DateTime.now().getTime());
        conta.CNPJ__c = '11.222.333/0001-81';
        conta.Email__c = 'TESTE@EXAMPLE.COM';

        Test.startTest();
        insert conta;
        Test.stopTest();

        Account contaConsultada = [
            SELECT CNPJ__c, Email__c
            FROM Account
            WHERE Id = :conta.Id
        ];

        System.assertEquals('11222333000181', contaConsultada.CNPJ__c);
        System.assertEquals('teste@example.com', contaConsultada.Email__c);
    }

    @IsTest
    static void deveBloquearCnpjComQuantidadeInvalidaDeDigitos() {
        Account conta = criarContaValida('Teste CNPJ Invalido ' + DateTime.now().getTime());
        conta.CNPJ__c = '12.345.678/0001-9';
        conta.Email__c = 'teste@example.com';

        Test.startTest();
        Database.SaveResult resultado = Database.insert(conta, false);
        Test.stopTest();

        System.assertEquals(false, resultado.isSuccess());
        System.assert(
            resultado.getErrors()[0].getMessage().contains('CNPJ'),
            'O CNPJ com quantidade invalida de digitos deveria ser bloqueado.'
        );
    }

    @IsTest
    static void deveBloquearEmailInvalido() {
        Account conta = criarContaValida('Teste Email Invalido ' + DateTime.now().getTime());
        conta.CNPJ__c = '11222333000181';
        conta.Email__c = 'email-invalido';

        Test.startTest();
        Database.SaveResult resultado = Database.insert(conta, false);
        Test.stopTest();

        System.assertEquals(false, resultado.isSuccess());
        System.assert(
            resultado.getErrors()[0].getMessage().contains('e-mail'),
            'O e-mail invalido deveria ser bloqueado.'
        );
    }

    @IsTest
    static void deveAceitarCamposCnpjEEmailVazios() {
        Account conta = criarContaValida('Teste Campos Vazios ' + DateTime.now().getTime());

        Test.startTest();
        insert conta;
        Test.stopTest();

        System.assertNotEquals(null, conta.Id);
    }
'@

$posicao = $texto.LastIndexOf('}')
if ($posicao -lt 0) {
    throw "Chave final da classe nao encontrada. O arquivo nao foi alterado."
}

$texto = $texto.Insert($posicao, "`r`n" + $novosTestes + "`r`n")

[System.IO.File]::WriteAllText(
    (Resolve-Path $arquivo),
    $texto,
    [System.Text.UTF8Encoding]::new($false)
)