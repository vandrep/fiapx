package br.com.fiapx.processing.application.contract;

import br.com.fiapx.processing.domain.ProcessingStatus;

public record ProcessingJobView(String id, ProcessingStatus status, String archiveObjectKey) { }
