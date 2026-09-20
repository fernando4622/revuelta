package com.revuelta.api.infrastructure.persistence;

import com.revuelta.api.application.port.TransactionRunnerPort;
import java.util.function.Supplier;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

@Component
public class SpringTransactionRunnerAdapter implements TransactionRunnerPort {

    private final TransactionTemplate transactionTemplate;

    public SpringTransactionRunnerAdapter(PlatformTransactionManager transactionManager) {
        this.transactionTemplate = new TransactionTemplate(transactionManager);
    }

    @Override
    public <T> T required(Supplier<T> operation) {
        return transactionTemplate.execute(status -> operation.get());
    }
}
