-- Initial Schema for ReVuelta V1

-- Users and Security
CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE roles (
    id UUID PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    PRIMARY KEY (user_id, role_id)
);

-- Container Catalog
CREATE TABLE containers (
    id UUID PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(30) NOT NULL CHECK (status IN ('REGISTERED', 'AVAILABLE', 'IN_USE', 'DAMAGED', 'LOST', 'RETIRED')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Circulation Management
CREATE TABLE circulations (
    id UUID PRIMARY KEY,
    container_id UUID NOT NULL REFERENCES containers(id) ON DELETE RESTRICT,
    borrower_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    delivered_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    delivered_at TIMESTAMP WITH TIME ZONE NOT NULL,
    due_at TIMESTAMP WITH TIME ZONE NOT NULL,
    returned_by UUID REFERENCES users(id) ON DELETE RESTRICT,
    returned_at TIMESTAMP WITH TIME ZONE,
    punctuality VARCHAR(20) CHECK (punctuality IS NULL OR punctuality IN ('ON_TIME', 'LATE')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE', 'COMPLETED')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- DL-013: Partial unique index to guarantee at most ONE active circulation per container
CREATE UNIQUE INDEX idx_circulations_active_container ON circulations(container_id) WHERE status = 'ACTIVE';

-- Container Audit Event History
CREATE TABLE container_events (
    id UUID PRIMARY KEY,
    container_id UUID NOT NULL REFERENCES containers(id) ON DELETE RESTRICT,
    event_type VARCHAR(50) NOT NULL,
    actor_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
    previous_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    reason TEXT
);

-- Return Policies
CREATE TABLE return_policies (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    duration_hours INT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);
