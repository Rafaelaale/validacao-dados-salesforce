public class AccountTriggerhandller {
    public static void run(
        Boolean isBefore,
        Boolean isAfter,
        Boolean isUpdate,
        List<Account> newAccountList,
        Map<Id, Account> oldAccountMap
    ) {
        if (isBefore && !isUpdate) {
            onebeforeInsert(newAccountList, null);
        }

        if (isBefore && isUpdate) {
            onebeforeUpdate(newAccountList, oldAccountMap);
        }
    }

    public static void onebeforeInsert(
        List<Account> newAccountList,
        Map<Id, Account> newAccountMap
    ) {
        for (Account newAccount : newAccountList) {
            if (String.isBlank(newAccount.Phone)) {
                newAccount.addError('por favor informar o telefone');
            } else if (newAccount.Phone.length() < 11) {
                newAccount.addError('por favor informar o telefone com o DDD');
            }
        }
    }

    public static void onebeforeUpdate(
        List<Account> newAccountList,
        Map<Id, Account> oldAccountMap
    ) {
        for (Account newAccount : newAccountList) {
            if (String.isBlank(newAccount.Phone)) {
                newAccount.addError('por favor informar o telefone');
            } else if (newAccount.Phone.length() < 11) {
                newAccount.addError('por favor informar o telefone com o DDD');
            }
        }
    }
}