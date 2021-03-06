package org.hemant.thakkar.financialexchange.orderbooks.domain;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class OrderBookEntry {

	private long orderId;
	private Side side;
	private int quantity;
	private OrderType type;
	private BigDecimal price;
	private long productId;
	private LocalDateTime entryTime;
	
	public long getOrderId() {
		return orderId;
	}
	public void setOrderId(long orderId) {
		this.orderId = orderId;
	}
	public Side getSide() {
		return side;
	}
	public void setSide(Side side) {
		this.side = side;
	}
	public int getQuantity() {
		return quantity;
	}
	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}
	public BigDecimal getPrice() {
		return price;
	}
	public void setPrice(BigDecimal price) {
		this.price = price;
	}
	public OrderType getType() {
		return type;
	}
	public void setType(OrderType type) {
		this.type = type;
	}
	public long getProductId() {
		return productId;
	}
	public void setProductId(long productId) {
		this.productId = productId;
	}
	public LocalDateTime getEntryTime() {
		return entryTime;
	}
	public void setEntryTime(LocalDateTime entryTime) {
		this.entryTime = entryTime;
	}
	
	public String toString() {
		StringBuffer message = new StringBuffer();
		message.append(" orderId = ").append(this.getOrderId()).append(";");
		message.append(" quantity = ").append(this.getQuantity()).append(";");
		message.append(" side = ").append(this.getSide()).append(";");
		message.append(" qty = ").append(this.getQuantity()).append(";");
		message.append(" price = ").append(this.getPrice());
		return message.toString();
	}

}
