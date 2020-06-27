package org.hemant.thakkar.financialexchange.trades.repository;

import java.util.List;

import org.hemant.thakkar.financialexchange.trades.domain.Trade;
import org.hemant.thakkar.financialexchange.trades.domain.TradeImpl;

public interface TradeRepository {
	long saveTrade(TradeImpl trade);
	boolean deleteTrade(long tradeId);
	Trade getTrade(long tradeId);
	List<Trade> getTrades(long orderId);
}

