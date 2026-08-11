/**
 * @description Enterprise Async Logger publishing Log_Event__e Platform Events
 * Allows exception logging without rolling back or interfering with standard database transactions.
 */
public inherited sharing class Logger {

    public static void error(String source, String message, Exception ex) {
        String stackTrace = ex != null ? ex.getStackTraceString() : '';
        String fullMessage = message + (ex != null ? ' | Exception: ' + ex.getMessage() : '');
        publishLog('ERROR', source, fullMessage, stackTrace);
    }

    public static void info(String source, String message) {
        publishLog('INFO', source, message, '');
    }

    public static void warn(String source, String message) {
        publishLog('WARN', source, message, '');
    }

    private static void publishLog(String level, String source, String message, String stackTrace) {
        Log_Event__e event = new Log_Event__e(
            Source__c = source,
            Level__c = level,
            Message__c = message,
            StackTrace__c = stackTrace
        );
        EventBus.publish(event);
    }
}
