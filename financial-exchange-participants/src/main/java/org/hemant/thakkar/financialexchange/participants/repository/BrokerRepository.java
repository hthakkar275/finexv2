package org.hemant.thakkar.financialexchange.participants.repository;

import java.util.Optional;

import org.hemant.thakkar.financialexchange.participants.domain.Broker;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BrokerRepository extends JpaRepository<Broker, Long> {

	public Optional<Broker> findByName(String name);

}
