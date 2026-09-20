package com.revuelta.api.infrastructure.persistence;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;

@ExtendWith(MockitoExtension.class)
class SpringTransactionRunnerAdapterTest {

    @Mock private PlatformTransactionManager transactionManager;
    @Mock private TransactionStatus transactionStatus;

    private SpringTransactionRunnerAdapter transactionRunner;

    @BeforeEach
    void setUp() {
        when(transactionManager.getTransaction(any())).thenReturn(transactionStatus);
        transactionRunner = new SpringTransactionRunnerAdapter(transactionManager);
    }

    @Test
    void shouldCommitSuccessfulOperation() {
        String result = transactionRunner.required(() -> "completed");

        assertEquals("completed", result);
        verify(transactionManager).commit(transactionStatus);
    }

    @Test
    void shouldRollbackFailedOperation() {
        IllegalStateException failure = new IllegalStateException("operation failed");

        IllegalStateException thrown = assertThrows(
                IllegalStateException.class,
                () -> transactionRunner.required(() -> {
                    throw failure;
                })
        );

        assertEquals(failure, thrown);
        verify(transactionManager).rollback(transactionStatus);
    }
}
