/**
 * @description Enterprise Base Trigger Handler supporting reentrancy protection and bypass controls
 */
public virtual inherited sharing class TriggerHandler {

    private static Set<String> bypassedHandlers;

    static {
        bypassedHandlers = new Set<String>();
    }

    @TestVisible
    protected TriggerContext context;
    @TestVisible
    protected Boolean isExecuting;

    public enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE
    }

    public TriggerHandler() {
        this.setTriggerContext();
    }

    public void run() {
        if (!validateRun()) {
            return;
        }

        switch on this.context {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }

    public static void bypass(String handlerName) {
        bypassedHandlers.add(handlerName);
    }

    public static void clearBypass(String handlerName) {
        bypassedHandlers.remove(handlerName);
    }

    public static Boolean isBypassed(String handlerName) {
        return bypassedHandlers.contains(handlerName);
    }

    public static void clearAllBypasses() {
        bypassedHandlers.clear();
    }

    @TestVisible
    protected virtual void beforeInsert() {}
    @TestVisible
    protected virtual void beforeUpdate() {}
    @TestVisible
    protected virtual void beforeDelete() {}
    @TestVisible
    protected virtual void afterInsert() {}
    @TestVisible
    protected virtual void afterUpdate() {}
    @TestVisible
    protected virtual void afterDelete() {}
    @TestVisible
    protected virtual void afterUndelete() {}

    private Boolean validateRun() {
        if (!this.isExecuting) {
            return false;
        }
        String handlerName = getHandlerName();
        if (bypassedHandlers.contains(handlerName)) {
            return false;
        }
        return true;
    }

    private String getHandlerName() {
        return String.valueOf(this).split(':')[0];
    }

    @TestVisible
    private void setTriggerContext() {
        this.isExecuting = Trigger.isExecuting;
        if (!this.isExecuting) {
            return;
        }
        if (Trigger.isBefore && Trigger.isInsert) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if (Trigger.isBefore && Trigger.isUpdate) {
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if (Trigger.isBefore && Trigger.isDelete) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if (Trigger.isAfter && Trigger.isInsert) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if (Trigger.isAfter && Trigger.isUpdate) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if (Trigger.isAfter && Trigger.isDelete) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if (Trigger.isAfter && Trigger.isUndelete) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }
}
