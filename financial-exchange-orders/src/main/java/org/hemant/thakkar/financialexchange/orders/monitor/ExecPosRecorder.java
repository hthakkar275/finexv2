package org.hemant.thakkar.financialexchange.orders.monitor;

public interface ExecPosRecorder {
	void recordExecutionPoint(String className, String methodSignature, long id, String entryExit);
}
