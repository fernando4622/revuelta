package com.revuelta.api.support;

import com.revuelta.api.application.port.TransactionRunnerPort;
import java.util.function.Supplier;

public final class ImmediateTransactionRunner implements TransactionRunnerPort {

    @Override
    public <T> T required(Supplier<T> operation) {
        return operation.get();
    }
}
