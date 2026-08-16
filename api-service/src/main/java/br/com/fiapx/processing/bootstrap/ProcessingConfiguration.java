package br.com.fiapx.processing.bootstrap;

import br.com.fiapx.processing.application.port.out.ProcessingJobRepository;
import br.com.fiapx.processing.application.usecase.VideoSubmissionService;
import jakarta.enterprise.inject.Produces;
import jakarta.inject.Singleton;

public class ProcessingConfiguration { @Produces @Singleton VideoSubmissionService processingService(ProcessingJobRepository jobs) { return new VideoSubmissionService(jobs, () -> java.util.UUID.randomUUID().toString()); } }
