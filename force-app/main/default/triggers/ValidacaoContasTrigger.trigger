trigger ValidacaoContasTrigger on Account (before insert, before update) {
    ValidacaoDados.validarContas(Trigger.new);
}
