package org.hemant.thakkar.financialexchange.orders.domain;

public enum OrderStatus {
	NEW,
	BOOKED,
	PARTIALLY_BOOKED_FILLED,
	PARTIALLY_FILLED,
	NOT_FILLED,
	FILLED,
	CANCELLED,
	PARTIALLY_CANCELLED,
	REJECTED,
	UNKNOWN
} 
