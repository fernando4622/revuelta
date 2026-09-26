package com.revuelta.api.application.query;

import java.util.List;

public record PageResult<T>(List<T> items, int page, int size, boolean hasNext) {
    public PageResult {
        items = List.copyOf(items);
        if (page < 0) throw new IllegalArgumentException("page must be greater than or equal to zero");
        if (size < 1 || size > 100) throw new IllegalArgumentException("size must be between 1 and 100");
    }

    public static <T> PageResult<T> fromExtraRow(List<T> rows, int page, int size) {
        boolean hasNext = rows.size() > size;
        List<T> items = hasNext ? rows.subList(0, size) : rows;
        return new PageResult<>(items, page, size, hasNext);
    }

    public static void validate(int page, int size) {
        if (page < 0) throw new IllegalArgumentException("page must be greater than or equal to zero");
        if (size < 1 || size > 100) throw new IllegalArgumentException("size must be between 1 and 100");
    }
}
