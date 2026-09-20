package com.revuelta.api.application.port;

import java.util.function.Supplier;

public interface TransactionRunnerPort {

    <T> T required(Supplier<T> operation);
}
