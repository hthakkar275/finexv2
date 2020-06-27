package org.hemant.thakkar.financialexchange.products.repository;

import java.util.Optional;

import org.hemant.thakkar.financialexchange.products.domain.Equity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EquityRepository  extends JpaRepository<Equity, Long> {
	public Optional<Equity> findBySymbol(String symbol);
}
