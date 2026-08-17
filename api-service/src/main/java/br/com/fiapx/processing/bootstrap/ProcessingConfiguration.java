package br.com.fiapx.processing.bootstrap;

import br.com.fiapx.processing.application.port.out.ProcessingJobRepository;
import br.com.fiapx.processing.application.port.out.ProcessingJobWorkPublisher;
import br.com.fiapx.processing.application.port.out.VideoSubmissionStorage;
import br.com.fiapx.processing.application.usecase.VideoSubmissionService;
import jakarta.enterprise.inject.Produces;
import jakarta.inject.Singleton;

public class ProcessingConfiguration {
    @Produces @Singleton VideoSubmissionService processingService(ProcessingJobRepository jobs, ProcessingJobWorkPublisher work, VideoSubmissionStorage videos) {
        return new VideoSubmissionService(jobs, () -> java.util.UUID.randomUUID().toString(), work, videos);
    }
}
