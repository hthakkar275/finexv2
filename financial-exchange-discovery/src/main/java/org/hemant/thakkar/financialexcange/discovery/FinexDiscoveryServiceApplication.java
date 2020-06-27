package org.hemant.thakkar.financialexcange.discovery;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@EnableEurekaServer
@SpringBootApplication
public class FinexDiscoveryServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(FinexDiscoveryServiceApplication.class, args);
	}

}
