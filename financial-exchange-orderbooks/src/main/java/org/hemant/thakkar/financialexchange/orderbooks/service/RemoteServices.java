package org.hemant.thakkar.financialexchange.orderbooks.service;

import java.time.LocalDateTime;

import org.hemant.thakkar.financialexchange.orderbooks.domain.TradeEntry;

public interface RemoteServices {

	boolean saveTrade(TradeEntry tradeEntry);
	boolean orderTradedQuantity(long orderId, LocalDateTime tradeTime, int tradedQuantity);
	boolean orderBookedQuantity(long orderId, int bookedQuantity, LocalDateTime bookedTime);
	boolean orderCancelledQuantity(long orderId, int bookedQuantity, LocalDateTime bookedTime);
	boolean updateOrders(TradeEntry tradeEntry);
	String getProductSymbol(long productId);

}
