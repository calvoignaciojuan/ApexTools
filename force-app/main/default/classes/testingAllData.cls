
@isTest
private class testingAllData {
        @isTest(SeeAllData=true)
        static void testMethodWithRealData() {
            system.debug('User: ' + [SELECT Id FROM User ].size());
            //delete new Account(Id='001Hn00002A1kFXIAZ', Name = 'Juan');
            //system.debug([SELECT Id FROM Account ].size());
        }
}
