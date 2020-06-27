package org.hemant.thakkar.financialexchange.orders.repository;

import java.util.List;

import org.hemant.thakkar.financialexchange.orders.domain.Order;
import org.hemant.thakkar.financialexchange.orders.domain.OrderImpl;

public interface OrderRepository {
	long saveOrder(OrderImpl order);
	boolean deleteOrder(long orderId);
	Order getOrder(long orderId);
	List<Order> getOrdersByProduct(long productId);
	List<Order> getOrdersByParticipant(long participantId);
	int getCount();
}

