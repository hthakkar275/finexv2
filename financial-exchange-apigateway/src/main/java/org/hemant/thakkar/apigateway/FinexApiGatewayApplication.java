package org.hemant.thakkar.apigateway;

import org.hemant.thakkar.apigateway.filters.ErrorFilter;
import org.hemant.thakkar.apigateway.filters.PostFilter;
import org.hemant.thakkar.apigateway.filters.PreFilter;
import org.hemant.thakkar.apigateway.filters.RouteFilter;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.zuul.EnableZuulProxy;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
@EnableZuulProxy
@EnableDiscoveryClient
public class FinexApiGatewayApplication {

	public static void main(String[] args) {
		SpringApplication.run(FinexApiGatewayApplication.class, args);
	}

    @Bean
    public PreFilter preFilter() {
        return new PreFilter();
    }
    
    @Bean
    public PostFilter postFilter() {
        return new PostFilter();
    }
    @Bean
    public ErrorFilter errorFilter() {
        return new ErrorFilter();
    }
    @Bean
    public RouteFilter routeFilter() {
        return new RouteFilter();
    }
}
