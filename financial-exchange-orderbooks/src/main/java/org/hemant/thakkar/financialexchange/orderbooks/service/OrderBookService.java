package org.hemant.thakkar.financialexchange.orderbooks.service;

import org.hemant.thakkar.financialexchange.orderbooks.domain.ExchangeException;
import org.hemant.thakkar.financialexchange.orderbooks.domain.OrderBookEntry;
import org.hemant.thakkar.financialexchange.orderbooks.domain.OrderBookState;

public interface OrderBookService {
	OrderBook getOrderBook(long productId) throws ExchangeException;
	void deleteOrderBook(long productId);
	void addOrder(OrderBookEntry orderBookEntry) throws ExchangeException;
	void cancelOrder(long productId, long orderId) throws ExchangeException;
	OrderBookState getOrderBookMontage(long productId);
}

