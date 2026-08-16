package br.com.fiapx.processing.domain;

import java.util.Objects;

public record UserId(String value) { public UserId { Objects.requireNonNull(value); } }
