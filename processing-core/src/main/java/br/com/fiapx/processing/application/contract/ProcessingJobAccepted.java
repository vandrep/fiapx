package br.com.fiapx.processing.application.contract;

/** Durable work fact consumed by independently scalable workers. */
public record ProcessingJobAccepted(String processingJobId, String videoObjectKey) { }
