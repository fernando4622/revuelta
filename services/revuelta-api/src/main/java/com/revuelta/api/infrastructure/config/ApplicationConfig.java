package com.revuelta.api.infrastructure.config;

import com.revuelta.api.application.auth.LoginUseCase;
import com.revuelta.api.application.circulation.DeliverContainerUseCase;
import com.revuelta.api.application.circulation.ReturnContainerUseCase;
import com.revuelta.api.application.container.ActivateContainerUseCase;
import com.revuelta.api.application.container.GetContainerHistoryUseCase;
import com.revuelta.api.application.container.GetContainerUseCase;
import com.revuelta.api.application.container.ListContainersUseCase;
import com.revuelta.api.application.container.RegisterContainerUseCase;
import com.revuelta.api.application.port.AccessTokenIssuerPort;
import com.revuelta.api.application.port.AuthenticationAuditPort;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.CorrelationIdProviderPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.PasswordVerifierPort;
import com.revuelta.api.application.port.ReturnPolicyRepositoryPort;
import com.revuelta.api.application.port.ServerClockPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.application.port.UserRepositoryPort;
import com.revuelta.api.application.port.OperationQrTokenRepositoryPort;
import com.revuelta.api.application.port.ParticipantRepositoryPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.application.qr.GenerateOperationQrUseCase;
import com.revuelta.api.application.qr.GetContainerQrUseCase;
import com.revuelta.api.application.qr.ResolveContainerQrUseCase;
import com.revuelta.api.application.qr.ResolveOperationQrUseCase;
import com.revuelta.api.application.qr.RotateContainerQrUseCase;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;

@Configuration
public class ApplicationConfig {

    @Bean
    public LoginUseCase loginUseCase(
            UserRepositoryPort userRepository,
            PasswordVerifierPort passwordVerifier,
            AccessTokenIssuerPort tokenIssuer,
            AuthenticationAuditPort authenticationAudit
    ) {
        return new LoginUseCase(userRepository, passwordVerifier, tokenIssuer, authenticationAudit);
    }

    @Bean
    public DeliverContainerUseCase deliverContainerUseCase(
            ContainerRepositoryPort containerRepository,
            CirculationRepositoryPort circulationRepository,
            UserRepositoryPort userRepository,
            ReturnPolicyRepositoryPort policyRepository,
            ContainerEventRepositoryPort eventRepository,
            TransactionRunnerPort transactionRunner,
            ServerClockPort clock,
            CorrelationIdProviderPort correlationIds
    ) {
        return new DeliverContainerUseCase(
                containerRepository,
                circulationRepository,
                userRepository,
                policyRepository,
                eventRepository,
                transactionRunner,
                clock,
                correlationIds
        );
    }

    @Bean
    public ReturnContainerUseCase returnContainerUseCase(
            ContainerRepositoryPort containerRepository,
            CirculationRepositoryPort circulationRepository,
            ContainerEventRepositoryPort eventRepository,
            TransactionRunnerPort transactionRunner,
            ServerClockPort clock,
            CorrelationIdProviderPort correlationIds
    ) {
        return new ReturnContainerUseCase(
                containerRepository,
                circulationRepository,
                eventRepository,
                transactionRunner,
                clock,
                correlationIds
        );
    }

    @Bean
    public ActivateContainerUseCase activateContainerUseCase(
            ContainerRepositoryPort containerRepository,
            ContainerEventRepositoryPort eventRepository,
            TransactionRunnerPort transactionRunner,
            ServerClockPort clock,
            CorrelationIdProviderPort correlationIds
    ) {
        return new ActivateContainerUseCase(
                containerRepository,
                eventRepository,
                transactionRunner,
                clock,
                correlationIds
        );
    }

    @Bean
    public RegisterContainerUseCase registerContainerUseCase(
            ContainerRepositoryPort containerRepository,
            TransactionRunnerPort transactionRunner,
            ServerClockPort clock,
            ContainerEventRepositoryPort eventRepository,
            CorrelationIdProviderPort correlationIds,
            QrPayloadCodecPort qrCodec
    ) {
        return new RegisterContainerUseCase(
                containerRepository, transactionRunner, clock, eventRepository, correlationIds, qrCodec
        );
    }

    @Bean
    public GetContainerHistoryUseCase getContainerHistoryUseCase(ContainerEventRepositoryPort eventRepository) {
        return new GetContainerHistoryUseCase(eventRepository);
    }

    @Bean
    public GetContainerUseCase getContainerUseCase(ContainerRepositoryPort containerRepository) {
        return new GetContainerUseCase(containerRepository);
    }

    @Bean
    public ListContainersUseCase listContainersUseCase(ContainerRepositoryPort containerRepository) {
        return new ListContainersUseCase(containerRepository);
    }

    @Bean
    public GenerateOperationQrUseCase generateOperationQrUseCase(
            ParticipantRepositoryPort participants,
            OperationQrTokenRepositoryPort tokens,
            QrPayloadCodecPort qrCodec,
            TransactionRunnerPort transactions,
            ServerClockPort clock,
            @Value("${qr.operation-ttl-seconds:120}") long ttlSeconds
    ) {
        return new GenerateOperationQrUseCase(
                participants, tokens, qrCodec, transactions, clock, Duration.ofSeconds(ttlSeconds)
        );
    }

    @Bean
    public ResolveOperationQrUseCase resolveOperationQrUseCase(
            OperationQrTokenRepositoryPort tokens,
            ParticipantRepositoryPort participants,
            QrPayloadCodecPort qrCodec,
            ServerClockPort clock
    ) {
        return new ResolveOperationQrUseCase(tokens, participants, qrCodec, clock);
    }

    @Bean
    public ResolveContainerQrUseCase resolveContainerQrUseCase(
            ContainerRepositoryPort containers,
            CirculationRepositoryPort circulations,
            QrPayloadCodecPort qrCodec
    ) {
        return new ResolveContainerQrUseCase(containers, circulations, qrCodec);
    }

    @Bean
    public GetContainerQrUseCase getContainerQrUseCase(
            ContainerRepositoryPort containers,
            QrPayloadCodecPort qrCodec
    ) {
        return new GetContainerQrUseCase(containers, qrCodec);
    }

    @Bean
    public RotateContainerQrUseCase rotateContainerQrUseCase(
            ContainerRepositoryPort containers,
            ContainerEventRepositoryPort events,
            QrPayloadCodecPort qrCodec,
            TransactionRunnerPort transactions,
            ServerClockPort clock,
            CorrelationIdProviderPort correlationIds
    ) {
        return new RotateContainerQrUseCase(
                containers, events, qrCodec, transactions, clock, correlationIds
        );
    }
}
