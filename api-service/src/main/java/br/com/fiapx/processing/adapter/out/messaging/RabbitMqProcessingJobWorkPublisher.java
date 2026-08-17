package br.com.fiapx.processing.adapter.out.messaging;

import br.com.fiapx.processing.application.contract.ProcessingJobAccepted;
import br.com.fiapx.processing.application.port.out.ProcessingJobWorkPublisher;
import io.smallrye.reactive.messaging.annotations.Channel;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.reactive.messaging.Emitter;

@ApplicationScoped
public class RabbitMqProcessingJobWorkPublisher implements ProcessingJobWorkPublisher {
    private final Emitter<ProcessingJobAccepted> jobs;

    public RabbitMqProcessingJobWorkPublisher(@Channel("processing-jobs") Emitter<ProcessingJobAccepted> jobs) { this.jobs = jobs; }

    @Override public void publishAccepted(ProcessingJobAccepted accepted) { jobs.send(accepted); }
}
