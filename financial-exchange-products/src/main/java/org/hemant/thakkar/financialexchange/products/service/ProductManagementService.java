package org.hemant.thakkar.financialexchange.products.service;

import org.hemant.thakkar.financialexchange.products.domain.ExchangeException;
import org.hemant.thakkar.financialexchange.products.domain.Product;
import org.hemant.thakkar.financialexchange.products.domain.ProductEntry;

public interface ProductManagementService {
	long addProduct(ProductEntry productEntry) throws ExchangeException;
	Product getProduct(String symbol) throws ExchangeException;
	Product getProduct(long productId) throws ExchangeException;
	void deleteProduct(long productId) throws ExchangeException;
	Product updateProduct(long productId, ProductEntry productEntry) throws ExchangeException;
}

