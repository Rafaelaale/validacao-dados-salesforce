# Validação de Dados de Contas no Salesforce

Trigger e classe Apex que validam e padronizam os dados de **Contas (Account)** antes de salvar, evitando cadastros duplicados ou inconsistentes.

## Problema que resolve

Cadastros de contas com nome repetido, telefone fora do padrão, e-mail ou CNPJ inválidos geram retrabalho e dados sujos no CRM. Este projeto bloqueia o que está errado e deixa o que está certo no mesmo formato.

## Como funciona

```
Account (before insert / before update)
   -> ValidacaoContasTrigger
   -> ValidacaoDados.validarContas(Trigger.new)
   -> cada regra adiciona um erro à conta, ou normaliza o campo
```

A trigger só chama a classe. Toda a regra de negócio fica em `ValidacaoDados`.

## Regras implementadas

| Campo | Regra |
|---|---|
| Nome | Não pode repetir dentro do mesmo lote nem coincidir com uma conta já existente. A comparação ignora espaços nas pontas e maiúsculas. |
| Telefone | Aceita 10 ou 11 dígitos. Remove a máscara e grava só os números. |
| Website | Deve começar com `http://` ou `https://`. |
| Faturamento anual | Não pode ser negativo. |
| CNPJ (`CNPJ__c`) | Remove a máscara e exige 14 dígitos. |
| E-mail (`Email__c`) | Valida o formato e grava em minúsculas. |

## Boas práticas aplicadas

- Trigger enxuta, com a lógica numa classe separada.
- Uma única consulta SOQL por execução, fora de qualquer loop (segura para cargas em lote).
- Mensagens de erro claras, associadas à conta que falhou.
- Testes automatizados em `ValidacaoDadosTest`.

## Tecnologias

Apex · Apex Trigger · SOQL · expressões regulares (`Pattern`) · Apex Test Classes

## Como usar

Faça o deploy para a sua org e rode os testes:

```
sf project deploy start --source-dir force-app --target-org <alias-da-org>
sf apex run test --class-names ValidacaoDadosTest --target-org <alias-da-org> --result-format human --wait 10
```

Os campos personalizados `CNPJ__c` e `Email__c` precisam existir no objeto Account da org de destino.

## Possíveis melhorias

- Validar os dígitos verificadores do CNPJ, e não só a quantidade de dígitos.
- Mover a lista de regras para metadados customizados, para ligar e desligar regras sem deploy.
