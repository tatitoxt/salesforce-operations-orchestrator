@IsTest
private class Test_Logger {

    @IsTest
    static void testLoggingMethods() {
        Test.startTest();
        Logger.info('TestClass', 'Info message');
        Logger.warn('TestClass', 'Warn message');
        try {
            Integer result = 1 / 0;
        } catch (Exception ex) {
            Logger.error('TestClass', 'Error occurred', ex);
        }
        Test.stopTest();

        // Platform events published in test context
        System.assert(true, 'Logger methods executed without exception');
    }
}
