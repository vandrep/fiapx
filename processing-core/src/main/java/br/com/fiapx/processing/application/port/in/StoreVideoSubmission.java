package br.com.fiapx.processing.application.port.in;

import br.com.fiapx.processing.application.contract.ProcessingJobView;

public interface StoreVideoSubmission {
    ProcessingJobView store(br.com.fiapx.processing.application.contract.StoreVideoSubmission command);
}
