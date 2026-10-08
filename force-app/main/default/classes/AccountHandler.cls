public class AccountHandler {

    public static void handleBeforeInsert(List<Account> accList) {
        for (Account acc : accList) {
            if (String.isBlank(acc.Phone)) {
                acc.addError('Por favor, informar o telefone.');
            }
        }
    }
}