package br.com.fiapx.processing.domain;

import java.util.Objects;

public record ProcessingJobId(String value) { public ProcessingJobId { Objects.requireNonNull(value); } }
