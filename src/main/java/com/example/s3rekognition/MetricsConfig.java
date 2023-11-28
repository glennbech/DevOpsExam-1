package com.example.s3rekognition;

import io.micrometer.cloudwatch2.CloudWatchConfig;
import io.micrometer.cloudwatch2.CloudWatchMeterRegistry;
import io.micrometer.core.instrument.Clock;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.cloudwatch.CloudWatchAsyncClient;

import java.util.Map;

@Configuration
public class MetricsConfig {

    //new check
    private final String  cloudWatchNameSpace = "2010namespace";
    private final boolean cloudWatchEnabled = true;


    @Bean
    public CloudWatchAsyncClient cloudWatchAsyncClient() {
        return CloudWatchAsyncClient.builder().region(Region.EU_WEST_1)
                .build();
    }

    @Bean
    public MeterRegistry getMeterRegistry() {
        return
                new CloudWatchMeterRegistry(
                        setupCloudWatchConfig(),
                        Clock.SYSTEM,
                        cloudWatchAsyncClient());
    }

    private CloudWatchConfig setupCloudWatchConfig() {
        return new CloudWatchConfig() {
            private final Map<String, String> configuration = Map.of(
                    "cloudwatch.namespace", cloudWatchNameSpace,
                    "cloudwatch.enabled", String.valueOf(cloudWatchEnabled)
            );

            @Override
            public String get(String key) {
                return configuration.get(key);
            }
        };
    }
}