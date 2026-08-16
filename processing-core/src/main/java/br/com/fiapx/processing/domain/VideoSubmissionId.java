package br.com.fiapx.processing.domain;

import java.util.Objects;

public record VideoSubmissionId(String value) { public VideoSubmissionId { Objects.requireNonNull(value); } }
