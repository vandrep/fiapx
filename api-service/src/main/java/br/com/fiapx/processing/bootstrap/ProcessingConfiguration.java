package br.com.fiapx.processing.bootstrap;

import br.com.fiapx.processing.application.usecase.InMemoryVideoSubmissionService;
import jakarta.enterprise.inject.Produces;
import jakarta.inject.Singleton;

public class ProcessingConfiguration { @Produces @Singleton InMemoryVideoSubmissionService processingService() { return new InMemoryVideoSubmissionService(); } }
