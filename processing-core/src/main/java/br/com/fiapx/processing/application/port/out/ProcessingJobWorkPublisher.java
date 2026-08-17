package br.com.fiapx.processing.application.port.out;

import br.com.fiapx.processing.application.contract.ProcessingJobAccepted;

/** Publishes work only after the accepted Processing Job has been persisted. */
public interface ProcessingJobWorkPublisher {
    void publishAccepted(ProcessingJobAccepted accepted);
}
