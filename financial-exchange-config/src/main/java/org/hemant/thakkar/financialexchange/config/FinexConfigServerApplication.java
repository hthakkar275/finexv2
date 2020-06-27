package org.hemant.thakkar.financialexchange.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;

@SpringBootApplication
@EnableConfigServer
public class FinexConfigServerApplication {

	public static void main(String[] args) {
		SpringApplication.run(FinexConfigServerApplication.class, args);
	}

}
