package br.com.fiapx.processing.application.port.in;

import br.com.fiapx.processing.application.contract.ProcessingJobView;
import java.util.List;

public interface ListProcessingJobs { List<ProcessingJobView> listFor(String userId); }
