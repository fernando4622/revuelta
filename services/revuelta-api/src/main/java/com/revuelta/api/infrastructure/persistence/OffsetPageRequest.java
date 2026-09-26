package com.revuelta.api.infrastructure.persistence;

import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

final class OffsetPageRequest implements Pageable {
    private final long offset;
    private final int pageSize;
    private final Sort sort;

    OffsetPageRequest(long offset, int pageSize) {
        this(offset, pageSize, Sort.unsorted());
    }

    OffsetPageRequest(long offset, int pageSize, Sort sort) {
        if (offset < 0) throw new IllegalArgumentException("offset must not be negative");
        if (pageSize < 1) throw new IllegalArgumentException("pageSize must be positive");
        this.offset = offset;
        this.pageSize = pageSize;
        this.sort = sort;
    }

    @Override public int getPageNumber() { return (int) (offset / pageSize); }
    @Override public int getPageSize() { return pageSize; }
    @Override public long getOffset() { return offset; }
    @Override public Sort getSort() { return sort; }
    @Override public Pageable next() { return new OffsetPageRequest(offset + pageSize, pageSize, sort); }
    @Override public Pageable previousOrFirst() { return hasPrevious() ? new OffsetPageRequest(offset - pageSize, pageSize, sort) : first(); }
    @Override public Pageable first() { return new OffsetPageRequest(0, pageSize, sort); }
    @Override public Pageable withPage(int pageNumber) { return new OffsetPageRequest((long) pageNumber * pageSize, pageSize, sort); }
    @Override public boolean hasPrevious() { return offset >= pageSize; }
}
