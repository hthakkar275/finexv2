package org.hemant.thakkar.financialexchange.trades.service;

import java.util.List;

import org.hemant.thakkar.financialexchange.trades.domain.ExchangeException;
import org.hemant.thakkar.financialexchange.trades.domain.TradeEntry;
import org.hemant.thakkar.financialexchange.trades.domain.TradeReport;

public interface TradeManagementService {
	long acceptTrade(TradeEntry tradeEntry) throws ExchangeException;
	void bustTrade(long tradeId) throws ExchangeException;
	TradeReport getTrade(long tradeId) throws ExchangeException;
	List<TradeReport> getTradesForOrder(long orderId) throws ExchangeException;
}

