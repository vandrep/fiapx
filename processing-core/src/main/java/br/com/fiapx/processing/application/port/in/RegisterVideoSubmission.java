package br.com.fiapx.processing.application.port.in;

import br.com.fiapx.processing.application.contract.SubmitVideoSubmission;
import br.com.fiapx.processing.application.contract.ProcessingJobView;

public interface RegisterVideoSubmission { ProcessingJobView register(SubmitVideoSubmission command); }
